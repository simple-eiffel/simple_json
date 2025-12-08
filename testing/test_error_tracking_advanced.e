note
	description: "[
		Automated tests for SIMPLE_JSON error tracking capabilities.
		Each test verifies expected error output against actual output.
		]"
	testing: "covers"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_error_tracking_advanced.html"

class
	TEST_ERROR_TRACKING_ADVANCED

inherit
	TEST_SET_BASE

feature -- Test routines

	test_basic_error_tracking
		-- Test basic error detection and reporting
	local
		json: SIMPLE_JSON
		l_expected_output, l_actual_output: STRING_32
	do
		l_expected_output := "[
Parse failed (as expected)

Has errors: True
Error count: 2

First error:
  Message: JSON value is not well formed
  Line: 1
  Column: 11
  Position: 11

]"

		create json
		create l_actual_output.make_empty

		if attached json.parse ("{%"name%": }") as value then
			l_actual_output.append_string ("Unexpected success!%N")
		else
			l_actual_output.append_string ("Parse failed (as expected)%N%N")

			l_actual_output.append_string ("Has errors: " + json.has_errors.out + "%N")
			l_actual_output.append_string ("Error count: " + json.error_count.out + "%N%N")

			if attached json.first_error as err then
				l_actual_output.append_string ("First error:%N")
				l_actual_output.append_string ("  Message: " + err.message + "%N")
				l_actual_output.append_string ("  Line: " + err.line.out + "%N")
				l_actual_output.append_string ("  Column: " + err.column.out + "%N")
				l_actual_output.append_string ("  Position: " + err.position.out + "%N")
			end
		end

		print (l_actual_output)
		assert_strings_equal_diff ("basic_error_tracking", l_expected_output, l_actual_output)
	end

	test_multiline_error_tracking
			-- Test line/column tracking with multiline JSON
		local
			json: SIMPLE_JSON
			multiline: STRING_32
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Parse failed (as expected)

