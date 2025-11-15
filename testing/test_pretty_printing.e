note
	description: "Tests for SIMPLE_JSON pretty printing functionality"
	testing: "type/manual"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_pretty_printing.html"

class
	TEST_PRETTY_PRINTING

inherit
	TEST_SET_BASE

feature -- Test routines: Basic types

	test_pretty_print_simple_string
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			l_expected, pretty: STRING_32
		do
			l_expected := "%"Hello, World!%""
			create json
			value := json.parse (l_expected)
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("contains_hello", pretty.has_substring ("Hello, World!"))
				assert_strings_equal_diff ("hello_diffed", l_expected, pretty)
			end
		end

	test_pretty_print_number
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("42")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("contains_42", pretty.has_substring ("42"))
			end
		end

	test_pretty_print_boolean_true
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("true")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("contains_true", pretty.has_substring ("true"))
			end
		end

	test_pretty_print_boolean_false
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("false")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("contains_false", pretty.has_substring ("false"))
			end
		end

	test_pretty_print_null
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("null")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("contains_null", pretty.has_substring ("null"))
			end
		end

feature -- Test routines: Empty structures

	test_pretty_print_empty_object
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("{}")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("is_empty_object", pretty.same_string ("{}"))
			end
		end

	test_pretty_print_empty_array
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("[]")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("is_empty_array", pretty.same_string ("[]"))
			end
		end

feature -- Test routines: Simple structures

	test_pretty_print_simple_object
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("{%"name%":%"Alice%",	%"age%":30}")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("has_newlines", pretty.has ('%N'))
				assert ("contains_name", pretty.has_substring ("name"))
				assert ("contains_alice", pretty.has_substring ("Alice"))
				assert ("contains_age", pretty.has_substring ("age"))
				assert ("contains_30", pretty.has_substring ("30"))
			end
		end

	test_pretty_print_simple_array
		local
			json: SIMPLE_JSON
			value: detachable SIMPLE_JSON_VALUE
			pretty: STRING_32
		do
			create json
			value := json.parse ("[1,2,3]")
			assert_attached ("value_parsed", value)
			if attached value as v then
				pretty := v.to_pretty_json
				assert ("has_newlines", pretty.has ('%N'))
				assert ("contains_1", pretty.has_substring ("1"))
				assert ("contains_2", pretty.has_substring ("2"))
				assert ("contains_3", pretty.has_substring ("3"))
			end
		end

feature -- Test routines: Nested structures

	test_pretty_print_nested_object
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			address: SIMPLE_JSON_OBJECT
			pretty: STRING_32
			lines: LIST [STRING_32]
		do
			create json
			address := json.new_object
				.put_string ("123 Main St", "street")
				.put_string ("Springfield", "city")
			obj := json.new_object
				.put_string ("Bob", "name")
				.put_object (address, "address")

			pretty := obj.to_pretty_json

			-- Should have multiple lines
			lines := pretty.split ('%N')
			assert ("multiple_lines", lines.count > 5)

			-- Should contain all data
			assert ("contains_name", pretty.has_substring ("name"))
			assert ("contains_bob", pretty.has_substring ("Bob"))
			assert ("contains_address", pretty.has_substring ("address"))
			assert ("contains_street", pretty.has_substring ("street"))
			assert ("contains_main_st", pretty.has_substring ("123 Main St"))
			assert ("contains_city", pretty.has_substring ("city"))
			assert ("contains_springfield", pretty.has_substring ("Springfield"))
		end

	test_pretty_print_nested_array
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			hobbies: SIMPLE_JSON_ARRAY
			pretty: STRING_32
		do
			create json
			hobbies := json.new_array
				.add_string ("reading")
				.add_string ("coding")
				.add_string ("gaming")
			obj := json.new_object
				.put_string ("Charlie", "name")
				.put_array (hobbies, "hobbies")

			pretty := obj.to_pretty_json

			assert ("has_newlines", pretty.has ('%N'))
			assert ("contains_name", pretty.has_substring ("name"))
			assert ("contains_charlie", pretty.has_substring ("Charlie"))
			assert ("contains_hobbies", pretty.has_substring ("hobbies"))
			assert ("contains_reading", pretty.has_substring ("reading"))
			assert ("contains_coding", pretty.has_substring ("coding"))
			assert ("contains_gaming", pretty.has_substring ("gaming"))
		end

	test_pretty_print_deeply_nested
		local
			json: SIMPLE_JSON
			root: SIMPLE_JSON_OBJECT
			level1: SIMPLE_JSON_OBJECT
			level2: SIMPLE_JSON_OBJECT
			pretty: STRING_32
			lines: LIST [STRING_32]
		do
			create json
			level2 := json.new_object.put_string ("deep", "level")
			level1 := json.new_object.put_object (level2, "nested")
			root := json.new_object.put_object (level1, "data")

			pretty := root.to_pretty_json

			lines := pretty.split ('%N')
			assert ("many_lines", lines.count >= 7)
			assert ("contains_data", pretty.has_substring ("data"))
			assert ("contains_nested", pretty.has_substring ("nested"))
			assert ("contains_level", pretty.has_substring ("level"))
			assert ("contains_deep", pretty.has_substring ("deep"))
		end

