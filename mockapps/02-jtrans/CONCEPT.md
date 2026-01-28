# jtrans - JSON Transform Engine

## Executive Summary

jtrans is an ETL-grade JSON transformation CLI designed for data engineers and integration specialists. While jq excels at ad-hoc queries and enterprise ETL tools like Altova MapForce handle complex visual mappings, jtrans occupies the middle ground: powerful enough for production data pipelines, simple enough for command-line scripting.

The tool enables declarative transformations through mapping files that define source-to-target field mappings with JSONPath queries, type conversions, and conditional logic. Unlike jq's functional programming approach, jtrans uses a familiar mapping syntax that non-programmers can understand and maintain. Unlike heavy ETL tools, it requires no GUI, no server, and no licensing infrastructure.

Key differentiators include streaming support for large files (using simple_json's SIMPLE_JSON_STREAM), decimal precision for financial data (via simple_decimal), and seamless CSV/JSON interoperability for data exchange workflows.

Revenue is generated through tiered licensing: free for simple transformations, professional for complex mappings and streaming, enterprise for unlimited throughput with custom function support.

## Problem Statement

**The problem:** Data engineers spend 60% of their time on data wrangling rather than analysis. JSON transformations are common in API integrations, data migrations, and ETL pipelines. Current solutions force a choice between too simple (jq requires programming), too complex (Altova requires training), or too expensive (enterprise ETL licenses).

**Current solutions:**
- **jq:** Powerful but requires functional programming knowledge. Complex transformations become unreadable.
- **Python scripts:** Flexible but requires development environment, testing infrastructure.
- **Enterprise ETL (Altova, Talend):** Feature-rich but expensive, complex, require dedicated teams.
- **Custom code:** Every project reinvents transformation logic.

**Our approach:** jtrans provides a declarative mapping file format that describes "what" not "how." A single command transforms JSON data according to a mapping specification. The same mapping works for single files, directories, or streaming pipelines. Output can be JSON, CSV, or line-delimited JSON.

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: Data Engineer | Builds data pipelines | Transform JSON at scale, reliable, scriptable |
| Primary: Integration Specialist | Connects systems via APIs | Map between API formats, handle edge cases |
| Secondary: SaaS Developer | Manages multi-tenant data | Transform customer exports, migration scripts |
| Secondary: Business Analyst | Creates reports from JSON | Extract and reshape data without coding |

## Value Proposition

**For** Data Engineers and Integration Specialists
**Who** need to transform JSON data in production pipelines
**This tool** provides declarative, scriptable JSON transformations
**Unlike** jq (too complex) or enterprise ETL (too expensive)
**We** deliver production-grade transformation with maintainable mapping files

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Free Tier | Simple mappings, single-file, 10 fields max | $0 |
| Professional | Complex mappings, streaming, unlimited fields, batch mode | $49/month per seat |
| Enterprise | Custom functions, parallel processing, priority support | Custom pricing |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Transformation accuracy | 100% field mapping | Automated test suite |
| Performance | 10K records/sec | Benchmark suite |
| Mapping readability | <5 min to understand | User study |
| Pipeline integration | Works with cron, Airflow, etc. | Integration tests |
