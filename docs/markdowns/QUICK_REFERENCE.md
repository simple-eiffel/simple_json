JSON Schema Validation - Quick Reference
=========================================

Files:
------
Core Classes:
- json_validation_error.e (1.4K) - Individual error representation
- json_validation_result.e (1.9K) - Result container with error collection
- json_schema.e (7.8K) - Schema definition and keyword access
- json_schema_validator.e (20K) - Main validation engine

Modified Classes:
- simple_json_object.e (13K) - Added item_at_key method
- simple_json_array.e (12K) - Added item_at method

Examples & Documentation:
- json_schema_examples.e (5.8K) - Usage examples
- JSON_SCHEMA_README.md (5.3K) - Complete guide
- IMPLEMENTATION_SUMMARY.md (4.2K) - Implementation overview

Basic Usage Pattern:
--------------------

```eiffel
-- 1. Create schema
local
	l_schema: JSON_SCHEMA
	l_validator: JSON_SCHEMA_VALIDATOR
	l_result: JSON_VALIDATION_RESULT
	l_instance: SIMPLE_JSON_VALUE
do
	create l_schema.make_from_string ("{%"type%": %"string%"}")
	
	-- 2. Create instance to validate
	create {SIMPLE_JSON_STRING} l_instance.make ("hello")
	
	-- 3. Validate
	create l_validator.make
	l_result := l_validator.validate (l_instance, l_schema)
	
	-- 4. Check result
	if l_result.is_valid then
		print ("Valid!%N")
	else
		print ("Invalid: " + l_result.error_message + "%N")
	end
end
```

Common Schema Patterns:
-----------------------

Type Validation:
```json
{"type": "string"}
{"type": "number"}
{"type": "integer"}
{"type": "boolean"}
{"type": "null"}
{"type": "object"}
{"type": "array"}
```

Numeric Ranges:
```json
{"type": "integer", "minimum": 0, "maximum": 100}
{"type": "number", "exclusiveMinimum": 0}
{"type": "number", "multipleOf": 0.01}
```

String Constraints:
```json
{"type": "string", "minLength": 1, "maxLength": 255}
{"type": "string", "pattern": "email"}
```

Enumerations:
```json
{"type": "string", "enum": ["red", "green", "blue"]}
{"enum": [1, 2, 3, "auto"]}
```

Object Validation:
```json
{
  "type": "object",
  "properties": {
    "name": {"type": "string"},
    "age": {"type": "integer", "minimum": 0}
  },
  "required": ["name"],
  "additionalProperties": false
}
```

Array Validation:
```json
{
  "type": "array",
  "items": {"type": "string"},
  "minItems": 1,
  "maxItems": 10,
  "uniqueItems": true
}
```

Logical Combinators:
```json
{"anyOf": [{"type": "string"}, {"type": "number"}]}
{"allOf": [{"type": "number"}, {"minimum": 0}]}
{"oneOf": [{"type": "string"}, {"type": "null"}]}
{"not": {"type": "null"}}
```

Error Handling:
---------------

```eiffel
l_result := l_validator.validate (l_instance, l_schema)

if not l_result.is_valid then
	-- Get error count
	print ("Found " + l_result.error_count.out + " errors:%N")
	
	-- Get all errors as formatted message
	print (l_result.error_message + "%N")
	
	-- Or iterate through individual errors
	across l_result.errors as ic loop
		print ("  Path: " + ic.item.path + "%N")
		print ("  Message: " + ic.item.message + "%N")
		if attached ic.item.keyword as al_keyword then
			print ("  Keyword: " + al_keyword + "%N")
		end
	end
end
```

Schema from Object:
-------------------

```eiffel
local
	l_parser: SIMPLE_JSON
	l_schema_obj: SIMPLE_JSON_OBJECT
	l_schema: JSON_SCHEMA
do
	create l_parser
	if attached l_parser.parse (a_schema_json_string) as al_obj then
		create l_schema.make_from_object (al_obj)
	end
end
```

Validating Parsed JSON:
------------------------

```eiffel
local
	l_parser: SIMPLE_JSON
	l_schema: JSON_SCHEMA
	l_validator: JSON_SCHEMA_VALIDATOR
	l_result: JSON_VALIDATION_RESULT
do
	-- Parse instance
	create l_parser
	if attached l_parser.parse (a_json_string) as al_obj then
		-- Create schema
		create l_schema.make_from_string (a_schema_string)
		
		-- Validate
		create l_validator.make
		l_result := l_validator.validate (al_obj, l_schema)
		
		-- Check result
		if l_result.is_valid then
			-- Process valid object
		else
			-- Handle errors
		end
	end
end
```

Testing Checklist:
------------------

□ Type validation for all types
□ Numeric constraints (min, max, multipleOf)
□ String constraints (length, pattern)
□ Array constraints (items, length, uniqueness)
□ Object constraints (properties, required, additional)
□ Enum validation
□ Const validation
□ AllOf combinator
□ AnyOf combinator
□ OneOf combinator
□ Not combinator
□ Nested objects
□ Nested arrays
□ Mixed nesting
□ Error message accuracy
□ Multiple simultaneous errors
□ Edge cases (empty, null, boundary values)

Notes:
------

1. Pattern matching is simplified (substring matching).
   For production, integrate PCRE for full regex support.

2. All validation errors are accumulated, not fail-fast.
   This provides comprehensive feedback to users.

3. Error paths use JSON Pointer format:
   "" = root
   "/name" = object property
   "/items/0" = first array element

4. Type "number" includes "integer" per JSON Schema spec.

5. Additional properties default to allowed unless
   explicitly set to false or a schema.
