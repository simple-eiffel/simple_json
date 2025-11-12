note
	description: "Tests for JSON generation and serialization in SIMPLE_JSON"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_GENERATION

inherit
	EQA_TEST_SET

feature -- Generation Tests

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

	test_round_trip_simple
			-- Test creating object, serializing, and parsing back
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.to_json_string"
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_obj1: SIMPLE_JSON_OBJECT
			l_json_string: STRING
			l_json: SIMPLE_JSON
			l_obj2: detachable SIMPLE_JSON_OBJECT
		do
			-- Create object
			create l_obj1.make_empty
			l_obj1.put_string ("name", "Charlie")
			l_obj1.put_integer ("score", 95)
			l_obj1.put_boolean ("passed", True)

			-- Serialize
			l_json_string := l_obj1.to_json_string

			-- Parse back
			create l_json
			l_obj2 := l_json.parse (l_json_string)

			-- Verify
			assert ("parsed_not_void", l_obj2 /= Void)
			if attached l_obj2 as obj then
				assert ("name_preserved", attached obj.string ("name") as n and then n.is_equal ("Charlie"))
				assert ("score_preserved", obj.integer ("score") = 95)
				assert ("passed_preserved", obj.boolean ("passed") = True)
			end
		end

	test_round_trip_all_types
			-- Test round-trip with all data types
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.to_json_string"
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_obj1: SIMPLE_JSON_OBJECT
			l_json_string: STRING
			l_json: SIMPLE_JSON
			l_obj2: detachable SIMPLE_JSON_OBJECT
		do
			-- Create complex object with all types
			create l_obj1.make_empty
			l_obj1.put_string ("text", "Hello World")
			l_obj1.put_integer ("count", 42)
			l_obj1.put_boolean ("flag", False)
			l_obj1.put_real ("temperature", -5.5)

			-- Round trip
			l_json_string := l_obj1.to_json_string
			create l_json
			l_obj2 := l_json.parse (l_json_string)

			-- Verify all types preserved
			assert ("parsed_not_void", l_obj2 /= Void)
			if attached l_obj2 as obj then
				assert ("count_matches", obj.count = 4)
				assert ("text_preserved", attached obj.string ("text") as t and then t.is_equal ("Hello World"))
				assert ("count_preserved", obj.integer ("count") = 42)
				assert ("flag_preserved", obj.boolean ("flag") = False)
				assert ("temp_preserved", (obj.real ("temperature") - (-5.5)).abs < 0.001)
			end
		end

	test_modify_existing_key
			-- Test updating existing key value
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.put_string"
		local
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			l_obj.put_string ("status", "pending")
			assert ("initial_value", attached l_obj.string ("status") as s and then s.is_equal ("pending"))
			assert ("count_one", l_obj.count = 1)

			-- Update existing key
			l_obj.put_string ("status", "completed")
			assert ("updated_value", attached l_obj.string ("status") as s and then s.is_equal ("completed"))
			assert ("count_still_one", l_obj.count = 1)
		end

	test_build_object_incrementally
			-- Test building JSON object step by step
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.put_string"
			testing: "covers/{SIMPLE_JSON_OBJECT}.put_integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.put_boolean"
		local
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			assert ("starts_empty", l_obj.is_empty)

			l_obj.put_string ("step", "1")
			assert ("has_one_key", l_obj.count = 1)
			assert ("not_empty", not l_obj.is_empty)

			l_obj.put_integer ("value", 100)
			assert ("has_two_keys", l_obj.count = 2)

			l_obj.put_boolean ("complete", False)
			assert ("has_three_keys", l_obj.count = 3)

			-- Verify all values
			assert ("step_is_1", attached l_obj.string ("step") as s and then s.is_equal ("1"))
			assert ("value_is_100", l_obj.integer ("value") = 100)
			assert ("complete_is_false", l_obj.boolean ("complete") = False)
		end

	test_empty_object_serialization
			-- Test serializing empty object
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.to_json_string"
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_json_string: STRING
			l_json: SIMPLE_JSON
			l_parsed: detachable SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			l_json_string := l_obj.to_json_string

			-- Should produce "{}"
			assert ("not_empty_string", not l_json_string.is_empty)

			-- Should parse back successfully
			create l_json
			l_parsed := l_json.parse (l_json_string)
			assert ("parsed_not_void", l_parsed /= Void)
			if attached l_parsed as p then
				assert ("parsed_is_empty", p.is_empty)
			end
		end

end
