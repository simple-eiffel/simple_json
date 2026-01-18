# simple_json Extracted Specifications

## S01: Baseline Verification

**Compilation**: SUCCESS (EiffelStudio 25.02.9.8732)
**Test Results**: 214 passed, 0 failed
**ECF Target**: simple_json_tests

---

## S02: ECF Configuration

```xml
Target: simple_json
UUID: C43DFE87-DAE3-4F85-8801-807151403E9F
Void Safety: all
SCOOP: thread (support=scoop)
Assertions: all enabled
```

### Dependencies
| Library | Source |
|---------|--------|
| base | $ISE_LIBRARY |
| decimal | $GOBO_LIBRARY (Gobo math) |
| encoder | EWF text encoder |
| encoding | ISE encoding |
| json | ISE contrib JSON parser |
| logging | ISE runtime logging |
| regexp | $GOBO_LIBRARY (Gobo PCRE) |
| simple_datetime | simple_* ecosystem |
| simple_decimal | simple_* ecosystem |

---

## S03: Architecture Overview

### Source Structure (30 files)

```
src/
├── constants/
│   └── simple_json_constants.e
├── core/
│   ├── json_decimal.e
│   ├── simple_json.e (Facade)
│   ├── simple_json_array.e
│   ├── simple_json_error.e
│   ├── simple_json_object.e
│   ├── simple_json_serializable.e
│   └── simple_json_value.e
├── merge_patch/ (RFC 7386)
│   ├── SIMPLE_JSON_MERGE_PATCH.e
│   └── SIMPLE_JSON_MERGE_PATCH_RESULT.e
├── patch/ (RFC 6902)
│   ├── simple_json_patch.e
│   ├── simple_json_patch_add.e
│   ├── simple_json_patch_copy.e
│   ├── simple_json_patch_move.e
│   ├── simple_json_patch_operation.e
│   ├── simple_json_patch_remove.e
│   ├── simple_json_patch_replace.e
│   ├── simple_json_patch_result.e
│   └── simple_json_patch_test.e
├── pointer/ (RFC 6901)
│   └── simple_json_pointer.e
├── schema/ (JSON Schema Draft 2020-12 subset)
│   ├── simple_json_schema.e
│   ├── simple_json_schema_validation_error.e
│   ├── simple_json_schema_validation_result.e
│   └── simple_json_schema_validator.e
├── streaming/
│   ├── simple_json_stream.e
│   ├── simple_json_stream_cursor.e
│   └── simple_json_stream_element.e
├── utilities/
│   └── simple_json_pretty_printer.e
├── simple_json_builder.e
└── simple_json_quick.e
```

---

## S04: Core Class Specifications

### SIMPLE_JSON (Facade)

**Purpose**: Main entry point for JSON operations with Unicode support.

**Features**:
- `parse/decode/deserialize/load_json/from_string/parse_response/decode_payload/parse_message (STRING_32): SIMPLE_JSON_VALUE` - Parse JSON
- `parse_file/load_config/read_json_file/load_from_file/deserialize_file (STRING_32): SIMPLE_JSON_VALUE` - Parse from file
- `is_valid_json (STRING_32): BOOLEAN` - Validate without creating object
- `new_object/create_object/empty_object/json_object/build_object/map/dictionary: SIMPLE_JSON_OBJECT` - Create object
- `new_array/create_array/empty_array/json_array/list/collection: SIMPLE_JSON_ARRAY` - Create array
- `string_value/text_value/str/json_string (STRING_32): SIMPLE_JSON_VALUE` - Create string
- `number_value/float_value/real_value/double_value/json_number (DOUBLE): SIMPLE_JSON_VALUE` - Create number
- `integer_value/int_value/whole_number/json_integer (INTEGER_64): SIMPLE_JSON_VALUE` - Create integer
- `boolean_value/bool_value/flag_value/json_boolean (BOOLEAN): SIMPLE_JSON_VALUE` - Create boolean
- `null_value/nothing_value/json_null: SIMPLE_JSON_VALUE` - Create null

