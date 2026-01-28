# Marketplace Research: simple_json

**Library**: simple_json
**Date**: 2026-01-24
**Purpose**: Identify viable Mock App candidates leveraging simple_json capabilities

---

## Library Profile

### Core Capabilities

| Capability | Description | Business Value |
|------------|-------------|----------------|
| JSON Parsing | Parse JSON text/files to typed values | Foundation for all JSON-based data processing |
| JSON Building | Fluent API for constructing JSON | Programmatic generation of configs, reports, API payloads |
| JSONPath Queries | SQL-like queries on JSON data | Extract specific data without manual traversal |
| JSON Schema Validation | Draft 7 validation | Data quality enforcement, contract validation |
| JSON Patch (RFC 6902) | add/remove/replace/move/copy/test operations | Atomic document modification, audit trails |
| JSON Merge Patch (RFC 7386) | Declarative document merging | Configuration merging, partial updates |
| JSON Pointer (RFC 6901) | Path notation for elements | Precise navigation, patch operation targeting |
| Streaming Parser | Memory-efficient large file processing | Process gigabyte files with constant memory |
| Pretty Printing | Human-readable JSON formatting | Documentation, debugging, reporting |
| Decimal Precision | Exact financial numbers via simple_decimal | Financial data integrity, regulatory compliance |
| Error Tracking | Line/column position information | User-friendly debugging, validation reporting |

### API Surface

| Feature Group | Type | Key Features |
|---------------|------|--------------|
| Parsing | Query | parse, parse_file, is_valid_json |
| Building | Command | new_object, new_array, put_* methods |
| Queries | Query | query_string, query_integer, query_strings |
| Patching | Command | create_patch, parse_patch, apply_patch |
| Schema | Query/Command | validate, has_type, has_properties |
| Streaming | Query | SIMPLE_JSON_STREAM iteration |
| Conversion | Query | to_json_string, to_pretty_json |

### Existing Dependencies

| simple_* Library | Purpose in simple_json |
|------------------|------------------------|
| simple_decimal | Exact decimal number representation |
| simple_zstring | Unicode/UTF-8 string conversion |
| simple_encoding | UTF-8 BOM detection |

### Integration Points

- **Input formats**: JSON strings, JSON files, JSON streams
- **Output formats**: JSON strings (compact/pretty), validation reports
- **Data flow**: Parse -> Query/Transform -> Build -> Output

---

## Marketplace Analysis

### Industry Applications

| Industry | Application | Pain Point Solved |
|----------|-------------|-------------------|
| DevOps/SRE | Configuration validation | Catch misconfigurations before deployment |
| Financial Services | Data transformation with precision | Avoid floating-point artifacts in monetary values |
| Healthcare | Schema-enforced data exchange | HIPAA/HL7 compliance validation |
| E-commerce | API response validation | Ensure data contracts between services |
| Enterprise IT | Configuration migration | Safe config updates with audit trails |
| Data Engineering | ETL pipelines | Transform JSON data at scale |
| SaaS Providers | Multi-tenant config management | Per-tenant customization with base configs |
| CI/CD | Contract testing | Validate API responses in pipelines |

### Commercial Products (Competitors/Inspirations)

| Product | Price Point | Key Features | Gap We Could Fill |
|---------|-------------|--------------|-------------------|
| jq | Free (OSS) | Query/transform | No schema validation, single-file focus |
| Ajv-CLI | Free (OSS) | Schema validation | No transformation, no patch support |
| JSONBuddy | $99-199/seat | GUI + CLI validation | Windows-only GUI, limited automation |
| DeltaJSON | Enterprise pricing | Compare/merge | No schema validation, no transformation |
| Altova MapForce | $449+ | Visual ETL | Heavyweight, complex learning curve |
| Postman/Newman | Free-$99/mo | API testing | Overkill for pure JSON validation |
| Sourcemeta jsonschema | Free (OSS) | Schema CLI | C++, no transformation or patching |

