# apict - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 5 days | simple_json, simple_http, simple_cli |
| Phase 2 | Test Suites | 4 days | Phase 1, simple_testing |
| Phase 3 | Production Polish | 4 days | Phase 2, simple_diff, simple_logger |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that tests a single API endpoint against a JSON Schema contract with human-readable output. This MVP proves the core value proposition and enables early feedback on the diff format.

### Deliverables

1. **APICT_CLI** - Main entry point with argument parsing
2. **APICT_TESTER** - Single endpoint test executor
3. **APICT_CONTRACT** - Schema contract loader
4. **APICT_CLIENT** - HTTP client wrapper
5. **APICT_RESULT** - Test result with violations
6. **Basic CLI** - `test` command with essential options

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create APICT_CLI with simple_cli | `apict --help` shows usage |
| T1.2 | Implement APICT_CONTRACT | Loads and validates schema files |
| T1.3 | Implement APICT_CLIENT | Makes HTTP GET requests |
| T1.4 | Implement APICT_TESTER | Validates response against contract |
| T1.5 | Create APICT_RESULT | Stores pass/fail, violations |
| T1.6 | Implement text reporter | Human-readable colored output |
| T1.7 | Wire test command | `apict test URL --contract schema.json` works |
| T1.8 | Add status code checking | Verify expected HTTP status |
| T1.9 | Add header support | `--headers` option |
| T1.10 | Add basic auth | `--auth basic:user:pass` |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid response | Matching response | Exit 0, "PASS" |
| Type violation | String where integer expected | Exit 1, violation details |
| Missing required | Response missing required field | Exit 1, "missing required: name" |
| Extra property | Response has undocumented field | Exit 0 (warn) or 1 (strict) |
| Invalid JSON | Non-JSON response | Exit 1, "Invalid JSON response" |
| Connection error | Unreachable endpoint | Exit 2, "Cannot connect" |
| Wrong status | Expected 200, got 404 | Exit 1, "Expected 200, got 404" |
| Auth required | 401 without auth | Exit 1, "401 Unauthorized" |

### Phase 1 Class Skeleton

```eiffel
class APICT_CLI
create
    make
feature
    make
        -- Parse arguments and execute command
    execute_test
        -- Run single endpoint test
    print_result (result: APICT_RESULT)
        -- Print test result
end

class APICT_TESTER
create
    make
feature
    make
        -- Initialize tester
    test (endpoint: STRING; contract: APICT_CONTRACT): APICT_RESULT
        -- Test endpoint against contract
end

class APICT_CONTRACT
create
    make_from_file, make_from_string
feature
    schema: SIMPLE_JSON_SCHEMA
    validate (response: SIMPLE_JSON_VALUE): SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
    is_required (path: STRING): BOOLEAN
end

class APICT_CLIENT
create
    make
feature
    get (url: STRING): SIMPLE_HTTP_RESPONSE
    set_header (name, value: STRING)
    set_basic_auth (user, password: STRING)
    set_bearer_token (token: STRING)
    set_timeout (ms: INTEGER)
end

class APICT_RESULT
create
    make_pass, make_fail
feature
    is_pass: BOOLEAN
    violations: LIST [APICT_VIOLATION]
    status_code: INTEGER
    response_time_ms: INTEGER
end
```

---

## Phase 2: Test Suites

### Objective

Add test suite support for running multiple tests from a suite file. Enable sequential and parallel execution with aggregated results.

### Deliverables

1. **APICT_SUITE** - Test suite loader
2. **APICT_SUITE_RUNNER** - Suite executor
3. **Enhanced HTTP client** - POST, PUT, DELETE, PATCH methods
4. **Request body support** - Load body from file
5. **Environment variables** - ${VAR} expansion
6. **Parallel execution** - `--parallel` option

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Design suite file format | JSON schema documented |
| T2.2 | Implement APICT_SUITE loader | Parses suite JSON to object model |
| T2.3 | Implement APICT_SUITE_RUNNER | Runs all tests, aggregates results |
| T2.4 | Add POST/PUT/DELETE/PATCH | All HTTP methods work |
| T2.5 | Add request body loading | Load body from JSON file |
| T2.6 | Add environment expansion | ${VAR} replaced with env values |
| T2.7 | Add parallel execution | --parallel N runs N concurrent tests |
| T2.8 | Add suite command | `apict suite tests.json` works |
| T2.9 | Add --fail-fast | Stop on first failure |
| T2.10 | Add --filter | Run subset of tests |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Suite load | Valid suite file | Parses without error |
| Suite run | Suite with 5 tests | Runs all 5, reports summary |
| POST body | POST with JSON body | Request includes body |
| Env expansion | ${API_TOKEN} | Replaced with env value |
| Parallel 4 | 20 tests, --parallel 4 | Faster than sequential |
| Fail fast | 2nd test fails | Only 2 tests run |
| Filter | --filter "user*" | Only matching tests run |

### Phase 2 Additions

