# jtrans - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 6 days | simple_json, simple_cli, simple_file |
| Phase 2 | Advanced Transformations | 5 days | Phase 1, simple_decimal, simple_template |
| Phase 3 | Production Polish | 4 days | Phase 2, simple_csv |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that transforms JSON files using a simple mapping specification. This MVP proves the core transformation concept and enables feedback on the mapping format.

### Deliverables

1. **JTRANS_CLI** - Main entry point with argument parsing
2. **JTRANS_ENGINE** - Core transformation engine
3. **JTRANS_MAPPING** - Mapping specification parser
4. **JTRANS_RESOLVER** - JSONPath field resolution
5. **Basic CLI** - `transform` command with essential options

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Design mapping file format | JSON schema documented, examples created |
| T1.2 | Create JTRANS_CLI with simple_cli | `jtrans --help` shows usage |
| T1.3 | Implement JTRANS_MAPPING parser | Parses mapping JSON to object model |
| T1.4 | Implement JTRANS_RESOLVER | Resolves JSONPath expressions |
| T1.5 | Implement JTRANS_ENGINE | Transforms single record |
| T1.6 | Wire transform command | `jtrans transform --mapping m.json input.json` works |
| T1.7 | Handle array inputs | Transform arrays of records |
| T1.8 | Implement JSON output | Write transformed JSON to file or stdout |
| T1.9 | Add basic type conversions | string, integer, boolean |
| T1.10 | Implement default values | Handle missing fields |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Simple mapping | Map $.name to name | {"name": "value"} |
| Nested source | Map $.user.name to user_name | {"user_name": "Alice"} |
| Array input | Array of 3 objects | Array of 3 transformed objects |
| Missing field | Source path not found | Uses default value |
| Type conversion | String "123" to integer | {"count": 123} |
| Multiple fields | Map 5 fields | All 5 fields in output |
| Null handling | Null source value | Uses default or null |

### Phase 1 Class Skeleton

```eiffel
class JTRANS_CLI
create
    make
feature
    make
        -- Parse arguments and execute command
    execute_transform
        -- Run transformation
end

class JTRANS_ENGINE
create
    make
feature
    make (a_mapping: JTRANS_MAPPING)
        -- Initialize with mapping
    transform (a_record: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
        -- Transform single record
    transform_all (a_records: LIST [SIMPLE_JSON_OBJECT]): LIST [SIMPLE_JSON_OBJECT]
        -- Transform all records
end

class JTRANS_MAPPING
create
    make_from_file, make_from_string
feature
    input_root: STRING
    output_root: STRING
    fields: LIST [JTRANS_FIELD_MAPPING]
    load (a_path: STRING)
        -- Load mapping from file
end

class JTRANS_FIELD_MAPPING
create
    make
feature
    source_path: STRING
    target_name: STRING
    target_type: STRING
    default_value: detachable ANY
end

class JTRANS_RESOLVER
create
    make
feature
    resolve_string (a_record: SIMPLE_JSON_VALUE; a_path: STRING): detachable STRING
    resolve_integer (a_record: SIMPLE_JSON_VALUE; a_path: STRING): INTEGER_64
    resolve_value (a_record: SIMPLE_JSON_VALUE; a_path: STRING): detachable SIMPLE_JSON_VALUE
end
```

---

## Phase 2: Advanced Transformations

### Objective

Add powerful transformation features: decimal precision, string templating, conditional logic, and value mapping. This phase enables complex real-world transformations.

### Deliverables

1. **JTRANS_CONVERTER** - Type conversion with transforms
2. **JTRANS_CONDITION** - Conditional record filtering
3. **Enhanced mapping format** - Transforms, conditions, concat
4. **Decimal support** - Precise financial transformations
5. **Template support** - String concatenation and interpolation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement decimal type | Transform with multiply, divide, round |
| T2.2 | Implement value mapping | {"active": true, "inactive": false} |
| T2.3 | Implement string concat | Concatenate multiple fields |
| T2.4 | Implement template interpolation | ${field} syntax in strings |
| T2.5 | Implement conditions | Filter records by field values |
| T2.6 | Implement date conversion | Parse and format dates |
| T2.7 | Implement array operations | count, join, first, last |
| T2.8 | Add validate command | Validate mapping file syntax |
| T2.9 | Add sample command | Generate sample output |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Decimal multiply | 1999 * 0.01 | 19.99 (exact) |
| Decimal round | 19.999 round 2 | 19.99 |
| Value map | "active" -> true | {"is_active": true} |
| String concat | street + city + country | "123 Main, NYC, USA" |
| Template | "${name} (${id})" | "Alice (42)" |
| Condition filter | status = "active" | Only active records |
| Array count | Count items | {"item_count": 5} |
| Array join | Join with ", " | "a, b, c" |