### Workflow Integration Points

| Workflow | Where simple_json Fits | Value Added |
|----------|-------------------------|-------------|
| CI/CD Pipeline | Pre-deployment validation | Catch config errors before release |
| API Development | Response schema validation | Contract enforcement |
| Configuration Management | Config diff/merge/patch | Safe incremental updates |
| Data Migration | Schema-guided transformation | Structured data conversion |
| Log Analysis | JSON log querying | Extract metrics without full parsing |
| Documentation | Schema-to-docs generation | API documentation automation |
| Testing | Expected vs actual comparison | Automated test assertions |

### Target User Personas

| Persona | Role | Need | Willingness to Pay |
|---------|------|------|-------------------|
| DevOps Engineer | Manages configs | Validate configs before deployment | HIGH |
| API Developer | Builds REST APIs | Ensure response contract compliance | HIGH |
| Data Engineer | Builds ETL pipelines | Transform JSON at scale | HIGH |
| QA Engineer | Tests APIs | Automated response validation | MEDIUM |
| Platform Engineer | Manages infrastructure | Configuration drift detection | HIGH |
| Solutions Architect | Designs integrations | Schema design and validation | MEDIUM |

---

## Mock App Candidates

### Candidate 1: JSON Config Validator (jcfg)

**One-liner:** Enterprise-grade JSON configuration validator with schema enforcement and policy rules for CI/CD pipelines.

**Target market:** DevOps teams, Platform Engineers, SRE teams managing infrastructure configurations.

**Revenue model:**
- Free tier for single-schema validation
- Professional ($29/mo): Multi-schema, custom rules
- Enterprise: Unlimited schemas, audit logging, SSO integration

**Ecosystem leverage:**
- simple_json (core parsing, schema validation)
- simple_file (file system operations)
- simple_cli (command-line interface)
- simple_logger (audit logging)
- simple_hash (content hashing for change detection)

**CLI-first value:** Integrates directly into CI/CD pipelines (GitHub Actions, Jenkins, GitLab CI).

**GUI/TUI potential:** Future VS Code extension, web-based schema editor.

**Viability:** HIGH - Direct competition with Ajv-CLI but adds transformation and policy rules.

---

### Candidate 2: JSON Transform Engine (jtrans)

**One-liner:** ETL-grade JSON transformation CLI with JSONPath queries, schema mapping, and batch processing.

**Target market:** Data Engineers, Integration Specialists, SaaS providers doing data migrations.

**Revenue model:**
- Free tier for simple transformations
- Professional ($49/mo): Complex mappings, streaming
- Enterprise: Unlimited throughput, custom functions

**Ecosystem leverage:**
- simple_json (parsing, queries, patching)
- simple_csv (CSV input/output for data exchange)
- simple_file (batch file processing)
- simple_cli (command-line interface)
- simple_template (transformation templates)
- simple_decimal (financial precision)

**CLI-first value:** Scriptable transformations for ETL pipelines, data migrations.

**GUI/TUI potential:** Visual mapping editor, transformation preview.

**Viability:** HIGH - Bridges gap between jq simplicity and Altova complexity.

---

### Candidate 3: API Contract Tester (apict)

**One-liner:** API response validation tool that tests actual responses against JSON Schema contracts with detailed diff reporting.

**Target market:** API Developers, QA Engineers, DevOps teams doing contract testing.

**Revenue model:**
- Free tier for manual testing
- Professional ($39/mo): CI integration, test suites
- Enterprise: Parallel testing, historical tracking

**Ecosystem leverage:**
- simple_json (parsing, schema validation, diff)
- simple_http (API requests)
- simple_cli (command-line interface)
- simple_diff (semantic JSON comparison)
- simple_testing (test framework)
- simple_logger (test reporting)

**CLI-first value:** Drop into any CI pipeline, compare expected vs actual responses.

