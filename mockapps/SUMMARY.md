# Mock Apps Summary: simple_json

## Generated: 2026-01-24

---

## Library Analyzed

- **Library:** simple_json
- **Core capability:** JSON parsing, building, querying, schema validation, patching, and streaming
- **Ecosystem position:** Foundation library for all JSON-based data processing in the simple_* ecosystem
- **Dependencies:** simple_decimal, simple_zstring, simple_encoding
- **Status:** Production Ready (v1.0.0, 216 tests passing)

---

## Mock Apps Designed

### 1. jcfg - JSON Config Validator

- **Purpose:** Enterprise-grade JSON configuration validator with schema enforcement and policy rules for CI/CD pipelines
- **Target:** DevOps Engineers, Platform Engineers, SRE teams
- **Ecosystem Libraries:** simple_json, simple_file, simple_cli, simple_logger, simple_hash
- **Revenue Model:** Free / Professional ($29/mo) / Enterprise (custom)
- **Status:** Design complete
- **Build Effort:** 12 days (3 phases)

**Key Features:**
- JSON Schema Draft 7 validation
- Custom policy rules (range, pattern, reference, enum)
- Multiple output formats (text, JSON, SARIF, JUnit)
- CI/CD-native exit codes and machine-readable output
- Audit logging for compliance

---

### 2. jtrans - JSON Transform Engine

- **Purpose:** ETL-grade JSON transformation CLI with JSONPath queries, schema mapping, and batch processing
- **Target:** Data Engineers, Integration Specialists, SaaS providers
- **Ecosystem Libraries:** simple_json, simple_csv, simple_file, simple_cli, simple_decimal, simple_template
- **Revenue Model:** Free / Professional ($49/mo) / Enterprise (custom)
- **Status:** Design complete
- **Build Effort:** 15 days (3 phases)

**Key Features:**
- Declarative mapping file format
- JSONPath field resolution
- Type conversions with decimal precision
- Streaming mode for large files (constant memory)
- CSV/JSON/NDJSON input/output
- Conditional filtering and value mapping

---

### 3. apict - API Contract Tester

- **Purpose:** API response validation tool that tests actual responses against JSON Schema contracts with detailed diff reporting
- **Target:** API Developers, QA Engineers, DevOps teams
- **Ecosystem Libraries:** simple_json, simple_http, simple_diff, simple_cli, simple_testing, simple_logger
- **Revenue Model:** Free / Professional ($39/mo) / Enterprise (custom)
- **Status:** Design complete
- **Build Effort:** 13 days (3 phases)

**Key Features:**
- HTTP client with authentication (Basic, Bearer, custom headers)
- JSON Schema contract validation
- Semantic diff with categorized changes
- Test suite execution (sequential and parallel)
- Multiple output formats (text, JUnit, SARIF, HTML)
- OpenAPI import for suite generation

---

## Ecosystem Coverage

| simple_* Library | Used In | Purpose |
|------------------|---------|---------|
| simple_json | jcfg, jtrans, apict | Core JSON operations |
| simple_file | jcfg, jtrans | File system operations |
| simple_cli | jcfg, jtrans, apict | Command-line interface |
| simple_logger | jcfg, apict | Logging and auditing |
| simple_hash | jcfg | Content fingerprinting |
| simple_csv | jtrans | CSV I/O |
| simple_decimal | jtrans | Financial precision |
| simple_template | jtrans | String interpolation |
| simple_http | apict | HTTP client |
| simple_diff | apict | Semantic comparison |
| simple_testing | apict | Test infrastructure |

**Total simple_* libraries leveraged:** 11

---

## Market Positioning

| App | Market Gap Filled | Key Competitors |
|-----|-------------------|-----------------|
| jcfg | Schema + policy validation for CI | Ajv-CLI (no policy), JSONBuddy (Windows GUI) |
| jtrans | Middle ground between jq and enterprise ETL | jq (complex), Altova (expensive) |
| apict | Focused contract testing for APIs | Postman (too heavy), raw validators (too basic) |

---

## Revenue Potential

| App | Free Tier | Professional | Enterprise |
|-----|-----------|--------------|------------|
| jcfg | Single schema | Multi-schema, custom rules | Unlimited, audit, SSO |
| jtrans | Simple mappings | Complex, streaming | Custom functions, parallel |
| apict | Manual testing | Suites, parallel, CI output | Historical, SLA monitoring |

**Combined addressable market:** DevOps + Data Engineering + API Development teams

---

## Next Steps

1. **Select Mock App for implementation**
   - Recommended: jcfg (shortest path to value, clearest market need)
   - Alternative: apict (leverages simple_http, demonstrates integration testing)

2. **Create project structure**
   ```
   simple_json/apps/jcfg/
   ├── jcfg.ecf
   ├── src/
   │   ├── core/
   │   ├── policy/
   │   ├── reporting/
   │   └── cli/
   └── tests/
   ```

3. **Implement Phase 1 (MVP)**
   - Follow BUILD-PLAN.md for task breakdown
   - Use Eiffel Spec Kit workflow: /eiffel.contracts -> /eiffel.review -> /eiffel.implement

4. **Run /eiffel.verify for contract validation**
   - Ensure all contracts are testable
   - Generate test suite from contracts

---

## Files Generated

```
simple_json/mockapps/
├── 00-MARKETPLACE-RESEARCH.md    # Library analysis and market research
├── 01-jcfg/
│   ├── CONCEPT.md                # Business concept and value proposition
│   ├── DESIGN.md                 # Technical architecture and CLI design
│   ├── BUILD-PLAN.md             # Phased implementation tasks
│   └── ECOSYSTEM-MAP.md          # simple_* integration patterns
├── 02-jtrans/
│   ├── CONCEPT.md
│   ├── DESIGN.md
│   ├── BUILD-PLAN.md
│   └── ECOSYSTEM-MAP.md
├── 03-apict/
│   ├── CONCEPT.md
│   ├── DESIGN.md
│   ├── BUILD-PLAN.md
│   └── ECOSYSTEM-MAP.md
└── SUMMARY.md                    # This file
```

---

## Research Sources

- [jq](https://jqlang.org/) - JSON CLI processor
- [Ajv-CLI](https://github.com/ajv-validator/ajv-cli) - Schema validation CLI
- [Sourcemeta jsonschema](https://github.com/sourcemeta/jsonschema) - JSON Schema CLI
- [Altova MapForce](https://www.altova.com/mapforce/etl-tool) - Enterprise ETL
- [Newman](https://dev.to/leading-edje/hello-newman-how-to-build-a-ci-cd-pipeline-that-executes-api-tests-2h5l) - Postman CLI
- [DeltaJSON](https://www.deltaxignia.com/solutions/json) - Enterprise JSON comparison
