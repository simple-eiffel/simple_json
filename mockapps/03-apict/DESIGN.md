# apict - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                          apict CLI                                |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - Argument parsing (simple_cli)                                |
|    - Command routing                                              |
|    - Output formatting (text, JSON, JUnit, HTML)                 |
+------------------------------------------------------------------+
|  Contract Testing Engine                                          |
|    - Schema loading and validation                                |
|    - Response fetching (simple_http)                             |
|    - Schema validation (simple_json schema)                      |
|    - Semantic diff generation (simple_diff)                      |
+------------------------------------------------------------------+
|  Test Suite Layer                                                 |
|    - Test case loader                                             |
|    - Test runner (sequential/parallel)                           |
|    - Result aggregation                                          |
+------------------------------------------------------------------+
|  Reporting Layer                                                  |
|    - Text reporter (colored output)                              |
|    - JUnit reporter (CI integration)                             |
|    - SARIF reporter (code scanning)                              |
|    - HTML reporter (shareable reports)                           |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_json (parsing, schema, diff)                         |
|    - simple_http (API requests)                                  |
|    - simple_diff (semantic comparison)                           |
|    - simple_testing (test infrastructure)                        |
|    - simple_logger (test logging)                                |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| APICT_CLI | Command-line interface | parse_arguments, route_command, format_output |
| APICT_TESTER | Contract test executor | test_endpoint, test_suite, run_parallel |
| APICT_CONTRACT | Schema contract | load_schema, validate, get_constraints |
| APICT_CLIENT | HTTP client wrapper | fetch, with_headers, with_auth |
| APICT_DIFFER | Semantic diff engine | diff_response, categorize_changes |
| APICT_CHANGE | Single diff item | change_type, path, expected, actual |
| APICT_RESULT | Test result | is_pass, violations, diff |
| APICT_SUITE | Test suite | tests, run, aggregate_results |
| APICT_REPORTER | Output generation | to_text, to_junit, to_sarif, to_html |

### Command Structure

```bash
apict <command> [options] [arguments]

Commands:
  test        Test endpoint against contract
  suite       Run test suite file
  diff        Compare two JSON responses
  validate    Validate contract schema
  init        Initialize test suite

Global Options:
  --output FORMAT     Output format: text|json|junit|sarif|html (default: text)
  --quiet             Suppress non-error output
  --verbose           Enable verbose output (shows request/response)
  --no-color          Disable colored output
  --version           Show version
  --help              Show help

test Command:
  apict test [options] <endpoint> --contract <schema>

  Options:
    --contract FILE   JSON Schema contract file (required)
    --method METHOD   HTTP method (default: GET)
    --headers FILE    Headers file (JSON)
    --body FILE       Request body file
    --auth AUTH       Authentication: basic:user:pass | bearer:token | header:name:value
    --status CODE     Expected status code (default: 200)
    --timeout MS      Request timeout (default: 30000)
    --strict          Fail on additional properties (default: warn)

  Examples:
    apict test https://api.example.com/users --contract users.schema.json
    apict test https://api.example.com/orders --contract orders.schema.json --method POST --body order.json
    apict test https://api.example.com/secure --contract secure.schema.json --auth bearer:$TOKEN

suite Command:
  apict suite [options] <suite-file>

  Options:
    --parallel N      Run tests in parallel (default: 1)
    --fail-fast       Stop on first failure
    --filter PATTERN  Run only tests matching pattern
    --env FILE        Environment variables file

  Examples:
    apict suite api-tests.json
    apict suite api-tests.json --parallel 4 --output junit > results.xml

diff Command:
  apict diff [options] <expected> <actual>

  Options:
    --contract FILE   Validate both against schema first

validate Command:
  apict validate [options] <contract>

init Command:
  apict init [options]

  Options:
    --from-openapi FILE  Generate suite from OpenAPI spec
```

### Test Suite File Format