**JSONPath Queries**:
- `query_string (SIMPLE_JSON_VALUE; STRING_32): STRING_32` - Query single string
- `query_integer (SIMPLE_JSON_VALUE; STRING_32): INTEGER_64` - Query single integer
- `query_strings (SIMPLE_JSON_VALUE; STRING_32): ARRAYED_LIST[STRING_32]` - Query multiple strings
- `query_integers (SIMPLE_JSON_VALUE; STRING_32): ARRAYED_LIST[INTEGER_64]` - Query multiple integers

**JSON Patch (RFC 6902)**:
- `create_patch: SIMPLE_JSON_PATCH` - Create empty patch
- `parse_patch (STRING_32): SIMPLE_JSON_PATCH` - Parse patch document
- `apply_patch (SIMPLE_JSON_VALUE; STRING_32): SIMPLE_JSON_PATCH_RESULT` - Apply patch

**Error Tracking**:
- `has_errors: BOOLEAN`
- `last_errors: ARRAYED_LIST[SIMPLE_JSON_ERROR]`
- `error_count: INTEGER`
- `first_error: SIMPLE_JSON_ERROR`
- `errors_as_string: STRING_32`
- `detailed_errors: STRING_32`
- `clear_errors`

**Contracts**:
```eiffel
invariant
    last_errors_attached: last_errors /= Void
    has_errors_definition: has_errors = not last_errors.is_empty
    error_count_definition: error_count = last_errors.count
    no_void_errors: across last_errors as ic_err all ic_err /= Void end
    has_errors_implies_first_error: has_errors implies first_error /= Void
    no_errors_implies_no_first_error: not has_errors implies first_error = Void
```

---

### SIMPLE_JSON_VALUE

**Purpose**: Wrapper around JSON_VALUE with Unicode/UTF-8 string access.

**Type Checking**:
- `is_string`, `is_number`, `is_integer`, `is_boolean`, `is_null`, `is_object`, `is_array`

**Accessors**:
- `as_string_32: STRING_32` (requires `is_string`)
- `as_integer: INTEGER_64` (requires `is_number`)
- `as_natural: NATURAL_64` (requires `is_number`)
- `as_real: DOUBLE` (requires `is_number`)
- `as_decimal: SIMPLE_DECIMAL` (requires `is_number`)
- `as_boolean: BOOLEAN` (requires `is_boolean`)
- `as_object: SIMPLE_JSON_OBJECT` (requires `is_object`)
- `as_array: SIMPLE_JSON_ARRAY` (requires `is_array`)

**Output**:
- `as_json: STRING` - JSON representation (STRING_8)
- `as_json_32: STRING_32` - JSON representation (STRING_32)
- `to_json_string: STRING_32`
- `to_pretty_json: STRING_32`
- `to_pretty_json_with_indent (STRING_32): STRING_32`
- `to_pretty_json_with_tabs: STRING_32`
- `to_pretty_json_with_spaces (INTEGER): STRING_32`

**Contracts**:
```eiffel
invariant
    json_value_attached: json_value /= Void
    valid_json_type: is_string or is_number or is_boolean or is_null or is_object or is_array
    string_excludes_others: is_string implies (not is_number and not is_boolean...)
    -- Type exclusivity for all 6 types
    string_type_accurate: is_string = (attached {JSON_STRING} json_value)
    -- Type accuracy for all 6 types
```

---

### SIMPLE_JSON_OBJECT

**Purpose**: JSON object with fluent API and Unicode keys.

**Access**:
- `count: INTEGER`
- `is_empty: BOOLEAN`
- `has_key (STRING_32): BOOLEAN`
- `item (STRING_32): SIMPLE_JSON_VALUE`
- `string_item (STRING_32): STRING_32`
- `integer_item (STRING_32): INTEGER_64`
- `integer_32_item (STRING_32): INTEGER_32` (convenience)
- `real_item (STRING_32): DOUBLE`
- `decimal_item (STRING_32): SIMPLE_DECIMAL`
- `boolean_item (STRING_32): BOOLEAN`
- `object_item (STRING_32): SIMPLE_JSON_OBJECT`
- `array_item (STRING_32): SIMPLE_JSON_ARRAY`

