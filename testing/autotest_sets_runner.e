note
	description: "[
		Runs the tests in simple_json's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 35 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 35 in all.
		do
			run_test_assertions_demo
			run_test_decimal_support
			run_test_string_diff_demo
			run_test_unicode_text
		end

feature {NONE} -- Test sets

	run_test_assertions_demo
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_ASSERTIONS_DEMO]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_refute), "TEST_ASSERTIONS_DEMO.test_refute")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_assert_true_false), "TEST_ASSERTIONS_DEMO.test_assert_true_false")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_greater_than), "TEST_ASSERTIONS_DEMO.test_greater_than")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_less_than), "TEST_ASSERTIONS_DEMO.test_less_than")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_in_range), "TEST_ASSERTIONS_DEMO.test_in_range")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_positive_negative_zero), "TEST_ASSERTIONS_DEMO.test_positive_negative_zero")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_reals_equal_with_tolerance), "TEST_ASSERTIONS_DEMO.test_reals_equal_with_tolerance")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_real_comparisons), "TEST_ASSERTIONS_DEMO.test_real_comparisons")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_string_contains), "TEST_ASSERTIONS_DEMO.test_string_contains")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_string_starts_ends_with), "TEST_ASSERTIONS_DEMO.test_string_starts_ends_with")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_string_empty_not_empty), "TEST_ASSERTIONS_DEMO.test_string_empty_not_empty")
			report (l_evaluator.execute (agent {TEST_ASSERTIONS_DEMO}.test_validation_pattern), "TEST_ASSERTIONS_DEMO.test_validation_pattern")
		end

	run_test_decimal_support
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_DECIMAL_SUPPORT]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_json_decimal_creation), "TEST_DECIMAL_SUPPORT.test_json_decimal_creation")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_json_decimal_from_string), "TEST_DECIMAL_SUPPORT.test_json_decimal_from_string")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_json_decimal_precision_preserved), "TEST_DECIMAL_SUPPORT.test_json_decimal_precision_preserved")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_object_put_decimal), "TEST_DECIMAL_SUPPORT.test_object_put_decimal")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_object_decimal_item), "TEST_DECIMAL_SUPPORT.test_object_decimal_item")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_object_decimal_json_output), "TEST_DECIMAL_SUPPORT.test_object_decimal_json_output")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_array_add_decimal), "TEST_DECIMAL_SUPPORT.test_array_add_decimal")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_array_decimal_item), "TEST_DECIMAL_SUPPORT.test_array_decimal_item")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_value_as_decimal), "TEST_DECIMAL_SUPPORT.test_value_as_decimal")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_decimal_round_trip), "TEST_DECIMAL_SUPPORT.test_decimal_round_trip")
			report (l_evaluator.execute (agent {TEST_DECIMAL_SUPPORT}.test_financial_calculation_precision), "TEST_DECIMAL_SUPPORT.test_financial_calculation_precision")
		end

	run_test_string_diff_demo
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_STRING_DIFF_DEMO]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_simple_string_diff), "TEST_STRING_DIFF_DEMO.test_simple_string_diff")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_case_difference), "TEST_STRING_DIFF_DEMO.test_case_difference")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_special_characters), "TEST_STRING_DIFF_DEMO.test_special_characters")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_length_difference), "TEST_STRING_DIFF_DEMO.test_length_difference")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_trailing_whitespace), "TEST_STRING_DIFF_DEMO.test_trailing_whitespace")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_unicode_difference), "TEST_STRING_DIFF_DEMO.test_unicode_difference")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_control_characters), "TEST_STRING_DIFF_DEMO.test_control_characters")
			report (l_evaluator.execute (agent {TEST_STRING_DIFF_DEMO}.test_embedded_quotes), "TEST_STRING_DIFF_DEMO.test_embedded_quotes")
		end

	run_test_unicode_text
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_UNICODE_TEXT]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_UNICODE_TEXT}.test_astral_round_trip_through_object), "TEST_UNICODE_TEXT.test_astral_round_trip_through_object")
			report (l_evaluator.execute (agent {TEST_UNICODE_TEXT}.test_surrogate_pair_escapes_combine), "TEST_UNICODE_TEXT.test_surrogate_pair_escapes_combine")
			report (l_evaluator.execute (agent {TEST_UNICODE_TEXT}.test_escaper_vectors), "TEST_UNICODE_TEXT.test_escaper_vectors")
			report (l_evaluator.execute (agent {TEST_UNICODE_TEXT}.test_array_and_facade_strings), "TEST_UNICODE_TEXT.test_array_and_facade_strings")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
