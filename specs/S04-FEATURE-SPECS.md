# S04: FEATURE SPECIFICATIONS - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_JSON Features

### Parsing (8 aliases)

| Feature | Description |
|---------|-------------|
| parse | Parse JSON text to value |
| decode | Alias for parse |
| deserialize | Alias for parse |
| load_json | Alias for parse |
| from_string | Alias for parse |
| parse_response | Alias for parse |
| decode_payload | Alias for parse |
| parse_message | Alias for parse |

### File Operations (5 aliases)

| Feature | Description |
|---------|-------------|
| parse_file | Parse JSON from file |
| load_config | Alias for parse_file |
| read_json_file | Alias for parse_file |
| load_from_file | Alias for parse_file |
| deserialize_file | Alias for parse_file |

### Building (multiple aliases per type)

| Feature | Return Type |
|---------|-------------|
| new_object / create_object / empty_object / json_object / map / dictionary | SIMPLE_JSON_OBJECT |
| new_array / create_array / empty_array / json_array / list / collection | SIMPLE_JSON_ARRAY |
| string_value / text_value / str / json_string | SIMPLE_JSON_VALUE |
| number_value / float_value / real_value / double_value / json_number | SIMPLE_JSON_VALUE |
| integer_value / int_value / whole_number / json_integer | SIMPLE_JSON_VALUE |
| boolean_value / bool_value / flag_value / json_boolean | SIMPLE_JSON_VALUE |
| null_value / nothing_value / json_null | SIMPLE_JSON_VALUE |

### JSONPath Queries

| Feature | Return Type | Description |
|---------|-------------|-------------|
| query_string | detachable STRING_32 | Single string by path |
| query_integer | INTEGER_64 | Single integer by path |
| query_strings | ARRAYED_LIST[STRING_32] | Multiple strings |
| query_integers | ARRAYED_LIST[INTEGER_64] | Multiple integers |

### JSON Patch

| Feature | Return Type | Description |
|---------|-------------|-------------|
| create_patch | SIMPLE_JSON_PATCH | New empty patch |
| parse_patch | detachable SIMPLE_JSON_PATCH | Parse patch JSON |
| apply_patch | SIMPLE_JSON_PATCH_RESULT | Apply patch to doc |

## SIMPLE_JSON_OBJECT Features

### Access

| Feature | Return Type | Description |
|---------|-------------|-------------|
| item | detachable SIMPLE_JSON_VALUE | Get by key |
| string_item | detachable STRING_32 | Get string |
| integer_item | INTEGER_64 | Get integer (0 if missing) |
| real_item | DOUBLE | Get real (0.0 if missing) |
| decimal_item | detachable SIMPLE_DECIMAL | Get decimal |
| boolean_item | BOOLEAN | Get boolean |
| object_item | detachable SIMPLE_JSON_OBJECT | Get nested object |
| array_item | detachable SIMPLE_JSON_ARRAY | Get nested array |

### Fluent Mutation

| Feature | Return Type | Description |
|---------|-------------|-------------|
| put_string | SIMPLE_JSON_OBJECT | Add string (fluent) |
| put_integer | SIMPLE_JSON_OBJECT | Add integer (fluent) |
| put_real | SIMPLE_JSON_OBJECT | Add real (fluent) |
| put_decimal | SIMPLE_JSON_OBJECT | Add decimal (fluent) |
| put_boolean | SIMPLE_JSON_OBJECT | Add boolean (fluent) |
| put_null | SIMPLE_JSON_OBJECT | Add null (fluent) |
| put_object | SIMPLE_JSON_OBJECT | Add object (fluent) |
| put_array | SIMPLE_JSON_OBJECT | Add array (fluent) |
| put_value | SIMPLE_JSON_OBJECT | Add any value (fluent) |