**Optional Access**:
- `optional_string (STRING_32): STRING_32`
- `optional_integer (STRING_32; INTEGER_64): INTEGER_64`
- `optional_boolean (STRING_32; BOOLEAN): BOOLEAN`

**Multi-Key Status**:
- `has_all_keys (ARRAY[STRING_32]): BOOLEAN`
- `has_any_key (ARRAY[STRING_32]): BOOLEAN`
- `missing_keys (ARRAY[STRING_32]): ARRAYED_LIST[STRING_32]`

**Fluent Modification**:
- `put_string (STRING_32; STRING_32): SIMPLE_JSON_OBJECT`
- `put_integer (INTEGER_64; STRING_32): SIMPLE_JSON_OBJECT`
- `put_real (DOUBLE; STRING_32): SIMPLE_JSON_OBJECT`
- `put_decimal (SIMPLE_DECIMAL; STRING_32): SIMPLE_JSON_OBJECT`
- `put_boolean (BOOLEAN; STRING_32): SIMPLE_JSON_OBJECT`
- `put_null (STRING_32): SIMPLE_JSON_OBJECT`
- `put_object (SIMPLE_JSON_OBJECT; STRING_32): SIMPLE_JSON_OBJECT`
- `put_array (SIMPLE_JSON_ARRAY; STRING_32): SIMPLE_JSON_OBJECT`
- `put_value (SIMPLE_JSON_VALUE; STRING_32): SIMPLE_JSON_OBJECT`

**Constants (DoS Protection)**:
- `Max_reasonable_key_length: INTEGER = 1024`
- `Max_reasonable_string_length: INTEGER = 10_000_000` (10MB)
- `Max_reasonable_object_size: INTEGER = 100_000`

**Contracts**:
```eiffel
invariant
    json_value_is_object: attached {JSON_OBJECT} json_value
    count_non_negative: count >= 0
    empty_definition: is_empty = (count = 0)
    keys_match_count: keys.count = count
    no_void_keys: across keys as ic_key all ic_key /= Void end
    no_empty_keys: across keys as ic_key all not ic_key.is_empty end
    every_key_exists: across keys as ic_key all has_key (ic_key) end
    every_key_has_value: across keys as ic_key all item (ic_key) /= Void end
```

---

## S05: RFC Implementation Specifications

### JSON Pointer (RFC 6901)

**Class**: `SIMPLE_JSON_POINTER`

**Path Format**: `/path/to/element` or `/array/0`

**Features**:
- `segments: ARRAYED_LIST[STRING_32]` - Path segments
- `last_segment: STRING_32` - Final segment
- `parse_path (STRING_32): BOOLEAN` - Parse pointer path
- `navigate (SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE` - Navigate to value
- `navigate_to_parent (SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE` - Navigate to parent

**Escape Sequences**:
- `~1` → `/` (slash)
- `~0` → `~` (tilde)

**Contracts**:
```eiffel
invariant
    segments_attached: segments /= Void
    no_void_segments: across segments as ic_seg all ic_seg /= Void end
    no_empty_segments: across segments as ic_seg all not ic_seg.is_empty end
```

---

### JSON Patch (RFC 6902)

**Class**: `SIMPLE_JSON_PATCH`

**Operations**: add, remove, replace, move, copy, test

**Building (Fluent)**:
- `add (STRING_32; SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH`
- `remove (STRING_32): SIMPLE_JSON_PATCH`
- `replace (STRING_32; SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH`
- `move (STRING_32; STRING_32): SIMPLE_JSON_PATCH`
- `copy_value (STRING_32; STRING_32): SIMPLE_JSON_PATCH`
- `test (STRING_32; SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH`

