# D01: Structure Analysis - simple_json + simple_encoding Integration

## Date: 2026-01-20

## Summary

- Classes: 31
- Current dependencies: simple_zstring, simple_reflection (already integrated)
- Proposed addition: simple_encoding

## Current UTF-8 Handling

simple_json already uses SIMPLE_ZSTRING for UTF-8 conversion in 3 files:

| File | Feature | Line |
|------|---------|------|
| `simple_json.e` | `string_32_to_utf_8` | 462-468 |
| `simple_json.e` | `utf_8_to_string_32` | 471-477 |
| `simple_json_value.e` | `utf_8_to_string_32` | 321-326 |
| `simple_json_stream.e` | `utf_8_to_string_32` | 202-207 |

## What SIMPLE_ENCODING Adds

SIMPLE_ENCODING provides capabilities not in SIMPLE_ZSTRING:

1. **BOM Detection** - Detects UTF-8/UTF-16/UTF-32 BOMs
2. **Encoding Detection** - Heuristic detection with confidence
3. **Codec Registry** - Multiple charset support (ISO-8859-x, Windows-1252)

## Integration Opportunity

The `parse_file`/`deserialize_file` feature (simple_json.e:74-100) reads files assuming UTF-8.
Adding BOM detection would improve handling of JSON files exported from systems that add BOMs.

```eiffel
-- Current (line 93):
l_content := utf_8_to_string_32 (l_file.last_string)

-- Enhanced:
l_bytes := l_file.last_string
l_bytes := strip_bom_if_present (l_bytes)
l_content := utf_8_to_string_32 (l_bytes)
```

## Dependency Graph

```
simple_json
├── simple_zstring (UTF-8 conversion) ✅ INTEGRATED
├── simple_reflection (serialization) ✅ INTEGRATED
└── simple_encoding (BOM detection) ❌ NOT YET
```

## Class Inventory (Core)

| Class | LOC | Features | Purpose |
|-------|-----|----------|---------|
| SIMPLE_JSON | ~500 | 25 | Main API facade |
| SIMPLE_JSON_VALUE | ~340 | 20 | Value wrapper |
| SIMPLE_JSON_OBJECT | ~300 | 15 | Object wrapper |
| SIMPLE_JSON_ARRAY | ~250 | 12 | Array wrapper |
| SIMPLE_JSON_SERIALIZER | ~200 | 8 | Reflection-based serialization |

## Decision

**Proceed with integration**: Add SIMPLE_ENCODING for BOM detection in file parsing.

- Effort: Low (1 new helper feature)
- Benefit: Better file handling compatibility
- Risk: None (additive change)

## Next Step

→ D02-SMELL-DETECTION.md
