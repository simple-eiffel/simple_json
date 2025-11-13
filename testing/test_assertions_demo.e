note
	description: "Demonstration of generic high-level assertions"
	testing: "type/manual"

class
	TEST_ASSERTIONS_DEMO

inherit
	TEST_SET_BASE

feature -- Boolean tests

	test_refute
		do
			refute ("should_be_false", False)
			refute ("five_not_zero", 5 = 0)
		end

	test_assert_true_false
		do
			assert_true ("should_be_true", True)
			assert_false ("should_be_false", False)
		end

feature -- Integer comparison tests

	test_greater_than
		local
			value: INTEGER
		do
			value := 10
			assert_greater_than ("ten_greater_than_five", value, 5)
		end

	test_less_than
		local
			value: INTEGER
		do
			value := 5
			assert_less_than ("five_less_than_ten", value, 10)
		end

	test_in_range
		local
			value: INTEGER
		do
			value := 50
			assert_in_range ("fifty_in_range", value, 0, 100)
		end

	test_positive_negative_zero
		do
			assert_positive ("ten_is_positive", 10)
			assert_negative ("minus_five_is_negative", -5)
			assert_zero ("zero_is_zero", 0)
			assert_non_zero ("ten_is_non_zero", 10)
		end

feature -- Real number tests

	test_reals_equal_with_tolerance
		local
			pi: REAL_64
		do
			pi := 3.14159
			assert_reals_equal ("pi_approximately", 3.14, pi, 0.01)
		end

	test_real_comparisons
		local
			value: REAL_64
		do
			value := 2.5
			assert_real_greater_than ("2.5_greater_than_2.0", value, 2.0)
			assert_real_less_than ("2.5_less_than_3.0", value, 3.0)
			assert_real_in_range ("2.5_in_range", value, 2.0, 3.0)
		end

feature -- String tests

	test_string_contains
		local
			str: STRING
		do
			str := "Hello World"
			assert_string_contains ("contains_world", str, "World")
			assert_string_contains ("contains_hello", str, "Hello")
		end

	test_string_starts_ends_with
		local
			str: STRING
		do
			str := "test_method_name"
			assert_string_starts_with ("starts_with_test", str, "test")
			assert_string_ends_with ("ends_with_name", str, "name")
		end

	test_string_empty_not_empty
		local
			empty_str, non_empty_str: STRING
		do
			create empty_str.make_empty
			create non_empty_str.make_from_string ("content")
			
			assert_string_empty ("empty_string", empty_str)
			assert_string_not_empty ("non_empty_string", non_empty_str)
		end

feature -- Combined usage tests

	test_validation_pattern
			-- Show how assertions make validation cleaner
		local
			age: INTEGER
			name: STRING
			score: REAL_64
		do
			age := 25
			name := "Alice"
			score := 95.5
			
			-- Validate age
			assert_positive ("age_positive", age)
			assert_in_range ("age_reasonable", age, 0, 150)
			
			-- Validate name
			assert_string_not_empty ("name_not_empty", name)
			assert_greater_than ("name_min_length", name.count, 1)
			
			-- Validate score
			assert_real_in_range ("score_valid", score, 0.0, 100.0)
			assert_real_greater_or_equal ("score_passing", score, 60.0)
		end

	assert_real_greater_or_equal (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: REAL_64)
			-- Helper for this test
		do
			assert (a_tag, a_value >= a_threshold)
		end

end