### Phase 2 Additions

```eiffel
class JTRANS_CONVERTER
create
    make
feature
    convert (a_value: ANY; a_target_type: STRING): ANY
    convert_decimal (a_value: ANY): SIMPLE_DECIMAL
    apply_transform (a_value: ANY; a_transform: JTRANS_TRANSFORM): ANY
end

class JTRANS_TRANSFORM
create
    make_multiply, make_map, make_round
feature
    transform_type: STRING  -- multiply, map, round, etc.
    parameters: HASH_TABLE [ANY, STRING]
    apply (a_value: ANY): ANY
end

class JTRANS_CONDITION
create
    make
feature
    field_path: STRING
    operator: STRING  -- equals, not_equals, contains, etc.
    value: ANY
    evaluate (a_record: SIMPLE_JSON_VALUE): BOOLEAN
end
```

---

## Phase 3: Production Polish

### Objective

Add streaming for large files, CSV support, batch processing, and production hardening for pipeline integration.

### Deliverables

1. **Streaming mode** - Process large files with constant memory
2. **CSV input/output** - Read CSV, write CSV
3. **NDJSON support** - Line-delimited JSON for streaming
4. **Batch processing** - Process multiple files
5. **Performance optimization** - 10K records/sec target
6. **Error handling** - --on-error skip/fail/log

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement streaming mode | Process 1GB file with <100MB memory |
| T3.2 | Implement CSV reader | Read CSV as JSON records |
| T3.3 | Implement CSV writer | Write JSON as CSV |
| T3.4 | Implement NDJSON reader | Read line-delimited JSON |
| T3.5 | Implement NDJSON writer | Write line-delimited JSON |
| T3.6 | Add batch mode | Process directory of files |
| T3.7 | Implement --on-error | Skip errors, continue processing |
| T3.8 | Add --stats | Show transformation statistics |
| T3.9 | Add infer command | Infer mapping from sample data |
| T3.10 | Performance optimization | Benchmark and optimize |
| T3.11 | Documentation | README, man page, examples |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Streaming 1GB | Large NDJSON file | Transforms without memory exhaustion |
| CSV to JSON | CSV with headers | JSON objects with headers as keys |
| JSON to CSV | Array of objects | CSV with headers from keys |
| NDJSON round-trip | NDJSON -> transform -> NDJSON | Valid NDJSON output |
| Batch processing | Directory of 100 files | All files transformed |
| Error skip | 1 bad record in 100 | 99 records transformed |
| Statistics | Any transformation | Shows records processed, time, rate |

---

## ECF Target Structure

```xml
<!-- Library target (reusable transformation engine) -->
<target name="jtrans_lib">
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/>
    <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
    <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location="src/">
        <cluster name="core" location="core/"/>
        <cluster name="mapping" location="mapping/"/>
        <cluster name="io" location="io/"/>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="jtrans_cli" extends="jtrans_lib">
    <root class="JTRANS_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <cluster name="cli" location="src/cli/"/>
</target>

<!-- Test target -->
<target name="jtrans_tests" extends="jtrans_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location="tests/"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI
/d/prod/ec.sh -batch -config jtrans.ecf -target jtrans_cli -c_compile

# Run CLI
./EIFGENs/jtrans_cli/W_code/jtrans.exe --help

# Compile tests
/d/prod/ec.sh -batch -config jtrans.ecf -target jtrans_tests -c_compile

# Run tests
./EIFGENs/jtrans_tests/W_code/jtrans.exe

# Finalize for release
/d/prod/ec.sh -batch -config jtrans.ecf -target jtrans_cli -finalize -c_compile

# Performance benchmark
./EIFGENs/jtrans_cli/F_code/jtrans.exe transform --mapping benchmark.json --stats large_file.ndjson
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors in all targets | 100% |
| Tests pass | All test cases pass | 100% |
| CLI works | All commands functional | Verified manually |
| Performance | Transformation throughput | 10K records/sec |
| Memory efficiency | Streaming mode | <100MB for 1GB file |
| Documentation | README complete | Reviewed |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| JSONPath complexity | Start with simple subset, expand based on needs |
| Streaming memory leaks | Profile early with large files |
| CSV edge cases | Use simple_csv which handles RFC 4180 |
| Mapping format confusion | Extensive examples and validation |
| Performance bottlenecks | Benchmark each phase, optimize hot paths |
