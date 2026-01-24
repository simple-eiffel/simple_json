# S03: CONTRACTS - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_JSON Contracts

### Parsing Contracts

```eiffel
parse (a_json_text: STRING_32): detachable SIMPLE_JSON_VALUE
    require
        not_empty: not a_json_text.is_empty
    ensure
        errors_cleared_on_success: Result /= Void implies not has_errors

is_valid_json (a_json_text: STRING_32): BOOLEAN
    require
        not_empty: not a_json_text.is_empty
    ensure
        valid_implies_no_errors: Result implies not has_errors
```

### Error Query Contracts

```eiffel
has_errors: BOOLEAN
    ensure
        definition: Result = not last_errors.is_empty

first_error: detachable SIMPLE_JSON_ERROR
    ensure
        has_error_implies_result: has_errors implies Result /= Void
        no_error_implies_void: not has_errors implies Result = Void
```

## SIMPLE_JSON_OBJECT Contracts

### Access Contracts

```eiffel
item (a_key: STRING_32): detachable SIMPLE_JSON_VALUE
    require
        key_not_empty: not a_key.is_empty
        key_reasonable_length: a_key.count <= Max_reasonable_key_length

has_key (a_key: STRING_32): BOOLEAN
    require
        key_not_empty: not a_key.is_empty
        key_reasonable_length: a_key.count <= Max_reasonable_key_length
```

### Fluent API Contracts

```eiffel
put_string (a_value: STRING_32; a_key: STRING_32): SIMPLE_JSON_OBJECT
    require
        key_not_empty: not a_key.is_empty
        key_reasonable_length: a_key.count <= Max_reasonable_key_length
        value_reasonable_length: a_value.count <= Max_reasonable_string_length
    ensure
        result_is_current: Result = Current
        key_exists: has_key (a_key)
        value_stored: attached string_item (a_key) as l implies l.same_string (a_value)
```

## SIMPLE_JSON_VALUE Invariants

```eiffel
invariant
    json_value_attached: json_value /= Void
    valid_json_type: is_string or is_number or is_boolean or
                     is_null or is_object or is_array
    string_excludes_others: is_string implies
        (not is_number and not is_boolean and not is_null and
         not is_object and not is_array)
    -- Similar for all types (mutual exclusion)
```

## SIMPLE_JSON_OBJECT Invariants

```eiffel
invariant
    json_value_is_object: attached {JSON_OBJECT} json_value
    count_non_negative: count >= 0
    empty_definition: is_empty = (count = 0)
    keys_match_count: keys.count = count
    no_void_keys: across keys as k all k /= Void end
    no_empty_keys: across keys as k all not k.is_empty end
    every_key_exists: across keys as k all has_key (k) end
    every_key_has_value: across keys as k all item (k) /= Void end
```
