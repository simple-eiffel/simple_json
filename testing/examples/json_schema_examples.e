note
	description: "Examples demonstrating JSON Schema validation"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_SCHEMA_EXAMPLES

feature -- Examples

	example_basic_type_validation
			-- Validate a simple type constraint
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_str_value: SIMPLE_JSON_STRING
		do
			-- Schema: must be a string
			create l_schema.make_from_string ("{%"type%": %"string%"}")
			
			-- Valid instance: a string
			create l_str_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_str_value, l_schema)
			
			if l_result.is_valid then
				print ("String validation: PASSED%N")
			else
				print ("String validation: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_numeric_constraints
			-- Validate numeric constraints
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_int_value: SIMPLE_JSON_INTEGER
		do
			-- Schema: integer between 1 and 100
			create l_schema.make_from_string ("{%"type%": %"integer%", %"minimum%": 1, %"maximum%": 100}")
			
			-- Valid instance: 42
			create l_int_value.make (42)
			create l_validator.make
			l_result := l_validator.validate (l_int_value, l_schema)
			
			if l_result.is_valid then
				print ("Numeric validation: PASSED%N")
			else
				print ("Numeric validation: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_string_constraints
			-- Validate string length constraints
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_str_value: SIMPLE_JSON_STRING
		do
			-- Schema: string with minLength 3, maxLength 10
			create l_schema.make_from_string ("{%"type%": %"string%", %"minLength%": 3, %"maxLength%": 10}")
			
			-- Valid instance
			create l_str_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_str_value, l_schema)
			
			if l_result.is_valid then
				print ("String constraints: PASSED%N")
			else
				print ("String constraints: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_object_validation
			-- Validate object with required properties
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_parser: SIMPLE_JSON
			l_schema_str: STRING
		do
			-- Schema: object with required "name" and "age" properties
			l_schema_str := "{%"type%": %"object%", %"required%": [%"name%", %"age%"], %"properties%": {%"name%": {%"type%": %"string%"}, %"age%": {%"type%": %"integer%", %"minimum%": 0}}}"
			create l_schema.make_from_string (l_schema_str)
			
			-- Valid instance
			create l_parser
			if attached l_parser.parse ("{%"name%": %"Alice%", %"age%": 30}") as al_obj then
				create l_validator.make
				l_result := l_validator.validate (al_obj, l_schema)
				
				if l_result.is_valid then
					print ("Object validation: PASSED%N")
				else
					print ("Object validation: FAILED - " + l_result.error_message + "%N")
				end
			end
		end

	example_array_validation
			-- Validate array with item constraints
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_array: SIMPLE_JSON_ARRAY
		do
			-- Schema: array of numbers with minItems 1, maxItems 5
			create l_schema.make_from_string ("{%"type%": %"array%", %"items%": {%"type%": %"number%"}, %"minItems%": 1, %"maxItems%": 5}")
			
			-- Valid instance
			create l_array.make_empty
			l_array.append_real (1.5)
			l_array.append_real (2.7)
			l_array.append_real (3.14)
			
			create l_validator.make
			l_result := l_validator.validate (l_array, l_schema)
			
			if l_result.is_valid then
				print ("Array validation: PASSED%N")
			else
				print ("Array validation: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_enum_validation
			-- Validate enum constraint
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_str_value: SIMPLE_JSON_STRING
		do
			-- Schema: string must be one of "red", "green", "blue"
			create l_schema.make_from_string ("{%"type%": %"string%", %"enum%": [%"red%", %"green%", %"blue%"]}")
			
			-- Valid instance
			create l_str_value.make ("green")
			create l_validator.make
			l_result := l_validator.validate (l_str_value, l_schema)
			
			if l_result.is_valid then
				print ("Enum validation: PASSED%N")
			else
				print ("Enum validation: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_any_of_validation
			-- Validate anyOf combinator
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_str_value: SIMPLE_JSON_STRING
		do
			-- Schema: must be either a string or a number
			create l_schema.make_from_string ("{%"anyOf%": [{%"type%": %"string%"}, {%"type%": %"number%"}]}")
			
			-- Valid instance: string
			create l_str_value.make ("hello")
			create l_validator.make
			l_result := l_validator.validate (l_str_value, l_schema)
			
			if l_result.is_valid then
				print ("AnyOf validation: PASSED%N")
			else
				print ("AnyOf validation: FAILED - " + l_result.error_message + "%N")
			end
		end

	example_validation_errors
			-- Example showing validation errors
		local
			l_validator: JSON_SCHEMA_VALIDATOR
			l_schema: JSON_SCHEMA
			l_result: JSON_VALIDATION_RESULT
			l_int_value: SIMPLE_JSON_INTEGER
		do
			-- Schema: integer must be at least 10
			create l_schema.make_from_string ("{%"type%": %"integer%", %"minimum%": 10}")
			
			-- Invalid instance: 5
			create l_int_value.make (5)
			create l_validator.make
			l_result := l_validator.validate (l_int_value, l_schema)
			
			if not l_result.is_valid then
				print ("Validation failed (as expected):%N")
				print (l_result.error_message + "%N")
			end
		end

end
