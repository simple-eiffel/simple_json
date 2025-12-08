note
	description: "Tests for SIMPLE_JSON error tracking and position reporting"
	testing: "covers"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_error_tracking.html"

class
	TEST_ERROR_TRACKING

inherit
	TEST_SET_BASE

feature -- Test routines: Basic error tracking

	test_no_errors_on_valid_json
			-- Valid JSON should not produce errors
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": %"Alice%"}") as value then
				assert ("no_errors", not json.has_errors)
				assert_integers_equal ("zero_errors", 0, json.error_count)
				assert ("no_first_error", json.first_error = Void)
			else
				assert ("parse_should_succeed", False)
			end
		end

	test_error_on_invalid_json
			-- Invalid JSON should produce errors
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				assert ("has_errors", json.has_errors)
				assert ("at_least_one_error", json.error_count > 0)
				assert ("has_first_error", json.first_error /= Void)
			end
		end

	test_error_message_content
			-- Error messages should contain meaningful information
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				assert ("has_errors", json.has_errors)
				if attached json.first_error as err then
					assert ("message_not_empty", not err.message.is_empty)
					assert ("has_position", err.has_position)
				else
					assert ("first_error_exists", False)
				end
			end
		end

	test_clear_errors
			-- Errors should be cleared between parse operations
		local
			json: SIMPLE_JSON
		do
			create json
			
			-- First parse with error
			if attached json.parse ("{invalid}") as value then
				assert ("should_fail", False)
			end
			assert ("has_errors_first", json.has_errors)
			
			-- Second parse with valid JSON
			if attached json.parse ("{%"valid%": true}") as value then
				assert ("no_errors_second", not json.has_errors)
				assert_integers_equal ("zero_errors_second", 0, json.error_count)
			else
				assert ("second_parse_should_succeed", False)
			end
		end

feature -- Test routines: Position tracking

	test_error_has_position
			-- Errors should include character position
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					assert ("has_position", err.has_position)
					assert ("position_positive", err.position > 0)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_error_has_line_column
			-- Errors should include line and column numbers
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					assert ("has_line_column", err.has_line_column)
					assert ("line_positive", err.line > 0)
					assert ("column_positive", err.column > 0)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_line_calculation_single_line
			-- Line should be 1 for errors on the first line
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					assert_integers_equal ("line_is_1", 1, err.line)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_line_calculation_multiline
			-- Line numbers should be correct for multiline JSON
		local
			json: SIMPLE_JSON
			multiline: STRING_32
		do
			create json
			create multiline.make_from_string ("{%N%"name%": %N}")
			
			if attached json.parse (multiline) as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					-- Error should be on line 3 (after the two newlines)
					assert ("line_at_least_2", err.line >= 2)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_column_calculation
			-- Column numbers should be correct
		local
			json: SIMPLE_JSON
		do
			create json
			-- Error at position 10 in "{%"name%": }"
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					assert ("column_positive", err.column > 0)
					assert ("column_reasonable", err.column <= 20)  -- Should be somewhere in the line
				else
					assert ("error_exists", False)
				end
			end
		end

feature -- Test routines: Error output

	test_to_string_with_position
			-- Error string should include position information
		local
			json: SIMPLE_JSON
			err_string: STRING_32
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					err_string := err.to_string_with_position
					assert ("contains_line", err_string.has_substring ("line"))
					assert ("contains_column", err_string.has_substring ("column"))
				else
					assert ("error_exists", False)
				end
			end
		end

	test_errors_as_string
			-- Should get formatted string of all errors
		local
			json: SIMPLE_JSON
			err_string: STRING_32
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				err_string := json.errors_as_string
				assert ("not_empty", not err_string.is_empty)
				assert ("contains_position_info", 
					err_string.has_substring ("line") or err_string.has_substring ("position"))
			end
		end

	test_detailed_errors
			-- Should get detailed error information
		local
			json: SIMPLE_JSON
			detailed: STRING_32
		do
			create json
			if attached json.parse ("{%"name%": }") as value then
				assert ("should_fail", False)
			else
				detailed := json.detailed_errors
				assert ("not_empty", not detailed.is_empty)
				assert ("contains_error_label", detailed.has_substring ("Error"))
				assert ("contains_line_label", detailed.has_substring ("Line"))
			end
		end

