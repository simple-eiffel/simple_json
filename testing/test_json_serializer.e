note
	description: "Tests for SIMPLE_JSON_SERIALIZER"

class
	TEST_JSON_SERIALIZER

inherit
	TEST_SET_BASE

feature -- Test

	test_serialize_simple_object
			-- Test serializing a simple object.
		local
			l_serializer: SIMPLE_JSON_SERIALIZER
			l_person: TEST_SERIALIZER_PERSON
			l_json: SIMPLE_JSON_OBJECT
		do
			create l_serializer.make
			create l_person.make ("John", 30)
			l_json := l_serializer.to_json (l_person)

			if attached l_json.string_item ("name") as l_name then
				assert_strings_equal ("name_field", "John", l_name)
			else
				assert ("name_exists", False)
			end
			assert_integers_equal ("age_field", 30, l_json.integer_item ("age").to_integer_32)
		end

	test_serialize_nested_object
			-- Test serializing nested objects.
		local
			l_serializer: SIMPLE_JSON_SERIALIZER
			l_person: TEST_SERIALIZER_PERSON
			l_address: TEST_SERIALIZER_ADDRESS
			l_json: SIMPLE_JSON_OBJECT
		do
			create l_serializer.make
			create l_address.make ("123 Main St", "NYC")
			create l_person.make_with_address ("Jane", 25, l_address)
			l_json := l_serializer.to_json (l_person)

			if attached l_json.string_item ("name") as l_name then
				assert_strings_equal ("name", "Jane", l_name)
			else
				assert ("name_exists", False)
			end
			if attached l_json.object_item ("address") as l_obj then
				if attached l_obj.string_item ("street") as l_street then
					assert_strings_equal ("street", "123 Main St", l_street)
				else
					assert ("street_exists", False)
				end
				if attached l_obj.string_item ("city") as l_city then
					assert_strings_equal ("city", "NYC", l_city)
				else
					assert ("city_exists", False)
				end
			else
				assert ("address_exists", False)
			end
		end

	test_serialize_to_string
			-- Test converting to JSON string.
		local
			l_serializer: SIMPLE_JSON_SERIALIZER
			l_person: TEST_SERIALIZER_PERSON
			l_json_str: STRING_32
		do
			create l_serializer.make
			create l_person.make ("Bob", 40)
			l_json_str := l_serializer.to_json_string (l_person)

			assert ("contains_name", l_json_str.has_substring ("Bob"))
			assert ("contains_age", l_json_str.has_substring ("40"))
		end

	test_exclude_field
			-- Test field exclusion.
		local
			l_serializer: SIMPLE_JSON_SERIALIZER
			l_person: TEST_SERIALIZER_PERSON
			l_json: SIMPLE_JSON_OBJECT
		do
			create l_serializer.make
			l_serializer.exclude_field ("age")
			create l_person.make ("Alice", 35)
			l_json := l_serializer.to_json (l_person)

			if attached l_json.string_item ("name") as l_name then
				assert_strings_equal ("name_present", "Alice", l_name)
			else
				assert ("name_exists", False)
			end
			assert ("age_excluded", not l_json.has_key ("age"))
		end

end
