note
	description: "Tests for JSON facade (JSON, JSON_BUILDER, JSON_QUERY)"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_JSON_FACADE

inherit
	EQA_TEST_SET

feature {NONE} -- Access

	json: JSON
			-- Shared JSON instance for all tests
		once
			create Result
		ensure
			instance_exists: attached Result
		end

feature -- JSON One-Liner Tests

	test_json_one_liner_string
			-- Test JSON.string one-liner access
		note
			testing: "covers/{JSON}.string"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"name%": %"Alice%", %"city%": %"NYC%"}"

			assert ("name_is_alice", attached JSON.string (l_json_string, "name") as n and then n.is_equal ("Alice"))
			assert ("city_is_nyc", attached JSON.string (l_json_string, "city") as c and then c.is_equal ("NYC"))
			assert ("missing_returns_void", JSON.string (l_json_string, "missing") = Void)
		end

	test_json_one_liner_integer
			-- Test JSON.integer one-liner access
		note
			testing: "covers/{JSON}.integer"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"age%": 30, %"count%": 100}"

			assert ("age_is_30", JSON.integer (l_json_string, "age") = 30)
			assert ("count_is_100", JSON.integer (l_json_string, "count") = 100)
			assert ("missing_returns_zero", JSON.integer (l_json_string, "missing") = 0)
		end

	test_json_one_liner_boolean
			-- Test JSON.boolean one-liner access
		note
			testing: "covers/{JSON}.boolean"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"active%": true, %"deleted%": false}"

			assert ("active_is_true", JSON.boolean (l_json_string, "active") = True)
			assert ("deleted_is_false", JSON.boolean (l_json_string, "deleted") = False)
			assert ("missing_returns_false", JSON.boolean (l_json_string, "missing") = False)
		end

	test_json_one_liner_real
			-- Test JSON.real one-liner access
		note
			testing: "covers/{JSON}.real"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"price%": 19.99, %"temperature%": -5.5}"

			assert ("price_correct", (JSON.real (l_json_string, "price") - 19.99).abs < 0.001)
			assert ("temp_correct", (JSON.real (l_json_string, "temperature") - (-5.5)).abs < 0.001)
			assert ("missing_returns_zero", JSON.real (l_json_string, "missing") = 0.0)
		end

feature -- JSON Path Navigation Tests

	test_json_path_string
			-- Test JSON.path_string for nested navigation
		note
			testing: "covers/{JSON}.path_string"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"user%": {%"address%": {%"city%": %"NYC%", %"state%": %"NY%"}}}"

			assert ("city_is_nyc", attached JSON.path_string (l_json_string, "user.address.city") as c and then c.is_equal ("NYC"))
			assert ("state_is_ny", attached JSON.path_string (l_json_string, "user.address.state") as s and then s.is_equal ("NY"))
			assert ("missing_path_void", JSON.path_string (l_json_string, "user.address.country") = Void)
		end

	test_json_path_integer
			-- Test JSON.path_integer for nested navigation
		note
			testing: "covers/{JSON}.path_integer"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"company%": {%"location%": {%"zip%": 10001}}}"

			assert ("zip_is_10001", JSON.path_integer (l_json_string, "company.location.zip") = 10001)
			assert ("missing_returns_zero", JSON.path_integer (l_json_string, "company.location.floor") = 0)
		end

	test_json_path_boolean
			-- Test JSON.path_boolean for nested navigation
		note
			testing: "covers/{JSON}.path_boolean"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"settings%": {%"notifications%": {%"email%": true}}}"

			assert ("email_is_true", JSON.path_boolean (l_json_string, "settings.notifications.email") = True)
		end

	test_json_path_real
			-- Test JSON.path_real for nested navigation
		note
			testing: "covers/{JSON}.path_real"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"data%": {%"metrics%": {%"score%": 98.5}}}"

			assert ("score_correct", (JSON.path_real (l_json_string, "data.metrics.score") - 98.5).abs < 0.001)
		end

	test_json_path_exists
			-- Test JSON.path_exists for checking nested paths
		note
			testing: "covers/{JSON}.path_exists"
		local
			l_json_string: STRING
		do
			l_json_string := "{%"user%": {%"name%": %"Alice%", %"age%": 30}}"

			assert ("user_name_exists", JSON.path_exists (l_json_string, "user.name"))
			assert ("user_age_exists", JSON.path_exists (l_json_string, "user.age"))
			assert ("user_email_not_exists", not JSON.path_exists (l_json_string, "user.email"))
			assert ("invalid_path_not_exists", not JSON.path_exists (l_json_string, "user.address.city"))
		end

