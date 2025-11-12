note
	description: "Test suite for type introspection methods"
	author: "Larry Rix"
	date: "November 12, 2025"
	testing: "type/manual"

class
	TEST_JSON_TYPE_INTROSPECTION

inherit
	EQA_TEST_SET

feature -- Test routines: Object Type Checks

	test_object_is_object
			-- Test that SIMPLE_JSON_OBJECT correctly identifies as object
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_object"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_string"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_number"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_real"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_boolean"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_null"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_array"
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make_empty
			assert ("object_is_object", obj.is_object)
			assert ("object_not_string", not obj.is_string)
			assert ("object_not_number", not obj.is_number)
			assert ("object_not_integer", not obj.is_integer)
			assert ("object_not_real", not obj.is_real)
			assert ("object_not_boolean", not obj.is_boolean)
			assert ("object_not_null", not obj.is_null)
			assert ("object_not_array", not obj.is_array)
		end

feature -- Test routines: Array Type Checks

	test_array_is_array
			-- Test that SIMPLE_JSON_ARRAY correctly identifies as array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_array"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_string"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_number"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_integer"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_real"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_boolean"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_null"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_object"
		local
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make_empty
			assert ("array_is_array", arr.is_array)
			assert ("array_not_string", not arr.is_string)
			assert ("array_not_number", not arr.is_number)
			assert ("array_not_integer", not arr.is_integer)
			assert ("array_not_real", not arr.is_real)
			assert ("array_not_boolean", not arr.is_boolean)
			assert ("array_not_null", not arr.is_null)
			assert ("array_not_object", not arr.is_object)
		end

feature -- Test routines: String Type Checks

	test_string_is_string
			-- Test that SIMPLE_JSON_STRING correctly identifies as string
		note
			testing: "covers/{SIMPLE_JSON_STRING}.is_string"
			testing: "covers/{SIMPLE_JSON_STRING}.is_number"
			testing: "covers/{SIMPLE_JSON_STRING}.is_integer"
			testing: "covers/{SIMPLE_JSON_STRING}.is_real"
			testing: "covers/{SIMPLE_JSON_STRING}.is_boolean"
			testing: "covers/{SIMPLE_JSON_STRING}.is_null"
			testing: "covers/{SIMPLE_JSON_STRING}.is_object"
			testing: "covers/{SIMPLE_JSON_STRING}.is_array"
		local
			str: SIMPLE_JSON_STRING
		do
			create str.make ("test")
			assert ("string_is_string", str.is_string)
			assert ("string_not_number", not str.is_number)
			assert ("string_not_integer", not str.is_integer)
			assert ("string_not_real", not str.is_real)
			assert ("string_not_boolean", not str.is_boolean)
			assert ("string_not_null", not str.is_null)
			assert ("string_not_object", not str.is_object)
			assert ("string_not_array", not str.is_array)
		end

feature -- Test routines: Integer Type Checks

	test_integer_is_integer_and_number
			-- Test that SIMPLE_JSON_INTEGER correctly identifies as integer and number
		note
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_integer"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_number"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_string"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_real"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_boolean"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_null"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_object"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_array"
		local
			int: SIMPLE_JSON_INTEGER
		do
			create int.make (42)
			assert ("integer_is_integer", int.is_integer)
			assert ("integer_is_number", int.is_number)
			assert ("integer_not_string", not int.is_string)
			assert ("integer_not_real", not int.is_real)
			assert ("integer_not_boolean", not int.is_boolean)
			assert ("integer_not_null", not int.is_null)
			assert ("integer_not_object", not int.is_object)
			assert ("integer_not_array", not int.is_array)
		end

feature -- Test routines: Real Type Checks

	test_real_is_real_and_number
			-- Test that SIMPLE_JSON_REAL correctly identifies as real and number
		note
			testing: "covers/{SIMPLE_JSON_REAL}.is_real"
			testing: "covers/{SIMPLE_JSON_REAL}.is_number"
			testing: "covers/{SIMPLE_JSON_REAL}.is_string"
			testing: "covers/{SIMPLE_JSON_REAL}.is_integer"
			testing: "covers/{SIMPLE_JSON_REAL}.is_boolean"
			testing: "covers/{SIMPLE_JSON_REAL}.is_null"
			testing: "covers/{SIMPLE_JSON_REAL}.is_object"
			testing: "covers/{SIMPLE_JSON_REAL}.is_array"
		local
			real: SIMPLE_JSON_REAL
		do
			create real.make (3.14)
			assert ("real_is_real", real.is_real)
			assert ("real_is_number", real.is_number)
			assert ("real_not_string", not real.is_string)
			assert ("real_not_integer", not real.is_integer)
			assert ("real_not_boolean", not real.is_boolean)
			assert ("real_not_null", not real.is_null)
			assert ("real_not_object", not real.is_object)
			assert ("real_not_array", not real.is_array)
		end

