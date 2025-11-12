note
	description: "Tests for error handling and edge cases in SIMPLE_JSON"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_ERRORS

inherit
	EQA_TEST_SET

feature -- Error Handling Tests

	test_parse_invalid_json
			-- Test parsing invalid JSON fails gracefully
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON}.last_parse_successful"
			testing: "covers/{SIMPLE_JSON}.last_error_message"
		local
			l_json: SIMPLE_JSON
			l_result: detachable SIMPLE_JSON_OBJECT
		do
			create l_json

			-- Malformed JSON
			l_result := l_json.parse ("{invalid json}")
			assert ("invalid_json_returns_void", l_result = Void)
			assert ("parse_failed", not l_json.last_parse_successful)
			assert ("has_error_message", l_json.last_error_message /= Void)

			-- Unclosed brace
			l_result := l_json.parse ("{%"name%": %"test%"")
			assert ("unclosed_returns_void", l_result = Void)

			-- Array instead of object
			l_result := l_json.parse ("[1, 2, 3]")
			assert ("array_not_object", l_result = Void)
		end

	test_parse_empty_object
			-- Test parsing empty JSON object
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{}")

			assert ("empty_object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("is_empty", obj.is_empty)
				assert ("count_is_zero", obj.count = 0)
			end
		end

	test_parse_empty_array
			-- Test parsing empty array
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.array"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_arr: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"items%": []}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_arr := obj.array ("items")
				assert ("array_not_void", l_arr /= Void)
				if attached l_arr as arr then
					assert ("array_is_empty", arr.is_empty)
					assert ("array_count_zero", arr.count = 0)
				end
			end
		end

	test_missing_key_returns_default
			-- Test accessing non-existent keys returns void/default values
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.string"
			testing: "covers/{SIMPLE_JSON_OBJECT}.integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.boolean"
			testing: "covers/{SIMPLE_JSON_OBJECT}.real"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"name%": %"Alice%"}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("has_name_key", obj.has_key ("name"))
				assert ("no_age_key", not obj.has_key ("age"))
				assert ("missing_string_returns_void", obj.string ("nonexistent") = Void)
				assert ("missing_int_returns_zero", obj.integer ("nonexistent") = 0)
				assert ("missing_bool_returns_false", obj.boolean ("nonexistent") = False)
				assert ("missing_real_returns_zero", obj.real ("nonexistent") = 0.0)
			end
		end

	test_wrong_type_access
			-- Test accessing value with wrong type returns default
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.string"
			testing: "covers/{SIMPLE_JSON_OBJECT}.boolean"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				-- Try to get string as integer (should return 0)
				assert ("string_as_integer_returns_zero", obj.integer ("name") = 0)

				-- Try to get integer as string (should return Void)
				assert ("integer_as_string_returns_void", obj.string ("age") = Void)

				-- Try to get integer as boolean (should return False)
				assert ("integer_as_boolean_returns_false", obj.boolean ("age") = False)
			end
		end

end
