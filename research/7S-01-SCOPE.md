# 7S-01: SCOPE - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Problem Domain

JSON parsing, building, querying, and manipulation for Eiffel applications with full Unicode support.

### What Problem Does This Solve?

1. **JSON Integration**: Parse and generate JSON for API communication
2. **Unicode Handling**: Proper STRING_32/UTF-8 support throughout
3. **Type Safety**: Strongly-typed JSON value wrappers
4. **Query Capability**: JSONPath-style queries for nested data
5. **Standards Compliance**: JSON Patch (RFC 6902), JSON Pointer (RFC 6901), JSON Merge Patch

### Target Users

- Eiffel developers consuming REST APIs
- Applications generating configuration files
- Data serialization/deserialization needs
- JSON-based protocols and messaging

### Use Cases

1. Parse API responses into typed objects
2. Build JSON requests with fluent API
3. Query nested data without manual traversal
4. Apply RFC 6902 patches to JSON documents
5. Schema validation of incoming JSON

## Boundaries

### In Scope

- JSON parsing (RFC 8259 compliant)
- JSON building with fluent API
- JSONPath queries (subset)
- JSON Patch (RFC 6902)
- JSON Merge Patch (RFC 7396)
- JSON Pointer (RFC 6901)
- JSON Schema validation (basic)
- Pretty printing
- Streaming parser
- Error tracking with positions

### Out of Scope

- Binary JSON formats (BSON, MessagePack)
- JSON-LD
- Full JSONPath specification
- JSON Web Tokens (see simple_jwt)

## Domain Vocabulary

| Term | Definition |
|------|------------|
| JSON Value | Any JSON type (object, array, string, number, boolean, null) |
| JSON Object | Key-value map with string keys |
| JSON Array | Ordered list of JSON values |
| JSONPath | Query language for JSON data |
| JSON Patch | RFC 6902 document modification operations |
| JSON Pointer | RFC 6901 path notation for JSON elements |
