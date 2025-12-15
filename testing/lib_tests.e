note
	description: "Tests for SIMPLE_JSON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Parsing

	test_parse_object
			-- Test parsing JSON object.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": %"Alice%", %"age%": 30}") as v then
				assert_true ("is object", v.is_object)
				assert_integers_equal ("count", 2, v.as_object.count)
			else
				assert_true ("parse succeeded", False)
			end
		end

	test_parse_array
			-- Test parsing JSON array.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("[1, 2, 3]") as v then
				assert_true ("is array", v.is_array)
				assert_integers_equal ("count", 3, v.as_array.count)
			else
				assert_true ("parse succeeded", False)
			end
		end

	test_parse_string
			-- Test parsing JSON string.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("%"hello%"") as v then
				assert_true ("is string", v.is_string)
				assert_strings_equal ("value", "hello", v.as_string_32)
			else
				assert_true ("parse succeeded", False)
			end
		end

	test_parse_number
			-- Test parsing JSON number.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("42") as v then
				assert_true ("is number", v.is_number)
				assert_integers_equal ("value", 42, v.as_integer.to_integer_32)
			else
				assert_true ("parse succeeded", False)
			end
		end

	test_parse_boolean
			-- Test parsing JSON boolean.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("true") as v then
				assert_true ("is boolean", v.is_boolean)
				assert_true ("value is true", v.as_boolean)
			else
				assert_true ("parse succeeded", False)
			end
		end

	test_parse_null
			-- Test parsing JSON null.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("null") as v then
				assert_true ("is null", v.is_null)
			else
				assert_true ("parse succeeded", False)
			end
		end

feature -- Test: Generation

	test_to_json_object
			-- Test generating JSON from object.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.to_json"
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make
			obj.put_string ("Bob", "name").do_nothing
			obj.put_integer (25, "age").do_nothing
			assert_string_contains ("has name", obj.to_json_string, "%"name%"")
			assert_string_contains ("has age", obj.to_json_string, "%"age%"")
		end

	test_to_json_array
			-- Test generating JSON from array.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.to_json"
		local
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make
			arr.add_integer (1).do_nothing
			arr.add_integer (2).do_nothing
			arr.add_integer (3).do_nothing
			assert_strings_equal ("array json", "[1,2,3]", arr.to_json_string)
		end

feature -- Test: Object Operations

	test_object_has_key
			-- Test object key checking.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.has_key"
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make
			obj.put_string ("value1", "key1").do_nothing
			assert_true ("has key1", obj.has_key ("key1"))
			assert_false ("no key2", obj.has_key ("key2"))
		end

	test_object_remove
			-- Test object key removal.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.remove"
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make
			obj.put_string ("value", "key").do_nothing
			assert_true ("has key", obj.has_key ("key"))
			obj.remove ("key")
			assert_false ("key removed", obj.has_key ("key"))
		end

feature -- Test: Array Operations

	test_array_count
			-- Test array count.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.count"
		local
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make
			assert_integers_equal ("empty", 0, arr.count)
			arr.add_string ("item").do_nothing
			assert_integers_equal ("one item", 1, arr.count)
		end

	test_array_is_empty
			-- Test array empty check.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.is_empty"
		local
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make
			assert_true ("initially empty", arr.is_empty)
			arr.add_integer (1).do_nothing
			assert_false ("not empty after add", arr.is_empty)
		end

feature -- Test: Error Handling

	test_parse_invalid_json
			-- Test parsing invalid JSON.
		note
			testing: "covers/{SIMPLE_JSON}.parse"
		local
			json: SIMPLE_JSON
		do
			create json
			assert_void ("invalid json", json.parse ("{invalid}"))
			assert_true ("has error", json.has_errors)
		end

feature -- Test: Decimal Support

	test_object_put_decimal
			-- Test putting decimal value in object preserves precision.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.put_decimal"
		local
			obj: SIMPLE_JSON_OBJECT
			dec: SIMPLE_DECIMAL
		do
			create obj.make
			create dec.make ("19.99")
			obj.put_decimal (dec, "price").do_nothing

			assert_true ("has price", obj.has_key ("price"))
			-- JSON output should have exact value, not floating-point artifacts
			assert_string_contains ("exact value", obj.to_json_string, "19.99")
			assert_string_not_contains ("no fp error", obj.to_json_string, "19.989")
		end

	test_object_decimal_item
			-- Test retrieving decimal value from object.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.decimal_item"
		local
			obj: SIMPLE_JSON_OBJECT
			dec: SIMPLE_DECIMAL
			retrieved: detachable SIMPLE_DECIMAL
		do
			create obj.make
			create dec.make ("99.95")
			obj.put_decimal (dec, "amount").do_nothing

			retrieved := obj.decimal_item ("amount")
			assert_attached ("retrieved", retrieved)
			if attached retrieved as r then
				assert_strings_equal ("value", "99.95", r.to_string)
			end
		end

	test_array_add_decimal
			-- Test adding decimal to array.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_decimal"
		local
			arr: SIMPLE_JSON_ARRAY
			dec: SIMPLE_DECIMAL
		do
			create arr.make
			create dec.make ("3.14159")
			arr.add_decimal (dec).do_nothing

			assert_integers_equal ("count", 1, arr.count)
			assert_string_contains ("exact pi", arr.to_json_string, "3.14159")
		end

	test_array_decimal_item
			-- Test retrieving decimal from array.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.decimal_item"
		local
			arr: SIMPLE_JSON_ARRAY
			dec: SIMPLE_DECIMAL
			retrieved: detachable SIMPLE_DECIMAL
		do
			create arr.make
			create dec.make ("2.71828")
			arr.add_decimal (dec).do_nothing

			retrieved := arr.decimal_item (1)
			assert_attached ("retrieved", retrieved)
			if attached retrieved as r then
				assert_strings_equal ("value", "2.71828", r.to_string)
			end
		end

	test_value_as_decimal
			-- Test SIMPLE_JSON_VALUE.as_decimal.
		note
			testing: "covers/{SIMPLE_JSON_VALUE}.as_decimal"
		local
			obj: SIMPLE_JSON_OBJECT
			dec: SIMPLE_DECIMAL
		do
			create obj.make
			create dec.make ("42.5")
			obj.put_decimal (dec, "num").do_nothing

			if attached obj.item ("num") as v then
				assert_true ("is number", v.is_number)
				assert_strings_equal ("as_decimal", "42.5", v.as_decimal.to_string)
			else
				assert_true ("item exists", False)
			end
		end

	test_decimal_round_trip
			-- Test decimal survives JSON encode/decode.
		note
			testing: "covers/{JSON_DECIMAL}"
		local
			obj: SIMPLE_JSON_OBJECT
			dec: SIMPLE_DECIMAL
			json_str: STRING_32
			parser: SIMPLE_JSON
			retrieved: detachable SIMPLE_DECIMAL
		do
			create obj.make
			create dec.make ("123.456")
			obj.put_decimal (dec, "value").do_nothing

			json_str := obj.to_json_string

			create parser
			if attached parser.parse (json_str) as parsed and then parsed.is_object then
				retrieved := parsed.as_object.decimal_item ("value")
				assert_attached ("round trip", retrieved)
				if attached retrieved as r then
					assert_strings_equal ("preserved", "123.456", r.to_string)
				end
			else
				assert_true ("parse succeeded", False)
			end
		end

end
