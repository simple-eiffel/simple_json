JSON Schema Validation Implementation
======================================

This implementation adds JSON Schema Draft-07 validation support to SIMPLE_JSON.

Files Created:
--------------
1. json_validation_error.e - Represents individual validation errors
2. json_validation_result.e - Contains validation results and error collection
3. json_schema.e - Represents a JSON Schema definition
4. json_schema_validator.e - Performs validation against schemas

Required Changes to Existing Classes:
--------------------------------------

### SIMPLE_JSON_OBJECT

Add the following method to the "Access" feature section (after the `object` method):

```eiffel
	item_at_key (a_key: STRING): detachable SIMPLE_JSON_VALUE
			-- Get value for key wrapped in appropriate SIMPLE_JSON_VALUE type
		require
			not_empty_key: not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				Result := wrap_json_value (l_value)
			end
		end
```

### SIMPLE_JSON_ARRAY

Add the following method to the "Access - Nested Structures" feature section (after `array_at`):

```eiffel
	item_at (a_index: INTEGER): detachable SIMPLE_JSON_VALUE
			-- Get value at index wrapped in appropriate SIMPLE_JSON_VALUE type
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				Result := wrap_json_value (l_value)
			end
		end
```

Usage Examples:
---------------

### Basic Validation

```eiffel
local
	l_validator: JSON_SCHEMA_VALIDATOR
	l_schema: JSON_SCHEMA
	l_instance: SIMPLE_JSON_VALUE
	l_result: JSON_VALIDATION_RESULT
	l_parser: SIMPLE_JSON
do
	-- Create schema
	create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 3}")
	
	-- Parse instance
	create l_parser
	if attached l_parser.parse ("{%"value%": %"hello%"}") as al_obj then
		if attached al_obj.item_at_key ("value") as al_value then
			-- Validate
			create l_validator.make
			l_result := l_validator.validate (al_value, l_schema)
			
			if l_result.is_valid then
				print ("Valid!%N")
			else
				print ("Invalid: " + l_result.error_message + "%N")
			end
		end
	end
end
```

### Object Validation with Properties

```eiffel
local
	l_schema_str: STRING
do
	l_schema_str := "[
		{
			"type": "object",
			"properties": {
				"name": {"type": "string", "minLength": 1},
				"age": {"type": "integer", "minimum": 0, "maximum": 150}
			},
			"required": ["name", "age"],
			"additionalProperties": false
		}
	]"
	
	create l_schema.make_from_string (l_schema_str)
	-- ... validate object instance
end
```

### Array Validation

```eiffel
local
	l_schema_str: STRING
do
	l_schema_str := "[
		{
			"type": "array",
			"items": {"type": "number"},
			"minItems": 1,
			"maxItems": 10,
			"uniqueItems": true
		}
	]"
	
	create l_schema.make_from_string (l_schema_str)
	-- ... validate array instance
end
```

### Logical Combinators (anyOf/allOf/oneOf)

```eiffel
local
	l_schema_str: STRING
do
	l_schema_str := "[
		{
			"anyOf": [
				{"type": "string"},
				{"type": "number"}
			]
		}
	]"
	
	create l_schema.make_from_string (l_schema_str)
	-- ... validate instance (passes if string OR number)
end
```

Supported JSON Schema Keywords:
--------------------------------

### Type Validation
- type - Validates the JSON type
- enum - Value must be one of the specified values
- const - Value must match exactly

### Numeric Constraints
- multipleOf - Number must be multiple of value
- maximum - Maximum value (inclusive)
- exclusiveMaximum - Maximum value (exclusive)
- minimum - Minimum value (inclusive)
- exclusiveMinimum - Minimum value (exclusive)

### String Constraints
- maxLength - Maximum string length
- minLength - Minimum string length
- pattern - Regular expression pattern (simplified matching)

### Array Constraints
- items - Schema for array items
- maxItems - Maximum array length
- minItems - Minimum array length
- uniqueItems - All items must be unique
- contains - At least one item must match schema

### Object Constraints
- properties - Schemas for specific properties
- required - Array of required property names
- maxProperties - Maximum number of properties
- minProperties - Minimum number of properties
- additionalProperties - Allow/forbid or validate additional properties

### Logical Combinators
- allOf - Instance must validate against ALL schemas
- anyOf - Instance must validate against AT LEAST ONE schema
- oneOf - Instance must validate against EXACTLY ONE schema
- not - Instance must NOT validate against schema

Notes:
------

1. Pattern matching is simplified - uses substring matching rather than full regex.
   For production use, integrate a proper regex library like PCRE.

2. This implementation focuses on the core validation keywords from Draft-07.
   Additional keywords like format, contentMediaType, etc. can be added as needed.

3. Error messages include the JSON path where validation failed (e.g., "/properties/age")
   and the specific keyword that failed.

4. The validator is designed to accumulate all errors rather than failing fast,
   providing comprehensive validation feedback.

Testing:
--------

Create test classes following the existing test pattern to cover:
- Each validation keyword
- Edge cases (empty arrays, null values, etc.)
- Nested objects and arrays
- Logical combinators
- Error message accuracy

Ensure 100% test coverage is maintained.