feature -- Test routines: Array of objects

	test_pretty_print_array_of_objects
		local
			json: SIMPLE_JSON
			arr: SIMPLE_JSON_ARRAY
			person1, person2: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			person1 := json.new_object
				.put_string ("Alice", "name")
				.put_integer (30, "age")
			person2 := json.new_object
				.put_string ("Bob", "name")
				.put_integer (25, "age")
			arr := json.new_array
				.add_object (person1)
				.add_object (person2)

			pretty := arr.to_pretty_json

			assert ("has_newlines", pretty.has ('%N'))
			assert ("contains_alice", pretty.has_substring ("Alice"))
			assert ("contains_bob", pretty.has_substring ("Bob"))
			assert ("contains_30", pretty.has_substring ("30"))
			assert ("contains_25", pretty.has_substring ("25"))
		end

	test_pretty_print_object_with_array_of_objects
		local
			json: SIMPLE_JSON
			root: SIMPLE_JSON_OBJECT
			people: SIMPLE_JSON_ARRAY
			person1, person2: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			person1 := json.new_object.put_string ("Diana", "name")
			person2 := json.new_object.put_string ("Eve", "name")
			people := json.new_array
				.add_object (person1)
				.add_object (person2)
			root := json.new_object.put_array (people, "team")

			pretty := root.to_pretty_json

			assert ("has_newlines", pretty.has ('%N'))
			assert ("contains_team", pretty.has_substring ("team"))
			assert ("contains_diana", pretty.has_substring ("Diana"))
			assert ("contains_eve", pretty.has_substring ("Eve"))
		end

feature -- Test routines: Custom indentation

	test_pretty_print_with_tabs
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object
				.put_string ("test", "key1")
				.put_integer (42, "key2")

			pretty := obj.to_pretty_json_with_tabs

			assert ("has_tabs", pretty.has ('%T'))
			assert ("contains_key1", pretty.has_substring ("key1"))
			assert ("contains_test", pretty.has_substring ("test"))
		end

	test_pretty_print_with_4_spaces
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object
				.put_string ("test", "key1")
				.put_integer (42, "key2")

			pretty := obj.to_pretty_json_with_spaces (4)

			assert ("has_spaces", pretty.has (' '))
			assert ("contains_key1", pretty.has_substring ("key1"))
			assert ("contains_test", pretty.has_substring ("test"))
		end

	test_pretty_print_with_custom_indent
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object
				.put_string ("test", "key1")
				.put_integer (42, "key2")

			pretty := obj.to_pretty_json_with_indent ("    ")

			assert ("contains_key1", pretty.has_substring ("key1"))
			assert ("contains_test", pretty.has_substring ("test"))
			assert ("has_newlines", pretty.has ('%N'))
		end

feature -- Test routines: Mixed types

	test_pretty_print_mixed_types
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object
				.put_string ("text", "str")
				.put_integer (42, "num")
				.put_real (3.14, "pi")
				.put_boolean (True, "flag")
				.put_null ("empty")

			pretty := obj.to_pretty_json

			assert ("contains_str", pretty.has_substring ("str"))
			assert ("contains_text", pretty.has_substring ("text"))
			assert ("contains_num", pretty.has_substring ("num"))
			assert ("contains_42", pretty.has_substring ("42"))
			assert ("contains_pi", pretty.has_substring ("pi"))
			assert ("contains_314", pretty.has_substring ("3.14"))
			assert ("contains_flag", pretty.has_substring ("flag"))
			assert ("contains_true", pretty.has_substring ("true"))
			assert ("contains_empty", pretty.has_substring ("empty"))
			assert ("contains_null", pretty.has_substring ("null"))
		end

