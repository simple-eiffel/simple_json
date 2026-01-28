# jtrans - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_json | Core JSON operations | Parsing, JSONPath queries, building output |
| simple_csv | CSV input/output | Read CSV as JSON, write JSON as CSV |
| simple_file | File system operations | Read/write files, glob patterns, directories |
| simple_cli | Command-line interface | Argument parsing, subcommands, progress |
| simple_decimal | Precision arithmetic | Financial transformations without float errors |
| simple_template | Output templating | Custom output formats, string interpolation |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_datetime | Date/time parsing | When transforming date fields |
| simple_http | Remote data fetching | When input is a URL |
| simple_compression | Compressed I/O | When reading/writing .gz files |
| simple_validation | Data validation | When adding validation rules to mappings |

## Integration Patterns

### simple_json Integration

**Purpose:** Core parsing, JSONPath queries, and JSON building.

**Usage:**
```eiffel
-- Parse input JSON
local
    json: SIMPLE_JSON
    input: detachable SIMPLE_JSON_VALUE
do
    create json
    input := json.parse_file (input_path)

    if attached input as doc then
        -- Navigate to data root
        if attached json.query_value (doc, mapping.input_root) as root_array then
            transform_records (root_array.as_array)
        end
    end
end
```

```eiffel
-- Resolve field using JSONPath
local
    value: detachable STRING_32
do
    value := json.query_string (record, field_mapping.source_path)

    if attached value then
        converter.convert (value, field_mapping.target_type)
    else
        -- Use default value
        Result := field_mapping.default_value
    end
end
```

```eiffel
-- Build output JSON
local
    output: SIMPLE_JSON_OBJECT
do
    create output.make

    across field_mappings as fm loop
        if attached resolve_field (record, fm) as value then
            output := output.put_value (value, fm.target_name)
        end
    end

    Result := output
end
```

**Data flow:** Input file -> SIMPLE_JSON.parse -> JSONPath queries -> Build output -> SIMPLE_JSON_OBJECT.to_json

### simple_csv Integration

**Purpose:** CSV input/output for data exchange workflows.

**Usage:**
```eiffel
-- Read CSV as JSON records
local
    reader: SIMPLE_CSV_READER
    records: LIST [SIMPLE_JSON_OBJECT]
do
    create reader.make_with_headers (csv_path)
    create {ARRAYED_LIST [SIMPLE_JSON_OBJECT]} records.make (100)

    across reader as row loop
        records.force (row_to_json (row))
    end

    transform_records (records)
end
```

```eiffel
-- Write JSON as CSV
local
    writer: SIMPLE_CSV_WRITER
    headers: LIST [STRING]
do
    headers := extract_headers_from_mapping (mapping)
    create writer.make (output_path, headers)

    across transformed_records as rec loop
        writer.write_row (json_to_row (rec, headers))
    end

    writer.close
end
```

**Data flow:** CSV file -> SIMPLE_CSV_READER -> JSON objects -> Transform -> SIMPLE_CSV_WRITER -> CSV output

### simple_file Integration

**Purpose:** File discovery, batch processing, and output writing.

**Usage:**
```eiffel
-- Discover input files with glob
local
    finder: SIMPLE_FILE_FINDER
    files: LIST [PATH]
do
    create finder.make
    files := finder.glob (input_pattern, recursive: True)

    across files as f loop
        process_file (f)
    end
end
```

```eiffel
-- Streaming input for large files
local
    stream: SIMPLE_JSON_STREAM
do
    create stream.make_from_file (large_file_path)

    across stream as element loop
        -- Process one record at a time
        if element.value.is_object then
            transform_and_write (element.value.as_object)
        end
    end
end
```

**Data flow:** Glob pattern -> SIMPLE_FILE_FINDER -> File paths -> Process each

### simple_decimal Integration

**Purpose:** Precise arithmetic for financial transformations.

**Usage:**
```eiffel
-- Convert cents to dollars with precision
local
    cents: INTEGER_64
    dollars: SIMPLE_DECIMAL
    multiplier: SIMPLE_DECIMAL
do
    cents := json.query_integer (record, "$.amount_cents")

    create multiplier.make ("0.01")
    create dollars.make_from_integer (cents)
    dollars := dollars.multiply (multiplier)

    output.put_decimal (dollars, "amount_usd")
end
```