feature -- JSON Validation Tests

	test_json_is_valid
			-- Test JSON.is_valid for validation
		note
			testing: "covers/{JSON}.is_valid"
		do
			assert ("valid_simple", JSON.is_valid ("{%"key%": %"value%"}"))
			assert ("valid_nested", JSON.is_valid ("{%"a%": {%"b%": 1}}"))
			assert ("valid_array", JSON.is_valid ("{%"items%": [1, 2, 3]}"))
			assert ("valid_empty", JSON.is_valid ("{}"))

			assert ("invalid_malformed", not JSON.is_valid ("{invalid}"))
			assert ("invalid_unclosed", not JSON.is_valid ("{%"key%": "))
		end

	test_json_validate
			-- Test JSON.validate for detailed validation
		note
			testing: "covers/{JSON}.validate"
		local
			l_result: TUPLE[valid: BOOLEAN; error: detachable STRING]
		do
			-- Valid JSON
			l_result := JSON.validate ("{%"key%": %"value%"}")
			assert ("valid_result_true", l_result.valid)
			assert ("valid_no_error", l_result.error = Void)

			-- Invalid JSON
			l_result := JSON.validate ("{invalid json}")
			assert ("invalid_result_false", not l_result.valid)
			assert ("invalid_has_error", l_result.error /= Void)
		end

feature -- JSON_BUILDER Tests

	test_json_builder_fluent
			-- Test JSON_BUILDER fluent interface
		note
			testing: "covers/{JSON}.build"
			testing: "covers/{JSON_BUILDER}.to_string"
		local
			l_builder: JSON_BUILDER
			l_json_string: STRING
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			l_builder := JSON.build
			l_json_string := l_builder
				.put_string ("name", "Bob")
				.put_integer ("age", 25)
				.put_boolean ("active", True)
				.put_real ("score", 95.5)
				.to_string

			assert ("json_string_not_empty", not l_json_string.is_empty)

			-- Parse back and verify
			l_obj := JSON.parse (l_json_string)
			assert ("parsed_not_void", l_obj /= Void)

			if attached l_obj as obj then
				assert ("name_is_bob", attached obj.string ("name") as n and then n.is_equal ("Bob"))
				assert ("age_is_25", obj.integer ("age") = 25)
				assert ("active_is_true", obj.boolean ("active") = True)
				assert ("score_correct", (obj.real ("score") - 95.5).abs < 0.001)
			end
		end

	test_json_builder_build
			-- Test JSON_BUILDER.build returns object
		note
			testing: "covers/{JSON_BUILDER}.build"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			l_builder := JSON.build
			l_obj := l_builder
				.put_string ("key1", "value1")
				.put_integer ("key2", 42)
				.build

			assert ("object_not_void", l_obj /= Void)
			assert ("has_key1", l_obj.has_key ("key1"))
			assert ("has_key2", l_obj.has_key ("key2"))
			assert ("count_is_two", l_obj.count = 2)
		end

	test_json_builder_empty
			-- Test building empty JSON object
		note
			testing: "covers/{JSON_BUILDER}.to_string"
		local
			l_builder: JSON_BUILDER
			l_json_string: STRING
		do
			l_builder := JSON.build
			l_json_string := l_builder.to_string

			assert ("empty_json_valid", JSON.is_valid (l_json_string))
			if attached JSON.parse (l_json_string) as obj then
				assert ("empty_object", obj.is_empty)
			end
		end

