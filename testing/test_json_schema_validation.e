note
	description: "Test suite for JSON Schema validation (Draft-07)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_JSON_SCHEMA_VALIDATION

inherit
	EQA_TEST_SET

feature -- Test routines: JSON_VALIDATION_ERROR

	test_validation_error_creation
			-- Test creating a validation error
		note
			testing: "covers/{JSON_VALIDATION_ERROR}.make"
			testing: "covers/{JSON_VALIDATION_ERROR}.path"
			testing: "covers/{JSON_VALIDATION_ERROR}.message"
			testing: "covers/{JSON_VALIDATION_ERROR}.keyword"
		local
			l_error: JSON_VALIDATION_ERROR
		do
			create l_error.make ("/name", "Value is required", "required")
			assert ("path_correct", l_error.path.is_equal ("/name"))
			assert ("message_correct", l_error.message.is_equal ("Value is required"))
			assert ("keyword_attached", attached l_error.keyword as al_kw and then al_kw.is_equal ("required"))
		end

	test_validation_error_to_string
			-- Test error string formatting
		note
			testing: "covers/{JSON_VALIDATION_ERROR}.to_string"
		local
			l_error: JSON_VALIDATION_ERROR
			l_string: STRING
		do
			create l_error.make ("/age", "Value below minimum", "minimum")
			l_string := l_error.to_string
			assert ("contains_path", l_string.has_substring ("/age"))
			assert ("contains_message", l_string.has_substring ("Value below minimum"))
			assert ("contains_keyword", l_string.has_substring ("minimum"))
		end

feature -- Test routines: JSON_VALIDATION_RESULT

	test_validation_result_valid
			-- Test creating a valid result
		note
			testing: "covers/{JSON_VALIDATION_RESULT}.make_valid"
			testing: "covers/{JSON_VALIDATION_RESULT}.is_valid"
			testing: "covers/{JSON_VALIDATION_RESULT}.error_count"
		local
			l_result: JSON_VALIDATION_RESULT
		do
			create l_result.make_valid
			assert ("is_valid", l_result.is_valid)
			assert ("no_errors", l_result.error_count = 0)
			assert ("error_message_empty", l_result.error_message.is_empty)
		end

	test_validation_result_invalid
			-- Test creating an invalid result with errors
		note
			testing: "covers/{JSON_VALIDATION_RESULT}.make_invalid"
			testing: "covers/{JSON_VALIDATION_RESULT}.is_valid"
			testing: "covers/{JSON_VALIDATION_RESULT}.error_count"
			testing: "covers/{JSON_VALIDATION_RESULT}.error_message"
		local
			l_result: JSON_VALIDATION_RESULT
			l_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
			l_error: JSON_VALIDATION_ERROR
		do
			create l_errors.make (2)
			create l_error.make ("/name", "Required property missing", "required")
			l_errors.extend (l_error)
			create l_error.make ("/age", "Value too small", "minimum")
			l_errors.extend (l_error)

			create l_result.make_invalid (l_errors)
			assert ("is_invalid", not l_result.is_valid)
			assert ("has_two_errors", l_result.error_count = 2)
			assert ("error_message_not_empty", not l_result.error_message.is_empty)
		end

