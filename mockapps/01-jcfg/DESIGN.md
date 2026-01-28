# jcfg - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                           jcfg CLI                                |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing                                              |
|    - Output formatting (text, JSON, SARIF)                        |
+------------------------------------------------------------------+
|  Validation Engine Layer                                          |
|    - Schema validation (simple_json schema)                       |
|    - Policy rule evaluation                                       |
|    - Cross-reference checking                                     |
|    - Aggregate result collection                                  |
+------------------------------------------------------------------+
|  Input/Output Layer                                               |
|    - File discovery and loading                                   |
|    - Schema resolution                                            |
|    - Result serialization                                         |
|    - Audit logging                                                |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_json (parsing, schema, queries)                       |
|    - simple_file (file operations)                                |
|    - simple_hash (content fingerprinting)                         |
|    - simple_logger (audit trails)                                 |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| JCFG_CLI | Command-line interface | parse_arguments, route_command, format_output |
| JCFG_VALIDATOR | Core validation engine | validate_schema, evaluate_policies, check_references |
| JCFG_SCHEMA_REGISTRY | Schema management | load_schema, resolve_refs, cache_schemas |
| JCFG_POLICY_ENGINE | Policy rule evaluation | parse_rule, evaluate, aggregate_results |
| JCFG_RESULT | Validation result | errors, warnings, suggestions, is_valid |
| JCFG_REPORTER | Output generation | to_text, to_json, to_sarif, to_junit |
| JCFG_CONFIG | Configuration management | load_config, validate_config |
| JCFG_AUDITOR | Audit logging | log_validation, export_audit_trail |

### Command Structure

```bash
jcfg <command> [options] [arguments]

Commands:
  validate    Validate JSON files against schema(s)
  policy      Manage custom policy rules
  schema      Schema operations (validate, bundle)
  init        Initialize jcfg configuration
  audit       View/export audit history

Global Options:
  --config FILE       Configuration file (default: .jcfg.json)
  --output FORMAT     Output format: text|json|sarif|junit (default: text)
  --quiet             Suppress non-error output
  --verbose           Enable verbose output
  --no-color          Disable colored output
  --version           Show version
  --help              Show help

validate Command:
  jcfg validate [options] <files...>

  Options:
    --schema FILE       JSON Schema file (required unless in config)
    --policy FILE       Policy rules file
    --strict            Treat warnings as errors
    --fail-fast         Stop on first error
    --parallel N        Parallel validation threads (default: 4)

  Examples:
    jcfg validate --schema config.schema.json config.json
    jcfg validate --schema schemas/ configs/*.json
    jcfg validate --policy security.rules.json *.json

policy Command:
  jcfg policy <subcommand> [options]

  Subcommands:
    test      Test policy rules against sample data
    lint      Validate policy rule syntax
    list      List available built-in policies

schema Command:
  jcfg schema <subcommand> [options]

  Subcommands:
    validate  Validate schema is well-formed
    bundle    Bundle schema with $ref resolutions
    convert   Convert between schema drafts

init Command:
  jcfg init [options]

  Options:
    --preset NAME    Use preset: minimal|standard|strict
    --force          Overwrite existing configuration

audit Command:
  jcfg audit [options]

  Options:
    --since DATE     Show audits since date
    --export FILE    Export audit trail to file
    --format FORMAT  Export format: json|csv
```

### Data Flow

```
Input Files                 Schemas                  Policies
    |                          |                        |
    v                          v                        v
+-------+    +-----------------+    +------------------+
| Load  |--->| Parse & Validate|--->| Evaluate Policies|
+-------+    +-----------------+    +------------------+
    |                |                       |
    |                v                       v
    |        +----------------+      +----------------+
    |        | Schema Errors  |      | Policy Errors  |
    |        +----------------+      +----------------+
    |                |                       |
    v                v                       v
+--------------------------------------------------+
|              Aggregate Results                    |
|  - Deduplicate errors                            |
|  - Sort by severity                              |
|  - Add location context                          |
+--------------------------------------------------+
    |
    v
+--------------------------------------------------+
|              Format Output                        |
|  - Text (human-readable)                         |
|  - JSON (machine-readable)                       |
|  - SARIF (code analysis standard)                |
|  - JUnit (CI integration)                        |
+--------------------------------------------------+
    |
    v
  Exit Code (0=pass, 1=fail, 2=error)
```

### Configuration Schema

```json
{
  "$schema": "https://jcfg.io/config-schema.json",
  "version": "1.0",
  "jcfg": {
    "schemas": {
      "config": "schemas/config.schema.json",
      "deployment": "schemas/deployment.schema.json"
    },
    "policies": [
      "policies/security.rules.json",
      "policies/naming.rules.json"
    ],
    "validation": {
      "strict": false,
      "failFast": false,
      "parallel": 4
    },
    "output": {
      "format": "text",
      "color": true
    },
    "audit": {
      "enabled": true,
      "path": ".jcfg/audit.log"
    }
  }
}
```

### Policy Rule Format

```json
{
  "name": "port-range-check",
  "description": "Ensure port numbers are valid",
  "severity": "error",
  "path": "$.server.port",
  "rule": {
    "type": "range",
    "min": 1024,
    "max": 65535
  }
}
```

```json
{
  "name": "env-reference-check",
  "description": "Ensure environment references exist",
  "severity": "error",
  "path": "$.deployment.environment",
  "rule": {
    "type": "reference",
    "source": "$.environments[*].name"
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| File not found | Exit with code 2 | "Error: Cannot read file '{path}': {reason}" |
| Invalid JSON | Collect error, continue | "Parse error in {file} at line {line}: {message}" |
| Schema violation | Collect error | "{file}: {path} - {schema_error}" |
| Policy violation | Collect error | "{file}: {path} - {rule_name}: {message}" |
| Schema not found | Exit with code 2 | "Error: Schema not found: {schema_path}" |
| Invalid schema | Exit with code 2 | "Error: Invalid schema: {validation_error}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All validations passed |
| 1 | Validation failures (schema or policy) |
| 2 | Tool error (file not found, invalid schema, etc.) |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **VS Code Extension**
   - Real-time validation as you type
   - Inline error highlighting using CLI output
   - Schema intellisense based on schema registry
   - Policy violation quick-fixes

2. **TUI Dashboard**
   - Live validation status across project
   - Policy violation browser
   - Audit trail viewer
   - Configuration editor

3. **Web Interface**
   - Schema editor with live preview
   - Policy rule builder
   - Team policy management
   - Validation history dashboard

**Shared components between CLI/GUI:**
- JCFG_VALIDATOR (core validation engine)
- JCFG_POLICY_ENGINE (policy evaluation)
- JCFG_SCHEMA_REGISTRY (schema management)
- All result and error types