feature -- JSON_QUERY Tests

	test_json_query_basic
			-- Test JSON_QUERY basic access
		note
			testing: "covers/{JSON}.query"
			testing: "covers/{JSON_QUERY}.string"
			testing: "covers/{JSON_QUERY}.integer"
			testing: "covers/{JSON_QUERY}.boolean"
			testing: "covers/{JSON_QUERY}.real"
		local
			l_query: JSON_QUERY
			l_json_string: STRING
		do
			l_json_string := "{%"name%": %"Charlie%", %"age%": 35, %"active%": true, %"score%": 88.5}"
			l_query := JSON.query (l_json_string)

			assert ("name_is_charlie", attached l_query.string ("name") as n and then n.is_equal ("Charlie"))
			assert ("age_is_35", l_query.integer ("age") = 35)
			assert ("active_is_true", l_query.boolean ("active") = True)
			assert ("score_correct", (l_query.real ("score") - 88.5).abs < 0.001)
		end

	test_json_query_exists
			-- Test JSON_QUERY.exists
		note
			testing: "covers/{JSON_QUERY}.exists"
		local
			l_query: JSON_QUERY
			l_json_string: STRING
		do
			l_json_string := "{%"name%": %"Alice%", %"age%": 30}"
			l_query := JSON.query (l_json_string)

			assert ("name_exists", l_query.exists ("name"))
			assert ("age_exists", l_query.exists ("age"))
			assert ("email_not_exists", not l_query.exists ("email"))
		end

	test_json_query_nested
			-- Test JSON_QUERY with nested objects
		note
			testing: "covers/{JSON_QUERY}.object"
		local
			l_query: JSON_QUERY
			l_json_string: STRING
			l_user: detachable SIMPLE_JSON_OBJECT
		do
			l_json_string := "{%"user%": {%"name%": %"Bob%", %"age%": 40}}"
			l_query := JSON.query (l_json_string)

			l_user := l_query.object ("user")
			assert ("user_not_void", l_user /= Void)

			if attached l_user as user then
				assert ("user_name_bob", attached user.string ("name") as n and then n.is_equal ("Bob"))
				assert ("user_age_40", user.integer ("age") = 40)
			end
		end

	test_json_query_array
			-- Test JSON_QUERY with arrays
		note
			testing: "covers/{JSON_QUERY}.array"
		local
			l_query: JSON_QUERY
			l_json_string: STRING
			l_arr: detachable SIMPLE_JSON_ARRAY
		do
			l_json_string := "{%"numbers%": [1, 2, 3, 4, 5]}"
			l_query := JSON.query (l_json_string)

			l_arr := l_query.array ("numbers")
			assert ("array_not_void", l_arr /= Void)

			if attached l_arr as arr then
				assert ("array_count_five", arr.count = 5)
				assert ("first_is_1", arr.integer_at (1) = 1)
				assert ("last_is_5", arr.integer_at (5) = 5)
			end
		end

feature -- Integration Tests

	test_json_object_creation
			-- Test JSON.object for manual construction
		note
			testing: "covers/{JSON}.object"
		local
			l_obj: SIMPLE_JSON_OBJECT
		do
			l_obj := JSON.object
			assert ("object_not_void", l_obj /= Void)
			assert ("object_empty", l_obj.is_empty)

			l_obj.put_string ("test", "value")
			assert ("object_not_empty", not l_obj.is_empty)
		end

	test_json_array_creation
			-- Test JSON.array creation
		note
			testing: "covers/{JSON}.array"
		local
			l_arr: SIMPLE_JSON_ARRAY
		do
			l_arr := JSON.array
			assert ("array_not_void", l_arr /= Void)
			assert ("array_empty", l_arr.is_empty)
		end

	test_json_parse_full_api
			-- Test JSON.parse for full API access
		note
			testing: "covers/{JSON}.parse"
		local
			l_json_string: STRING
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			l_json_string := "{%"name%": %"Test%"}"
			l_obj := JSON.parse (l_json_string)

			assert ("parsed_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("has_name", obj.has_key ("name"))
				obj.put_string ("added", "new_value")
				assert ("has_added", obj.has_key ("added"))
			end
		end

	test_builder_and_query_integration
			-- Test building with JSON_BUILDER and querying with JSON_QUERY
		note
			testing: "covers/{JSON}.build"
			testing: "covers/{JSON}.query"
		local
			l_json_string: STRING
			l_query: JSON_QUERY
		do
			-- Build JSON
			l_json_string := JSON.build
				.put_string ("name", "Integration")
				.put_integer ("value", 99)
				.to_string

			-- Query it
			l_query := JSON.query (l_json_string)
			assert ("name_matches", attached l_query.string ("name") as n and then n.is_equal ("Integration"))
			assert ("value_matches", l_query.integer ("value") = 99)
		end

end
