# apict - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_json | Core JSON operations | Parsing responses, schema validation, building reports |
| simple_http | HTTP client | Fetch API responses, handle authentication |
| simple_diff | Semantic comparison | Compare expected vs actual JSON structures |
| simple_cli | Command-line interface | Argument parsing, subcommands, output |
| simple_testing | Test infrastructure | Test runner patterns, assertions |
| simple_logger | Test logging | Request/response logging, debug output |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_env | Environment expansion | When tests use ${VAR} syntax |
| simple_encryption | Secure auth storage | When storing credentials |
| simple_file | File operations | When loading test fixtures |
| simple_xml | OpenAPI parsing | When generating from OpenAPI specs |

## Integration Patterns

### simple_json Integration

**Purpose:** Parse responses, validate against schemas, build reports.

**Usage:**
```eiffel
-- Parse API response
local
    json: SIMPLE_JSON
    response: detachable SIMPLE_JSON_VALUE
do
    create json
    response := json.parse (http_response.body)

    if json.has_errors then
        -- Response is not valid JSON
        result.add_failure ("Invalid JSON response", json.errors_as_string)
    else
        validate_against_contract (response)
    end
end
```

```eiffel
-- Schema validation
local
    schema: SIMPLE_JSON_SCHEMA
    validator: SIMPLE_JSON_SCHEMA_VALIDATOR
    validation: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
do
    create schema.make_from_string (contract_json)
    create validator.make (schema)

    validation := validator.validate (response)

    if not validation.is_valid then
        across validation.errors as err loop
            result.add_violation (create {APICT_CHANGE}.make_schema_violation (err))
        end
    end
end
```

```eiffel
-- Build JUnit XML output
local
    output: SIMPLE_JSON_OBJECT
    tests: SIMPLE_JSON_ARRAY
do
    create output.make
    create tests.make

    across suite_results as test_result loop
        tests := tests.add_object (test_result_to_json (test_result))
    end

    output := output.put_string (suite.name, "name")
    output := output.put_integer (suite_results.count, "tests")
    output := output.put_integer (failures_count, "failures")
    output := output.put_array (tests, "testcase")

    Result := output.to_json_string
end
```

**Data flow:** HTTP response -> SIMPLE_JSON.parse -> SIMPLE_JSON_SCHEMA.validate -> APICT_RESULT

### simple_http Integration

**Purpose:** Make HTTP requests to API endpoints.

**Usage:**
```eiffel
-- Simple GET request
local
    client: SIMPLE_HTTP_CLIENT
    response: SIMPLE_HTTP_RESPONSE
do
    create client.make
    client.set_timeout (test_config.timeout)

    -- Add headers
    across test_config.headers as h loop
        client.add_header (h.key, h)
    end

    -- Add authentication
    if attached test_config.auth as auth then
        apply_authentication (client, auth)
    end

    response := client.get (test_config.endpoint)

    if response.is_success then
        validate_response (response)
    else
        handle_http_error (response)
    end
end
```

```eiffel
-- POST request with body
local
    client: SIMPLE_HTTP_CLIENT
    response: SIMPLE_HTTP_RESPONSE
do
    create client.make
    client.add_header ("Content-Type", "application/json")

    if attached load_body (test_config.body_file) as body then
        response := client.post (test_config.endpoint, body)
    end

    validate_response (response)
end
```

```eiffel
-- Authentication patterns
apply_authentication (client: SIMPLE_HTTP_CLIENT; auth: STRING)
    local
        parts: LIST [STRING]
    do
        parts := auth.split (':')
        if parts.count >= 2 then
            if parts [1].is_equal ("bearer") then
                client.add_header ("Authorization", "Bearer " + parts [2])
            elseif parts [1].is_equal ("basic") and parts.count >= 3 then
                client.set_basic_auth (parts [2], parts [3])
            elseif parts [1].is_equal ("header") and parts.count >= 3 then
                client.add_header (parts [2], parts [3])
            end
        end
    end
```

**Data flow:** Test config -> SIMPLE_HTTP_CLIENT -> HTTP request -> Response -> Validation

### simple_diff Integration

**Purpose:** Semantic comparison of expected vs actual JSON.

**Usage:**
```eiffel
-- Compare schema-defined structure with actual response
local
    differ: SIMPLE_JSON_DIFFER
    diff: SIMPLE_JSON_DIFF_RESULT
do
    create differ.make

    -- Compare structure (not values, for contract testing)
    differ.set_compare_structure (True)
    differ.set_compare_values (False)
    differ.set_strict_mode (test_config.strict)

    diff := differ.compare (expected_structure, actual_response)

    if not diff.is_empty then
        across diff.changes as change loop
            categorize_and_add_change (change)
        end
    end
end
```

