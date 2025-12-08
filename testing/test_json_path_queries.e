note
	description: "Tests for JSONPath query functionality in SIMPLE_JSON"
	testing: "covers"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_json_path_queries.html"

class
	TEST_JSON_PATH_QUERIES

inherit
	TEST_SET_BASE
		redefine
			on_prepare
		end

feature {NONE} -- Events

	on_prepare
			-- <Precursor>
		do
			Precursor
		end

feature -- Test Sample Data

	sample_person_json: STRING_32
			-- Sample JSON for testing queries
		once
			Result := "[
{
	"person": {
		"name": "Alice",
		"age": 30,
		"city": "New York",
		"hobbies": ["reading", "coding", "hiking"],
		"address": {
			"street": "123 Main St",
			"zip": "10001"
		}
	}
}
]"
		end

	sample_array_json: STRING_32
			-- Sample JSON array for testing
		once
			Result := "[
{
	"people": [
		{"name": "Alice", "age": 30},
		{"name": "Bob", "age": 25},
		{"name": "Charlie", "age": 35}
	]
}
]"
		end

feature -- Basic Query Tests

	test_query_string_simple
			-- Test simple string query
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			name: detachable STRING_32
		do
			l_expected_output := "[
Name: Alice

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				name := json.query_string (value, "$.person.name")
				if attached name then
					l_actual_output.append_string ("Name: " + name + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_string_simple", l_expected_output, l_actual_output)
		end

	test_query_integer_simple
			-- Test simple integer query
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			age: INTEGER_64
		do
			l_expected_output := "[
Age: 30

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				age := json.query_integer (value, "$.person.age")
				l_actual_output.append_string ("Age: " + age.out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_integer_simple", l_expected_output, l_actual_output)
		end

	test_query_nested_string
			-- Test nested string query
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			street: detachable STRING_32
		do
			l_expected_output := "[
Street: 123 Main St

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				street := json.query_string (value, "$.person.address.street")
				if attached street then
					l_actual_output.append_string ("Street: " + street + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_nested_string", l_expected_output, l_actual_output)
		end

feature -- Array Query Tests

	test_query_array_element
			-- Test querying specific array element
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			hobby: detachable STRING_32
		do
			l_expected_output := "[
First hobby: reading

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				hobby := json.query_string (value, "$.person.hobbies[0]")
				if attached hobby then
					l_actual_output.append_string ("First hobby: " + hobby + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_array_element", l_expected_output, l_actual_output)
		end

	test_query_array_wildcard
			-- Test querying all array elements with wildcard
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			hobbies: ARRAYED_LIST [STRING_32]
			i: INTEGER
		do
			l_expected_output := "[
Hobbies: reading, coding, hiking

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				hobbies := json.query_strings (value, "$.person.hobbies[*]")
				l_actual_output.append_string ("Hobbies: ")
				from
					i := 1
				until
					i > hobbies.count
				loop
					l_actual_output.append_string (hobbies [i])
					if i < hobbies.count then
						l_actual_output.append_string (", ")
					end
					i := i + 1
				end
				l_actual_output.append_string ("%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_array_wildcard", l_expected_output, l_actual_output)
		end

	test_query_nested_array_field
			-- Test querying field from all objects in array
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			names: ARRAYED_LIST [STRING_32]
			i: INTEGER
		do
			l_expected_output := "[
Names: Alice, Bob, Charlie

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_array_json) as v then
				value := v
				names := json.query_strings (value, "$.people[*].name")
				l_actual_output.append_string ("Names: ")
				from
					i := 1
				until
					i > names.count
				loop
					l_actual_output.append_string (names [i])
					if i < names.count then
						l_actual_output.append_string (", ")
					end
					i := i + 1
				end
				l_actual_output.append_string ("%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_nested_array_field", l_expected_output, l_actual_output)
		end

	test_query_integers_from_array
			-- Test querying integers from array of objects
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			ages: ARRAYED_LIST [INTEGER_64]
			i: INTEGER
		do
			l_expected_output := "[
Ages: 30, 25, 35

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_array_json) as v then
				value := v
				ages := json.query_integers (value, "$.people[*].age")
				l_actual_output.append_string ("Ages: ")
				from
					i := 1
				until
					i > ages.count
				loop
					l_actual_output.append_string (ages [i].out)
					if i < ages.count then
						l_actual_output.append_string (", ")
					end
					i := i + 1
				end
				l_actual_output.append_string ("%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_integers_from_array", l_expected_output, l_actual_output)
		end

feature -- Edge Cases and Error Handling

	test_query_nonexistent_path
			-- Test querying nonexistent path returns Void
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
		do
			l_expected_output := "[
Result is void: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				l_actual_output.append_string ("Result is void: " + (json.query_string (value, "$.person.nonexistent") = Void).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_nonexistent_path", l_expected_output, l_actual_output)
		end

	test_query_wrong_type
			-- Test querying with wrong type expectation
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			age: INTEGER_64
		do
			l_expected_output := "[
String query on integer returns void: True
Integer query on string returns zero: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				l_actual_output.append_string ("String query on integer returns void: " +
					(json.query_string (value, "$.person.age") = Void).out + "%N")
				age := json.query_integer (value, "$.person.name")
				l_actual_output.append_string ("Integer query on string returns zero: " + (age = 0).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_wrong_type", l_expected_output, l_actual_output)
		end

	test_query_empty_result
			-- Test query that returns no results
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
			value: detachable SIMPLE_JSON_VALUE
			results: ARRAYED_LIST [STRING_32]
		do
			l_expected_output := "[
Results are empty: True
Count is zero: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse (sample_person_json) as v then
				value := v
				results := json.query_strings (value, "$.person.nonexistent[*]")
				l_actual_output.append_string ("Results are empty: " + results.is_empty.out + "%N")
				l_actual_output.append_string ("Count is zero: " + (results.count = 0).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("query_empty_result", l_expected_output, l_actual_output)
		end

note
	copyright: "2024, Larry Rix"
	license: "MIT License"
	testing: "Automated tests for JSONPath query functionality"

end
