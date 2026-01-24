# S05: CONSTRAINTS - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Size Constraints

### String Limits

| Constant | Value | Purpose |
|----------|-------|---------|
| Max_reasonable_key_length | 1,024 | Key length limit |
| Max_reasonable_string_length | 10,000,000 | 10MB string limit |

### Container Limits

| Constant | Value | Purpose |
|----------|-------|---------|
| Max_reasonable_object_size | 100,000 | Property count |
| Max_reasonable_array_size | 1,000,000 | Element count |

### Internal Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| Position_prefix_length | 11 | Error parsing |
| Substring_skip_first_char | 2 | Path parsing |
| Substring_skip_first_two_chars | 3 | Path parsing |
| Default_path_segments_capacity | 8 | JSONPath parsing |

## Type Constraints

### Value Type Exclusivity

- A value is exactly ONE of: string, number, boolean, null, object, array
- Type queries are mutually exclusive
- Enforced via invariant

### Number Representation

| Type | Precision | Use Case |
|------|-----------|----------|
| INTEGER_64 | Exact integers | Counts, IDs |
| DOUBLE | ~15 digits | General numbers |
| SIMPLE_DECIMAL | Arbitrary | Financial data |

## JSONPath Constraints

### Supported Syntax

| Pattern | Example | Supported |
|---------|---------|-----------|
| Root | $ | Yes |
| Property | $.name | Yes |
| Nested | $.a.b.c | Yes |
| Array index | $.arr[0] | Yes |
| Wildcard | $.arr[*] | Yes |

### Not Supported

- Filter expressions: $[?(@.price<10)]
- Recursive descent: $..name
- Slice: $[0:5]
- Multiple indices: $[0,1,2]

## Character Encoding Constraints

- Input: UTF-8 encoded STRING_8 or STRING_32
- Output: STRING_32 for values, STRING_8 for JSON text
- BOM: Automatically stripped on file read