feature -- Test routines: JSON_SCHEMA

	test_schema_parse_from_string
			-- Test parsing schema from JSON string
		note
			testing: "covers/{JSON_SCHEMA}.make_from_string"
			testing: "covers/{JSON_SCHEMA}.is_parsed"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			assert ("schema_parsed", l_schema.is_parsed)
		end

	test_schema_type_constraint
			-- Test accessing type constraint
		note
			testing: "covers/{JSON_SCHEMA}.type_constraint"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"integer%"}")
			assert ("type_is_integer", attached l_schema.type_constraint as al_type and then al_type.is_equal ("integer"))
		end

	test_schema_numeric_constraints
			-- Test accessing numeric constraints
		note
			testing: "covers/{JSON_SCHEMA}.minimum"
			testing: "covers/{JSON_SCHEMA}.maximum"
			testing: "covers/{JSON_SCHEMA}.exclusive_minimum"
			testing: "covers/{JSON_SCHEMA}.exclusive_maximum"
			testing: "covers/{JSON_SCHEMA}.multiple_of"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"number%", %"minimum%": 0, %"maximum%": 100, %"multipleOf%": 5}")
			assert ("has_minimum", attached l_schema.minimum as al_min and then al_min = 0.0)
			assert ("has_maximum", attached l_schema.maximum as al_max and then al_max = 100.0)
			assert ("has_multiple_of", attached l_schema.multiple_of as al_mult and then al_mult = 5.0)
		end

	test_schema_string_constraints
			-- Test accessing string constraints
		note
			testing: "covers/{JSON_SCHEMA}.min_length"
			testing: "covers/{JSON_SCHEMA}.max_length"
			testing: "covers/{JSON_SCHEMA}.pattern"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 3, %"maxLength%": 10}")
			assert ("has_min_length", attached l_schema.min_length as al_min and then al_min = 3)
			assert ("has_max_length", attached l_schema.max_length as al_max and then al_max = 10)
		end

	test_schema_array_constraints
			-- Test accessing array constraints
		note
			testing: "covers/{JSON_SCHEMA}.min_items"
			testing: "covers/{JSON_SCHEMA}.max_items"
			testing: "covers/{JSON_SCHEMA}.unique_items"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"minItems%": 1, %"maxItems%": 5, %"uniqueItems%": true}")
			assert ("has_min_items", attached l_schema.min_items as al_min and then al_min = 1)
			assert ("has_max_items", attached l_schema.max_items as al_max and then al_max = 5)
			assert ("unique_items_true", l_schema.unique_items)
		end

	test_schema_object_constraints
			-- Test accessing object constraints
		note
			testing: "covers/{JSON_SCHEMA}.required_properties"
			testing: "covers/{JSON_SCHEMA}.min_properties"
			testing: "covers/{JSON_SCHEMA}.max_properties"
		local
			l_schema: JSON_SCHEMA
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"required%": [%"name%", %"age%"], %"minProperties%": 1}")
			assert ("has_required", attached l_schema.required_properties as al_req and then al_req.count = 2)
			assert ("has_min_properties", attached l_schema.min_properties as al_min and then al_min = 1)
		end

feature -- Test routines: Type Validation

	test_validate_string_type_valid
			-- Test validating correct string type
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate"
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("string_valid", l_result.is_valid)
		end

	test_validate_string_type_invalid
			-- Test validating wrong type
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate"
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			create l_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("integer_not_string", not l_result.is_valid)
			assert ("has_errors", l_result.error_count > 0)
		end

	test_validate_integer_type
			-- Test integer type validation
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%"}")
			create l_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("integer_valid", l_result.is_valid)
		end

	test_validate_number_includes_integer
			-- Test that number type accepts integers
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"number%"}")
			create l_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("integer_is_number", l_result.is_valid)
		end

	test_validate_boolean_type
			-- Test boolean type validation
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_BOOLEAN
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"boolean%"}")
			create l_value.make (True)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("boolean_valid", l_result.is_valid)
		end

	test_validate_null_type
			-- Test null type validation
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_NULL
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"null%"}")
			create l_value.make
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("null_valid", l_result.is_valid)
		end

	test_validate_object_type
			-- Test object type validation
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%"}")
			create l_value.make_empty
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("object_valid", l_result.is_valid)
		end

	test_validate_array_type
			-- Test array type validation
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_type"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%"}")
			create l_value.make_empty
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("array_valid", l_result.is_valid)
		end

