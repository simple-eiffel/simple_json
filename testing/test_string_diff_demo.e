note
	description: "Demo of string diff assertion showing special character handling"
	testing: "type/manual"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_string_diff_demo.html"

class
	TEST_STRING_DIFF_DEMO

inherit
	TEST_SET_BASE

feature -- String diff tests

	test_simple_string_diff
			-- Show diff for simple string difference
		local
			expected, actual: STRING
		do
			expected := "Hello World"
			actual := "Hello World"
			
			-- This passes
			assert_strings_equal_diff ("identical_strings", expected, actual)
		end

	test_case_difference
			-- Show diff when case differs
		local
			expected, actual: STRING
		do
			expected := "Hello World"
			actual := "Hello world"
			
			-- This will fail and show detailed diff at position 7 (W vs w)
			-- assert_strings_equal_diff ("case_diff", expected, actual)
		end

	test_special_characters
			-- Show diff with tabs and newlines
		local
			expected, actual: STRING
		do
			expected := "Line1%NLine2"
			actual := "Line1%TLine2"
			
			-- This will fail and show \n vs \t
			-- assert_strings_equal_diff ("special_chars", expected, actual)
		end

	test_length_difference
			-- Show diff when strings have different lengths
		local
			expected, actual: STRING
		do
			expected := "Short"
			actual := "Short string"
			
			-- This will fail and show length metrics
			-- assert_strings_equal_diff ("length_diff", expected, actual)
		end

	test_trailing_whitespace
			-- Show diff with trailing whitespace
		local
			expected, actual: STRING
		do
			expected := "test"
			actual := "test "
			
			-- This will fail and show the trailing space
			-- assert_strings_equal_diff ("trailing_space", expected, actual)
		end

	test_unicode_difference
			-- Show diff with unicode characters
		local
			expected, actual: STRING_32
		do
			create expected.make_from_string ("Hello")
			create actual.make_from_string ("Hell😀")
			
			-- This will fail and show unicode code points
			-- assert_strings_equal_diff ("unicode_diff", expected, actual)
		end

	test_control_characters
			-- Show diff with control characters
		local
			expected, actual: STRING
		do
			expected := "Start%REnd"
			actual := "Start%NEnd"
			
			-- This will fail and show \r vs \n
			-- assert_strings_equal_diff ("control_chars", expected, actual)
		end

	test_embedded_quotes
			-- Show diff with quote characters
		local
			expected, actual: STRING
		do
			expected := "He said %"hello%""
			actual := "He said 'hello'"
			
			-- This will fail and show quote differences
			-- assert_strings_equal_diff ("quote_diff", expected, actual)
		end

feature -- Demonstration of output

	show_diff_output
			-- This is what a diff looks like when it fails
			-- (commented out to avoid test failure)
		local
			expected, actual: STRING
		do
			expected := "The quick brown fox"
			actual := "The quick brwon fox"
			
			-- When this fails, output looks like:
			-- ================================================================================
			-- Expected length: 19
			-- Actual length:   19
			-- First diff at:   position 14
			-- ================================================================================
			-- EXPECTED:
			--   The quick brown fox
			-- ACTUAL:
			--   The quick brwon fox
			-- ================================================================================
			-- Character-by-character at difference position 14:
			--   Position 12: Expected=o (111)  Actual=o (111)
			--   Position 13: Expected=w (119)  Actual=w (119)
			--   Position 14: Expected=n (110)  Actual=o (111) <-- FIRST DIFFERENCE
			--   Position 15: Expected=  (32)   Actual=n (110)
			--   Position 16: Expected=f (102)  Actual=  (32)
			-- ================================================================================
			
			-- assert_strings_equal_diff ("typo", expected, actual)
		end

end
