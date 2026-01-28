# jtrans - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                          jtrans CLI                               |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing                                              |
|    - Progress reporting                                           |
+------------------------------------------------------------------+
|  Transformation Engine Layer                                      |
|    - Mapping parser                                               |
|    - Field resolver (JSONPath queries)                            |
|    - Type converter                                               |
|    - Conditional evaluator                                        |
+------------------------------------------------------------------+
|  Data Flow Layer                                                  |
|    - Input readers (JSON, NDJSON, CSV)                           |
|    - Streaming processor (SIMPLE_JSON_STREAM)                    |
|    - Output writers (JSON, NDJSON, CSV)                          |
|    - Batch coordinator                                            |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_json (parsing, queries, building)                     |
|    - simple_csv (CSV I/O)                                        |
|    - simple_file (file operations)                               |
|    - simple_decimal (precision math)                             |
|    - simple_template (output templates)                          |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| JTRANS_CLI | Command-line interface | parse_arguments, route_command, show_progress |
| JTRANS_ENGINE | Transformation coordinator | load_mapping, transform, batch_transform |
| JTRANS_MAPPING | Mapping specification | fields, conditions, defaults |
| JTRANS_FIELD_MAPPER | Single field transformation | source_path, target_path, converter |
| JTRANS_RESOLVER | JSONPath field resolution | resolve_path, resolve_array |
| JTRANS_CONVERTER | Type conversion | to_string, to_integer, to_decimal, to_date |
| JTRANS_CONDITION | Conditional logic | evaluate, and_conditions, or_conditions |
| JTRANS_READER | Input abstraction | read_json, read_ndjson, read_csv |
| JTRANS_WRITER | Output abstraction | write_json, write_ndjson, write_csv |
| JTRANS_STREAMER | Streaming processor | stream_transform, on_record |

### Command Structure

```bash
jtrans <command> [options] [arguments]

Commands:
  transform   Transform JSON using mapping file
  validate    Validate mapping file syntax
  sample      Generate sample output from mapping
  infer       Infer mapping from sample data

Global Options:
  --mapping FILE      Mapping specification file (required)
  --input-format FMT  Input format: json|ndjson|csv (auto-detect)
  --output-format FMT Output format: json|ndjson|csv (default: json)
  --quiet             Suppress progress output
  --verbose           Enable verbose output
  --version           Show version
  --help              Show help

transform Command:
  jtrans transform [options] <input> [output]

  Options:
    --mapping FILE     Mapping file (required)
    --stream           Enable streaming mode for large files
    --batch SIZE       Batch size for streaming (default: 1000)
    --parallel N       Parallel workers (default: 1)
    --on-error MODE    Error handling: skip|fail|log (default: fail)
    --stats            Show transformation statistics

  Examples:
    jtrans transform --mapping map.json input.json output.json
    jtrans transform --mapping map.json --stream large.ndjson result.ndjson
    jtrans transform --mapping map.json data/*.json --output-format csv > combined.csv

validate Command:
  jtrans validate [options] <mapping-file>

  Options:
    --sample FILE      Validate against sample input

sample Command:
  jtrans sample [options] <mapping-file>

  Options:
    --count N          Number of sample records (default: 5)

infer Command:
  jtrans infer [options] <input-file> [target-file]

  Options:
    --output FILE      Write inferred mapping to file
```

### Mapping File Format

```json
{
  "$schema": "https://jtrans.io/mapping-schema.json",
  "version": "1.0",
  "name": "API Response to Report",
  "description": "Transform API response to flat report format",

  "input": {
    "root": "$.data.records",
    "format": "json"
  },

  "output": {
    "format": "json",
    "root": "records"
  },

  "fields": [
    {
      "source": "$.id",
      "target": "record_id",
      "type": "string"
    },
    {
      "source": "$.user.name",
      "target": "user_name",
      "type": "string",
      "default": "Unknown"
    },
    {
      "source": "$.amount",
      "target": "amount_usd",
      "type": "decimal",
      "transform": {
        "multiply": 0.01
      }
    },
    {
      "source": "$.created_at",
      "target": "created_date",
      "type": "date",
      "format": {
        "input": "ISO8601",
        "output": "YYYY-MM-DD"
      }
    },
    {
      "source": "$.status",
      "target": "is_active",
      "type": "boolean",
      "transform": {
        "map": {
          "active": true,
          "inactive": false,
          "pending": false
        }
      }
    },
    {
      "target": "full_address",
      "type": "string",
      "concat": [
        "$.address.street",
        ", ",
        "$.address.city",
        ", ",
        "$.address.country"
      ]
    }
  ],

  "conditions": [
    {
      "name": "include_only_active",
      "field": "$.status",
      "operator": "equals",
      "value": "active"
    }
  ],

  "defaults": {
    "null_handling": "use_default",
    "missing_handling": "use_default"
  }
}
```

### Data Flow

```
Input Sources                    Mapping                    Output Targets
     |                              |                            |
     v                              v                            v
+----------+                 +-----------+                 +-----------+
| JSON     |     Load        |  MAPPING  |     Apply       | JSON      |
| NDJSON   |---------------->|  SPEC     |---------------->| NDJSON    |
| CSV      |                 +-----------+                 | CSV       |
+----------+                       |                       +-----------+
     |                             |                            ^
     v                             v                            |
+----------+                 +-----------+                      |
| READER   |                 | RESOLVER  |                      |
| (parse)  |                 | (JSONPath)|                      |
+----------+                 +-----------+                      |
     |                             |                            |
     v                             v                            |
+----------+                 +-----------+                      |
| Records  |---------------->| CONVERTER |----------------------+
| Stream   |   for each      | (type)    |    write
+----------+                 +-----------+
```

### Type Conversion System

| Source Type | Target Types | Notes |
|-------------|--------------|-------|
| string | string, integer, decimal, boolean, date | Parse as needed |
| number | integer, decimal, string, boolean | Truncate/format |
| boolean | boolean, string, integer | true/false, "true"/"false", 1/0 |
| null | any | Uses default value |
| array | array, string (join), count (integer) | Join with delimiter |
| object | object, string (serialize) | JSON stringify |

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Input file not found | Exit with code 2 | "Error: Cannot read file '{path}'" |
| Invalid JSON | Skip or fail (configurable) | "Parse error at record {n}: {message}" |
| Invalid mapping | Exit with code 2 | "Mapping error: {details}" |
| Field not found | Use default or fail | "Field not found: {path}" |
| Type conversion failure | Use default or fail | "Cannot convert '{value}' to {type}" |
| Output write failure | Exit with code 2 | "Cannot write to '{path}': {reason}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Transformation completed successfully |
| 1 | Transformation completed with errors (--on-error skip) |
| 2 | Tool error (file not found, invalid mapping, etc.) |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **Visual Mapping Editor**
   - Drag-and-drop field mapping
   - Live preview using CLI transform
   - Mapping file generation

2. **TUI Dashboard**
   - Real-time transformation progress
   - Error browser
   - Statistics viewer

3. **Web Interface**
   - Mapping builder
   - Sample data testing
   - Transformation job scheduler

**Shared components between CLI/GUI:**
- JTRANS_ENGINE (transformation logic)
- JTRANS_MAPPING (mapping specification)
- JTRANS_CONVERTER (type conversions)
- All reader/writer implementations