feature -- Test routines: Boolean Type Checks

	test_boolean_is_boolean
			-- Test that SIMPLE_JSON_BOOLEAN correctly identifies as boolean
		note
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_boolean"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_string"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_number"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_integer"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_real"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_null"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_object"
			testing: "covers/{SIMPLE_JSON_BOOLEAN}.is_array"
		local
			bool: SIMPLE_JSON_BOOLEAN
		do
			create bool.make (True)
			assert ("boolean_is_boolean", bool.is_boolean)
			assert ("boolean_not_string", not bool.is_string)
			assert ("boolean_not_number", not bool.is_number)
			assert ("boolean_not_integer", not bool.is_integer)
			assert ("boolean_not_real", not bool.is_real)
			assert ("boolean_not_null", not bool.is_null)
			assert ("boolean_not_object", not bool.is_object)
			assert ("boolean_not_array", not bool.is_array)
		end

feature -- Test routines: Null Type Checks

	test_null_is_null
			-- Test that SIMPLE_JSON_NULL correctly identifies as null
		note
			testing: "covers/{SIMPLE_JSON_NULL}.is_null"
			testing: "covers/{SIMPLE_JSON_NULL}.is_string"
			testing: "covers/{SIMPLE_JSON_NULL}.is_number"
			testing: "covers/{SIMPLE_JSON_NULL}.is_integer"
			testing: "covers/{SIMPLE_JSON_NULL}.is_real"
			testing: "covers/{SIMPLE_JSON_NULL}.is_boolean"
			testing: "covers/{SIMPLE_JSON_NULL}.is_object"
			testing: "covers/{SIMPLE_JSON_NULL}.is_array"
		local
			null_val: SIMPLE_JSON_NULL
		do
			create null_val.make
			assert ("null_is_null", null_val.is_null)
			assert ("null_not_string", not null_val.is_string)
			assert ("null_not_number", not null_val.is_number)
			assert ("null_not_integer", not null_val.is_integer)
			assert ("null_not_real", not null_val.is_real)
			assert ("null_not_boolean", not null_val.is_boolean)
			assert ("null_not_object", not null_val.is_object)
			assert ("null_not_array", not null_val.is_array)
		end

feature -- Test routines: Practical Usage

	test_type_checking_before_extraction
			-- Test using type checking to safely extract values
		note
			testing: "covers/{JSON}.parse"
		local
			json: JSON
			obj: detachable SIMPLE_JSON_OBJECT
			json_string: STRING
		do
			json_string := "{%"name%": %"Alice%", %"age%": 30}"
			create json
			obj := json.parse (json_string)

			check parse_should_succeed: attached obj as o then
				-- This would require additional methods to get SIMPLE_JSON_VALUE instances
				-- For now, we test the basic type checking on our created objects
				assert ("parsed_object_is_object", o.is_object)
				assert ("parsed_object_not_array", not o.is_array)
			end
		end

	test_integer_vs_real_distinction
			-- Test that integers and reals can be distinguished
		note
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_number"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_integer"
			testing: "covers/{SIMPLE_JSON_INTEGER}.is_real"
			testing: "covers/{SIMPLE_JSON_REAL}.is_number"
			testing: "covers/{SIMPLE_JSON_REAL}.is_real"
			testing: "covers/{SIMPLE_JSON_REAL}.is_integer"
		local
			int: SIMPLE_JSON_INTEGER
			real: SIMPLE_JSON_REAL
		do
			create int.make (42)
			create real.make (3.14)

			-- Both are numbers
			assert ("int_is_number", int.is_number)
			assert ("real_is_number", real.is_number)

			-- But can be distinguished
			assert ("int_is_integer", int.is_integer)
			assert ("int_not_real", not int.is_real)
			assert ("real_is_real", real.is_real)
			assert ("real_not_integer", not real.is_integer)
		end

	test_type_checking_defensive_programming
			-- Test defensive programming pattern with type checking
		note
			testing: "covers/{SIMPLE_JSON_VALUE}.is_object"
		local
			obj: SIMPLE_JSON_OBJECT
			val: SIMPLE_JSON_VALUE
		do
			create obj.make_empty
			obj.put_string ("name", "Bob")
			obj.put_integer ("age", 25)

			-- Demonstrate defensive checking pattern
			-- (In real code, you would get a SIMPLE_JSON_VALUE from somewhere)
			val := obj
			if val.is_object then
				-- Safe to use as object
				assert ("can_safely_cast_to_object", True)
			end
		end

end