```eiffel
-- Categorize changes by severity
categorize_and_add_change (change: SIMPLE_JSON_DIFF_CHANGE)
    do
        inspect change.change_type
        when Added then
            -- Extra property in response
            if contract.allows_additional then
                result.add_info (change)
            else
                result.add_warning (change)
            end
        when Removed then
            -- Missing property
            if contract.is_required (change.path) then
                result.add_error (change)
            else
                result.add_info (change)
            end
        when Modified then
            -- Type or value changed
            result.add_error (change)
        end
    end
```

**Data flow:** Expected structure + Actual response -> SIMPLE_JSON_DIFFER -> Diff changes -> Categorized results

### simple_testing Integration

**Purpose:** Test runner infrastructure and assertions.

**Usage:**
```eiffel
-- Test suite runner
class APICT_SUITE_RUNNER

inherit
    SIMPLE_TEST_RUNNER

feature
    run_suite (suite: APICT_SUITE): APICT_SUITE_RESULT
        do
            create Result.make (suite.name)

            across suite.tests as test_def loop
                Result.add_test_result (run_test (test_def))
            end
        end

    run_test (test_def: APICT_TEST_DEFINITION): APICT_RESULT
        local
            tester: APICT_TESTER
        do
            create tester.make
            Result := tester.execute (test_def)
        end
end
```

```eiffel
-- Parallel execution
run_suite_parallel (suite: APICT_SUITE; workers: INTEGER): APICT_SUITE_RESULT
    local
        pool: SIMPLE_THREAD_POOL
        futures: LIST [SIMPLE_FUTURE [APICT_RESULT]]
    do
        create pool.make (workers)
        create {ARRAYED_LIST [SIMPLE_FUTURE [APICT_RESULT]]} futures.make (suite.tests.count)

        -- Submit all tests
        across suite.tests as test_def loop
            futures.force (pool.submit (agent run_test (test_def)))
        end

        -- Collect results
        create Result.make (suite.name)
        across futures as f loop
            Result.add_test_result (f.get)
        end

        pool.shutdown
    end
```

**Data flow:** Test suite -> SIMPLE_TEST_RUNNER -> Individual tests -> Aggregated results

### simple_logger Integration

**Purpose:** Request/response logging for debugging.

**Usage:**
```eiffel
-- Verbose logging
local
    logger: SIMPLE_LOGGER
do
    create logger.make_console
    logger.set_level (Log_debug)

    -- Log request
    logger.debug ("Request: " + test.method + " " + test.endpoint)
    across test.headers as h loop
        logger.debug ("  Header: " + h.key + ": " + h)
    end
    if attached test.body as b then
        logger.debug ("  Body: " + b.head (200) + "...")
    end

    -- Execute test
    result := tester.execute (test)

    -- Log response
    logger.debug ("Response: " + result.status_code.out)
    logger.debug ("  Body: " + result.response_body.head (500) + "...")
    logger.debug ("  Time: " + result.duration_ms.out + "ms")
end
```

**Data flow:** Test execution -> SIMPLE_LOGGER -> Console/file output

## Dependency Graph

```
apict
    |
    +-- simple_json (required)
    |       |
    |       +-- simple_decimal
    |       +-- simple_zstring
    |       +-- simple_encoding
    |
    +-- simple_http (required)
    |       |
    |       +-- simple_socket
    |
    +-- simple_diff (required)
    |
    +-- simple_cli (required)
    |
    +-- simple_testing (required)
    |
    +-- simple_logger (required)
    |
    +-- simple_env (optional)
    |
    +-- simple_file (optional)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<system name="apict" uuid="550e8400-e29b-41d4-a716-446655440003" xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0">
    <description>API Contract Tester</description>

    <target name="apict">
        <root class="APICT_CLI" feature="make"/>

        <option warning="warning" syntax="standard">
            <assertions precondition="require" postcondition="ensure" check="check" invariant="invariant"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="feature"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_http" location="$SIMPLE_EIFFEL/simple_http/simple_http.ecf"/>
        <library name="simple_diff" location="$SIMPLE_EIFFEL/simple_diff/simple_diff.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>

        <!-- Optional dependencies -->
        <library name="simple_env" location="$SIMPLE_EIFFEL/simple_env/simple_env.ecf">
            <condition>
                <custom name="env_support" value="true"/>
            </condition>
        </library>

        <!-- ISE base library -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Application source -->
        <cluster name="src" location="src/" recursive="true"/>
    </target>

    <target name="apict_tests" extends="apict">
        <root class="TEST_APP" feature="make"/>
        <cluster name="tests" location="tests/" recursive="true"/>
    </target>
</system>
```

## Integration Test Points

| Integration | Test Focus | Example |
|-------------|------------|---------|
| simple_json parsing | Response parsing | Parse various JSON responses |
| simple_json schema | All Draft 7 keywords | Validate against schema test suite |
| simple_http | All HTTP methods | GET, POST, PUT, DELETE, PATCH |
| simple_http auth | Auth patterns | Basic, Bearer, custom headers |
| simple_diff | Change detection | Added, removed, modified fields |
| simple_testing | Suite execution | Sequential and parallel runs |
| simple_logger | Log levels | Debug, info, error output |
