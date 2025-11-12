note
	description: "Tests for SIMPLE_JSON class"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON

inherit
	EQA_TEST_SET

feature -- Test routines

	test_parse_simple_object
			-- Test parsing a simple JSON object
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_json_string: STRING
		do
			l_json_string := "{%"name%": %"John%", %"age%": 30}"

			create l_json
			l_obj := l_json.parse (l_json_string)

			assert ("object_not_void", attached l_obj)

			if attached l_obj as obj then
				assert ("name_is_john", attached obj.string ("name") as name and then name.is_equal ("John"))
				assert ("age_is_30", obj.integer ("age") = 30)
			end
		end

	test_parse_boolean
			-- Test parsing boolean values
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_json_string: STRING
		do
			l_json_string := "{%"active%": true, %"deleted%": false}"

			create l_json
			l_obj := l_json.parse (l_json_string)

			assert ("object_not_void", l_obj /= Void)

			if attached l_obj as obj then
				assert ("active_is_true", obj.boolean ("active") = True)
				assert ("deleted_is_false", obj.boolean ("deleted") = False)
			end
		end

	test_parse_real
			-- Test parsing real/double values
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_json_string: STRING
		do
			l_json_string := "{%"price%": 19.99, %"temperature%": -5.5}"

			create l_json
			l_obj := l_json.parse (l_json_string)

			assert ("object_not_void", l_obj /= Void)

			if attached l_obj as obj then
				assert ("price_is_correct", (obj.real ("price") - 19.99).abs < 0.001)
				assert ("temperature_is_correct", (obj.real ("temperature") - (-5.5)).abs < 0.001)
			end
		end

	test_parse_array
			-- Test parsing arrays
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.array"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_arr: detachable SIMPLE_JSON_ARRAY
			l_json_string: STRING
		do
			l_json_string := "{%"names%": [%"Alice%", %"Bob%", %"Charlie%"], %"scores%": [95, 87, 92]}"

			create l_json
			l_obj := l_json.parse (l_json_string)

			assert ("object_not_void", l_obj /= Void)

			if attached l_obj as obj then
					-- Test string array
				l_arr := obj.array ("names")
				assert ("names_array_not_void", l_arr /= Void)
				if attached l_arr as names then
					assert ("names_count_is_3", names.count = 3)
					assert ("first_name_is_alice", attached names.string_at (1) as n1 and then n1.is_equal ("Alice"))
					assert ("second_name_is_bob", attached names.string_at (2) as n2 and then n2.is_equal ("Bob"))
					assert ("third_name_is_charlie", attached names.string_at (3) as n3 and then n3.is_equal ("Charlie"))
				end

					-- Test integer array
				l_arr := obj.array ("scores")
				assert ("scores_array_not_void", l_arr /= Void)
				if attached l_arr as scores then
					assert ("scores_count_is_3", scores.count = 3)
					assert ("first_score_is_95", scores.integer_at (1) = 95)
					assert ("second_score_is_87", scores.integer_at (2) = 87)
					assert ("third_score_is_92", scores.integer_at (3) = 92)
				end
			end
		end

	test_parse_nested_object
			-- Test parsing nested objects
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.object"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_user: detachable SIMPLE_JSON_OBJECT
			l_json_string: STRING
		do
			l_json_string := "{%"user%": {%"name%": %"Alice%", %"age%": 30, %"active%": true}}"

			create l_json
			l_obj := l_json.parse (l_json_string)

			assert ("object_not_void", l_obj /= Void)

			if attached l_obj as obj then
				l_user := obj.object ("user")
				assert ("user_object_not_void", l_user /= Void)

				if attached l_user as user then
					assert ("name_is_alice", attached user.string ("name") as n and then n.is_equal ("Alice"))
					assert ("age_is_30", user.integer ("age") = 30)
					assert ("active_is_true", user.boolean ("active") = True)
				end
			end
		end

	test_generate_json
			-- Test generating JSON from objects
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.to_json_string"
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_json_string: STRING
			l_parsed: detachable SIMPLE_JSON_OBJECT
			l_json: SIMPLE_JSON
		do
				-- Create a JSON object programmatically
			create l_obj.make_empty
			l_obj.put_string ("name", "Bob")
			l_obj.put_integer ("age", 25)
			l_obj.put_boolean ("active", True)
			l_obj.put_real ("score", 98.5)

				-- Convert to JSON string
			l_json_string := l_obj.to_json_string
			assert ("json_string_not_empty", l_json_string /= Void and then not l_json_string.is_empty)

				-- Parse it back and verify
			create l_json
			l_parsed := l_json.parse (l_json_string)
			assert ("parsed_not_void", l_parsed /= Void)

			if attached l_parsed as parsed then
				assert ("name_is_bob", attached parsed.string ("name") as n and then n.is_equal ("Bob"))
				assert ("age_is_25", parsed.integer ("age") = 25)
				assert ("active_is_true", parsed.boolean ("active") = True)
				assert ("score_correct", (parsed.real ("score") - 98.5).abs < 0.001)
			end
		end

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

end
