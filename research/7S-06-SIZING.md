# 7S-06: SIZING - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Implementation Size

### Core Classes

| Component | Lines | Classes |
|-----------|-------|---------|
| SIMPLE_JSON | ~876 | 1 |
| SIMPLE_JSON_VALUE | ~361 | 1 |
| SIMPLE_JSON_OBJECT | ~540 | 1 |
| SIMPLE_JSON_ARRAY | ~338 | 1 |
| SIMPLE_JSON_QUICK | ~200 | 1 |
| SIMPLE_JSON_BUILDER | ~150 | 1 |

### Patch Classes

| Component | Lines | Classes |
|-----------|-------|---------|
| SIMPLE_JSON_PATCH | ~150 | 1 |
| SIMPLE_JSON_PATCH_* (ops) | ~400 | 6 |
| SIMPLE_JSON_MERGE_PATCH | ~100 | 1 |
| SIMPLE_JSON_POINTER | ~150 | 1 |

### Support Classes

| Component | Lines | Classes |
|-----------|-------|---------|
| SIMPLE_JSON_ERROR | ~100 | 1 |
| SIMPLE_JSON_SCHEMA* | ~300 | 3 |
| SIMPLE_JSON_STREAM* | ~250 | 3 |
| SIMPLE_JSON_PRETTY_PRINTER | ~200 | 1 |
| SIMPLE_JSON_SERIALIZER | ~150 | 1 |

### Total

| Category | Classes | LOC |
|----------|---------|-----|
| Core | 6 | ~2,500 |
| Patch | 9 | ~800 |
| Support | 9 | ~1,000 |
| **Total** | **24** | **~4,300** |

### Testing

| Component | Lines | Classes |
|-----------|-------|---------|
| Test classes | ~2,000 | 15+ |
| Benchmark | ~200 | 2 |
| Adversarial | ~300 | 1 |