```eiffel
class APICT_SUITE
create
    make_from_file
feature
    name: STRING
    defaults: APICT_DEFAULTS
    tests: LIST [APICT_TEST_DEFINITION]
    environment: HASH_TABLE [STRING, STRING]
    load (path: STRING)
end

class APICT_TEST_DEFINITION
create
    make
feature
    name: STRING
    endpoint: STRING
    method: STRING
    headers: HASH_TABLE [STRING, STRING]
    body_file: detachable STRING
    contract_path: STRING
    expected_status: INTEGER
end

class APICT_SUITE_RUNNER
create
    make
feature
    run (suite: APICT_SUITE): APICT_SUITE_RESULT
    run_parallel (suite: APICT_SUITE; workers: INTEGER): APICT_SUITE_RESULT
    set_fail_fast (enable: BOOLEAN)
    set_filter (pattern: STRING)
end

class APICT_SUITE_RESULT
create
    make
feature
    suite_name: STRING
    test_results: LIST [APICT_RESULT]
    total_count: INTEGER
    pass_count: INTEGER
    fail_count: INTEGER
    total_time_ms: INTEGER
end
```

---

## Phase 3: Production Polish

### Objective

Add semantic diffing, multiple output formats, and production hardening for CI integration.

### Deliverables

1. **Semantic diff** - Categorized change detection
2. **JUnit output** - CI integration
3. **SARIF output** - Code scanning tools
4. **HTML output** - Shareable reports
5. **Verbose mode** - Request/response logging
6. **OpenAPI import** - Generate suite from spec

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement APICT_DIFFER | Semantic JSON comparison |
| T3.2 | Categorize changes | Added, removed, modified with severity |
| T3.3 | Implement JUnit reporter | Valid JUnit XML output |
| T3.4 | Implement SARIF reporter | Valid SARIF 2.1 output |
| T3.5 | Implement HTML reporter | Shareable HTML report |
| T3.6 | Add --verbose | Log request/response details |
| T3.7 | Add validate command | Validate contract schema |
| T3.8 | Add diff command | Compare two JSON files |
| T3.9 | Add init command | Initialize suite from OpenAPI |
| T3.10 | Performance optimization | <500ms per test |
| T3.11 | Documentation | README, man page, examples |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Diff added field | Response has extra field | ADDED change detected |
| Diff removed field | Response missing field | REMOVED change detected |
| Diff type change | String became integer | TYPE_CHANGE detected |
| JUnit output | Suite results | Valid JUnit XML |
| SARIF output | Violations | Valid SARIF with locations |
| HTML output | Suite results | Viewable HTML report |
| Verbose | --verbose | Shows request/response |
| OpenAPI init | openapi.yaml | Generates suite file |

### Phase 3 Additions

```eiffel
class APICT_DIFFER
create
    make
feature
    diff (expected, actual: SIMPLE_JSON_VALUE): LIST [APICT_CHANGE]
    set_strict (enable: BOOLEAN)
end

class APICT_CHANGE
create
    make_added, make_removed, make_modified, make_type_change
feature
    change_type: INTEGER  -- Added, Removed, Modified, TypeChange
    path: STRING
    expected: detachable ANY
    actual: detachable ANY
    severity: INTEGER  -- Error, Warning, Info
end

class APICT_JUNIT_REPORTER
create
    make
feature
    generate (suite_result: APICT_SUITE_RESULT): STRING
        -- Generate JUnit XML
end

class APICT_SARIF_REPORTER
create
    make
feature
    generate (suite_result: APICT_SUITE_RESULT): STRING
        -- Generate SARIF JSON
end

class APICT_HTML_REPORTER
create
    make
feature
    generate (suite_result: APICT_SUITE_RESULT): STRING
        -- Generate HTML report
end
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable testing engine) -->
<target name="apict_lib">
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_http" location="$SIMPLE_EIFFEL/simple_http/simple_http.ecf"/>
    <library name="simple_diff" location="$SIMPLE_EIFFEL/simple_diff/simple_diff.ecf"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location="src/">
        <cluster name="core" location="core/"/>
        <cluster name="http" location="http/"/>
        <cluster name="reporting" location="reporting/"/>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="apict_cli" extends="apict_lib">
    <root class="APICT_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <cluster name="cli" location="src/cli/"/>
</target>

<!-- Test target -->
<target name="apict_tests" extends="apict_lib">
    <root class="TEST_APP" feature="make"/>
    <cluster name="tests" location="tests/"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI
/d/prod/ec.sh -batch -config apict.ecf -target apict_cli -c_compile

# Run CLI
./EIFGENs/apict_cli/W_code/apict.exe --help

# Test single endpoint
./EIFGENs/apict_cli/W_code/apict.exe test https://api.example.com/users --contract users.schema.json

# Run test suite
./EIFGENs/apict_cli/W_code/apict.exe suite api-tests.json --output junit > results.xml

# Compile tests
/d/prod/ec.sh -batch -config apict.ecf -target apict_tests -c_compile

# Run tests
./EIFGENs/apict_tests/W_code/apict.exe

# Finalize for release
/d/prod/ec.sh -batch -config apict.ecf -target apict_cli -finalize -c_compile
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors in all targets | 100% |
| Tests pass | All test cases pass | 100% |
| CLI works | All commands functional | Verified manually |
| Performance | Test execution time | <500ms per endpoint |
| CI integration | JUnit output valid | Jenkins/GitHub Actions parse |
| Documentation | README complete | Reviewed |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| simple_http limitations | Test against multiple APIs early |
| Schema validation edge cases | Use JSON Schema test suite |
| Parallel execution complexity | Start with sequential, add parallel in Phase 2 |
| Network reliability in tests | Use mock server for unit tests |
| Large response handling | Benchmark with multi-MB responses |
