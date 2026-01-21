# MML Integration - simple_json

## Overview
Applied X03 Contract Assault with simple_mml on 2025-01-21.

## MML Classes Used
- `MML_MAP [STRING, SIMPLE_JSON_VALUE]` - Models JSON objects
- `MML_SEQUENCE [SIMPLE_JSON_VALUE]` - Models JSON arrays

## Model Queries Added
- `model_object: MML_MAP [STRING, SIMPLE_JSON_VALUE]` - Object fields
- `model_array: MML_SEQUENCE [SIMPLE_JSON_VALUE]` - Array elements

## Model-Based Postconditions
| Feature | Postcondition | Purpose |
|---------|---------------|---------|
| `put` | `field_set: model_object.item (a_key) = a_value` | Put sets field |
| `at` | `result_from_model: Result = model_object.item (a_key)` | At reads from model |
| `append` | `element_added: model_array.last = a_value` | Append adds to end |
| `item` | `result_from_model: Result = model_array.item (a_index)` | Item reads from model |
| `count` | `consistent_with_model: Result = model_array.count` | Count matches model |
| `has_key` | `definition: Result = model_object.domain [a_key]` | Has via model |
| `is_object` | `model_consistent: Result implies model_array.is_empty` | Type consistency |
| `is_array` | `model_consistent: Result implies model_object.is_empty` | Type consistency |

## Invariants Added
- `exclusive_type: not (is_object and is_array)` - Mutually exclusive types
- `keys_valid: across model_object.domain as k all not k.is_empty end` - No empty keys

## Bugs Found
None

## Test Results
- Compilation: SUCCESS
- Tests: All PASS (35+ postconditions added)
