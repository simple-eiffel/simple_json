note
	description: "Tests for SIMPLE_JSON_ARRAY enhancements"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_JSON_ARRAY_ENHANCEMENTS

inherit
	EQA_TEST_SET

feature -- Test: Append Operations

	test_append_string
			-- Test appending string values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_string"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("value1")
			l_array.append_string ("value2")
			
			assert ("count_is_2", l_array.count = 2)
			assert ("first_correct", attached l_array.string_at (1) as s and then s.is_equal ("value1"))
			assert ("second_correct", attached l_array.string_at (2) as s and then s.is_equal ("value2"))
		end

	test_append_integer
			-- Test appending integer values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_integer"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_integer (10)
			l_array.append_integer (20)
			l_array.append_integer (30)
			
			assert ("count_is_3", l_array.count = 3)
			assert ("first_is_10", l_array.integer_at (1) = 10)
			assert ("second_is_20", l_array.integer_at (2) = 20)
			assert ("third_is_30", l_array.integer_at (3) = 30)
		end

	test_append_real
			-- Test appending real values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_real"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_real (1.5)
			l_array.append_real (2.5)
			
			assert ("count_is_2", l_array.count = 2)
			assert ("first_correct", (l_array.real_at (1) - 1.5).abs < 0.001)
			assert ("second_correct", (l_array.real_at (2) - 2.5).abs < 0.001)
		end

	test_append_boolean
			-- Test appending boolean values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_boolean"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_boolean (True)
			l_array.append_boolean (False)
			l_array.append_boolean (True)
			
			assert ("count_is_3", l_array.count = 3)
			assert ("first_is_true", l_array.boolean_at (1) = True)
			assert ("second_is_false", l_array.boolean_at (2) = False)
			assert ("third_is_true", l_array.boolean_at (3) = True)
		end

	test_append_object
			-- Test appending object values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_object"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_obj1, l_obj2: SIMPLE_JSON_OBJECT
		do
			create l_array.make_empty
			
			create l_obj1.make_empty
			l_obj1.put_string ("name", "Alice")
			
			create l_obj2.make_empty
			l_obj2.put_string ("name", "Bob")
			
			l_array.append_object (l_obj1)
			l_array.append_object (l_obj2)
			
			assert ("count_is_2", l_array.count = 2)
			
			if attached l_array.object_at (1) as obj1 then
				assert ("first_name_alice", attached obj1.string ("name") as n and then n.is_equal ("Alice"))
			else
				assert ("first_should_exist", False)
			end
			
			if attached l_array.object_at (2) as obj2 then
				assert ("second_name_bob", attached obj2.string ("name") as n and then n.is_equal ("Bob"))
			else
				assert ("second_should_exist", False)
			end
		end

	test_append_nested_array
			-- Test appending array values
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_array"
		local
			l_array, l_nested1, l_nested2: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			
			create l_nested1.make_empty
			l_nested1.append_integer (1)
			l_nested1.append_integer (2)
			
			create l_nested2.make_empty
			l_nested2.append_integer (3)
			l_nested2.append_integer (4)
			
			l_array.append_array (l_nested1)
			l_array.append_array (l_nested2)
			
			assert ("count_is_2", l_array.count = 2)
			
			if attached l_array.array_at (1) as arr1 then
				assert ("first_array_count", arr1.count = 2)
			else
				assert ("first_array_should_exist", False)
			end
		end

	test_append_mixed_types
			-- Test appending different types to same array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_string"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_integer"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_boolean"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_real"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("text")
			l_array.append_integer (42)
			l_array.append_boolean (True)
			l_array.append_real (3.14)
			
			assert ("count_is_4", l_array.count = 4)
			assert ("string_correct", attached l_array.string_at (1) as s and then s.is_equal ("text"))
			assert ("integer_correct", l_array.integer_at (2) = 42)
			assert ("boolean_correct", l_array.boolean_at (3) = True)
			assert ("real_correct", (l_array.real_at (4) - 3.14).abs < 0.001)
		end

