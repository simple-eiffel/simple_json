note
	description: "Tests for streaming JSON parser (SIMPLE_JSON_STREAM)"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_STREAM

inherit
	TEST_SET_BASE

feature -- Test routines - Basic streaming

	test_stream_empty_array
			-- Test streaming an empty array
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
		do
			create l_stream.make_from_string ("[]")

			across l_stream as ic loop
				l_count := l_count + 1
			end

			assert_integers_equal ("no_elements", 0, l_count)
			assert_integers_equal ("element_count_zero", 0, l_stream.element_count)
		end

	test_stream_single_element
			-- Test streaming array with single element
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
			l_first_value: detachable SIMPLE_JSON_VALUE
		do
			create l_stream.make_from_string ("[42]")

			across l_stream as ic loop
				l_count := l_count + 1
				if l_count = 1 then
					l_first_value := ic.value
				end
			end

			assert_integers_equal ("one_element", 1, l_count)
			assert ("first_value_attached", l_first_value /= Void)

			if attached l_first_value as al_value then
				assert ("is_number", al_value.is_number)
				assert_integers_equal ("value_is_42", 42, al_value.as_integer.to_integer_32)
			end
		end

	test_stream_multiple_numbers
			-- Test streaming array with multiple numeric elements
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
			l_values: ARRAYED_LIST [INTEGER]
		do
			create l_stream.make_from_string ("[1, 2, 3, 4, 5]")
			create l_values.make (5)

			across l_stream as ic loop
				l_count := l_count + 1
				l_values.extend (ic.value.as_integer.to_integer_32)
			end

			assert_integers_equal ("five_elements", 5, l_count)
			assert_integers_equal ("first_is_1", 1, l_values.i_th (1))
			assert_integers_equal ("second_is_2", 2, l_values.i_th (2))
			assert_integers_equal ("third_is_3", 3, l_values.i_th (3))
			assert_integers_equal ("fourth_is_4", 4, l_values.i_th (4))
			assert_integers_equal ("fifth_is_5", 5, l_values.i_th (5))
		end

	test_stream_string_elements
			-- Test streaming array with string elements
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
			l_strings: ARRAYED_LIST [STRING_32]
		do
			create l_stream.make_from_string ("[%"Alice%", %"Bob%", %"Charlie%"]")
			create l_strings.make (3)

			across l_stream as ic loop
				l_count := l_count + 1
				l_strings.extend (ic.value.as_string_32)
			end

			assert_integers_equal ("three_elements", 3, l_count)
			assert_strings_equal ("first_is_alice", "Alice", l_strings.i_th (1))
			assert_strings_equal ("second_is_bob", "Bob", l_strings.i_th (2))
			assert_strings_equal ("third_is_charlie", "Charlie", l_strings.i_th (3))
		end

	test_stream_object_elements
			-- Test streaming array with object elements
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
			l_first_name: detachable STRING_32
			l_second_age: INTEGER_64
		do
			create l_stream.make_from_string ("[{%"name%": %"Alice%", %"age%": 30}, {%"name%": %"Bob%", %"age%": 25}]")

			across l_stream as ic loop
				l_count := l_count + 1

				if l_count = 1 and then ic.value.is_object then
					l_first_name := ic.value.as_object.string_item ("name")
				elseif l_count = 2 and then ic.value.is_object then
					l_second_age := ic.value.as_object.integer_item ("age")
				end
			end

			assert_integers_equal ("two_elements", 2, l_count)
			assert ("first_name_attached", l_first_name /= Void)
			if attached l_first_name as al_name then
				assert_strings_equal ("first_name_is_alice", "Alice", al_name)
			end
			assert_integers_equal ("second_age_is_25", 25, l_second_age.to_integer_32)
		end

feature -- Test routines - Element metadata

	test_element_index
			-- Test that elements have correct index
		local
			l_stream: SIMPLE_JSON_STREAM
		do
			create l_stream.make_from_string ("[1, 2, 3]")

			across l_stream as ic loop
				assert_integers_equal ("index_matches", ic.index, ic.value.as_integer.to_integer_32)
			end
		end

feature -- Test routines - Error handling

	test_error_on_non_array
			-- Test that non-array root causes error
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
		do
			create l_stream.make_from_string ("{%"key%": %"value%"}")

			across l_stream as ic loop
				l_count := l_count + 1
			end

			assert_integers_equal ("no_elements", 0, l_count)
			assert ("has_errors", l_stream.has_errors)
		end

	test_error_on_invalid_json
			-- Test that invalid JSON causes error
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count: INTEGER
		do
			create l_stream.make_from_string ("[invalid json")

			across l_stream as ic loop
				l_count := l_count + 1
			end

			assert_integers_equal ("no_elements", 0, l_count)
			assert ("has_errors", l_stream.has_errors)
		end

feature -- Test routines - File streaming

	test_stream_from_file
			-- Test streaming from a file
		local
			l_stream: SIMPLE_JSON_STREAM
			l_file: PLAIN_TEXT_FILE
			l_file_path: STRING_32
			l_count: INTEGER
			l_utf8: STRING_8
		do
			-- Create a temporary test file
			l_file_path := "test_stream.json"
			create l_file.make_create_read_write (l_file_path)
			l_utf8 := utf_converter.utf_32_string_to_utf_8_string_8 ({STRING_32} "[1, 2, 3, 4, 5]")
			l_file.put_string (l_utf8)
			l_file.close

			-- Stream from file
			create l_stream.make_from_file (l_file_path)

			across l_stream as ic loop
				l_count := l_count + 1
			end

			assert_integers_equal ("five_elements", 5, l_count)
			assert ("no_errors", not l_stream.has_errors)

			-- Clean up
			l_file.delete
		end

feature -- Test routines - Multiple iterations

	test_multiple_iterations
			-- Test that we can iterate multiple times
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count1, l_count2: INTEGER
		do
			create l_stream.make_from_string ("[1, 2, 3]")

			-- First iteration
			across l_stream as ic loop
				l_count1 := l_count1 + 1
			end

			-- Second iteration
			across l_stream as ic loop
				l_count2 := l_count2 + 1
			end

			assert_integers_equal ("first_iteration_3", 3, l_count1)
			assert_integers_equal ("second_iteration_3", 3, l_count2)
		end

feature {NONE} -- Implementation

	utf_converter: UTF_CONVERTER
			-- UTF conversion utility
		once
			create Result
		end

note
	copyright: "Copyright (c) 2024, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser tests
	]"
end