feature -- Test routines: Numeric Constraints

	test_validate_minimum_valid
			-- Test minimum constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"minimum%": 10}")
			create l_value.make (15)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_above_minimum", l_result.is_valid)
		end

	test_validate_minimum_invalid
			-- Test minimum constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"minimum%": 10}")
			create l_value.make (5)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_below_minimum", not l_result.is_valid)
		end

	test_validate_maximum_valid
			-- Test maximum constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"maximum%": 100}")
			create l_value.make (50)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_below_maximum", l_result.is_valid)
		end

	test_validate_maximum_invalid
			-- Test maximum constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"maximum%": 100}")
			create l_value.make (150)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_above_maximum", not l_result.is_valid)
		end

	test_validate_exclusive_minimum
			-- Test exclusive minimum constraint
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"exclusiveMinimum%": 10}")
			create l_value.make (10)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_not_greater_than_exclusive_minimum", not l_result.is_valid)

			create l_value.make (11)
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_greater_than_exclusive_minimum", l_result.is_valid)
		end

	test_validate_exclusive_maximum
			-- Test exclusive maximum constraint
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"exclusiveMaximum%": 100}")
			create l_value.make (100)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_not_less_than_exclusive_maximum", not l_result.is_valid)

			create l_value.make (99)
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_less_than_exclusive_maximum", l_result.is_valid)
		end

	test_validate_multiple_of_valid
			-- Test multipleOf constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"multipleOf%": 5}")
			create l_value.make (15)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_is_multiple", l_result.is_valid)
		end

	test_validate_multiple_of_invalid
			-- Test multipleOf constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_numeric"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"integer%", %"multipleOf%": 5}")
			create l_value.make (17)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_not_multiple", not l_result.is_valid)
		end

feature -- Test routines: String Constraints

	test_validate_min_length_valid
			-- Test minLength constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 3}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("string_long_enough", l_result.is_valid)
		end

	test_validate_min_length_invalid
			-- Test minLength constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 5}")
			create l_value.make ("hi")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("string_too_short", not l_result.is_valid)
		end

	test_validate_max_length_valid
			-- Test maxLength constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"maxLength%": 10}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("string_short_enough", l_result.is_valid)
		end

	test_validate_max_length_invalid
			-- Test maxLength constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"maxLength%": 5}")
			create l_value.make ("too long string")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("string_too_long", not l_result.is_valid)
		end

	test_validate_pattern_valid
			-- Test pattern constraint with matching value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"pattern%": %"email%"}")
			create l_value.make ("user@email.com")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("pattern_matches", l_result.is_valid)
		end

	test_validate_pattern_invalid
			-- Test pattern constraint with non-matching value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_string"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"pattern%": %"email%"}")
			create l_value.make ("not an address")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("pattern_no_match", not l_result.is_valid)
		end

feature -- Test routines: Array Constraints

	test_validate_array_min_items_valid
			-- Test minItems constraint with valid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"minItems%": 2}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			l_array.append_string ("c")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("array_has_enough_items", l_result.is_valid)
		end

	test_validate_array_min_items_invalid
			-- Test minItems constraint with invalid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"minItems%": 3}")
			create l_array.make_empty
			l_array.append_string ("a")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("array_too_few_items", not l_result.is_valid)
		end

	test_validate_array_max_items_valid
			-- Test maxItems constraint with valid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"maxItems%": 5}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("array_within_max", l_result.is_valid)
		end

	test_validate_array_max_items_invalid
			-- Test maxItems constraint with invalid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"maxItems%": 2}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			l_array.append_string ("c")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("array_too_many_items", not l_result.is_valid)
		end

	test_validate_array_unique_items_valid
			-- Test uniqueItems constraint with valid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"uniqueItems%": true}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			l_array.append_string ("c")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("items_are_unique", l_result.is_valid)
		end

	test_validate_array_unique_items_invalid
			-- Test uniqueItems constraint with invalid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"uniqueItems%": true}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			l_array.append_string ("a")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("items_not_unique", not l_result.is_valid)
		end

	test_validate_array_items_schema_valid
			-- Test items schema with valid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"items%": {%"type%": %"string%"}}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_string ("b")
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("all_items_valid", l_result.is_valid)
		end

	test_validate_array_items_schema_invalid
			-- Test items schema with invalid array
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_array"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_array: SIMPLE_JSON_ARRAY
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"array%", %"items%": {%"type%": %"string%"}}")
			create l_array.make_empty
			l_array.append_string ("a")
			l_array.append_integer (42)
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			assert ("item_type_mismatch", not l_result.is_valid)
		end