feature -- Test: Insert Operations

	test_insert_string_at_beginning
			-- Test inserting at index 1
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.insert_string_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("second")
			l_array.insert_string_at (1, "first")
			
			assert ("count_is_2", l_array.count = 2)
			assert ("first_correct", attached l_array.string_at (1) as s and then s.is_equal ("first"))
			assert ("second_correct", attached l_array.string_at (2) as s and then s.is_equal ("second"))
		end

	test_insert_string_at_end
			-- Test inserting at end position
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.insert_string_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("first")
			l_array.insert_string_at (2, "second")
			
			assert ("count_is_2", l_array.count = 2)
			assert ("second_correct", attached l_array.string_at (2) as s and then s.is_equal ("second"))
		end

	test_insert_integer_middle
			-- Test inserting in middle of array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.insert_integer_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_integer (1)
			l_array.append_integer (3)
			l_array.insert_integer_at (2, 2)
			
			assert ("count_is_3", l_array.count = 3)
			assert ("first_is_1", l_array.integer_at (1) = 1)
			assert ("second_is_2", l_array.integer_at (2) = 2)
			assert ("third_is_3", l_array.integer_at (3) = 3)
		end

feature -- Test: Remove Operations

	test_remove_at_beginning
			-- Test removing first element
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.remove_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("first")
			l_array.append_string ("second")
			l_array.append_string ("third")
			
			l_array.remove_at (1)
			
			assert ("count_is_2", l_array.count = 2)
			assert ("first_now_second", attached l_array.string_at (1) as s and then s.is_equal ("second"))
			assert ("second_now_third", attached l_array.string_at (2) as s and then s.is_equal ("third"))
		end

	test_remove_at_middle
			-- Test removing middle element
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.remove_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_integer (1)
			l_array.append_integer (2)
			l_array.append_integer (3)
			
			l_array.remove_at (2)
			
			assert ("count_is_2", l_array.count = 2)
			assert ("first_unchanged", l_array.integer_at (1) = 1)
			assert ("second_now_3", l_array.integer_at (2) = 3)
		end

	test_remove_at_end
			-- Test removing last element
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.remove_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("first")
			l_array.append_string ("second")
			
			l_array.remove_at (2)
			
			assert ("count_is_1", l_array.count = 1)
			assert ("only_first_remains", attached l_array.string_at (1) as s and then s.is_equal ("first"))
		end

	test_remove_all_elements
			-- Test removing all elements one by one
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.remove_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_integer (1)
			l_array.append_integer (2)
			
			l_array.remove_at (1)
			assert ("count_is_1", l_array.count = 1)
			
			l_array.remove_at (1)
			assert ("count_is_0", l_array.count = 0)
			assert ("is_empty", l_array.is_empty)
		end

feature -- Test: Clear Operations

	test_clear_empty_array
			-- Test clearing already empty array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.clear"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.clear
			
			assert ("still_empty", l_array.is_empty)
			assert ("count_zero", l_array.count = 0)
		end

	test_clear_populated_array
			-- Test clearing populated array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.clear"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("value1")
			l_array.append_integer (42)
			l_array.append_boolean (True)
			
			l_array.clear
			
			assert ("is_empty", l_array.is_empty)
			assert ("count_zero", l_array.count = 0)
		end

	test_clear_and_reuse
			-- Test clearing and then adding new elements
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.clear"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("old_value")
			l_array.clear
			l_array.append_string ("new_value")
			
			assert ("count_is_1", l_array.count = 1)
			assert ("has_new_value", attached l_array.string_at (1) as s and then s.is_equal ("new_value"))
		end