```json
{
  "$schema": "https://apict.io/suite-schema.json",
  "name": "User API Contract Tests",
  "version": "1.0",
  "description": "Contract tests for User API v2",

  "defaults": {
    "baseUrl": "https://api.example.com",
    "headers": {
      "Accept": "application/json",
      "X-API-Version": "2"
    },
    "timeout": 5000
  },

  "environment": {
    "API_TOKEN": "${API_TOKEN}",
    "BASE_URL": "https://api.example.com"
  },

  "tests": [
    {
      "name": "Get all users",
      "description": "List users endpoint returns valid user array",
      "endpoint": "/users",
      "method": "GET",
      "contract": "schemas/users-list.schema.json",
      "status": 200
    },
    {
      "name": "Get single user",
      "description": "Get user by ID returns valid user object",
      "endpoint": "/users/123",
      "method": "GET",
      "contract": "schemas/user.schema.json",
      "status": 200
    },
    {
      "name": "Create user",
      "description": "Create user returns created user",
      "endpoint": "/users",
      "method": "POST",
      "headers": {
        "Content-Type": "application/json"
      },
      "body": "fixtures/new-user.json",
      "contract": "schemas/user.schema.json",
      "status": 201
    },
    {
      "name": "User not found",
      "description": "Non-existent user returns 404",
      "endpoint": "/users/999999",
      "method": "GET",
      "contract": "schemas/error.schema.json",
      "status": 404
    },
    {
      "name": "Unauthorized access",
      "description": "Missing auth returns 401",
      "endpoint": "/admin/users",
      "method": "GET",
      "headers": {},
      "contract": "schemas/error.schema.json",
      "status": 401
    }
  ]
}
```

### Data Flow

```
Test Definition                    Contract Schema
     |                                   |
     v                                   v
+----------+                      +------------+
| Resolve  |                      | Load       |
| endpoint |                      | Schema     |
| + config |                      +------------+
+----------+                             |
     |                                   v
     v                            +------------+
+----------+                      | Compile    |
| HTTP     |----> Response ---->  | Validate   |
| Request  |      JSON           +------------+
+----------+                             |
     |                                   v
     |                            +------------+
     |                            | Schema     |
     |                            | Violations |
     |                            +------------+
     |                                   |
     v                                   v
+--------------------------------------------------+
|              Semantic Diff Engine                 |
|  - Compare expected vs actual structure          |
|  - Identify added/removed/changed fields         |
|  - Categorize by severity                        |
+--------------------------------------------------+
     |
     v
+--------------------------------------------------+
|              Test Result                          |
|  - Pass/Fail status                              |
|  - Schema violations (if any)                    |
|  - Semantic diff (all changes)                   |
|  - Response metadata (status, time, size)        |
+--------------------------------------------------+
     |
     v
+--------------------------------------------------+
|              Format Output                        |
|  - Text (human-readable, colored)                |
|  - JSON (machine-readable)                       |
|  - JUnit (CI integration)                        |
|  - SARIF (code scanning)                         |
|  - HTML (shareable report)                       |
+--------------------------------------------------+
```

### Semantic Diff Categories

| Category | Severity | Description | Example |
|----------|----------|-------------|---------|
| MISSING_REQUIRED | Error | Required field missing | Expected "id", not present |
| TYPE_MISMATCH | Error | Wrong type | Expected integer, got string |
| CONSTRAINT_VIOLATION | Error | Value outside constraints | Value 150, max is 100 |
| EXTRA_PROPERTY | Warning | Undocumented field present | "debug_info" not in schema |
| VALUE_MISMATCH | Info | Different value (for test assertions) | Expected "active", got "pending" |
| MISSING_OPTIONAL | Info | Optional field missing | "nickname" not present |

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Contract not found | Exit with code 2 | "Error: Cannot read contract: {path}" |
| Invalid contract | Exit with code 2 | "Error: Invalid schema: {details}" |
| Connection failed | Exit with code 2 | "Error: Cannot connect to {endpoint}: {reason}" |
| Timeout | Mark test failed | "Timeout: {endpoint} did not respond in {ms}ms" |
| HTTP error | Depends on expected status | Test passes if status matches expectation |
| Schema violation | Mark test failed | "Contract violation at {path}: {details}" |
| Invalid response JSON | Mark test failed | "Invalid JSON response: {parse_error}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |
| 2 | Tool error (file not found, connection error, etc.) |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **VS Code Extension**
   - Run tests from editor
   - Inline contract violation highlighting
   - Schema intellisense in test files

2. **TUI Dashboard**
   - Live test execution status
   - Response browser
   - Diff viewer with side-by-side comparison

3. **Web Interface**
   - Test suite builder
   - Historical test results
   - Contract diff timeline
   - Team dashboards

**Shared components between CLI/GUI:**
- APICT_TESTER (test execution)
- APICT_DIFFER (semantic diff)
- APICT_CONTRACT (schema handling)
- All result and change types
