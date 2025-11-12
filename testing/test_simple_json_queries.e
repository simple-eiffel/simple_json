note
	description: "Tests for status queries and validation in SIMPLE_JSON"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_QUERIES

inherit
	EQA_TEST_SET

feature -- Status Query Tests

	test_object_status_queries
			-- Test has_key, count, is_empty on objects
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.has_key"
			testing: "covers/{SIMPLE_JSON_OBJECT}.count"
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_empty"
		local
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			assert ("initially_empty", l_obj.is_empty)
			assert ("count_zero", l_obj.count = 0)

			l_obj.put_string ("key1", "value1")
			assert ("not_empty", not l_obj.is_empty)
			assert ("count_one", l_obj.count = 1)
			assert ("has_key1", l_obj.has_key ("key1"))
			assert ("no_key2", not l_obj.has_key ("key2"))

			l_obj.put_integer ("key2", 42)
			assert ("count_two", l_obj.count = 2)
			assert ("has_key2", l_obj.has_key ("key2"))

			l_obj.put_boolean ("key3", True)
			assert ("count_three", l_obj.count = 3)
			assert ("has_all_keys", l_obj.has_key ("key1") and l_obj.has_key ("key2") and l_obj.has_key ("key3"))
		end

	test_array_valid_index
			-- Test valid_index query on arrays
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.valid_index"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_arr: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"items%": [1, 2, 3]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_arr := obj.array ("items")
				assert ("array_not_void", l_arr /= Void)

				if attached l_arr as arr then
					assert ("valid_1", arr.valid_index (1))
					assert ("valid_2", arr.valid_index (2))
					assert ("valid_3", arr.valid_index (3))
					assert ("invalid_0", not arr.valid_index (0))
					assert ("invalid_4", not arr.valid_index (4))
					assert ("invalid_negative", not arr.valid_index (-1))
					assert ("invalid_large", not arr.valid_index (100))
				end
			end
		end

	test_array_status_queries
			-- Test count and is_empty on arrays
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.count"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_empty"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_empty_arr, l_full_arr: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"empty%": [], %"full%": [1, 2, 3, 4, 5]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
					-- Test empty array
				l_empty_arr := obj.array ("empty")
				if attached l_empty_arr as empty then
					assert ("empty_is_empty", empty.is_empty)
					assert ("empty_count_zero", empty.count = 0)
				end

					-- Test full array
				l_full_arr := obj.array ("full")
				if attached l_full_arr as full then
					assert ("full_not_empty", not full.is_empty)
					assert ("full_count_five", full.count = 5)
				end
			end
		end

	test_is_valid_json
			-- Test JSON validation
		note
			testing: "covers/{SIMPLE_JSON}.is_valid_json"
		local
			l_json: SIMPLE_JSON
		do
			create l_json

				-- Valid JSON objects
			assert ("valid_simple_object", l_json.is_valid_json ("{%"key%": %"value%"}"))
			assert ("valid_nested", l_json.is_valid_json ("{%"a%": {%"b%": 1}}"))
			assert ("valid_with_array", l_json.is_valid_json ("{%"items%": [1, 2, 3]}"))
			assert ("valid_empty", l_json.is_valid_json ("{}"))
			assert ("valid_complex", l_json.is_valid_json ("{%"name%": %"test%", %"age%": 30, %"active%": true}"))

				-- Invalid JSON
			assert ("invalid_malformed", not l_json.is_valid_json ("{invalid}"))
			assert ("invalid_unclosed", not l_json.is_valid_json ("{%"key%": "))
			assert ("invalid_no_quotes", not l_json.is_valid_json ("{key: value}"))
			assert ("invalid_trailing_comma", not l_json.is_valid_json ("{%"key%": %"value%",}"))
		end

	test_has_key_after_parsing
			-- Test has_key on parsed objects
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.has_key"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"name%": %"Alice%", %"age%": 30, %"city%": %"NYC%"}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("has_name", obj.has_key ("name"))
				assert ("has_age", obj.has_key ("age"))
				assert ("has_city", obj.has_key ("city"))
				assert ("no_country", not obj.has_key ("country"))
				assert ("no_phone", not obj.has_key ("phone"))
			end
		end

	test_count_matches_keys
			-- Test that count matches actual number of keys
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.count"
			testing: "covers/{SIMPLE_JSON_OBJECT}.has_key"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"a%": 1, %"b%": 2, %"c%": 3, %"d%": 4}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("count_is_four", obj.count = 4)
				assert ("has_a", obj.has_key ("a"))
				assert ("has_b", obj.has_key ("b"))
				assert ("has_c", obj.has_key ("c"))
				assert ("has_d", obj.has_key ("d"))
			end
		end

	test_parse_status_tracking
			-- Test last_parse_successful and last_error_message
		note
			testing: "covers/{SIMPLE_JSON}.last_parse_successful"
			testing: "covers/{SIMPLE_JSON}.last_error_message"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json

				-- Valid parse
			l_obj := l_json.parse ("{%"key%": %"value%"}")
			assert ("valid_parse_successful", l_json.last_parse_successful)
			assert ("no_error_on_success", l_json.last_error_message = Void)

				-- Invalid parse
			l_obj := l_json.parse ("{invalid json}")
			assert ("invalid_parse_failed", not l_json.last_parse_successful)
			assert ("has_error_message", l_json.last_error_message /= Void)

				-- Another valid parse resets status
			l_obj := l_json.parse ("{}")
			assert ("second_valid_successful", l_json.last_parse_successful)
			assert ("error_cleared", l_json.last_error_message = Void)
		end

	test_empty_key_queries
			-- Test querying empty objects and arrays
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.is_empty"
			testing: "covers/{SIMPLE_JSON_OBJECT}.count"
			testing: "covers/{SIMPLE_JSON_OBJECT}.has_key"
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_empty"
			testing: "covers/{SIMPLE_JSON_ARRAY}.count"
			testing: "covers/{SIMPLE_JSON_ARRAY}.valid_index"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"empty_obj%": {}, %"empty_arr%": []}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
					-- Check empty nested object
				if attached obj.object ("empty_obj") as empty_obj then
					assert ("empty_obj_is_empty", empty_obj.is_empty)
					assert ("empty_obj_count_zero", empty_obj.count = 0)
					assert ("empty_obj_no_keys", not empty_obj.has_key ("anything"))
				end

					-- Check empty nested array
				if attached obj.array ("empty_arr") as empty_arr then
					assert ("empty_arr_is_empty", empty_arr.is_empty)
					assert ("empty_arr_count_zero", empty_arr.count = 0)
					assert ("no_valid_index", not empty_arr.valid_index (1))
				end
			end
		end

end
