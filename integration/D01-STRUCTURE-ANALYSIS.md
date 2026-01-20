# D01: Structure Analysis - simple_json

## Date: 2026-01-19
## Purpose: Map class structure for Eiffel-Loop library integration

## Baseline Status

- **Compiles:** YES (System Recompiled)
- **Tests:** 253 passed, 0 failed

## Summary

| Metric | Value |
|--------|-------|
| Total files | 30 |
| Total LOC | 7,150 |
| Max inheritance depth | 2 |
| Generic classes | 0 |
| Deferred classes | 1 (SIMPLE_JSON_PATCH_OPERATION) |

## Class Inventory

| Class | LOC | Features | Inherits | Purpose |
|-------|-----|----------|----------|---------|
| SIMPLE_JSON | 849 | ~40 | SIMPLE_JSON_CONSTANTS | Main facade |
| SIMPLE_JSON_OBJECT | 491 | ~30 | SIMPLE_JSON_VALUE | JSON object wrapper |
| SIMPLE_JSON_ARRAY | 296 | ~20 | SIMPLE_JSON_VALUE | JSON array wrapper |
| SIMPLE_JSON_VALUE | 357 | ~25 | ANY | JSON value wrapper |
| SIMPLE_JSON_ERROR | 193 | ~15 | ANY | Error with position |
| SIMPLE_JSON_CONSTANTS | 245 | ~30 | ANY | Constants |
| JSON_DECIMAL | 101 | ~10 | JSON_NUMBER | Decimal support |
| SIMPLE_JSON_SERIALIZABLE | 104 | ~5 | ANY | Serialization interface |
| **Patch Classes** | | | | |
| SIMPLE_JSON_PATCH | 242 | ~15 | ANY | RFC 6902 patch |
| SIMPLE_JSON_PATCH_OPERATION | 142 | ~10 | ANY | Deferred base |
| SIMPLE_JSON_PATCH_ADD | 198 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Add operation |
| SIMPLE_JSON_PATCH_REMOVE | 236 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Remove operation |
| SIMPLE_JSON_PATCH_REPLACE | 101 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Replace operation |
| SIMPLE_JSON_PATCH_TEST | 117 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Test operation |
| SIMPLE_JSON_PATCH_MOVE | 118 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Move operation |
| SIMPLE_JSON_PATCH_COPY | 104 | ~10 | SIMPLE_JSON_PATCH_OPERATION | Copy operation |
| SIMPLE_JSON_PATCH_RESULT | 111 | ~8 | ANY | Patch result |
| **Schema Classes** | | | | |
| SIMPLE_JSON_SCHEMA | 398 | ~20 | ANY | JSON Schema |
| SIMPLE_JSON_SCHEMA_VALIDATOR | 486 | ~25 | ANY | Schema validation |
| SIMPLE_JSON_SCHEMA_VALIDATION_RESULT | 108 | ~8 | ANY | Validation result |
| SIMPLE_JSON_SCHEMA_VALIDATION_ERROR | 61 | ~5 | ANY | Validation error |
| **Streaming Classes** | | | | |
| SIMPLE_JSON_STREAM | 241 | ~15 | ANY | Stream parser |
| SIMPLE_JSON_STREAM_CURSOR | 109 | ~8 | ANY | Stream cursor |
| SIMPLE_JSON_STREAM_ELEMENT | 70 | ~5 | ANY | Stream element |
| **Other Classes** | | | | |
| SIMPLE_JSON_POINTER | 224 | ~15 | ANY | RFC 6901 pointer |
| SIMPLE_JSON_MERGE_PATCH | 426 | ~20 | ANY | RFC 7396 merge patch |
| SIMPLE_JSON_MERGE_PATCH_RESULT | 107 | ~8 | ANY | Merge patch result |
| SIMPLE_JSON_PRETTY_PRINTER | 368 | ~15 | ANY | Pretty printing |
| SIMPLE_JSON_BUILDER | 220 | ~15 | ANY | Fluent builder |
| SIMPLE_JSON_QUICK | 327 | ~15 | SIMPLE_JSON | Quick facade |

## Inheritance Hierarchy

```
ANY
├── SIMPLE_JSON_CONSTANTS
│   └── SIMPLE_JSON
│       └── SIMPLE_JSON_QUICK
├── SIMPLE_JSON_VALUE
│   ├── SIMPLE_JSON_OBJECT
│   └── SIMPLE_JSON_ARRAY
├── SIMPLE_JSON_PATCH_OPERATION (deferred)
│   ├── SIMPLE_JSON_PATCH_ADD
│   ├── SIMPLE_JSON_PATCH_REMOVE
│   ├── SIMPLE_JSON_PATCH_REPLACE
│   ├── SIMPLE_JSON_PATCH_TEST
│   ├── SIMPLE_JSON_PATCH_MOVE
│   └── SIMPLE_JSON_PATCH_COPY
├── JSON_NUMBER
│   └── JSON_DECIMAL
└── (other classes inherit directly from ANY)
```

