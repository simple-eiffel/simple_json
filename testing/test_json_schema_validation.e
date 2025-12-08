note
	description: "Tests for SIMPLE_JSON_SCHEMA_VALIDATOR"
	testing: "covers"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_json_schema_validation.html"

class
	TEST_JSON_SCHEMA_VALIDATION

inherit
	TEST_SET_BASE

feature -- Test routines: Type validation

	test_valid_string_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			create l_json
			l_instance := l_json.parse ("%"hello%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
				assert_integers_equal ("no_errors", 0, l_result.error_count)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_invalid_string_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			create l_json
			l_instance := l_json.parse ("42")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
				assert_greater_than ("has_errors", l_result.error_count, 0)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_number_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%"}")
			create l_json
			l_instance := l_json.parse ("42.5")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_integer_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"integer%"}")
			create l_json
			l_instance := l_json.parse ("42")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_boolean_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"boolean%"}")
			create l_json
			l_instance := l_json.parse ("true")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_null_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"null%"}")
			create l_json
			l_instance := l_json.parse ("null")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_object_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"object%"}")
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%"}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_valid_array_type
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%"}")
			create l_json
			l_instance := l_json.parse ("[1, 2, 3]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: String validation

	test_string_min_length_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 5}")
			create l_json
			l_instance := l_json.parse ("%"hello%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_string_min_length_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 10}")
			create l_json
			l_instance := l_json.parse ("%"short%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
				assert_greater_than ("has_errors", l_result.error_count, 0)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_string_max_length_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"maxLength%": 10}")
			create l_json
			l_instance := l_json.parse ("%"short%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_string_max_length_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"maxLength%": 5}")
			create l_json
			l_instance := l_json.parse ("%"toolongstring%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_string_pattern_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"pattern%": %"^[a-z]+$%"}")
			create l_json
			l_instance := l_json.parse ("%"hello%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_string_pattern_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"string%", %"pattern%": %"^[a-z]+$%"}")
			create l_json
			l_instance := l_json.parse ("%"Hello123%"")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: Number validation

	test_number_minimum_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%", %"minimum%": 0}")
			create l_json
			l_instance := l_json.parse ("42")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_number_minimum_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%", %"minimum%": 10}")
			create l_json
			l_instance := l_json.parse ("5")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_number_maximum_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%", %"maximum%": 100}")
			create l_json
			l_instance := l_json.parse ("42")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_number_maximum_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%", %"maximum%": 50}")
			create l_json
			l_instance := l_json.parse ("100")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_number_range_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"number%", %"minimum%": 0, %"maximum%": 100}")
			create l_json
			l_instance := l_json.parse ("50")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: Object validation

	test_object_required_properties_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"object%", %"required%": [%"name%", %"age%"]}")
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_object_required_properties_missing
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"object%", %"required%": [%"name%", %"age%"]}")
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%"}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
				assert_greater_than ("has_errors", l_result.error_count, 0)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_object_properties_validation_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
			l_schema_str: STRING_32
		do
			create l_schema_str.make_from_string_general ("{%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%", %"minimum%": 0}}}")
			create l_validator.make
			create l_schema.make_from_string (l_schema_str)
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_object_properties_validation_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
			l_schema_str: STRING_32
		do
			create l_schema_str.make_from_string_general ("{%"type%": %"object%", %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%"}}}")
			create l_validator.make
			create l_schema.make_from_string (l_schema_str)
			create l_json
			l_instance := l_json.parse ("{%"name%": 123, %"age%": 30}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: Array validation

	test_array_min_items_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"minItems%": 2}")
			create l_json
			l_instance := l_json.parse ("[1, 2, 3]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_array_min_items_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"minItems%": 5}")
			create l_json
			l_instance := l_json.parse ("[1, 2]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_array_max_items_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"maxItems%": 5}")
			create l_json
			l_instance := l_json.parse ("[1, 2, 3]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_array_max_items_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"maxItems%": 2}")
			create l_json
			l_instance := l_json.parse ("[1, 2, 3, 4, 5]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_array_items_validation_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"items%": {%"type%": %"string%"}}")
			create l_json
			l_instance := l_json.parse ("[%"a%", %"b%", %"c%"]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_array_items_validation_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			create l_validator.make
			create l_schema.make_from_string ("{%"type%": %"array%", %"items%": {%"type%": %"string%"}}")
			create l_json
			l_instance := l_json.parse ("[%"a%", 123, %"c%"]")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: Complex validation

	test_complex_nested_object_valid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
			l_schema_str: STRING_32
		do
			create l_schema_str.make_from_string_general ("{%"type%": %"object%", %"required%": [%"name%", %"age%"], %"properties%": {%"name%": {%"type%": %"string%", %"minLength%": 1}, %"age%": {%"type%": %"integer%", %"minimum%": 0, %"maximum%": 120}}}")
			create l_validator.make
			create l_schema.make_from_string (l_schema_str)
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_true ("is_valid", l_result.is_valid)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_complex_nested_object_invalid
		local
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			l_schema: SIMPLE_JSON_SCHEMA
			l_json: SIMPLE_JSON
			l_instance: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
			l_schema_str: STRING_32
		do
			create l_schema_str.make_from_string_general ("{%"type%": %"object%", %"required%": [%"name%", %"age%"], %"properties%": {%"name%": {%"type%": %"string%", %"minLength%": 1}, %"age%": {%"type%": %"integer%", %"minimum%": 0, %"maximum%": 120}}}")
			create l_validator.make
			create l_schema.make_from_string (l_schema_str)
			create l_json
			l_instance := l_json.parse ("{%"name%": %"Alice%", %"age%": 150}")
			
			if attached l_instance as al_instance then
				l_result := l_validator.validate (al_instance, l_schema)
				assert_false ("not_valid", l_result.is_valid)
				assert_greater_than ("has_errors", l_result.error_count, 0)
			else
				assert_false ("parse_failed", True)
			end
		end

end