feature -- Test: Clone Operations

	test_clone_empty_array
			-- Test cloning empty array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.json_clone"
		local
			l_array, l_clone: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_clone := l_array.json_clone
			
			assert ("clone_exists", l_clone /= Void)
			assert ("clone_empty", l_clone.is_empty)
			assert ("independent", l_clone /= l_array)
		end

	test_clone_simple_array
			-- Test cloning simple array
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.json_clone"
		local
			l_array, l_clone: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("value1")
			l_array.append_integer (42)
			l_array.append_boolean (True)
			
			l_clone := l_array.json_clone
			
			assert ("clone_same_count", l_clone.count = l_array.count)
			assert ("clone_has_string", attached l_clone.string_at (1) as s and then s.is_equal ("value1"))
			assert ("clone_has_integer", l_clone.integer_at (2) = 42)
			assert ("clone_has_boolean", l_clone.boolean_at (3) = True)
			assert ("independent", l_clone /= l_array)
		end

	test_clone_independence
			-- Test that clone is independent of original
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.json_clone"
		local
			l_array, l_clone: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("original")
			
			l_clone := l_array.json_clone
			
			-- Modify original
			l_array.append_string ("modified")
			
			-- Clone should be unchanged
			assert ("clone_count_1", l_clone.count = 1)
			assert ("original_count_2", l_array.count = 2)
		end

	test_clone_nested_structures
			-- Test cloning array with nested objects
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.json_clone"
		local
			l_array, l_clone: SIMPLE_JSON_ARRAY
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_array.make_empty
			
			create l_obj.make_empty
			l_obj.put_string ("key", "value")
			
			l_array.append_object (l_obj)
			l_clone := l_array.json_clone
			
			-- Both should have the nested object
			if attached l_array.object_at (1) as orig_obj and then
			   attached l_clone.object_at (1) as clone_obj then
				assert ("both_have_key", orig_obj.has_key ("key") and clone_obj.has_key ("key"))
				assert ("values_match", attached orig_obj.string ("key") as ov and then
				                        attached clone_obj.string ("key") as cv and then
				                        ov.is_equal (cv))
			else
				assert ("objects_should_exist", False)
			end
		end

feature -- Test: Integration

	test_build_array_fluently
			-- Test building array with multiple operations
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_string"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_integer"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_boolean"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_real"
			testing: "covers/{SIMPLE_JSON_ARRAY}.remove_at"
		local
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_array.make_empty
			l_array.append_string ("first")
			l_array.append_integer (42)
			l_array.append_boolean (True)
			l_array.remove_at (2)  -- Remove integer
			l_array.append_real (3.14)
			
			assert ("count_is_3", l_array.count = 3)
			assert ("has_string", attached l_array.string_at (1))
			assert ("has_boolean", l_array.boolean_at (2) = True)
			assert ("has_real", (l_array.real_at (3) - 3.14).abs < 0.001)
		end

	test_array_round_trip
			-- Test array to JSON and back
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.to_json_string"
			testing: "covers/{SIMPLE_JSON_ARRAY}.make_from_json"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_json_string: STRING
			l_parser: JSON_PARSER
		do
			create l_array.make_empty
			l_array.append_string ("test")
			l_array.append_integer (123)
			
			l_json_string := l_array.to_json_string
			
			create l_parser.make_with_string (l_json_string)
			l_parser.parse_content
			
			if l_parser.is_parsed and l_parser.is_valid then
				if attached {JSON_ARRAY} l_parser.parsed_json_value as parsed_arr then
					create l_array.make_from_json (parsed_arr)
					assert ("count_preserved", l_array.count = 2)
				end
			end
		end

	test_complex_array_manipulation
			-- Test complex real-world array manipulation
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_object"
			testing: "covers/{SIMPLE_JSON_ARRAY}.append_string"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_array.make_empty
			
			-- Build array of objects
			create l_obj.make_empty
			l_obj.put_string ("name", "Alice")
			l_obj.put_integer ("age", 30)
			l_array.append_object (l_obj)
			
			create l_obj.make_empty
			l_obj.put_string ("name", "Bob")
			l_obj.put_integer ("age", 25)
			l_array.append_object (l_obj)
			
			-- Add more data
			l_array.append_string ("Extra info")
			
			assert ("count_is_3", l_array.count = 3)
			assert ("first_is_object", attached l_array.object_at (1))
			assert ("second_is_object", attached l_array.object_at (2))
			assert ("third_is_string", attached l_array.string_at (3))
		end

end
