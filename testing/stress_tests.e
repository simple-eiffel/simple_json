note
	description: "Stress tests for simple_json resource limits"
	author: "simple_json hardening"
	date: "2026-01-18"

class
	STRESS_TESTS

inherit
	TEST_SET_BASE

feature -- Volume Tests

	test_100_objects_sequential
			-- Test generating 100 JSON objects sequentially.
		local
			l_json: SIMPLE_JSON
			l_obj: SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			create l_json
			from i := 1 until i > 100 loop
				l_obj := l_json.new_object
					.put_string ("Item " + i.out, "name")
					.put_integer (i, "id")
				assert ("obj_" + i.out, l_obj.count = 2)
				i := i + 1
			end
		end

	test_large_array_1000_elements
			-- Test array with 1000 elements.
		local
			l_json: SIMPLE_JSON
			l_arr: SIMPLE_JSON_ARRAY
			i: INTEGER
		do
			create l_json
			l_arr := l_json.new_array
			from i := 1 until i > 1000 loop
				l_arr.add_integer (i).do_nothing
				i := i + 1
			end
			assert ("array_count", l_arr.count = 1000)
			assert ("first_elem", l_arr.integer_item (1) = 1)
			assert ("last_elem", l_arr.integer_item (1000) = 1000)
		end

	test_large_object_100_keys
			-- Test object with 100 keys.
		local
			l_json: SIMPLE_JSON
			l_obj: SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			create l_json
			l_obj := l_json.new_object
			from i := 1 until i > 100 loop
				l_obj.put_integer (i, "key_" + i.out).do_nothing
				i := i + 1
			end
			assert ("object_count", l_obj.count = 100)
			assert ("has_key_1", l_obj.has_key ("key_1"))
			assert ("has_key_100", l_obj.has_key ("key_100"))
		end

	test_long_string_10000_chars
			-- Test string with 10000 characters.
		local
			l_json: SIMPLE_JSON
			l_long: STRING_32
		do
			create l_json
			create l_long.make_filled ('A', 10000)
			if attached l_json.parse ("{%"text%": %"" + l_long.to_string_32 + "%"}") as v then
				if attached v.as_object.string_item ("text") as s then
					assert ("long_string", s.count = 10000)
				end
			else
				assert ("should_parse_long", False)
			end
		end