**GUI/TUI potential:** Test report viewer, schema documentation generator.

**Viability:** HIGH - Fills niche between Postman (too heavy) and raw validation (too basic).

---

### Candidate 4: JSON Config Manager (jcm)

**One-liner:** Configuration management tool with environment-based inheritance, merge strategies, and change tracking.

**Target market:** Platform Engineers, SaaS providers managing multi-tenant configurations.

**Revenue model:**
- Free tier for basic merging
- Professional ($35/mo): Environment inheritance, secrets management
- Enterprise: Audit trails, compliance reporting

**Ecosystem leverage:**
- simple_json (parsing, merging, patching)
- simple_file (file system operations)
- simple_cli (command-line interface)
- simple_encryption (secrets handling)
- simple_env (environment variable expansion)
- simple_hash (content change detection)

**CLI-first value:** Manage configs across dev/staging/prod with single source of truth.

**GUI/TUI potential:** Config hierarchy viewer, merge conflict resolver.

**Viability:** MEDIUM-HIGH - Competes with existing config management but adds JSON-native merging.

---

## Selection Rationale

**Selected for detailed design: Candidates 1, 2, and 3**

1. **JSON Config Validator (jcfg)** - Selected because:
   - Clear market need (DevOps adoption increasing)
   - Strong ecosystem integration (5+ simple_* libraries)
   - Direct revenue opportunity (CI/CD tooling budgets)
   - Natural extension of simple_json's schema capabilities

2. **JSON Transform Engine (jtrans)** - Selected because:
   - Large market (ETL/data engineering growing rapidly)
   - Unique positioning (between jq and enterprise ETL)
   - Multi-library integration showcases ecosystem
   - High business value (data migration projects have budgets)

3. **API Contract Tester (apict)** - Selected because:
   - API-first development is industry standard
   - Integrates simple_http for real API testing
   - Natural fit for CI/CD (tested contracts = quality gates)
   - Competitive gap exists (Postman too heavy, raw validation too basic)

**Candidate 4 (jcm) deferred** because config management overlaps with existing tools (Ansible, Puppet) and has a steeper adoption curve due to workflow changes required.

---

## Research Sources

### JSON CLI Tools
- [jq](https://jqlang.org/) - sed for JSON data
- [fx](https://fx.wtf/) - Terminal JSON viewer & processor
- [jless](https://jless.io/) - Command-line JSON viewer

### JSON Schema Validation
- [ajv-cli](https://github.com/ajv-validator/ajv-cli) - CLI for Ajv validator
- [Sourcemeta jsonschema](https://github.com/sourcemeta/jsonschema) - C++ JSON Schema CLI
- [JSONBuddy](https://www.json-buddy.com/json-validator-command-line-tool.htm) - Commercial Windows tool
- [check-jsonschema](https://github.com/python-jsonschema/check-jsonschema) - Python CLI with pre-commit hooks

### ETL and Data Transformation
- [Altova MapForce](https://www.altova.com/mapforce/etl-tool) - Enterprise ETL tool
- [Integrate.io](https://www.integrate.io/docs/etl/how-do-i-process-json-data/) - Cloud ETL platform
- [Best ETL Tools for JSON](https://airbyte.com/top-etl-tools-for-sources/json-file) - Airbyte comparison

### JSON Diff and Comparison
- [JSON Diff](https://jsondiff.com/) - Semantic JSON comparison
- [DeltaJSON](https://www.deltaxignia.com/solutions/json) - Enterprise JSON comparison

### API Testing
- [Newman (Postman CLI)](https://dev.to/leading-edje/hello-newman-how-to-build-a-ci-cd-pipeline-that-executes-api-tests-2h5l) - Postman CLI runner
- [REST-assured](https://techvzero.com/api-testing-in-ci-cd-tools-comparison/) - Java API testing
- [JSON-RPC Tools CI/CD](https://json-rpc.dev/docs/integration/cicd) - CI integration patterns
