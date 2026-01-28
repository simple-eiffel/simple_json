# jcfg - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI | 5 days | simple_json, simple_cli, simple_file |
| Phase 2 | Policy Engine | 4 days | Phase 1 complete |
| Phase 3 | Production Polish | 3 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Deliver a working CLI that validates JSON files against JSON Schema with human-readable error output. This MVP proves the core value proposition and enables early user feedback.

### Deliverables

1. **JCFG_CLI** - Main entry point with argument parsing
2. **JCFG_VALIDATOR** - Schema validation engine
3. **JCFG_RESULT** - Validation result with errors
4. **JCFG_REPORTER** - Text output formatter
5. **Basic CLI** - `validate` command with `--schema` option

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create JCFG_CLI with simple_cli | `jcfg --help` shows usage |
| T1.2 | Implement JCFG_VALIDATOR | Validates JSON against schema |
| T1.3 | Create JCFG_RESULT | Stores errors with path, message, severity |
| T1.4 | Implement JCFG_REPORTER.to_text | Human-readable error output |
| T1.5 | Wire validate command | `jcfg validate --schema s.json f.json` works |
| T1.6 | Handle multiple files | Validates all files, aggregates results |
| T1.7 | Implement exit codes | 0=pass, 1=fail, 2=error |
| T1.8 | Add --quiet and --verbose | Output verbosity control |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid config | config.json matching schema | Exit 0, no errors |
| Invalid type | string where integer expected | Exit 1, "expected integer, got string" |
| Missing required | object missing required field | Exit 1, "missing required property: name" |
| Invalid JSON | malformed JSON | Exit 1, parse error with line number |
| Schema not found | --schema nonexistent.json | Exit 2, "Cannot read schema" |
| Multiple files | 3 files, 1 invalid | Exit 1, errors for invalid file only |

### Phase 1 Class Skeleton

```eiffel
class JCFG_CLI
create
    make
feature
    make
        -- Parse arguments and execute command
    execute_validate
        -- Run validation command
    print_help
        -- Show usage information
end

class JCFG_VALIDATOR
create
    make
feature
    make (a_schema: SIMPLE_JSON_SCHEMA)
        -- Initialize with schema
    validate (a_config: SIMPLE_JSON_VALUE): JCFG_RESULT
        -- Validate config against schema
end

class JCFG_RESULT
create
    make, make_valid
feature
    is_valid: BOOLEAN
    errors: LIST [JCFG_ERROR]
    add_error (a_error: JCFG_ERROR)
end

class JCFG_REPORTER
create
    make
feature
    to_text (a_result: JCFG_RESULT): STRING
        -- Format as human-readable text
end
```

---

## Phase 2: Policy Engine

### Objective

Add custom policy rules that extend beyond schema validation. This enables semantic validation like range checks, cross-references, and naming conventions.

### Deliverables

1. **JCFG_POLICY_ENGINE** - Policy evaluation engine
2. **JCFG_POLICY_RULE** - Single policy rule representation
3. **JCFG_POLICY_LOADER** - Parse policy rule files
4. **Enhanced JCFG_CLI** - `--policy` option, `policy` subcommand
5. **Built-in rules** - range, pattern, reference, enum

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Design policy rule format | JSON schema for rules documented |
| T2.2 | Implement JCFG_POLICY_LOADER | Parses policy rule files |
| T2.3 | Implement range rule | `{"type": "range", "min": 1, "max": 100}` |
| T2.4 | Implement pattern rule | `{"type": "pattern", "regex": "^[a-z]+$"}` |
| T2.5 | Implement reference rule | Cross-reference checking |
| T2.6 | Implement enum rule | Value in allowed set |
| T2.7 | Add --policy option | `jcfg validate --policy rules.json` |
| T2.8 | Add policy subcommand | `jcfg policy test`, `jcfg policy lint` |
| T2.9 | Combine schema + policy errors | Unified error reporting |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Range pass | port: 8080, rule: 1024-65535 | No error |
| Range fail | port: 80, rule: 1024-65535 | "port 80 not in range 1024-65535" |
| Pattern pass | name: "myapp", rule: ^[a-z]+$ | No error |
| Pattern fail | name: "MyApp", rule: ^[a-z]+$ | "name 'MyApp' does not match pattern" |
| Reference pass | env: "prod", exists in envs[] | No error |
| Reference fail | env: "staging", not in envs[] | "env 'staging' not found in environments" |
| Invalid policy | malformed rule JSON | Exit 2, "Invalid policy rule" |

