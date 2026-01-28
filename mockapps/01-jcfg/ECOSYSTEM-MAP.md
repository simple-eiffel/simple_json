# jcfg - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_json | Core JSON operations | Parsing, schema validation, JSONPath queries |
| simple_file | File system operations | Read configs, schemas, policies; write results |
| simple_cli | Command-line interface | Argument parsing, subcommands, help generation |
| simple_logger | Audit logging | Validation audit trails, debug logging |
| simple_hash | Content fingerprinting | Change detection, caching, deduplication |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_http | Remote schema fetching | When $ref points to URLs |
| simple_encryption | Secrets masking | When auditing sensitive configs |
| simple_env | Environment expansion | When configs use ${VAR} syntax |
| simple_yaml | YAML config support | Future: validate YAML as JSON |

## Integration Patterns

### simple_json Integration

**Purpose:** Core parsing, schema validation, and JSONPath queries for policy rules.

**Usage:**
```eiffel
-- Parse configuration file
local
    json: SIMPLE_JSON
    config: detachable SIMPLE_JSON_VALUE
do
    create json
    config := json.parse_file (config_path)

    if json.has_errors then
        -- Handle parse errors with line/column info
        across json.last_errors as err loop
            reporter.add_parse_error (config_path, err)
        end
    end
end
```

```eiffel
-- Schema validation
local
    schema: SIMPLE_JSON_SCHEMA
    validator: SIMPLE_JSON_SCHEMA_VALIDATOR
    result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
do
    create schema.make_from_string (schema_json)
    create validator.make (schema)

    result := validator.validate (config)

    if not result.is_valid then
        across result.errors as err loop
            reporter.add_schema_error (config_path, err)
        end
    end
end
```

```eiffel
-- JSONPath queries for policy evaluation
local
    value: detachable STRING_32
do
    -- Query value at policy path
    value := json.query_string (config, policy.path)

    if attached value as v then
        policy_engine.evaluate (policy.rule, v)
    end
end
```

**Data flow:** Config file -> SIMPLE_JSON.parse_file -> SIMPLE_JSON_VALUE -> Schema validation -> Policy evaluation

### simple_file Integration

**Purpose:** File system operations for configs, schemas, and output.

**Usage:**
```eiffel
-- Discover config files
local
    finder: SIMPLE_FILE_FINDER
    files: LIST [PATH]
do
    create finder.make
    files := finder.glob (input_pattern, recursive: True)

    across files as f loop
        validate_file (f)
    end
end
```

```eiffel
-- Write validation results
local
    writer: SIMPLE_FILE_WRITER
do
    create writer.make (output_path)
    writer.put_string (reporter.to_json)
    writer.close
end
```

**Data flow:** Input pattern -> SIMPLE_FILE_FINDER -> File paths -> Processing

### simple_cli Integration

**Purpose:** Command-line argument parsing and subcommand routing.

**Usage:**
```eiffel
-- Define CLI structure
local
    cli: SIMPLE_CLI
do
    create cli.make ("jcfg", "JSON configuration validator")

    -- Global options
    cli.add_option ("config", "c", "Configuration file", has_value: True)
    cli.add_option ("output", "o", "Output format", has_value: True)
    cli.add_option ("quiet", "q", "Suppress non-error output", has_value: False)

    -- Subcommands
    cli.add_command ("validate", "Validate JSON files")
    cli.command ("validate").add_option ("schema", "s", "Schema file", required: True)
    cli.command ("validate").add_option ("strict", Void, "Treat warnings as errors")
    cli.command ("validate").add_positional ("files", "Files to validate", multiple: True)

    cli.parse (arguments)

    if cli.has_command ("validate") then
        execute_validate (cli)
    end
end
```

**Data flow:** Command line args -> SIMPLE_CLI.parse -> Command routing -> Execution

### simple_logger Integration

**Purpose:** Audit logging and debug output.

**Usage:**
```eiffel
-- Audit logging
local
    auditor: SIMPLE_LOGGER
do
    create auditor.make_file (audit_log_path)
    auditor.set_format ("${timestamp} | ${level} | ${message}")

    -- Log each validation
    auditor.info ("Validating: " + file_path)
    auditor.info ("Schema: " + schema_path)
    auditor.info ("Result: " + result.status)

    if not result.is_valid then
        across result.errors as err loop
            auditor.error ("  " + err.to_string)
        end
    end
end
```

**Data flow:** Validation events -> SIMPLE_LOGGER -> Audit log file

### simple_hash Integration

**Purpose:** Content fingerprinting for caching and change detection.

**Usage:**
```eiffel
-- Cache schema by content hash
local
    hasher: SIMPLE_HASH
    hash: STRING
    cached: detachable SIMPLE_JSON_SCHEMA
do
    create hasher.make_sha256
    hash := hasher.hash_string (schema_content)

    cached := schema_cache.item (hash)
    if attached cached then
        Result := cached
    else
        Result := parse_and_cache_schema (schema_content, hash)
    end
end
```

**Data flow:** Schema content -> SIMPLE_HASH.hash_string -> Cache key -> Cached schema

## Dependency Graph

```
jcfg
    |
    +-- simple_json (required)
    |       |
    |       +-- simple_decimal
    |       +-- simple_zstring
    |       +-- simple_encoding
    |
    +-- simple_file (required)
    |
    +-- simple_cli (required)
    |
    +-- simple_logger (required)
    |
    +-- simple_hash (required)
    |
    +-- simple_http (optional)
    |       |
    |       +-- simple_socket
    |
    +-- simple_encryption (optional)
    |
    +-- simple_env (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<system name="jcfg" uuid="550e8400-e29b-41d4-a716-446655440001" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <description>JSON Configuration Validator</description>

    <target name="jcfg">
        <root class="JCFG_CLI" feature="make"/>

        <option warning="warning" syntax="standard">
            <assertions precondition="require" postcondition="ensure" check="check" invariant="invariant"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="feature"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>
        <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>

        <!-- Optional dependencies (conditional) -->
        <library name="simple_http" location="$SIMPLE_EIFFEL/simple_http/simple_http.ecf">
            <condition>
                <custom name="http_support" value="true"/>
            </condition>
        </library>

        <!-- ISE base library -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <target name="jcfg_tests" extends="jcfg">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>
</system>
```

## Integration Test Points

| Integration | Test Focus | Example |
|-------------|------------|---------|
| simple_json parsing | UTF-8, large files, error positions | Parse 10MB file, verify line numbers |
| simple_json schema | All Draft 7 keywords | Validate against official test suite |
| simple_file | Glob patterns, permissions | Find *.json in nested dirs |
| simple_cli | All options, subcommands | --help, validate --schema x.json |
| simple_logger | Log rotation, format | 1000 validations, check log |
| simple_hash | Collision resistance | Hash 10K schemas, check uniqueness |