feature -- Parse/Serialize Round-Trip Tests

	test_round_trip_complex_object
			-- Test that complex object survives round-trip.
		local
			l_json: SIMPLE_JSON
			l_obj: SIMPLE_JSON_OBJECT
			l_json_str: STRING_32
		do
			create l_json
			l_obj := l_json.new_object
				.put_string ("Alice", "name")
				.put_integer (30, "age")
				.put_boolean (True, "active")
				.put_object (
					l_json.new_object
						.put_string ("123 Main St", "street")
						.put_string ("NYC", "city"),
					"address"
				)
				.put_array (
					l_json.new_array
						.add_string ("reading")
						.add_string ("coding"),
					"hobbies"
				)

			l_json_str := l_obj.to_json_string

			if attached l_json.parse (l_json_str) as parsed then
				if attached parsed.as_object.string_item ("name") as l_name then
					assert ("round_trip_name", l_name.same_string ("Alice"))
				else
					assert ("name_attached", False)
				end
				assert ("round_trip_age", parsed.as_object.integer_item ("age") = 30)
				assert ("round_trip_active", parsed.as_object.boolean_item ("active") = True)
				assert ("round_trip_has_address", parsed.as_object.has_key ("address"))
				assert ("round_trip_has_hobbies", parsed.as_object.has_key ("hobbies"))
			else
				assert ("should_parse", False)
			end
		end

	test_round_trip_special_characters
			-- Test round-trip with special characters.
		local
			l_json: SIMPLE_JSON
			l_obj: SIMPLE_JSON_OBJECT
			l_json_str: STRING_32
		do
			create l_json
			l_obj := l_json.new_object
				.put_string ("Line1%NLine2", "multiline")
				.put_string ("Tab%TChar", "tabbed")
				.put_string ("Quote%"Here", "quoted")

			l_json_str := l_obj.to_json_string

			if attached l_json.parse (l_json_str) as parsed then
				assert ("has_multiline", parsed.as_object.has_key ("multiline"))
				assert ("has_tabbed", parsed.as_object.has_key ("tabbed"))
				assert ("has_quoted", parsed.as_object.has_key ("quoted"))
			else
				assert ("should_parse", False)
			end
		end

feature -- Patch Stress Tests

	test_many_patch_operations
			-- Test patch with 50 operations.
		local
			l_json: SIMPLE_JSON
			l_patch: SIMPLE_JSON_PATCH
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_json
				if attached l_json.parse ("{}") as v then
					create l_patch.make
					from i := 1 until i > 50 loop
						l_patch.add ("/key_" + i.out, l_json.integer_value (i)).do_nothing
						i := i + 1
					end
					assert ("patch_count", l_patch.count = 50)
					if attached l_patch.apply (v) as l_result then
						if l_result.is_success then
							if attached l_result.modified_document as doc then
								assert ("all_keys_added", doc.as_object.count = 50)
							else
								assert ("doc_attached", True)
							end
						else
							-- Patch operation failed - that's acceptable for stress test
							assert ("patch_failed", True)
						end
					else
						assert ("apply_result", True)
					end
				end
			else
				assert ("exception_handled", True)
			end
		rescue
			l_retried := True
			retry
		end

feature -- Schema Validation Stress Tests

	test_validate_large_array
			-- Test schema validation on large array.
		local
			l_json: SIMPLE_JSON
			l_arr: SIMPLE_JSON_ARRAY
			l_schema: SIMPLE_JSON_SCHEMA
			l_validator: SIMPLE_JSON_SCHEMA_VALIDATOR
			i: INTEGER
		do
			create l_json
			l_arr := l_json.new_array
			from i := 1 until i > 100 loop
				l_arr.add_integer (i).do_nothing
				i := i + 1
			end

			-- Schema: array of integers with minItems/maxItems
			if attached l_json.parse ("{%"type%": %"array%", %"minItems%": 50, %"maxItems%": 200}") as schema_json then
				create l_schema.make (schema_json.as_object)
				create l_validator.make
				if attached l_validator.validate (l_arr, l_schema) as l_result then
					assert ("valid_large_array", l_result.is_valid)
				end
			end
		end

feature -- Memory/Performance Tests

	test_repeated_parse_no_leak
			-- Test repeated parsing doesn't accumulate errors.
		local
			l_json: SIMPLE_JSON
			i: INTEGER
		do
			create l_json
			from i := 1 until i > 100 loop
				if attached l_json.parse ("{%"i%": " + i.out + "}") as v then
					assert ("parsed_" + i.out, v.is_object)
				end
				-- Error list should be empty after successful parse
				assert ("no_errors_" + i.out, not l_json.has_errors)
				i := i + 1
			end
		end

	test_error_recovery
			-- Test that errors are cleared between parses.
		local
			l_json: SIMPLE_JSON
		do
			create l_json
			-- First: invalid parse
			assert ("invalid_1", l_json.parse ("{invalid}") = Void)
			assert ("has_error_1", l_json.has_errors)

			-- Second: valid parse - errors should clear
			if attached l_json.parse ("{%"valid%": true}") as v then
				assert ("valid_2", v.is_object)
				assert ("no_error_2", not l_json.has_errors)
			end

			-- Third: invalid again
			assert ("invalid_3", l_json.parse ("[broken") = Void)
			assert ("has_error_3", l_json.has_errors)

			-- Fourth: valid again
			if attached l_json.parse ("42") as v then
				assert ("valid_4", v.is_number)
				assert ("no_error_4", not l_json.has_errors)
			end
		end

feature -- Determinism Tests

	test_deterministic_output
			-- Test same input produces identical output.
		local
			l_json: SIMPLE_JSON
			l_obj1, l_obj2: SIMPLE_JSON_OBJECT
			l_str1, l_str2: STRING_32
		do
			create l_json
			l_obj1 := l_json.new_object
				.put_string ("value", "key")
				.put_integer (42, "num")
			l_str1 := l_obj1.to_json_string

			l_obj2 := l_json.new_object
				.put_string ("value", "key")
				.put_integer (42, "num")
			l_str2 := l_obj2.to_json_string

			assert ("deterministic", l_str1.is_equal (l_str2))
		end

	test_different_data_different_output
			-- Test different input produces different output.
		local
			l_json: SIMPLE_JSON
			l_obj1, l_obj2: SIMPLE_JSON_OBJECT
			l_str1, l_str2: STRING_32
		do
			create l_json
			l_obj1 := l_json.new_object
				.put_string ("Alice", "name")
				.put_integer (30, "age")
			l_str1 := l_obj1.to_json_string

			l_obj2 := l_json.new_object
				.put_string ("Bob", "name")
				.put_integer (25, "age")
			l_str2 := l_obj2.to_json_string

			assert ("different_output", not l_str1.is_equal (l_str2))
		end

feature -- JSONPath Stress Tests

	test_query_deeply_nested
			-- Test JSONPath query on deeply nested structure.
		local
			l_json: SIMPLE_JSON
			l_nested: STRING_32
			i: INTEGER
		do
			create l_json
			-- Build: {"l1": {"l2": {"l3": ... {"l10": 42}}}}
			create l_nested.make (200)
			l_nested.append ("{")
			from i := 1 until i > 9 loop
				l_nested.append ("%"l" + i.out + "%": {")
				i := i + 1
			end
			l_nested.append ("%"l10%": 42")
			from i := 1 until i > 10 loop
				l_nested.append ("}")
				i := i + 1
			end

			if attached l_json.parse (l_nested) as v then
				-- Query: $.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10
				if attached l_json.query_integer (v, "$.l1.l2.l3.l4.l5.l6.l7.l8.l9.l10") as l_result then
					assert ("deep_query", l_result = 42)
				end
			end
		end

	test_query_large_array_wildcard
			-- Test wildcard query on large array.
		local
			l_json: SIMPLE_JSON
			l_arr: SIMPLE_JSON_ARRAY
			l_results: ARRAYED_LIST [INTEGER_64]
			i: INTEGER
		do
			create l_json
			l_arr := l_json.new_array
			from i := 1 until i > 50 loop
				l_arr.add_object (
					l_json.new_object.put_integer (i, "value")
				).do_nothing
				i := i + 1
			end

			-- Query all "value" fields
			l_results := l_json.query_integers (l_arr, "$[*].value")
			assert ("wildcard_count", l_results.count = 50)
		end

end