---

## Phase 3: Production Polish

### Objective

Add enterprise features, multiple output formats, and production hardening for CI/CD integration.

### Deliverables

1. **Multiple output formats** - JSON, SARIF, JUnit
2. **Configuration file** - .jcfg.json support
3. **Parallel validation** - --parallel option
4. **Audit logging** - simple_logger integration
5. **Schema bundling** - $ref resolution
6. **Error hardening** - Graceful handling of all edge cases

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement JCFG_REPORTER.to_json | Machine-readable JSON output |
| T3.2 | Implement JCFG_REPORTER.to_sarif | SARIF 2.1 format for code scanning |
| T3.3 | Implement JCFG_REPORTER.to_junit | JUnit XML for CI integration |
| T3.4 | Add .jcfg.json config file | Auto-load from current/parent dirs |
| T3.5 | Implement --parallel | Process files in parallel threads |
| T3.6 | Add audit logging | Log all validations with timestamps |
| T3.7 | Implement schema bundling | Resolve $ref to inline schemas |
| T3.8 | Add init command | `jcfg init` creates .jcfg.json |
| T3.9 | Performance optimization | <100ms for typical configs |
| T3.10 | Documentation | README, man page, examples |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| JSON output | --output json | Valid JSON with errors array |
| SARIF output | --output sarif | Valid SARIF 2.1 document |
| JUnit output | --output junit | Valid JUnit XML |
| Config file | .jcfg.json present | Uses config without --schema |
| Parallel | 100 files, --parallel 8 | Faster than sequential |
| Audit | audit enabled | Log file contains validation records |
| Large file | 10MB JSON | Completes in <5s |

---

## ECF Target Structure

```xml
<!-- Library target (reusable validation engine) -->
<target name="jcfg_lib">
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
    <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <cluster name="src" location="src/">
        <cluster name="core" location="core/"/>
        <cluster name="policy" location="policy/"/>
        <cluster name="reporting" location="reporting/"/>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="jcfg_cli" extends="jcfg_lib">
    <root class="JCFG_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
    <cluster name="cli" location="src/cli/"/>
</target>

<!-- Test target -->
<target name="jcfg_tests" extends="jcfg_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location="tests/"/>
</target>
```

---

## Build Commands

```bash
# Compile CLI (workbench for development)
/d/prod/ec.sh -batch -config jcfg.ecf -target jcfg_cli -c_compile

# Run CLI
./EIFGENs/jcfg_cli/W_code/jcfg.exe --help

# Compile tests
/d/prod/ec.sh -batch -config jcfg.ecf -target jcfg_tests -c_compile

# Run tests
./EIFGENs/jcfg_tests/W_code/jcfg.exe

# Finalize for release
/d/prod/ec.sh -batch -config jcfg.ecf -target jcfg_cli -finalize -c_compile
```

---

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors in all targets | 100% |
| Tests pass | All test cases pass | 100% |
| CLI works | All commands functional | Verified manually |
| Performance | Validation time | <100ms for 100KB file |
| Exit codes | Correct exit codes | Verified in CI |
| Documentation | README complete | Reviewed |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| simple_json schema limitations | Test against JSON Schema test suite early |
| Performance on large files | Benchmark streaming parser in Phase 1 |
| Policy rule complexity | Start with simple rules, extend based on feedback |
| CI integration issues | Test on GitHub Actions, GitLab CI, Jenkins in Phase 3 |