feature -- Test routines: Unicode

	test_pretty_print_unicode
			-- Test that \uNNNN codes are translated to actual Unicode characters
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
			reparsed: detachable SIMPLE_JSON_VALUE
			chinese, russian, arabic: STRING_32
		do
			create json

			-- Create Unicode strings explicitly
			create chinese.make_from_string ("你好")
			create russian.make_from_string ("Здравствуй")
			create arabic.make_from_string ("مرحبا")

			obj := json.new_object
				.put_string ("Hello", "english")
				.put_string (chinese, "chinese")
				.put_string (russian, "russian")
				.put_string (arabic, "arabic")

			pretty := obj.to_pretty_json

			-- Pretty print should translate \uNNNN codes to actual characters
			assert ("pretty_not_empty", not pretty.is_empty)
			assert ("has_newlines", pretty.has ('%N'))
			assert ("contains_literal_chinese", pretty.has_substring (chinese))
			assert ("contains_literal_russian", pretty.has_substring (russian))
			assert ("contains_literal_arabic", pretty.has_substring (arabic))

			-- Round-trip test: parse the pretty output and verify values preserved
			reparsed := json.parse (pretty)
			assert_attached ("reparsed_successfully", reparsed)

			if attached reparsed as v then
				assert ("is_object", v.is_object)
				if attached v.as_object.string_item ("chinese") as s then
					assert_strings_equal ("chinese_preserved", chinese, s)
				else
					assert ("chinese_exists", False)
				end
				if attached v.as_object.string_item ("russian") as s then
					assert_strings_equal ("russian_preserved", russian, s)
				else
					assert ("russian_exists", False)
				end
				if attached v.as_object.string_item ("arabic") as s then
					assert_strings_equal ("arabic_preserved", arabic, s)
				else
					assert ("arabic_exists", False)
				end
			end
		end

	test_pretty_print_unicode_basic
			-- Test that Unicode strings display as actual characters (not \uNNNN)
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json

			obj := json.new_object
				.put_string ("Hello", "english")
				.put_string ("你好", "chinese")

			pretty := obj.to_pretty_json

			-- Verify actual Unicode characters appear in output
			assert ("pretty_not_empty", not pretty.is_empty)
			assert ("contains_chinese_key", pretty.has_substring ("chinese"))
			assert ("contains_english_key", pretty.has_substring ("english"))
			assert ("contains_chinese_value", pretty.has_substring ("你好"))
		end

feature -- Test routines: Edge cases

	test_pretty_print_with_empty_string
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object.put_string ("", "empty")

			pretty := obj.to_pretty_json

			assert ("contains_empty", pretty.has_substring ("empty"))
			assert ("has_empty_quotes", pretty.has_substring ("%"%""))
		end

	test_pretty_print_with_zero
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object.put_integer (0, "zero")

			pretty := obj.to_pretty_json

			assert ("contains_zero_key", pretty.has_substring ("zero"))
			assert ("contains_zero_value", pretty.has_substring ("0"))
		end

	test_pretty_print_negative_number
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
		do
			create json
			obj := json.new_object.put_integer (-42, "negative")

			pretty := obj.to_pretty_json

			assert ("contains_negative", pretty.has_substring ("negative"))
			assert ("contains_minus_42", pretty.has_substring ("-42"))
		end

feature -- Test routines: Consistency

	test_pretty_print_reparseable
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty: STRING_32
			reparsed: detachable SIMPLE_JSON_VALUE
		do
			create json
			obj := json.new_object
				.put_string ("Alice", "name")
				.put_integer (30, "age")
				.put_boolean (True, "active")

			pretty := obj.to_pretty_json
			reparsed := json.parse (pretty)

			assert_attached ("reparsed_successfully", reparsed)
			if attached reparsed as v then
				assert ("still_object", v.is_object)
				assert ("has_name", v.as_object.has_key ("name"))
				assert ("has_age", v.as_object.has_key ("age"))
				assert ("has_active", v.as_object.has_key ("active"))
			end
		end

	test_pretty_vs_compact
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			pretty, compact: STRING_32
		do
			create json
			obj := json.new_object
				.put_string ("test", "key")
				.put_integer (42, "num")

			pretty := obj.to_pretty_json
			compact := obj.to_json_string

			-- Pretty should be longer (has whitespace)
			assert ("pretty_longer", pretty.count > compact.count)

			-- Pretty should have newlines, compact shouldn't
			assert ("pretty_has_newlines", pretty.has ('%N'))
		end

end
