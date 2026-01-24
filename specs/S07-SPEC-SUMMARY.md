# S07: SPECIFICATION SUMMARY - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Executive Summary

simple_json provides comprehensive JSON handling for Eiffel with full void safety, Unicode support, and RFC-compliant patch operations. It serves as foundational infrastructure for the simple_* ecosystem.

## Key Specifications

### Architecture

- **Pattern**: Wrapper + Facade + Builder
- **Classes**: 26
- **LOC**: ~4,300

### RFC Compliance

| RFC | Feature | Status |
|-----|---------|--------|
| 8259 | JSON syntax | Full |
| 6901 | JSON Pointer | Full |
| 6902 | JSON Patch | Full |
| 7396 | Merge Patch | Full |

### API Surface

| Category | Features |
|----------|----------|
| Parsing | 8 aliases + file parsing |
| Building | 14 factory methods |
| Object access | 12 typed getters |
| Object mutation | 9 fluent setters |
| Array access | 8 typed getters |
| Array mutation | 9 fluent adders |
| Queries | 4 JSONPath methods |
| Patch | 3 operations |

### Contract Coverage

| Class | Preconditions | Postconditions | Invariants |
|-------|---------------|----------------|------------|
| SIMPLE_JSON | 3 | 4 | 5 |
| SIMPLE_JSON_VALUE | 10 | 6 | 9 |
| SIMPLE_JSON_OBJECT | 24 | 22 | 8 |
| SIMPLE_JSON_ARRAY | 11 | 12 | 5 |

## Design Decisions

1. **Wrapper over rewrite**: Leverage existing JSON parser
2. **STRING_32 native**: Unicode-first design
3. **Fluent API**: Readable JSON construction
4. **Multiple aliases**: Discoverable API
5. **Position errors**: Debuggable parse failures

## Quality Attributes

| Attribute | Rating |
|-----------|--------|
| Reliability | Excellent |
| Usability | Excellent |
| Performance | Good |
| Maintainability | Good |
| Testability | Excellent |
