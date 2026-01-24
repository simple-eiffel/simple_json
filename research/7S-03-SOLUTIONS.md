# 7S-03: SOLUTIONS - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Existing Solutions Comparison

### EiffelStudio JSON Library

| Aspect | EiffelStudio JSON | simple_json |
|--------|-------------------|-------------|
| Void safety | Partial | Full |
| Unicode | STRING_8 focus | STRING_32 native |
| Fluent API | No | Yes |
| JSONPath | No | Yes |
| JSON Patch | No | Full RFC 6902 |
| Error tracking | Basic | Line/column position |
| Documentation | Limited | Contracts |

### Eiffel-Loop JSON

| Aspect | Eiffel-Loop | simple_json |
|--------|-------------|-------------|
| Void safety | None | Full |
| Streaming | Yes | Yes |
| Schema | No | Basic |
| Learning curve | Steep | Gentle |

### Direct JSON_* Classes

| Aspect | Direct Use | simple_json |
|--------|------------|-------------|
| Type safety | Low | High |
| Boilerplate | High | Low |
| Consistency | Manual | Automatic |

## Why simple_json?

1. **Void-safe wrappers**: Every value wrapped safely
2. **STRING_32 everywhere**: Native Unicode support
3. **Fluent building**: Natural JSON construction
4. **Error positions**: Debug JSON errors easily
5. **RFC compliance**: JSON Patch, Pointer, Merge Patch
6. **Decimal support**: Precise financial numbers
7. **Strong contracts**: Self-documenting API

## Architecture Choice

Wrapper architecture over EiffelStudio JSON:
- Leverages battle-tested parsing
- Adds void-safe wrappers
- Extends with query/patch capabilities
- Maintains compatibility