feature -- Test routines: Multiple errors

	test_multiple_errors
			-- Should capture all errors from parser
		local
			json: SIMPLE_JSON
		do
			create json
			-- This might generate multiple errors depending on parser behavior
			if attached json.parse ("{%"a%": , %"b%": }") as value then
				assert ("should_fail", False)
			else
				assert ("has_errors", json.has_errors)
				-- At least one error should be reported
				assert ("at_least_one", json.error_count >= 1)
			end
		end

feature -- Test routines: Edge cases

	test_error_at_start
			-- Error at the very beginning of JSON
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse ("X{%"name%": %"value%"}") as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					assert ("has_position", err.has_position)
					assert_integers_equal ("line_is_1", 1, err.line)
					assert ("column_low", err.column <= 3)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_error_after_newlines
			-- Line tracking should handle newlines correctly
		local
			json: SIMPLE_JSON
			text: STRING_32
		do
			create json
			create text.make_from_string ("%N%N{invalid}")
			
			if attached json.parse (text) as value then
				assert ("should_fail", False)
			else
				if attached json.first_error as err then
					-- Error should be on line 3 (after two newlines)
					assert ("line_is_3", err.line >= 3)
				else
					assert ("error_exists", False)
				end
			end
		end

	test_empty_json_error
			-- Attempting to parse empty string should be caught by precondition
		local
			json: SIMPLE_JSON
			error_caught: BOOLEAN
		do
			create json
			if not error_caught then
				-- This should violate precondition
				if attached json.parse ("") as value then
				end
			end
		rescue
			error_caught := True
			retry
		end

	test_is_valid_json_with_error_tracking
			-- is_valid_json should also populate errors
		local
			json: SIMPLE_JSON
		do
			create json
			if json.is_valid_json ("{%"name%": }") then
				assert ("should_be_invalid", False)
			else
				assert ("has_errors", json.has_errors)
				assert ("error_count_positive", json.error_count > 0)
			end
		end

	test_parse_file_error_tracking
			-- parse_file should track file access errors
		local
			json: SIMPLE_JSON
		do
			create json
			if attached json.parse_file ("nonexistent_file_xyz.json") as value then
				assert ("should_fail", False)
			else
				assert ("has_errors", json.has_errors)
				if attached json.first_error as err then
					assert ("message_about_file", 
						err.message.has_substring ("file") or err.message.has_substring ("Cannot"))
				else
					assert ("error_exists", False)
				end
			end
		end

feature -- Test routines: Error object

	test_error_make
			-- Test creating error with message only
		local
			err: SIMPLE_JSON_ERROR
		do
			create err.make ("Test error message")
			assert ("message_set", err.message.same_string ("Test error message"))
			assert ("no_position", not err.has_position)
			assert ("no_line_column", not err.has_line_column)
		end

	test_error_make_with_position
			-- Test creating error with position
		local
			err: SIMPLE_JSON_ERROR
			json_text: STRING_32
		do
			create json_text.make_from_string ("{%"test%": 123}")
			create err.make_with_position ("Error message", json_text, 5)
			
			assert ("message_set", not err.message.is_empty)
			assert ("has_position", err.has_position)
			assert ("has_line_column", err.has_line_column)
			assert_integers_equal ("position_is_5", 5, err.position)
			assert_integers_equal ("line_is_1", 1, err.line)
		end

	test_error_position_to_line_column
			-- Test line/column calculation with various positions
		local
			err: SIMPLE_JSON_ERROR
			text: STRING_32
		do
			create text.make_from_string ("line1%Nline2%Nline3")
			
			-- Position 1 should be line 1, column 1
			create err.make_with_position ("msg", text, 1)
			assert_integers_equal ("pos1_line", 1, err.line)
			assert_integers_equal ("pos1_col", 1, err.column)
			
			-- Position 7 (after first newline) should be line 2, column 1
			create err.make_with_position ("msg", text, 7)
			assert_integers_equal ("pos7_line", 2, err.line)
		end

note
	copyright: "2024, Larry Rix"
	license: "MIT License"

end
