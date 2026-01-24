# S06: BOUNDARIES - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## System Boundaries

### What simple_json IS

- JSON parsing and generation
- Type-safe value wrappers
- JSONPath queries (subset)
- RFC 6902 JSON Patch
- RFC 7396 JSON Merge Patch
- RFC 6901 JSON Pointer
- Basic schema validation
- Streaming parser
- Pretty printer

### What simple_json IS NOT

- JWT handling (see simple_jwt)
- Binary JSON (BSON, MessagePack)
- Full JSONPath specification
- Full JSON Schema validator
- JSON-LD processor
- YAML processor

## Integration Boundaries

### Input Sources

| Source | Support |
|--------|---------|
| STRING_32 | Direct parse |
| STRING_8 (UTF-8) | Converted internally |
| File (UTF-8) | parse_file |
| File (UTF-8 BOM) | Auto-stripped |

### Output Targets

| Target | Method |
|--------|--------|
| STRING_8 | as_json |
| STRING_32 | as_json_32 |
| Pretty STRING_32 | to_pretty_json |

## API Boundaries

### Public API

All features of:
- SIMPLE_JSON
- SIMPLE_JSON_QUICK
- SIMPLE_JSON_VALUE
- SIMPLE_JSON_OBJECT
- SIMPLE_JSON_ARRAY
- SIMPLE_JSON_PATCH

### Semi-Public API

- SIMPLE_JSON_CONSTANTS (inherited)
- SIMPLE_JSON_ERROR (returned, not created)
- SIMPLE_JSON_PATCH_RESULT (returned)

### Internal API

- JSON_* classes (underlying implementation)
- Conversion utilities
- Error extraction helpers

## Ecosystem Boundaries

### Uses

| Library | Purpose |
|---------|---------|
| EiffelStudio json | Parser engine |
| simple_zstring | UTF conversion |
| simple_encoding | BOM detection |
| simple_decimal | Precise numbers |

### Used By

| Library | Purpose |
|---------|---------|
| simple_http | API responses |
| simple_jwt | Token payloads |
| simple_k8s | K8s API |
| simple_logger | JSON logging |
| simple_config | Config files |