```eiffel
-- Currency conversion with precision
local
    amount: SIMPLE_DECIMAL
    rate: SIMPLE_DECIMAL
    converted: SIMPLE_DECIMAL
do
    create amount.make (json.query_string (record, "$.amount"))
    create rate.make (transform.rate)

    converted := amount.multiply (rate)
    converted := converted.round (2)  -- Round to cents

    output.put_decimal (converted, transform.target_field)
end
```

**Data flow:** Integer -> SIMPLE_DECIMAL -> Arithmetic -> SIMPLE_JSON_OBJECT.put_decimal

### simple_template Integration

**Purpose:** Custom output formatting and string interpolation.

**Usage:**
```eiffel
-- String concatenation with template
local
    template: SIMPLE_TEMPLATE
    context: HASH_TABLE [ANY, STRING]
do
    create template.make ("${street}, ${city}, ${country}")
    create context.make (3)

    context.put (json.query_string (record, "$.address.street"), "street")
    context.put (json.query_string (record, "$.address.city"), "city")
    context.put (json.query_string (record, "$.address.country"), "country")

    Result := template.render (context)
end
```

**Data flow:** Template string + Field values -> SIMPLE_TEMPLATE.render -> Output string

### simple_cli Integration

**Purpose:** Command-line argument parsing and progress display.

**Usage:**
```eiffel
-- Define CLI with progress
local
    cli: SIMPLE_CLI
    progress: SIMPLE_CLI_PROGRESS
do
    create cli.make ("jtrans", "JSON transformation engine")

    cli.add_command ("transform", "Transform JSON using mapping")
    cli.command ("transform").add_option ("mapping", "m", "Mapping file", required: True)
    cli.command ("transform").add_option ("stream", Void, "Enable streaming mode")
    cli.command ("transform").add_positional ("input", "Input file")
    cli.command ("transform").add_positional ("output", "Output file", optional: True)

    cli.parse (arguments)

    if cli.has_command ("transform") then
        -- Show progress for large files
        if cli.has_flag ("stream") then
            create progress.make ("Transforming")
            progress.set_total (file_line_count)
            transform_with_progress (progress)
        else
            transform_simple
        end
    end
end
```

**Data flow:** Arguments -> SIMPLE_CLI.parse -> Command execution with progress

## Dependency Graph

```
jtrans
    |
    +-- simple_json (required)
    |       |
    |       +-- simple_decimal
    |       +-- simple_zstring
    |       +-- simple_encoding
    |
    +-- simple_csv (required)
    |
    +-- simple_file (required)
    |
    +-- simple_cli (required)
    |
    +-- simple_decimal (required)
    |
    +-- simple_template (required)
    |
    +-- simple_datetime (optional)
    |
    +-- simple_http (optional)
    |       |
    |       +-- simple_socket
    |
    +-- simple_compression (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<system name="jtrans" uuid="550e8400-e29b-41d4-a716-446655440002" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <description>JSON Transform Engine</description>

    <target name="jtrans">
        <root class="JTRANS_CLI" feature="make"/>

        <option warning="warning" syntax="standard">
            <assertions precondition="require" postcondition="ensure" check="check" invariant="invariant"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="feature"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/>
        <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>

        <!-- Optional dependencies -->
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf">
            <condition>
                <custom name="datetime_support" value="true"/>
            </condition>
        </library>

        <!-- ISE base library -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <target name="jtrans_tests" extends="jtrans">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>
</system>
```

## Integration Test Points

| Integration | Test Focus | Example |
|-------------|------------|---------|
| simple_json parsing | Large files, streaming | Transform 1GB NDJSON file |
| simple_json queries | Complex JSONPath | Nested arrays, wildcards |
| simple_csv read | Headers, escaping | CSV with quotes, commas in values |
| simple_csv write | All types | Integers, decimals, strings with special chars |
| simple_decimal | Precision | Financial calculations without float errors |
| simple_template | Interpolation | Nested values, missing values |
| simple_file | Glob patterns | Recursive directory scan |
