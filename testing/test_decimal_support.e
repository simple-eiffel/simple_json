note
	description: "Tests for SIMPLE_DECIMAL integration in simple_json"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_DECIMAL_SUPPORT

inherit
	TEST_SET_BASE

feature -- Tests: JSON_DECIMAL

	test_json_decimal_creation
			-- Test JSON_DECIMAL creation from SIMPLE_DECIMAL
		local
			l_decimal: SIMPLE_DECIMAL
			l_json_decimal: JSON_DECIMAL
		do
			create l_decimal.make ("19.99")
			create l_json_decimal.make_decimal (l_decimal)

			assert_strings_equal ("representation", "19.99", l_json_decimal.representation)
			assert ("is_real", l_json_decimal.is_real)
			assert ("is_number", l_json_decimal.is_number)
		end

	test_json_decimal_from_string
			-- Test JSON_DECIMAL creation from string
		local
			l_json_decimal: JSON_DECIMAL
		do
			create l_json_decimal.make_from_string ("123.456")

			assert_strings_equal ("representation", "123.456", l_json_decimal.representation)
		end

	test_json_decimal_precision_preserved
			-- Test that decimal precision is preserved (no floating-point errors)
		local
			l_decimal: SIMPLE_DECIMAL
			l_json_decimal: JSON_DECIMAL
		do
			-- This is the classic floating-point problem: 0.1 + 0.2 != 0.3
			create l_decimal.make ("0.3")
			create l_json_decimal.make_decimal (l_decimal)

			-- Should be exactly "0.3", not "0.30000000000000004"
			assert_strings_equal ("exact_0.3", "0.3", l_json_decimal.representation)

			-- Test currency value that often fails with REAL
			create l_decimal.make ("19.99")
			create l_json_decimal.make_decimal (l_decimal)
			assert_strings_equal ("exact_19.99", "19.99", l_json_decimal.representation)
		end

feature -- Tests: SIMPLE_JSON_OBJECT decimal

	test_object_put_decimal
			-- Test putting decimal value in object
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_decimal: SIMPLE_DECIMAL
		do
			create l_obj.make
			create l_decimal.make ("19.99")

			l_obj.put_decimal (l_decimal, "price").do_nothing

			assert ("has_price", l_obj.has_key ("price"))
			assert ("is_number", attached l_obj.item ("price") as v and then v.is_number)
		end

	test_object_decimal_item
			-- Test retrieving decimal value from object
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_decimal: SIMPLE_DECIMAL
			l_retrieved: detachable SIMPLE_DECIMAL
		do
			create l_obj.make
			create l_decimal.make ("99.95")

			l_obj.put_decimal (l_decimal, "amount").do_nothing
			l_retrieved := l_obj.decimal_item ("amount")

			assert ("retrieved_not_void", l_retrieved /= Void)
			if attached l_retrieved as r then
				assert_strings_equal ("value_preserved", "99.95", r.to_string)
			end
		end

	test_object_decimal_json_output
			-- Test JSON serialization preserves decimal precision
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_decimal: SIMPLE_DECIMAL
			l_json: STRING_32
		do
			create l_obj.make
			create l_decimal.make ("19.99")

			l_obj.put_decimal (l_decimal, "price").do_nothing
			l_json := l_obj.to_json_string

			-- JSON should contain 19.99 not 19.989999999999998
			assert ("contains_exact_value", l_json.has_substring ("19.99"))
			assert ("no_floating_error", not l_json.has_substring ("19.989"))
		end

feature -- Tests: SIMPLE_JSON_ARRAY decimal

	test_array_add_decimal
			-- Test adding decimal to array
		local
			l_arr: SIMPLE_JSON_ARRAY
			l_decimal: SIMPLE_DECIMAL
		do
			create l_arr.make
			create l_decimal.make ("3.14159")

			l_arr.add_decimal (l_decimal).do_nothing

			assert_integers_equal ("count", 1, l_arr.count)
			assert ("is_number", l_arr.item (1).is_number)
		end

	test_array_decimal_item
			-- Test retrieving decimal from array
		local
			l_arr: SIMPLE_JSON_ARRAY
			l_decimal: SIMPLE_DECIMAL
			l_retrieved: detachable SIMPLE_DECIMAL
		do
			create l_arr.make
			create l_decimal.make ("2.71828")

			l_arr.add_decimal (l_decimal).do_nothing
			l_retrieved := l_arr.decimal_item (1)

			assert ("retrieved_not_void", l_retrieved /= Void)
			if attached l_retrieved as r then
				assert_strings_equal ("value_preserved", "2.71828", r.to_string)
			end
		end

feature -- Tests: SIMPLE_JSON_VALUE decimal

	test_value_as_decimal
			-- Test converting JSON number to decimal
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_decimal: SIMPLE_DECIMAL
			l_value: detachable SIMPLE_JSON_VALUE
		do
			create l_obj.make
			create l_decimal.make ("42.5")

			l_obj.put_decimal (l_decimal, "num").do_nothing
			l_value := l_obj.item ("num")

			assert ("value_attached", l_value /= Void)
			if attached l_value as v then
				assert ("is_number", v.is_number)
				assert_strings_equal ("as_decimal", "42.5", v.as_decimal.to_string)
			end
		end

feature -- Tests: Round-trip

	test_decimal_round_trip
			-- Test that decimal survives JSON encode/decode round-trip
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_decimal: SIMPLE_DECIMAL
			l_json_str: STRING_32
			l_parser: SIMPLE_JSON
			l_parsed: detachable SIMPLE_JSON_VALUE
			l_retrieved: detachable SIMPLE_DECIMAL
		do
			-- Create object with decimal
			create l_obj.make
			create l_decimal.make ("123.456")
			l_obj.put_decimal (l_decimal, "value").do_nothing

			-- Serialize to JSON
			l_json_str := l_obj.to_json_string

			-- Parse back
			create l_parser
			l_parsed := l_parser.parse (l_json_str)

			assert ("parsed_not_void", l_parsed /= Void)
			if attached l_parsed as p and then p.is_object then
				l_retrieved := p.as_object.decimal_item ("value")
				assert ("retrieved_not_void", l_retrieved /= Void)
				if attached l_retrieved as r then
					assert_strings_equal ("round_trip_preserved", "123.456", r.to_string)
				end
			end
		end

	test_financial_calculation_precision
			-- Test financial calculations maintain precision
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_price, l_tax_rate, l_total: SIMPLE_DECIMAL
		do
			create l_price.make ("19.99")
			create l_tax_rate.make ("0.0825")

			-- Calculate total with tax
			l_total := l_price.add (l_price.multiply (l_tax_rate)).round_cents

			create l_obj.make
			l_obj.put_decimal (l_price, "price").do_nothing
			l_obj.put_decimal (l_tax_rate, "tax_rate").do_nothing
			l_obj.put_decimal (l_total, "total").do_nothing

			-- Verify JSON has exact values
			assert ("price_exact", l_obj.to_json_string.has_substring ("19.99"))
			assert ("tax_exact", l_obj.to_json_string.has_substring ("0.0825"))
		end

end