**Application**:
- `apply (SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT`
- Atomic execution: all-or-nothing semantics

**Contracts**:
```eiffel
invariant
    operations_attached: operations /= Void
    count_definition: count = operations.count
    is_empty_definition: is_empty = operations.is_empty
    no_void_operations: across operations as ic_op all ic_op /= Void end
    all_operations_valid: across operations as ic_op all ic_op.is_valid end
```

---

### JSON Merge Patch (RFC 7386)

**Class**: `SIMPLE_JSON_MERGE_PATCH`

**Semantics**:
- JSON document as patch format
- `null` means delete key
- Objects merged recursively
- Non-objects replace entirely
- Nulls in arrays preserved

**Features**:
- `make_from_json (SIMPLE_JSON_VALUE)` - From JSON
- `make_from_string (STRING)` - From string
- `apply (SIMPLE_JSON_VALUE): SIMPLE_JSON_MERGE_PATCH_RESULT` - Apply patch
- `is_valid: BOOLEAN`
- `has_errors: BOOLEAN`

**Contracts**:
```eiffel
invariant
    patch_document_attached: patch_document /= Void
    validation_errors_attached: validation_errors /= Void
    is_valid_definition: is_valid = not has_errors
    has_errors_definition: has_errors = not validation_errors.is_empty
    no_void_error_messages: across validation_errors as ic_err all ic_err /= Void end
```

---

## S06: JSON Schema Specification

**Class**: `SIMPLE_JSON_SCHEMA_VALIDATOR`

**Supported Keywords** (Draft 2020-12 subset):
| Keyword | Applies To | Validation |
|---------|------------|------------|
| `type` | All | string/number/integer/object/array/boolean/null |
| `properties` | Object | Nested schema for each property |
| `required` | Object | List of required property names |
| `minimum` | Number | Minimum value |
| `maximum` | Number | Maximum value |
| `minLength` | String | Minimum character count |
| `maxLength` | String | Maximum character count |
| `pattern` | String | PCRE regex pattern |
| `minItems` | Array | Minimum element count |
| `maxItems` | Array | Maximum element count |
| `items` | Array | Schema for array elements |

**Features**:
- `validate (SIMPLE_JSON_VALUE; SIMPLE_JSON_SCHEMA): SIMPLE_JSON_SCHEMA_VALIDATION_RESULT`

**Validation Result**:
- `is_valid: BOOLEAN`
- `errors: ARRAY[SIMPLE_JSON_SCHEMA_VALIDATION_ERROR]`

---

## S07: Error Tracking Specification

**Class**: `SIMPLE_JSON_ERROR`

**Features**:
- `message: STRING_32` - Error message
- `position: INTEGER` - Character position in source (0 = unknown)
- `line: INTEGER` - Line number (calculated)
- `column: INTEGER` - Column number (calculated)
- `has_position: BOOLEAN`
- `to_string_with_position: STRING_32`
- `to_detailed_string: STRING_32`

**Position Calculation**:
- Line/column calculated from source text and character position
- Supports error recovery with position tracking

---

## S08: Design Patterns

### Fluent Builder Pattern
All modification methods return `Current` for chaining:
```eiffel
l_json.new_object
    .put_string ("name", "Alice")
    .put_integer (30, "age")
    .put_boolean (True, "active")
```

### Facade Pattern
`SIMPLE_JSON` provides unified API hiding complexity:
- Parsing delegates to ISE JSON library
- UTF-8/Unicode conversion handled internally
- Error capture from underlying parser

### Command/Query Separation
- Queries: `is_*`, `as_*`, `has_*`, `item`, `count`
- Commands: `put_*`, `remove`, `wipe_out`, `apply`
- Fluent methods: Commands that return `Current` (documented exception)

### Null Safety
- All features use proper `detachable` annotations
- Preconditions protect against void dereferencing
- Invariants ensure data integrity

---

*Extraction completed: 2026-01-18*
*Source: simple_json v1.x, 30 source files, 214 tests*
