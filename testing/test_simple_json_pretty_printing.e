note
	description: "Tests for pretty printing JSON values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	TEST_SIMPLE_JSON_PRETTY_PRINTING

inherit
	EQA_TEST_SET

feature -- Test - Primitives

	test_null_pretty
			-- Test NULL pretty printing
		local
			l_null: SIMPLE_JSON_NULL
			l_expected: STRING
			l_actual: STRING
		do
			create l_null.make
			l_expected := "null"
			l_actual := l_null.to_pretty_string (0)
			assert_strings_equal ("null_pretty", l_expected, l_actual)
		end

	test_boolean_true_pretty
			-- Test BOOLEAN true pretty printing
		local
			l_bool: SIMPLE_JSON_BOOLEAN
			l_expected: STRING
			l_actual: STRING
		do
			create l_bool.make (True)
			l_expected := "true"
			l_actual := l_bool.to_pretty_string (0)
			assert_strings_equal ("bool_true_pretty", l_expected, l_actual)
		end

	test_boolean_false_pretty
			-- Test BOOLEAN false pretty printing
		local
			l_bool: SIMPLE_JSON_BOOLEAN
			l_expected: STRING
			l_actual: STRING
		do
			create l_bool.make (False)
			l_expected := "false"
			l_actual := l_bool.to_pretty_string (0)
			assert_strings_equal ("bool_false_pretty", l_expected, l_actual)
		end

	test_integer_pretty
			-- Test INTEGER pretty printing
		local
			l_int: SIMPLE_JSON_INTEGER
			l_expected: STRING
			l_actual: STRING
		do
			create l_int.make (42)
			l_expected := "42"
			l_actual := l_int.to_pretty_string (0)
			assert_strings_equal ("integer_pretty", l_expected, l_actual)
		end

	test_real_pretty
		-- Test REAL pretty printing
		local
			l_real: SIMPLE_JSON_REAL
			l_actual: STRING
		do
			create l_real.make (3.14)
			l_actual := l_real.to_pretty_string (0)
			-- JSON allows flexible number representation
			assert ("real_pretty_valid",
				l_actual.starts_with ("3.14") and l_actual.to_real = 3.14)
		end

	test_string_pretty
			-- Test STRING pretty printing
		local
			l_string: SIMPLE_JSON_STRING
			l_expected: STRING
			l_actual: STRING
		do
			create l_string.make ("hello")
			l_expected := "%"hello%""
			l_actual := l_string.to_pretty_string (0)
			assert_strings_equal ("string_pretty", l_expected, l_actual)
		end

feature -- Test - Collections

	test_empty_array_pretty
			-- Test empty ARRAY pretty printing
		local
			l_array: SIMPLE_JSON_ARRAY
			l_expected: STRING
			l_actual: STRING
		do
			create l_array.make_empty
			l_expected := "[]"
			l_actual := l_array.to_pretty_string (0)
			assert_strings_equal ("empty_array_pretty", l_expected, l_actual)
		end

	test_simple_array_pretty
			-- Test simple ARRAY pretty printing
		local
			l_array: SIMPLE_JSON_ARRAY
			l_expected: STRING
			l_actual: STRING
		do
			create l_array.make_empty
			l_array.append_integer (1)
			l_array.append_integer (2)
			l_array.append_integer (3)

			l_expected := "[%N%T1,%N%T2,%N%T3%N]"
			l_actual := l_array.to_pretty_string (0)
			assert_strings_equal ("simple_array_pretty", l_expected, l_actual)
		end

	test_empty_object_pretty
			-- Test empty OBJECT pretty printing
		local
			l_object: SIMPLE_JSON_OBJECT
			l_expected: STRING
			l_actual: STRING
		do
			create l_object.make_empty
			l_expected := "{}"
			l_actual := l_object.to_pretty_string (0)
			assert_strings_equal ("empty_object_pretty", l_expected, l_actual)
		end

	test_simple_object_pretty
			-- Test simple OBJECT pretty printing
		local
			l_object: SIMPLE_JSON_OBJECT
			l_expected: STRING
			l_actual: STRING
		do
			create l_object.make_empty
			l_object.put_string ("name", "Alice")
			l_object.put_integer ("age", 30)

				-- Note: Order depends on JSON_OBJECT implementation
			l_actual := l_object.to_pretty_string (0)
			assert ("object_has_name", l_actual.has_substring ("%"name%": %"Alice%""))
			assert ("object_has_age", l_actual.has_substring ("%"age%": 30"))
			assert ("object_has_braces", l_actual.starts_with ("{%N") and l_actual.ends_with ("%N}"))
		end

feature -- Test - Nested Structures

	test_nested_array_pretty
			-- Test nested array pretty printing
		local
			l_outer: SIMPLE_JSON_ARRAY
			l_inner: SIMPLE_JSON_ARRAY
			l_expected: STRING
			l_actual: STRING
		do
			create l_inner.make_empty
			l_inner.append_integer (1)
			l_inner.append_integer (2)

			create l_outer.make_empty
			l_outer.append_array (l_inner)

			l_expected := "[%N%T[%N%T%T1,%N%T%T2%N%T]%N]"
			l_actual := l_outer.to_pretty_string (0)
			assert_strings_equal ("nested_array_pretty", l_expected, l_actual)
		end

	test_nested_object_pretty
			-- Test nested object pretty printing
		local
			l_root: SIMPLE_JSON_OBJECT
			l_array: SIMPLE_JSON_ARRAY
			l_actual: STRING
		do
			create l_array.make_empty
			l_array.append_integer (1)
			l_array.append_integer (2)

			create l_root.make_empty
			l_root.put_string ("name", "test")
			l_root.put_array ("items", l_array)

			l_actual := l_root.to_pretty_string (0)
			assert ("has_name", l_actual.has_substring ("%"name%": %"test%""))
			assert ("has_array", l_actual.has_substring ("%"items%": ["))
			assert ("has_nested_content", l_actual.has_substring ("%T%T1"))
		end

	test_complex_nested_pretty
			-- Test complex nested structure
		local
			l_root: SIMPLE_JSON_OBJECT
			l_person: SIMPLE_JSON_OBJECT
			l_hobbies: SIMPLE_JSON_ARRAY
			l_actual: STRING
		do
			create l_hobbies.make_empty
			l_hobbies.append_string ("reading")
			l_hobbies.append_string ("coding")

			create l_person.make_empty
			l_person.put_string ("name", "Bob")
			l_person.put_integer ("age", 25)
			l_person.put_array ("hobbies", l_hobbies)

			create l_root.make_empty
			l_root.put_object ("person", l_person)
			l_root.put_boolean ("active", True)

			l_actual := l_root.to_pretty_string (0)
			assert ("has_person_object", l_actual.has_substring ("%"person%": {"))
			assert ("has_nested_name", l_actual.has_substring ("%"name%": %"Bob%""))
			assert ("has_double_indent", l_actual.has_substring ("%T%T"))
		end

feature {NONE} -- Assertions

	assert_strings_equal (a_tag: STRING; a_expected: STRING; a_actual: STRING)
			-- Assert that `a_actual' equals `a_expected'
		local
			l_message: STRING
		do
			if not a_expected.is_equal (a_actual) then
				create l_message.make_empty
				l_message.append (a_tag)
				l_message.append ("%NExpected: ")
				l_message.append (a_expected)
				l_message.append ("%NActual:   ")
				l_message.append (a_actual)
				assert (l_message, False)
			else
				assert (a_tag, True)
			end
		end

end
