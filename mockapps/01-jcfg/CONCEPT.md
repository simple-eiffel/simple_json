# jcfg - JSON Config Validator

## Executive Summary

jcfg is an enterprise-grade JSON configuration validator designed for modern DevOps workflows. Unlike simple schema validators that only check syntax, jcfg combines JSON Schema Draft 7 validation with custom policy rules, cross-file dependency checking, and detailed diagnostic reporting. Built specifically for CI/CD pipeline integration, jcfg ensures configuration quality gates are enforced before deployment, catching errors that would otherwise surface in production.

The tool addresses a critical gap in the market: while tools like Ajv-CLI provide schema validation and jq enables transformation, no single tool combines schema validation, policy enforcement, cross-reference checking, and CI/CD-friendly output formats. jcfg fills this gap with a lightweight, fast CLI that fits seamlessly into existing DevOps toolchains.

Revenue is generated through tiered licensing: a free tier for individual developers, a professional tier for teams needing multi-schema validation and custom rules, and an enterprise tier with audit logging, compliance reporting, and SSO integration.

## Problem Statement

**The problem:** Configuration errors are a leading cause of production incidents. A 2024 Gartner study found that 40% of outages stem from misconfigurations. Teams deploy JSON configurations (Kubernetes manifests, Terraform variables, application configs) without systematic validation, relying on manual review or runtime failures to catch issues.

**Current solutions:**
- **Manual review:** Error-prone, doesn't scale, inconsistent across teams
- **Schema-only validation:** Catches type errors but misses semantic issues (e.g., invalid port ranges, missing cross-references)
- **Runtime validation:** Issues discovered too late, increases incident rate
- **Heavy enterprise tools:** Expensive, complex, require dedicated teams

**Our approach:** jcfg provides lightweight, CI-native validation that combines schema validation with policy rules. A single command validates a configuration against its schema AND custom rules (e.g., "port must be 1024-65535", "environment must reference existing secret"). Output is machine-readable for pipeline integration and human-readable for debugging.

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: DevOps Engineer | Manages deployment pipelines, infrastructure configs | Validate configs before deployment, fail fast, actionable errors |
| Primary: Platform Engineer | Builds internal developer platforms | Enforce standards across teams, policy-as-code |
| Secondary: SRE | Maintains production reliability | Detect config drift, audit changes |
| Secondary: Security Engineer | Ensures compliance | Validate against security policies, audit trail |

## Value Proposition

**For** DevOps and Platform Engineers
**Who** manage JSON configurations across environments
**This tool** provides schema validation with custom policy rules
**Unlike** schema-only validators like Ajv-CLI
**We** combine validation with policy enforcement and CI-native output

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Free Tier | Single schema, basic validation, CLI output | $0 |
| Professional | Multi-schema, custom rules, JSON/XML output, parallel validation | $29/month per seat |
| Enterprise | Unlimited schemas, audit logging, SARIF output, policy libraries, SSO | Custom pricing |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Pipeline integration rate | 80% of users add to CI within 7 days | Telemetry (opt-in) |
| Validation performance | <100ms for typical configs | Benchmark suite |
| Error clarity | <2 questions before fix | User feedback survey |
| Enterprise conversion | 5% free-to-enterprise | Sales pipeline |
