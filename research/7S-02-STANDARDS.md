# 7S-02: STANDARDS - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Applicable Standards

### Core JSON

- **RFC 8259**: The JavaScript Object Notation (JSON) Data Interchange Format
- **ECMA-404**: The JSON Data Interchange Standard

### JSON Extensions

- **RFC 6901**: JavaScript Object Notation (JSON) Pointer
- **RFC 6902**: JavaScript Object Notation (JSON) Patch
- **RFC 7396**: JSON Merge Patch

### Schema Validation

- **JSON Schema Draft-07**: Subset implementation

## Standards Compliance

### RFC 8259 (JSON)

| Feature | Compliance |
|---------|------------|
| Object parsing | Full |
| Array parsing | Full |
| String (Unicode) | Full (STRING_32) |
| Number | Full (INTEGER_64, DOUBLE, DECIMAL) |
| Boolean | Full |
| Null | Full |
| Whitespace handling | Full |
| UTF-8 encoding | Full |

### RFC 6902 (JSON Patch)

| Operation | Compliance |
|-----------|------------|
| add | Full |
| remove | Full |
| replace | Full |
| move | Full |
| copy | Full |
| test | Full |

### RFC 6901 (JSON Pointer)

| Feature | Compliance |
|---------|------------|
| Path navigation | Full |
| Escape sequences | Full |
| Array indices | Full |

## Design Patterns Applied

1. **Wrapper Pattern**: SIMPLE_JSON_VALUE wraps JSON_VALUE
2. **Builder Pattern**: Fluent API for JSON construction
3. **Visitor Pattern**: Streaming parser
4. **Facade Pattern**: SIMPLE_JSON as main entry point
