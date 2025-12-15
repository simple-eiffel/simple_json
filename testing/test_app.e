note
	description: "Test application for SIMPLE_JSON"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_JSON tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests
			run_simple_json_tests
			run_json_path_queries_tests
			run_json_schema_validation_tests
			run_pretty_printing_tests
			run_merge_patch_tests
			run_patch_tests
			run_stream_tests
			run_error_tracking_tests
			run_error_tracking_advanced_tests
			run_decimal_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests
			run_test (agent lib_tests.test_parse_object, "test_parse_object")
			run_test (agent lib_tests.test_parse_array, "test_parse_array")
			run_test (agent lib_tests.test_parse_string, "test_parse_string")
			run_test (agent lib_tests.test_parse_number, "test_parse_number")
			run_test (agent lib_tests.test_parse_boolean, "test_parse_boolean")
			run_test (agent lib_tests.test_parse_null, "test_parse_null")
			run_test (agent lib_tests.test_to_json_object, "test_to_json_object")
			run_test (agent lib_tests.test_to_json_array, "test_to_json_array")
			run_test (agent lib_tests.test_object_has_key, "test_object_has_key")
			run_test (agent lib_tests.test_object_remove, "test_object_remove")
			run_test (agent lib_tests.test_array_count, "test_array_count")
			run_test (agent lib_tests.test_array_is_empty, "test_array_is_empty")
			run_test (agent lib_tests.test_parse_invalid_json, "test_parse_invalid_json")
		end

	run_simple_json_tests
		do
			create simple_json_tests
			run_test (agent simple_json_tests.test_parse_simple_object, "test_parse_simple_object")
			run_test (agent simple_json_tests.test_parse_object_with_types, "test_parse_object_with_types")
			run_test (agent simple_json_tests.test_parse_empty_array, "test_parse_empty_array")
			run_test (agent simple_json_tests.test_parse_string, "test_parse_string")
			run_test (agent simple_json_tests.test_parse_number, "test_parse_number")
			run_test (agent simple_json_tests.test_parse_real, "test_parse_real")
			run_test (agent simple_json_tests.test_parse_boolean_true, "test_parse_boolean_true")
			run_test (agent simple_json_tests.test_parse_boolean_false, "test_parse_boolean_false")
			run_test (agent simple_json_tests.test_parse_null, "test_parse_null")
			run_test (agent simple_json_tests.test_build_object, "test_build_object")
			run_test (agent simple_json_tests.test_build_array, "test_build_array")
			run_test (agent simple_json_tests.test_fluent_object, "test_fluent_object")
			run_test (agent simple_json_tests.test_fluent_array, "test_fluent_array")
			run_test (agent simple_json_tests.test_nested_object, "test_nested_object")
			run_test (agent simple_json_tests.test_nested_array, "test_nested_array")
			run_test (agent simple_json_tests.test_unicode_string, "test_unicode_string")
			run_test (agent simple_json_tests.test_type_checking_string, "test_type_checking_string")
			run_test (agent simple_json_tests.test_type_checking_number, "test_type_checking_number")
			run_test (agent simple_json_tests.test_type_checking_boolean, "test_type_checking_boolean")
			run_test (agent simple_json_tests.test_type_checking_null, "test_type_checking_null")
			run_test (agent simple_json_tests.test_type_checking_object, "test_type_checking_object")
			run_test (agent simple_json_tests.test_type_checking_array, "test_type_checking_array")
			run_test (agent simple_json_tests.test_object_with_null, "test_object_with_null")
			run_test (agent simple_json_tests.test_empty_string, "test_empty_string")
			run_test (agent simple_json_tests.test_zero_integer, "test_zero_integer")
			run_test (agent simple_json_tests.test_negative_integer, "test_negative_integer")
			run_test (agent simple_json_tests.test_object_keys, "test_object_keys")
			run_test (agent simple_json_tests.test_array_access, "test_array_access")
			run_test (agent simple_json_tests.test_to_json_string, "test_to_json_string")
			run_test (agent simple_json_tests.test_is_valid_json, "test_is_valid_json")
		end

	run_json_path_queries_tests
		do
			create json_path_tests
			run_test (agent json_path_tests.test_query_string_simple, "test_query_string_simple")
			run_test (agent json_path_tests.test_query_integer_simple, "test_query_integer_simple")
			run_test (agent json_path_tests.test_query_nested_string, "test_query_nested_string")
			run_test (agent json_path_tests.test_query_array_element, "test_query_array_element")
			run_test (agent json_path_tests.test_query_array_wildcard, "test_query_array_wildcard")
			run_test (agent json_path_tests.test_query_nested_array_field, "test_query_nested_array_field")
			run_test (agent json_path_tests.test_query_integers_from_array, "test_query_integers_from_array")
			run_test (agent json_path_tests.test_query_nonexistent_path, "test_query_nonexistent_path")
			run_test (agent json_path_tests.test_query_wrong_type, "test_query_wrong_type")
			run_test (agent json_path_tests.test_query_empty_result, "test_query_empty_result")
		end

	run_json_schema_validation_tests
		do
			create schema_tests
			run_test (agent schema_tests.test_valid_string_type, "test_valid_string_type")
			run_test (agent schema_tests.test_invalid_string_type, "test_invalid_string_type")
			run_test (agent schema_tests.test_valid_number_type, "test_valid_number_type")
			run_test (agent schema_tests.test_valid_integer_type, "test_valid_integer_type")
			run_test (agent schema_tests.test_valid_boolean_type, "test_valid_boolean_type")
			run_test (agent schema_tests.test_valid_null_type, "test_valid_null_type")
			run_test (agent schema_tests.test_valid_object_type, "test_valid_object_type")
			run_test (agent schema_tests.test_valid_array_type, "test_valid_array_type")
			run_test (agent schema_tests.test_string_min_length_valid, "test_string_min_length_valid")
			run_test (agent schema_tests.test_string_min_length_invalid, "test_string_min_length_invalid")
			run_test (agent schema_tests.test_string_max_length_valid, "test_string_max_length_valid")
			run_test (agent schema_tests.test_string_max_length_invalid, "test_string_max_length_invalid")
			run_test (agent schema_tests.test_string_pattern_valid, "test_string_pattern_valid")
			run_test (agent schema_tests.test_string_pattern_invalid, "test_string_pattern_invalid")
			run_test (agent schema_tests.test_number_minimum_valid, "test_number_minimum_valid")
			run_test (agent schema_tests.test_number_minimum_invalid, "test_number_minimum_invalid")
			run_test (agent schema_tests.test_number_maximum_valid, "test_number_maximum_valid")
			run_test (agent schema_tests.test_number_maximum_invalid, "test_number_maximum_invalid")
			run_test (agent schema_tests.test_number_range_valid, "test_number_range_valid")
			run_test (agent schema_tests.test_object_required_properties_valid, "test_object_required_properties_valid")
			run_test (agent schema_tests.test_object_required_properties_missing, "test_object_required_properties_missing")
			run_test (agent schema_tests.test_object_properties_validation_valid, "test_object_properties_validation_valid")
			run_test (agent schema_tests.test_object_properties_validation_invalid, "test_object_properties_validation_invalid")
			run_test (agent schema_tests.test_array_min_items_valid, "test_array_min_items_valid")
			run_test (agent schema_tests.test_array_min_items_invalid, "test_array_min_items_invalid")
			run_test (agent schema_tests.test_array_max_items_valid, "test_array_max_items_valid")
			run_test (agent schema_tests.test_array_max_items_invalid, "test_array_max_items_invalid")
			run_test (agent schema_tests.test_array_items_validation_valid, "test_array_items_validation_valid")
			run_test (agent schema_tests.test_array_items_validation_invalid, "test_array_items_validation_invalid")
			run_test (agent schema_tests.test_complex_nested_object_valid, "test_complex_nested_object_valid")
			run_test (agent schema_tests.test_complex_nested_object_invalid, "test_complex_nested_object_invalid")
		end

	run_pretty_printing_tests
		do
			create pretty_tests
			run_test (agent pretty_tests.test_pretty_print_simple_string, "test_pretty_print_simple_string")
			run_test (agent pretty_tests.test_pretty_print_number, "test_pretty_print_number")
			run_test (agent pretty_tests.test_pretty_print_boolean_true, "test_pretty_print_boolean_true")
			run_test (agent pretty_tests.test_pretty_print_boolean_false, "test_pretty_print_boolean_false")
			run_test (agent pretty_tests.test_pretty_print_null, "test_pretty_print_null")
			run_test (agent pretty_tests.test_pretty_print_empty_object, "test_pretty_print_empty_object")
			run_test (agent pretty_tests.test_pretty_print_empty_array, "test_pretty_print_empty_array")
			run_test (agent pretty_tests.test_pretty_print_simple_object, "test_pretty_print_simple_object")
			run_test (agent pretty_tests.test_pretty_print_simple_array, "test_pretty_print_simple_array")
			run_test (agent pretty_tests.test_pretty_print_nested_object, "test_pretty_print_nested_object")
			run_test (agent pretty_tests.test_pretty_print_nested_array, "test_pretty_print_nested_array")
			run_test (agent pretty_tests.test_pretty_print_deeply_nested, "test_pretty_print_deeply_nested")
			run_test (agent pretty_tests.test_pretty_print_array_of_objects, "test_pretty_print_array_of_objects")
			run_test (agent pretty_tests.test_pretty_print_object_with_array_of_objects, "test_pretty_print_object_with_array_of_objects")
			run_test (agent pretty_tests.test_pretty_print_with_tabs, "test_pretty_print_with_tabs")
			run_test (agent pretty_tests.test_pretty_print_with_4_spaces, "test_pretty_print_with_4_spaces")
			run_test (agent pretty_tests.test_pretty_print_with_custom_indent, "test_pretty_print_with_custom_indent")
			run_test (agent pretty_tests.test_pretty_print_mixed_types, "test_pretty_print_mixed_types")
			run_test (agent pretty_tests.test_pretty_print_unicode, "test_pretty_print_unicode")
			run_test (agent pretty_tests.test_pretty_print_unicode_basic, "test_pretty_print_unicode_basic")
			run_test (agent pretty_tests.test_pretty_print_with_empty_string, "test_pretty_print_with_empty_string")
			run_test (agent pretty_tests.test_pretty_print_with_zero, "test_pretty_print_with_zero")
			run_test (agent pretty_tests.test_pretty_print_negative_number, "test_pretty_print_negative_number")
			run_test (agent pretty_tests.test_pretty_print_reparseable, "test_pretty_print_reparseable")
			run_test (agent pretty_tests.test_pretty_vs_compact, "test_pretty_vs_compact")
		end

	run_merge_patch_tests
		do
			create merge_patch_tests
			run_test (agent merge_patch_tests.test_rfc_example_1_simple_value_merge, "test_rfc_example_1_simple_value_merge")
			run_test (agent merge_patch_tests.test_rfc_example_2_add_member, "test_rfc_example_2_add_member")
			run_test (agent merge_patch_tests.test_rfc_example_3_delete_member, "test_rfc_example_3_delete_member")
			run_test (agent merge_patch_tests.test_rfc_example_4_delete_nonexistent, "test_rfc_example_4_delete_nonexistent")
			run_test (agent merge_patch_tests.test_rfc_example_5_replace_array, "test_rfc_example_5_replace_array")
			run_test (agent merge_patch_tests.test_rfc_example_6_replace_string_with_array, "test_rfc_example_6_replace_string_with_array")
			run_test (agent merge_patch_tests.test_rfc_example_7_nested_object_merge, "test_rfc_example_7_nested_object_merge")
			run_test (agent merge_patch_tests.test_rfc_example_8_nested_object_delete, "test_rfc_example_8_nested_object_delete")
			run_test (agent merge_patch_tests.test_rfc_example_9_replace_scalar_with_null, "test_rfc_example_9_replace_scalar_with_null")
			run_test (agent merge_patch_tests.test_rfc_example_10_complex_merge, "test_rfc_example_10_complex_merge")
			run_test (agent merge_patch_tests.test_rfc_example_11_replace_object_with_scalar, "test_rfc_example_11_replace_object_with_scalar")
			run_test (agent merge_patch_tests.test_rfc_example_12_replace_non_object_target, "test_rfc_example_12_replace_non_object_target")
			run_test (agent merge_patch_tests.test_rfc_example_13_array_not_merged, "test_rfc_example_13_array_not_merged")
			run_test (agent merge_patch_tests.test_rfc_example_14_empty_objects, "test_rfc_example_14_empty_objects")
			run_test (agent merge_patch_tests.test_make_creates_empty_patch, "test_make_creates_empty_patch")
			run_test (agent merge_patch_tests.test_make_from_json, "test_make_from_json")
			run_test (agent merge_patch_tests.test_make_from_string, "test_make_from_string")
			run_test (agent merge_patch_tests.test_empty_patch_on_empty_target, "test_empty_patch_on_empty_target")
			run_test (agent merge_patch_tests.test_multiple_nested_objects, "test_multiple_nested_objects")
		end

	run_patch_tests
		do
			create patch_tests
			run_test (agent patch_tests.test_make_creates_empty_patch, "test_make_creates_empty_patch")
			run_test (agent patch_tests.test_make_from_array_with_operations, "test_make_from_array_with_operations")
			run_test (agent patch_tests.test_make_from_array_empty, "test_make_from_array_empty")
			run_test (agent patch_tests.test_add_returns_current, "test_add_returns_current")
			run_test (agent patch_tests.test_add_increments_count, "test_add_increments_count")
			run_test (agent patch_tests.test_remove_returns_current, "test_remove_returns_current")
			run_test (agent patch_tests.test_remove_increments_count, "test_remove_increments_count")
			run_test (agent patch_tests.test_replace_returns_current, "test_replace_returns_current")
			run_test (agent patch_tests.test_replace_increments_count, "test_replace_increments_count")
			run_test (agent patch_tests.test_move_returns_current, "test_move_returns_current")
			run_test (agent patch_tests.test_move_increments_count, "test_move_increments_count")
			run_test (agent patch_tests.test_copy_value_returns_current, "test_copy_value_returns_current")
			run_test (agent patch_tests.test_copy_value_increments_count, "test_copy_value_increments_count")
			run_test (agent patch_tests.test_test_returns_current, "test_test_returns_current")
			run_test (agent patch_tests.test_test_increments_count, "test_test_increments_count")
			run_test (agent patch_tests.test_fluent_chaining, "test_fluent_chaining")
			run_test (agent patch_tests.test_apply_empty_patch_returns_success, "test_apply_empty_patch_returns_success")
			run_test (agent patch_tests.test_apply_add_to_object, "test_apply_add_to_object")
			run_test (agent patch_tests.test_apply_remove_from_object, "test_apply_remove_from_object")
			run_test (agent patch_tests.test_apply_replace_in_object, "test_apply_replace_in_object")
			run_test (agent patch_tests.test_apply_multiple_operations, "test_apply_multiple_operations")
			run_test (agent patch_tests.test_apply_with_test_operation_success, "test_apply_with_test_operation_success")
			run_test (agent patch_tests.test_apply_with_test_operation_failure, "test_apply_with_test_operation_failure")
			run_test (agent patch_tests.test_apply_atomic_failure_first_operation, "test_apply_atomic_failure_first_operation")
			run_test (agent patch_tests.test_apply_atomic_failure_middle_operation, "test_apply_atomic_failure_middle_operation")
			run_test (agent patch_tests.test_apply_move_operation, "test_apply_move_operation")
			run_test (agent patch_tests.test_apply_copy_operation, "test_apply_copy_operation")
			run_test (agent patch_tests.test_to_json_array_empty, "test_to_json_array_empty")
			run_test (agent patch_tests.test_to_json_array_single_operation, "test_to_json_array_single_operation")
			run_test (agent patch_tests.test_to_json_array_multiple_operations, "test_to_json_array_multiple_operations")
			run_test (agent patch_tests.test_to_json_array_contains_objects, "test_to_json_array_contains_objects")
			run_test (agent patch_tests.test_to_json_string_empty, "test_to_json_string_empty")
			run_test (agent patch_tests.test_to_json_string_with_operations, "test_to_json_string_with_operations")
			run_test (agent patch_tests.test_to_json_string_add_operation, "test_to_json_string_add_operation")
			run_test (agent patch_tests.test_to_json_string_remove_operation, "test_to_json_string_remove_operation")
			run_test (agent patch_tests.test_to_json_string_replace_operation, "test_to_json_string_replace_operation")
			run_test (agent patch_tests.test_to_json_string_move_operation, "test_to_json_string_move_operation")
			run_test (agent patch_tests.test_to_json_string_copy_operation, "test_to_json_string_copy_operation")
			run_test (agent patch_tests.test_to_json_string_test_operation, "test_to_json_string_test_operation")
		end

	run_stream_tests
		do
			create stream_tests
			run_test (agent stream_tests.test_stream_empty_array, "test_stream_empty_array")
			run_test (agent stream_tests.test_stream_single_element, "test_stream_single_element")
			run_test (agent stream_tests.test_stream_multiple_numbers, "test_stream_multiple_numbers")
			run_test (agent stream_tests.test_stream_string_elements, "test_stream_string_elements")
			run_test (agent stream_tests.test_stream_object_elements, "test_stream_object_elements")
			run_test (agent stream_tests.test_element_index, "test_element_index")
			run_test (agent stream_tests.test_error_on_non_array, "test_error_on_non_array")
			run_test (agent stream_tests.test_error_on_invalid_json, "test_error_on_invalid_json")
			run_test (agent stream_tests.test_stream_from_file, "test_stream_from_file")
			run_test (agent stream_tests.test_multiple_iterations, "test_multiple_iterations")
		end

	run_error_tracking_tests
		do
			create error_tests
			run_test (agent error_tests.test_no_errors_on_valid_json, "test_no_errors_on_valid_json")
			run_test (agent error_tests.test_error_on_invalid_json, "test_error_on_invalid_json")
			run_test (agent error_tests.test_error_message_content, "test_error_message_content")
			run_test (agent error_tests.test_clear_errors, "test_clear_errors")
			run_test (agent error_tests.test_error_has_position, "test_error_has_position")
			run_test (agent error_tests.test_error_has_line_column, "test_error_has_line_column")
			run_test (agent error_tests.test_line_calculation_single_line, "test_line_calculation_single_line")
			run_test (agent error_tests.test_line_calculation_multiline, "test_line_calculation_multiline")
			run_test (agent error_tests.test_column_calculation, "test_column_calculation")
			run_test (agent error_tests.test_to_string_with_position, "test_to_string_with_position")
			run_test (agent error_tests.test_errors_as_string, "test_errors_as_string")
			run_test (agent error_tests.test_detailed_errors, "test_detailed_errors")
			run_test (agent error_tests.test_multiple_errors, "test_multiple_errors")
			run_test (agent error_tests.test_error_at_start, "test_error_at_start")
			run_test (agent error_tests.test_error_after_newlines, "test_error_after_newlines")
			run_test (agent error_tests.test_empty_json_error, "test_empty_json_error")
			run_test (agent error_tests.test_is_valid_json_with_error_tracking, "test_is_valid_json_with_error_tracking")
			run_test (agent error_tests.test_parse_file_error_tracking, "test_parse_file_error_tracking")
			run_test (agent error_tests.test_error_make, "test_error_make")
			run_test (agent error_tests.test_error_make_with_position, "test_error_make_with_position")
			run_test (agent error_tests.test_error_position_to_line_column, "test_error_position_to_line_column")
		end

	run_error_tracking_advanced_tests
		do
			create error_advanced_tests
			run_test (agent error_advanced_tests.test_basic_error_tracking, "test_basic_error_tracking")
			run_test (agent error_advanced_tests.test_multiline_error_tracking, "test_multiline_error_tracking")
			run_test (agent error_advanced_tests.test_multiple_errors, "test_multiple_errors")
			run_test (agent error_advanced_tests.test_error_output_formats, "test_error_output_formats")
			run_test (agent error_advanced_tests.test_error_recovery, "test_error_recovery")
			run_test (agent error_advanced_tests.test_file_error_tracking, "test_file_error_tracking")
			run_test (agent error_advanced_tests.test_error_position_accuracy, "test_error_position_accuracy")
			run_test (agent error_advanced_tests.test_errors_as_string_format, "test_errors_as_string_format")
			run_test (agent error_advanced_tests.test_detailed_errors_format, "test_detailed_errors_format")
			run_test (agent error_advanced_tests.test_validation_with_error_tracking, "test_validation_with_error_tracking")
		end

	run_decimal_tests
		do
			create decimal_tests
			run_test (agent decimal_tests.test_object_put_decimal, "test_object_put_decimal")
			run_test (agent decimal_tests.test_object_decimal_item, "test_object_decimal_item")
			run_test (agent decimal_tests.test_array_add_decimal, "test_array_add_decimal")
			run_test (agent decimal_tests.test_array_decimal_item, "test_array_decimal_item")
			run_test (agent decimal_tests.test_value_as_decimal, "test_value_as_decimal")
			run_test (agent decimal_tests.test_decimal_round_trip, "test_decimal_round_trip")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS
	simple_json_tests: TEST_SIMPLE_JSON
	json_path_tests: TEST_JSON_PATH_QUERIES
	schema_tests: TEST_JSON_SCHEMA_VALIDATION
	pretty_tests: TEST_PRETTY_PRINTING
	merge_patch_tests: TEST_SIMPLE_JSON_MERGE_PATCH
	patch_tests: TEST_SIMPLE_JSON_PATCH
	stream_tests: TEST_SIMPLE_JSON_STREAM
	error_tests: TEST_ERROR_TRACKING
	error_advanced_tests: TEST_ERROR_TRACKING_ADVANCED
	decimal_tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