## Current Dependencies (ECF)

```xml
<library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
<library name="encoding" location="$ISE_LIBRARY\library\encoding\encoding.ecf"/>  <!-- UTF_CONVERTER -->
<library name="json" location="$ISE_LIBRARY\contrib\library\text\parser\json\library\json.ecf"/>
<library name="logging" location="$ISE_LIBRARY\library\runtime\logging\logging.ecf"/>
<library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
<library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/>
<library name="regexp" location="$GOBO_LIBRARY/regexp/library.ecf"/>
```

## Integration Targets

### UTF_CONVERTER Usage (Replace with simple_zstring/simple_encoding)

| File | Line | Usage |
|------|------|-------|
| simple_json.e | 46 | `utf_converter.utf_32_string_to_utf_8_string_8` |
| simple_json.e | 93 | `utf_converter.utf_8_string_8_to_string_32` |
| simple_json.e | 115 | `utf_converter.utf_32_string_to_utf_8_string_8` |
| simple_json.e | 462 | `utf_converter: UTF_CONVERTER` (once) |
| simple_json_value.e | 251 | `utf_converter.utf_8_string_8_to_string_32` |
| simple_json_value.e | 264 | `utf_converter.utf_8_string_8_to_string_32` |
| simple_json_value.e | 321 | `utf_converter: UTF_CONVERTER` (once) |
| simple_json_stream.e | 136 | `utf_converter.utf_8_string_8_to_string_32` |
| simple_json_stream.e | 202 | `utf_converter: UTF_CONVERTER` (once) |
| simple_json_pretty_printer.e | 251 | `utf_converter: UTF_CONVERTER` (once) |

**Total: 4 files, 10 usages**

### JSON String Escaping (Replace with SIMPLE_ZSTRING_ESCAPER)

| File | Line | Function |
|------|------|----------|
| simple_json_pretty_printer.e | 257 | `escape_json_string` (manual implementation) |

### JSONPath Parsing (Could use SIMPLE_ZSTRING_SPLITTER)

| File | Line | Function |
|------|------|----------|
| simple_json.e | 539 | `parse_json_path` - splits by `.` and `[]` |

## Integration Plan

### Phase 1: Add Dependencies

```xml
<library name="simple_encoding" location="$SIMPLE_EIFFEL/simple_encoding/simple_encoding.ecf"/>
<library name="simple_zstring" location="$SIMPLE_EIFFEL/simple_zstring/simple_zstring.ecf"/>
```

### Phase 2: Replace UTF_CONVERTER

Replace in 4 files:
- Use `SIMPLE_ZSTRING.make_from_utf_8` for UTF-8 → STRING_32
- Use `SIMPLE_ZSTRING.to_utf_8` for STRING_32 → UTF-8

### Phase 3: Replace escape_json_string

Replace manual implementation with `SIMPLE_ZSTRING_ESCAPER.escape_json`

### Phase 4: (Optional) Add Reflection-Based Serialization

Add new class `SIMPLE_JSON_SERIALIZER` using simple_reflection for auto-serialization.

## Verification Criteria

- [x] All 253 tests still pass after changes
- [x] No regressions in UTF-8 handling
- [x] Escaping behavior unchanged (escape_json_string kept manual impl for now)
- [ ] Memory usage comparable or better (not benchmarked yet)

## Completed Changes (2026-01-19)

### UTF_CONVERTER Replacement - COMPLETE

| File | Change |
|------|--------|
| simple_json.e | Replaced `utf_converter` with `string_32_to_utf_8` and `utf_8_to_string_32` helper functions using SIMPLE_ZSTRING |
| simple_json_value.e | Replaced `utf_converter` with `utf_8_to_string_32` helper function |
| simple_json_stream.e | Replaced `utf_converter` with `utf_8_to_string_32` helper function |
| simple_json_pretty_printer.e | Removed unused `utf_converter` feature |
| test_simple_json_stream.e | Replaced `utf_converter` with `string_32_to_utf_8` helper function |

### ECF Changes

- Added: `simple_zstring` library
- Removed: `encoding` library (no longer needed)

### Result

- **Compiles:** YES
- **Tests:** 253 passed, 0 failed
- **Dependencies reduced:** Removed ISE encoding library

## Next Step

→ D02-SMELL-DETECTION.md (or proceed directly to M01-AUDIT-CONTRACTS)
