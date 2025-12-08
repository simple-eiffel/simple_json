note
	description: "Tests for SIMPLE_JSON library"
	testing: "covers"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_simple_json.html"

class
	TEST_SIMPLE_JSON

inherit
	TEST_SET_BASE

feature -- Test routines

	test_parse_simple_object
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": %"Alice%"}") as v then
				assert ("is_object", v.is_object)
				assert ("has_name", v.as_object.has_key ("name"))
				if attached v.as_object.string_item ("name") as s then
					assert_strings_equal ("name_is_alice", "Alice", s)
				else
					assert ("name_exists", False)
				end
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_object_with_types
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			if attached json.parse ("{%"str%": %"test%", %"num%": 42, %"bool%": true, %"null%": null}") as v then
				assert ("is_object", v.is_object)
				obj := v.as_object
				assert_integers_equal ("count_4", 4, obj.count)
				assert ("has_str", obj.has_key ("str"))
				assert ("has_num", obj.has_key ("num"))
				assert ("has_bool", obj.has_key ("bool"))
				assert ("has_null", obj.has_key ("null"))
			else
				assert ("parse_failed", False)
			end
		end

--	test_parse_array
--		local
--			json: SIMPLE_JSON
--		do
--			create json
--			if attached json.parse ("[1, 2, 3]") as v then
--				assert ("is_array", v.is_array)
--				assert_integers_equal ("count_3", 3, v.as_array.count)
--				assert_integers_equal ("first_is_1", 1, v.as_array.integer_item (1))
--				assert_integers_equal ("second_is_2", 2, v.as_array.integer_item (2))
--				assert_integers_equal ("third_is_3", 3, v.as_array.integer_item (3))
--			else
--				assert ("parse_failed", False)
--			end
--		end

	test_parse_empty_array
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("[]") as v then
				assert ("is_array", v.is_array)
				assert ("is_empty", v.as_array.is_empty)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_string
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("%"Hello%"") as v then
				assert ("is_string", v.is_string)
				assert_strings_equal ("value_hello", "Hello", v.as_string_32)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_number
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("42") as v then
				assert ("is_number", v.is_number)
				assert ("is_integer", v.is_integer)
				assert_integers_equal ("value_42", 42, v.as_integer.to_integer_32)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_real
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("3.14") as v then
				assert ("is_number", v.is_number)
				assert ("not_integer", not v.is_integer)
				assert ("value_314", (v.as_real - 3.14).abs < 0.001)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_boolean_true
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("true") as v then
				assert ("is_boolean", v.is_boolean)
				assert_booleans_equal ("value_true", True, v.as_boolean)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_boolean_false
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("false") as v then
				assert ("is_boolean", v.is_boolean)
				assert_booleans_equal ("value_false", False, v.as_boolean)
			else
				assert ("parse_failed", False)
			end
		end

	test_parse_null
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("null") as v then
				assert ("is_null", v.is_null)
			else
				assert ("parse_failed", False)
			end
		end

	test_build_object
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object
				.put_string ("Alice", "name")
				.put_integer (30, "age")
			assert_integers_equal ("count_2", 2, obj.count)
			assert ("has_name", obj.has_key ("name"))
			assert ("has_age", obj.has_key ("age"))
		end

	test_build_array
		local
			json: SIMPLE_JSON
			arr: SIMPLE_JSON_ARRAY
		do
			create json
			arr := json.new_array
				.add_string ("apple")
				.add_string ("banana")
				.add_integer (42)
			assert_integers_equal ("count_3", 3, arr.count)
		end

	test_fluent_object
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object
				.put_string ("A", "a")
				.put_string ("B", "b")
				.put_string ("C", "c")
			assert_integers_equal ("count_3", 3, obj.count)
		end

	test_fluent_array
		local
			json: SIMPLE_JSON
			arr: SIMPLE_JSON_ARRAY
		do
			create json
			arr := json.new_array
				.add_string ("A")
				.add_string ("B")
				.add_string ("C")
			assert_integers_equal ("count_3", 3, arr.count)
		end

	test_nested_object
		local
			json: SIMPLE_JSON
			person: SIMPLE_JSON_OBJECT
			address: SIMPLE_JSON_OBJECT
		do
			create json
			address := json.new_object
				.put_string ("123 Main St", "street")
				.put_string ("City", "city")
			person := json.new_object
				.put_string ("Charlie", "name")
				.put_object (address, "address")
			assert_integers_equal ("count_2", 2, person.count)
			assert_attached ("address_exists", person.object_item ("address"))
			if attached person.object_item ("address") as addr then
				assert ("address_has_street", addr.has_key ("street"))
			end
		end

	test_nested_array
		local
			json: SIMPLE_JSON
			person: SIMPLE_JSON_OBJECT
			hobbies: SIMPLE_JSON_ARRAY
		do
			create json
			hobbies := json.new_array
				.add_string ("reading")
				.add_string ("coding")
			person := json.new_object
				.put_string ("Diana", "name")
				.put_array (hobbies, "hobbies")
			assert_integers_equal ("count_2", 2, person.count)
			assert_attached ("hobbies_exists", person.array_item ("hobbies"))
			if attached person.array_item ("hobbies") as h then
				assert_integers_equal ("hobbies_count_2", 2, h.count)
			end
		end

	test_unicode_string
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object
				.put_string ("Hello", "english")
				.put_string ("你好", "chinese")
				.put_string ("Здравствуй", "russian")
			assert_integers_equal ("count_3", 3, obj.count)
			if attached obj.string_item ("chinese") as s then
				assert_strings_equal ("chinese_correct", "你好", s)
			else
				assert ("chinese_exists", False)
			end
		end

	test_type_checking_string
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("%"test%"") as v then
				assert ("is_string", v.is_string)
				assert ("not_number", not v.is_number)
				assert ("not_boolean", not v.is_boolean)
				assert ("not_null", not v.is_null)
				assert ("not_object", not v.is_object)
				assert ("not_array", not v.is_array)
			else
				assert ("parse_failed", False)
			end
		end

	test_type_checking_number
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("42") as v then
				assert ("is_number", v.is_number)
				assert ("is_integer", v.is_integer)
				assert ("not_string", not v.is_string)
			else
				assert ("parse_failed", False)
			end
		end

	test_type_checking_boolean
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("true") as v then
				assert ("is_boolean", v.is_boolean)
				assert ("not_number", not v.is_number)
				assert ("not_string", not v.is_string)
			else
				assert ("parse_failed", False)
			end
		end

	test_type_checking_null
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("null") as v then
				assert ("is_null", v.is_null)
				assert ("not_string", not v.is_string)
				assert ("not_number", not v.is_number)
			else
				assert ("parse_failed", False)
			end
		end

	test_type_checking_object
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{}") as v then
				assert ("is_object", v.is_object)
				assert ("not_array", not v.is_array)
			else
				assert ("parse_failed", False)
			end
		end

	test_type_checking_array
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("[]") as v then
				assert ("is_array", v.is_array)
				assert ("not_object", not v.is_object)
			else
				assert ("parse_failed", False)
			end
		end

	test_object_with_null
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object
				.put_string ("valid", "key1")
				.put_null ("key2")
			assert_integers_equal ("count_2", 2, obj.count)
			assert ("has_key2", obj.has_key ("key2"))
		end

	test_empty_string
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object.put_string ("", "empty")
			if attached obj.string_item ("empty") as s then
				assert ("is_empty", s.is_empty)
			else
				assert ("empty_exists", False)
			end
		end

	test_zero_integer
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object.put_integer (0, "zero")
			assert_integers_equal ("zero_value", 0, obj.integer_item ("zero").to_integer_32)
		end

	test_negative_integer
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
		do
			create json
			obj := json.new_object.put_integer (-42, "negative")
			assert_integers_equal ("negative_value", -42, obj.integer_item ("negative").to_integer_32)
		end

	test_object_keys
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			keys: ARRAY [STRING_32]
		do
			create json
			obj := json.new_object
				.put_string ("A", "key1")
				.put_string ("B", "key2")
			keys := obj.keys
			assert_integers_equal ("keys_count_2", 2, keys.count)
		end

	test_array_access
		local
			json: SIMPLE_JSON
			arr: SIMPLE_JSON_ARRAY
		do
			create json
			arr := json.new_array
				.add_string ("first")
				.add_integer (42)
				.add_boolean (True)
			if attached arr.string_item (1) as s then
				assert_strings_equal ("first_is_first", "first", s)
			else
				assert ("first_exists", False)
			end
			assert_integers_equal ("second_is_42", 42, arr.integer_item (2).to_integer_32)
			assert_booleans_equal ("third_is_true", True, arr.boolean_item (3))
		end

	test_to_json_string
		local
			json: SIMPLE_JSON
			obj: SIMPLE_JSON_OBJECT
			json_str: STRING_32
		do
			create json
			obj := json.new_object.put_string ("test", "key")
			json_str := obj.to_json_string
			assert ("json_not_empty", not json_str.is_empty)
		end

	test_is_valid_json
		local
			json: SIMPLE_JSON
		do
			create json
			assert ("valid_object", json.is_valid_json ("{%"key%": %"value%"}"))
			assert ("valid_array", json.is_valid_json ("[1, 2, 3]"))
			assert ("invalid_json", not json.is_valid_json ("not json"))
		end

end
