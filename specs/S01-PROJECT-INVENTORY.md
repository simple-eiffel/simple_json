# S01: PROJECT INVENTORY - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Project Overview

| Attribute | Value |
|-----------|-------|
| Library Name | simple_json |
| Purpose | JSON parsing, building, and manipulation |
| Phase | Production |
| Void Safety | Full |
| SCOOP Ready | Yes |

## File Inventory

### Core Classes (src/core/)

| File | Purpose |
|------|---------|
| simple_json.e | Main facade with parsing and building |
| simple_json_value.e | JSON value wrapper |
| simple_json_object.e | JSON object wrapper with fluent API |
| simple_json_array.e | JSON array wrapper with fluent API |
| simple_json_error.e | Error with position information |
| simple_json_serializable.e | Serialization interface |
| json_decimal.e | Decimal number support |

### Patch Classes (src/patch/)

| File | Purpose |
|------|---------|
| simple_json_patch.e | JSON Patch document |
| simple_json_patch_operation.e | Base operation class |
| simple_json_patch_add.e | Add operation |
| simple_json_patch_remove.e | Remove operation |
| simple_json_patch_replace.e | Replace operation |
| simple_json_patch_move.e | Move operation |
| simple_json_patch_copy.e | Copy operation |
| simple_json_patch_test.e | Test operation |
| simple_json_patch_result.e | Operation result |

### Support Classes

| File | Path | Purpose |
|------|------|---------|
| simple_json_pointer.e | src/pointer/ | RFC 6901 JSON Pointer |
| simple_json_merge_patch.e | src/merge_patch/ | RFC 7396 Merge Patch |
| simple_json_schema*.e | src/schema/ | Schema validation |
| simple_json_stream*.e | src/streaming/ | Streaming parser |
| simple_json_pretty_printer.e | src/utilities/ | Pretty printing |
| simple_json_serializer.e | src/serialization/ | Object serialization |
| simple_json_quick.e | src/ | Quick API convenience |
| simple_json_builder.e | src/ | Builder utilities |

### Test Files (testing/)

| File | Purpose |
|------|---------|
| lib_tests.e | Main test suite |
| test_simple_json.e | Core JSON tests |
| test_simple_json_patch.e | Patch tests |
| test_json_schema_validation.e | Schema tests |
| adversarial_tests.e | Security tests |
| stress_tests.e | Performance tests |