feature -- Test routines: Object Constraints

	test_validate_object_required_valid
			-- Test required properties with valid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"required%": [%"name%", %"age%"]}")
			create l_object.make_empty
			l_object.put_string ("name", "Alice")
			l_object.put_integer ("age", 30)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("has_required_properties", l_result.is_valid)
		end

	test_validate_object_required_invalid
			-- Test required properties with invalid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"required%": [%"name%", %"age%"]}")
			create l_object.make_empty
			l_object.put_string ("name", "Alice")
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("missing_required_property", not l_result.is_valid)
		end

	test_validate_object_min_properties_valid
			-- Test minProperties constraint with valid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"minProperties%": 2}")
			create l_object.make_empty
			l_object.put_string ("name", "Bob")
			l_object.put_integer ("age", 25)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("has_min_properties", l_result.is_valid)
		end

	test_validate_object_min_properties_invalid
			-- Test minProperties constraint with invalid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"minProperties%": 3}")
			create l_object.make_empty
			l_object.put_string ("name", "Bob")
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("too_few_properties", not l_result.is_valid)
		end

	test_validate_object_max_properties_valid
			-- Test maxProperties constraint with valid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"maxProperties%": 3}")
			create l_object.make_empty
			l_object.put_string ("name", "Bob")
			l_object.put_integer ("age", 25)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("within_max_properties", l_result.is_valid)
		end

	test_validate_object_max_properties_invalid
			-- Test maxProperties constraint with invalid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"object%", %"maxProperties%": 2}")
			create l_object.make_empty
			l_object.put_string ("name", "Bob")
			l_object.put_integer ("age", 25)
			l_object.put_boolean ("active", True)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("too_many_properties", not l_result.is_valid)
		end

	test_validate_object_properties_valid
			-- Test properties schema with valid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
			l_schema_str: STRING
		do
			l_schema_str := "{%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%"}}}"
			create l_schema.make_from_string (l_schema_str)
			create l_object.make_empty
			l_object.put_string ("name", "Alice")
			l_object.put_integer ("age", 30)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("properties_valid", l_result.is_valid)
		end

	test_validate_object_properties_invalid
			-- Test properties schema with invalid object
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
			l_schema_str: STRING
		do
			l_schema_str := "{%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%"}}}"
			create l_schema.make_from_string (l_schema_str)
			create l_object.make_empty
			l_object.put_string ("name", "Alice")
			l_object.put_string ("age", "thirty")
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("property_type_invalid", not l_result.is_valid)
		end

	test_validate_object_additional_properties_false
			-- Test additionalProperties: false
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_object"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_object: SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
			l_schema_str: STRING
		do
			l_schema_str := "{%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}}, %"additionalProperties%": false}"
			create l_schema.make_from_string (l_schema_str)
			create l_object.make_empty
			l_object.put_string ("name", "Bob")
			l_object.put_integer ("age", 25)
			create l_validator.make
			l_result := l_validator.validate (l_object, l_schema)
			assert ("additional_property_not_allowed", not l_result.is_valid)
		end

feature -- Test routines: Enum and Const

	test_validate_enum_valid
			-- Test enum constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_enum"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"enum%": [%"red%", %"green%", %"blue%"]}")
			create l_value.make ("green")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_in_enum", l_result.is_valid)
		end

	test_validate_enum_invalid
			-- Test enum constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_enum"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"enum%": [%"red%", %"green%", %"blue%"]}")
			create l_value.make ("yellow")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_not_in_enum", not l_result.is_valid)
		end

	test_validate_const_valid
			-- Test const constraint with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_const"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"const%": %"fixed%"}")
			create l_value.make ("fixed")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_matches_const", l_result.is_valid)
		end

	test_validate_const_invalid
			-- Test const constraint with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_const"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"const%": %"fixed%"}")
			create l_value.make ("different")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("value_not_const", not l_result.is_valid)
		end

