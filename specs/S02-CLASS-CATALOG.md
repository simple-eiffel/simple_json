# S02: CLASS CATALOG - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Class Hierarchy

```
SIMPLE_JSON_SERIALIZABLE (deferred)

SIMPLE_JSON_VALUE
    |
    +-- SIMPLE_JSON_OBJECT
    |
    +-- SIMPLE_JSON_ARRAY

SIMPLE_JSON_PATCH_OPERATION (deferred)
    |
    +-- SIMPLE_JSON_PATCH_ADD
    +-- SIMPLE_JSON_PATCH_REMOVE
    +-- SIMPLE_JSON_PATCH_REPLACE
    +-- SIMPLE_JSON_PATCH_MOVE
    +-- SIMPLE_JSON_PATCH_COPY
    +-- SIMPLE_JSON_PATCH_TEST

SIMPLE_JSON (facade, inherits SIMPLE_JSON_CONSTANTS)
SIMPLE_JSON_QUICK (convenience, uses SIMPLE_JSON)
```

## Core Classes

### SIMPLE_JSON

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | Main facade for all operations |
| Pattern | Facade |
| LOC | ~876 |

### SIMPLE_JSON_VALUE

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | JSON value wrapper |
| Wraps | JSON_VALUE |
| LOC | ~361 |

### SIMPLE_JSON_OBJECT

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | Object with fluent API |
| Inherits | SIMPLE_JSON_VALUE |
| LOC | ~540 |

### SIMPLE_JSON_ARRAY

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | Array with fluent API |
| Inherits | SIMPLE_JSON_VALUE |
| LOC | ~338 |

## Class Metrics Summary

| Category | Classes | Total LOC |
|----------|---------|-----------|
| Core | 6 | ~2,500 |
| Patch | 9 | ~800 |
| Schema | 4 | ~400 |
| Streaming | 3 | ~250 |
| Utilities | 4 | ~350 |
| **Total** | **26** | **~4,300** |
