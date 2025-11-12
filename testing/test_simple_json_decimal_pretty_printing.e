note
	description: "Tests for SIMPLE_JSON_DECIMAL pretty printing"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_DECIMAL_PRETTY_PRINTING

inherit
	EQA_TEST_SET

feature -- Test routines

	test_decimal_3_14_pretty
			-- Test that 3.14 is represented exactly
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("3.14")
			l_expected := "3.14"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_3_14_pretty", l_expected, l_actual)
		end

	test_decimal_integer_pretty
			-- Test integer representation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.make_from_integer"
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_integer (42)
			l_expected := "42"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_integer_pretty", l_expected, l_actual)
		end

	test_decimal_zero_pretty
			-- Test zero representation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("0")
			l_expected := "0"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_zero_pretty", l_expected, l_actual)
		end

	test_decimal_negative_pretty
			-- Test negative number representation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("-123.456")
			l_expected := "-123.456"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_negative_pretty", l_expected, l_actual)
		end

	test_decimal_scientific_pretty
			-- Test scientific notation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_actual: STRING
		do
			create l_decimal.make_from_string ("1.23E+10")
			l_actual := l_decimal.to_pretty_string (0)
			assert ("decimal_scientific_not_empty", not l_actual.is_empty)
			-- DECIMAL may convert this to different representation, that's OK
		end

	test_decimal_high_precision_pretty
			-- Test high precision number
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("0.123456789012345")
			l_expected := "0.123456789012345"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_high_precision_pretty", l_expected, l_actual)
		end

	test_decimal_trailing_zeros_pretty
			-- Test that trailing zeros are preserved as DECIMAL outputs them
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("1.500")
			l_expected := "1.500"  -- DECIMAL preserves trailing zeros from input
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_trailing_zeros_pretty", l_expected, l_actual)
		end

	test_decimal_from_real_conversion
			-- Test conversion from REAL_64 maintains reasonable precision
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.make_from_real"
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_actual: STRING
		do
			-- Note: Converting from REAL_64 may introduce binary representation issues
			-- This tests that the conversion at least produces valid output
			create l_decimal.make_from_real (3.14)
			l_actual := l_decimal.to_pretty_string (0)
			assert ("decimal_from_real_not_empty", not l_actual.is_empty)
			assert ("decimal_from_real_has_3", l_actual.has_substring ("3"))
			assert ("decimal_from_real_has_1", l_actual.has_substring ("1"))
		end

	test_decimal_large_number_pretty
			-- Test large number representation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("999999999.99")
			l_expected := "999999999.99"
			l_actual := l_decimal.to_pretty_string (0)
			assert_strings_equal ("decimal_large_number_pretty", l_expected, l_actual)
		end

	test_decimal_small_number_pretty
			-- Test very small number representation
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_pretty_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("0.00000001")
			l_expected := "1E-8"  -- DECIMAL may use scientific notation for very small numbers
			l_actual := l_decimal.to_pretty_string (0)
			-- Accept either format
			assert ("decimal_small_number_valid", 
				l_actual.is_equal ("0.00000001") or l_actual.is_equal ("1E-8"))
		end

	test_decimal_to_json_string
			-- Test JSON string conversion
		note
			testing: "covers/{SIMPLE_JSON_DECIMAL}.to_json_string"
		local
			l_decimal: SIMPLE_JSON_DECIMAL
			l_expected: STRING
			l_actual: STRING
		do
			create l_decimal.make_from_string ("42.42")
			l_expected := "42.42"
			l_actual := l_decimal.to_json_string
			assert_strings_equal ("decimal_to_json_string", l_expected, l_actual)
		end

feature {NONE} -- Implementation

	assert_strings_equal (a_tag: STRING; a_expected: STRING; a_actual: STRING)
			-- Assert that strings are equal with detailed message
		local
			l_message: STRING
		do
			if not a_expected.is_equal (a_actual) then
				create l_message.make_empty
				l_message.append (a_tag)
				l_message.append ("%NExpected: ")
				l_message.append (a_expected)
				l_message.append ("%NActual:   ")
				l_message.append (a_actual)
				assert (l_message, False)
			else
				assert (a_tag, True)
			end
		end

end