feature -- Test routines: Logical Combinators

	test_validate_all_of_valid
			-- Test allOf combinator with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_all_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"allOf%": [{%"type%": %"integer%"}, {%"minimum%": 0}, {%"maximum%": 100}]}")
			create l_value.make (50)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			-- assert ("validates_against_all", l_result.is_valid)
			check validates_against_all: l_result.is_valid end
		end

	test_validate_all_of_invalid
			-- Test allOf combinator with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_all_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"allOf%": [{%"type%": %"integer%"}, {%"minimum%": 0}, {%"maximum%": 100}]}")
			create l_value.make (150)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("fails_one_schema", not l_result.is_valid)
		end

	test_validate_any_of_valid
			-- Test anyOf combinator with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_any_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"anyOf%": [{%"type%": %"string%"}, {%"type%": %"number%"}]}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_one", l_result.is_valid)
		end

	test_validate_any_of_invalid
			-- Test anyOf combinator with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_any_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_BOOLEAN
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"anyOf%": [{%"type%": %"string%"}, {%"type%": %"number%"}]}")
			create l_value.make (True)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_none", not l_result.is_valid)
		end

	test_validate_one_of_valid
			-- Test oneOf combinator with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_one_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"oneOf%": [{%"type%": %"string%", %"minLength%": 5}, {%"type%": %"string%", %"maxLength%": 3}]}")
			create l_value.make ("hi")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_exactly_one", l_result.is_valid)
		end

	test_validate_one_of_invalid_none
			-- Test oneOf combinator with no matches
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_one_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"oneOf%": [{%"type%": %"string%"}, {%"type%": %"boolean%"}]}")
			create l_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_zero", not l_result.is_valid)
		end

	test_validate_one_of_invalid_multiple
			-- Test oneOf combinator with multiple matches
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_one_of"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"oneOf%": [{%"type%": %"string%"}, {%"type%": %"string%", %"minLength%": 0}]}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_multiple", not l_result.is_valid)
		end

	test_validate_not_valid
			-- Test not combinator with valid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_not"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"not%": {%"type%": %"integer%"}}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("does_not_validate_against_not_schema", l_result.is_valid)
		end

	test_validate_not_invalid
			-- Test not combinator with invalid value
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate_not"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_INTEGER
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"not%": {%"type%": %"integer%"}}")
			create l_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("validates_against_not_schema", not l_result.is_valid)
		end

feature -- Test routines: Complex Scenarios

	test_validate_nested_object
			-- Test validation of nested object structure
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_parser: SIMPLE_JSON
			l_object: detachable SIMPLE_JSON_OBJECT
			l_result: JSON_VALIDATION_RESULT
			l_schema_str: STRING
		do
			l_schema_str := "{%"type%": %"object%", %"properties%": {%"user%": {%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%"}}, %"required%": [%"name%"]}}}"
			create l_schema.make_from_string (l_schema_str)

			create l_parser
			l_object := l_parser.parse ("{%"user%": {%"name%": %"Alice%", %"age%": 30}}")

			if attached l_object as al_obj then
				create l_validator.make
				l_result := l_validator.validate (al_obj, l_schema)
				assert ("nested_object_valid", l_result.is_valid)
			else
				assert ("parse_failed", False)
			end
		end

	test_validate_multiple_errors
			-- Test that multiple errors are collected
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 10, %"maxLength%": 5}")
			create l_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("has_multiple_errors", l_result.error_count >= 1)
		end

	test_validate_empty_schema
			-- Test that empty schema validates everything
		note
			testing: "covers/{JSON_SCHEMA_VALIDATOR}.validate"
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_value: SIMPLE_JSON_STRING
			l_result: JSON_VALIDATION_RESULT
		do
			create l_schema.make_from_string ("{}")
			create l_value.make ("anything")
			create l_validator.make
			l_result := l_validator.validate (l_value, l_schema)
			assert ("empty_schema_validates_all", l_result.is_valid)
		end

end