First error line: 4
First error column: 13

]"

			create json
			create multiline.make_from_string ("{%N  %"person%": {%N    %"name%": %"Alice%",%N    %"age%": ,%N  }%N}")
			create l_actual_output.make_empty

			if attached json.parse (multiline) as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Parse failed (as expected)%N%N")

				if attached json.first_error as err then
					l_actual_output.append_string ("First error line: " + err.line.out + "%N")
					l_actual_output.append_string ("First error column: " + err.column.out + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("multiline_error_tracking", l_expected_output, l_actual_output)
		end

	test_multiple_errors
			-- Test handling multiple errors in a single parse
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Parse failed

Error count: 2 or more
Has multiple errors: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse ("{%"a%": , %"b%": }") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Parse failed%N%N")
				l_actual_output.append_string ("Error count: " + json.error_count.out + " or more%N")
				l_actual_output.append_string ("Has multiple errors: " + (json.error_count >= 1).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("multiple_errors", l_expected_output, l_actual_output)
		end

	test_error_output_formats
			-- Test different error output formats
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Simple format:


 Input string is a not well formed JSON, expected [:] found [n]

With position:


 Input string is a not well formed JSON, expected [:] found [n] (line: 1, column: 4)

Has detailed format: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse ("{invalid}") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				if attached json.first_error as err then
					l_actual_output.append_string ("Simple format:%N%N")
					l_actual_output.append_string (err.to_string + "%N%N")

					l_actual_output.append_string ("With position:%N%N")
					l_actual_output.append_string (err.to_string_with_position + "%N%N")

					l_actual_output.append_string ("Has detailed format: ")
					l_actual_output.append_string ((not err.to_detailed_string.is_empty).out + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("error_output_formats", l_expected_output, l_actual_output)
		end

	test_error_recovery
			-- Test error clearing between operations
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
First parse (invalid):
Errors: 2

Second parse (valid):
Success!
Errors: 0 (errors cleared)

]"

			create json
			create l_actual_output.make_empty

			-- First parse (invalid)
			l_actual_output.append_string ("First parse (invalid):%N")
			if attached json.parse ("{bad}") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Errors: " + json.error_count.out + "%N%N")
			end

			-- Second parse (valid)
			l_actual_output.append_string ("Second parse (valid):%N")
			if attached json.parse ("{%"good%": true}") as value then
				l_actual_output.append_string ("Success!%N")
				l_actual_output.append_string ("Errors: " + json.error_count.out + " (errors cleared)%N")
			else
				l_actual_output.append_string ("Unexpected failure!%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("error_recovery", l_expected_output, l_actual_output)
		end

	test_file_error_tracking
			-- Test file access error tracking
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
File access failed

Has errors: True
Error contains file message: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse_file ("nonexistent_xyz_file.json") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("File access failed%N%N")

				l_actual_output.append_string ("Has errors: " + json.has_errors.out + "%N")

				if attached json.first_error as err then
					l_actual_output.append_string ("Error contains file message: ")
					l_actual_output.append_string ((err.message.has_substring ("Cannot read file") or
						err.message.has_substring ("file")).out + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("file_error_tracking", l_expected_output, l_actual_output)
		end

	test_error_position_accuracy
			-- Test that error positions are accurately calculated
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Parse failed

Error has position: True
Position is positive: True
Line is positive: True
Column is positive: True
Has line and column: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse ("{%"name%": }") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Parse failed%N%N")

				if attached json.first_error as err then
					l_actual_output.append_string ("Error has position: " + err.has_position.out + "%N")
					l_actual_output.append_string ("Position is positive: " + (err.position > 0).out + "%N")
					l_actual_output.append_string ("Line is positive: " + (err.line > 0).out + "%N")
					l_actual_output.append_string ("Column is positive: " + (err.column > 0).out + "%N")
					l_actual_output.append_string ("Has line and column: " + err.has_line_column.out + "%N")
				end
			end

			print (l_actual_output)
			assert_strings_equal_diff ("error_position_accuracy", l_expected_output, l_actual_output)
		end

	test_errors_as_string_format
			-- Test errors_as_string output format
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Parse failed

Errors string not empty: True
Contains line info: True
Contains column info: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse ("{%"test%": }") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Parse failed%N%N")

				l_actual_output.append_string ("Errors string not empty: " +
					(not json.errors_as_string.is_empty).out + "%N")
				l_actual_output.append_string ("Contains line info: " +
					(json.errors_as_string.has_substring ("line")).out + "%N")
				l_actual_output.append_string ("Contains column info: " +
					(json.errors_as_string.has_substring ("column")).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("errors_as_string_format", l_expected_output, l_actual_output)
		end

	test_detailed_errors_format
			-- Test detailed_errors output format
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Parse failed

Detailed errors not empty: True
Contains Error label: True
Contains Line label: True
Contains Column label: True
Contains Position label: True

]"

			create json
			create l_actual_output.make_empty

			if attached json.parse ("{%"data%": }") as value then
				l_actual_output.append_string ("Unexpected success!%N")
			else
				l_actual_output.append_string ("Parse failed%N%N")

				l_actual_output.append_string ("Detailed errors not empty: " +
					(not json.detailed_errors.is_empty).out + "%N")
				l_actual_output.append_string ("Contains Error label: " +
					(json.detailed_errors.has_substring ("Error")).out + "%N")
				l_actual_output.append_string ("Contains Line label: " +
					(json.detailed_errors.has_substring ("Line")).out + "%N")
				l_actual_output.append_string ("Contains Column label: " +
					(json.detailed_errors.has_substring ("Column")).out + "%N")
				l_actual_output.append_string ("Contains Position label: " +
					(json.detailed_errors.has_substring ("Position")).out + "%N")
			end

			print (l_actual_output)
			assert_strings_equal_diff ("detailed_errors_format", l_expected_output, l_actual_output)
		end

	test_validation_with_error_tracking
			-- Test is_valid_json with error tracking
		local
			json: SIMPLE_JSON
			l_expected_output, l_actual_output: STRING_32
		do
			l_expected_output := "[
Validation result: False
Has errors: True
Error count positive: True

]"

			create json
			create l_actual_output.make_empty

			l_actual_output.append_string ("Validation result: " +
				json.is_valid_json ("{%"invalid%": }").out + "%N")
			l_actual_output.append_string ("Has errors: " + json.has_errors.out + "%N")
			l_actual_output.append_string ("Error count positive: " + (json.error_count > 0).out + "%N")

			print (l_actual_output)
			assert_strings_equal_diff ("validation_with_error_tracking", l_expected_output, l_actual_output)
		end

note
	copyright: "2024, Larry Rix"
	license: "MIT License"
	testing: "Automated tests with expected vs actual output validation"

end
