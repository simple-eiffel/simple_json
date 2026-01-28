# apict - API Contract Tester

## Executive Summary

apict is a lightweight API contract testing tool that validates actual HTTP responses against JSON Schema contracts with detailed semantic diff reporting. In an API-first world where microservices communicate via JSON APIs, contract drift is a leading cause of integration failures. apict catches breaking changes before they reach production by comparing expected schemas with actual responses.

Unlike Postman/Newman which are full-featured API testing platforms, apict focuses on one thing: contract validation. Unlike schema validators that only check structure, apict performs semantic comparison showing exactly what changed (added fields, removed fields, type changes). This focus enables a smaller footprint, faster execution, and simpler CI integration.

The tool bridges the gap between API documentation (which describes contracts) and runtime reality (which often drifts). By running apict in CI pipelines, teams ensure their APIs honor their contracts, reducing integration bugs and improving developer experience for API consumers.

Revenue is generated through tiered licensing: free for manual testing, professional for CI integration with test suites and parallel execution, enterprise for historical tracking and SLA monitoring.

## Problem Statement

**The problem:** API contract violations are discovered too late - often by customers in production. A 2025 survey found that 45% of API integration issues stem from undocumented contract changes. Teams publish OpenAPI/JSON Schema specs but have no automated way to verify implementations match.

**Current solutions:**
- **Postman/Newman:** Full API testing suite, requires learning Postman, overkill for contract validation.
- **Manual testing:** Doesn't scale, inconsistent, not automated.
- **Unit tests:** Test internal behavior, not external contracts.
- **Consumer-driven contract testing (Pact):** Complex setup, requires both sides to participate.
- **Schema-only validation:** Catches type errors but not semantic drift (renamed fields, new required fields).

**Our approach:** apict takes a schema file and an API endpoint, fetches the actual response, and produces a detailed semantic diff. The diff shows not just "invalid" but exactly what's different: new fields, missing fields, type changes, value constraints. Output formats support CI integration (JUnit, SARIF) and human debugging (colored text, HTML reports).

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: API Developer | Builds and maintains REST APIs | Ensure implementations match specs |
| Primary: QA Engineer | Tests API integrations | Automated contract validation in test suites |
| Secondary: DevOps Engineer | Manages CI/CD pipelines | Quality gates for API deployments |
| Secondary: Technical PM | Tracks API quality | SLA compliance, contract violation trends |

## Value Proposition

**For** API Developers and QA Engineers
**Who** need to ensure APIs honor their contracts
**This tool** validates responses against JSON Schema with semantic diffing
**Unlike** heavy API testing tools (Postman) or raw validators (Ajv)
**We** provide focused contract testing with CI-native output

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Free Tier | Manual testing, single contract, text output | $0 |
| Professional | Test suites, parallel execution, JUnit/SARIF output | $39/month per seat |
| Enterprise | Historical tracking, SLA monitoring, team dashboards | Custom pricing |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test execution time | <500ms per endpoint | Benchmark suite |
| Contract violations caught | 95% before production | User reports |
| CI integration rate | 70% users add to pipeline | Telemetry (opt-in) |
| Diff clarity | <3 min to understand issue | User feedback |
