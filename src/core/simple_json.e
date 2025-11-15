note
	description: "[
		Simple, high-level API for working with JSON using STRING_32/Unicode/UTF-8.
		This class provides an easy-to-use interface over the Eiffel JSON library.
		Includes comprehensive error tracking with line/column position information.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=JSON Specification", "protocol=URI", "src=https://www.json.org"

class
	SIMPLE_JSON

feature -- Parsing

	parse (a_json_text: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Parse JSON text and return a SIMPLE_JSON_VALUE wrapper.
			-- On error, returns Void and populates `last_errors' with details.
		require
			not_empty: not a_json_text.is_empty
		local
			l_parser: JSON_PARSER
			l_utf8: STRING_8
			l_wrapped: STRING_8
			l_array: JSON_ARRAY
		do
			-- Clear previous errors
			clear_errors
			last_json_text := a_json_text

			-- Convert STRING_32 to UTF-8 STRING_8 for the parser
			l_utf8 := utf_converter.utf_32_string_to_utf_8_string_8 (a_json_text)

			create l_parser.make_with_string (l_utf8)
			l_parser.parse_content

			if l_parser.is_valid and then attached l_parser.parsed_json_value as l_value then
				create Result.make (l_value)
			else
				-- Try wrapping in array for primitive values
				-- JSON parser only accepts objects/arrays at top level
				l_wrapped := "[" + l_utf8 + "]"
				create l_parser.make_with_string (l_wrapped)
				l_parser.parse_content

				if l_parser.is_valid and then attached l_parser.parsed_json_array as l_arr then
					l_array := l_arr
					if l_array.count = 1 then
						create Result.make (l_array.i_th (1))
					end
				else
					-- Capture errors from parser
					capture_parser_errors (l_parser, a_json_text)
				end
			end
		ensure
			errors_cleared_on_success: Result /= Void implies not has_errors
		end

	parse_file (a_file_path: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Parse JSON from file and return a SIMPLE_JSON_VALUE wrapper.
			-- On error, returns Void and populates `last_errors' with details.
		require
			not_empty: not a_file_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			clear_errors

			create l_file.make_with_name (a_file_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				l_content := utf_converter.utf_8_string_8_to_string_32 (l_file.last_string)
				l_file.close
				Result := parse (l_content)
			else
				-- File access error
				add_error (create {SIMPLE_JSON_ERROR}.make ("Cannot read file: " + a_file_path))
			end
		end

	is_valid_json (a_json_text: STRING_32): BOOLEAN
			-- Check if text is valid JSON without creating the value.
			-- On invalid JSON, populates `last_errors' with details.
		require
			not_empty: not a_json_text.is_empty
		local
			l_parser: JSON_PARSER
			l_utf8: STRING_8
			l_wrapped: STRING_8
		do
			clear_errors
			last_json_text := a_json_text

			l_utf8 := utf_converter.utf_32_string_to_utf_8_string_8 (a_json_text)
			create l_parser.make_with_string (l_utf8)
			l_parser.parse_content
			Result := l_parser.is_valid

			if not Result then
				-- Try wrapping in array for primitive values
				l_wrapped := "[" + l_utf8 + "]"
				create l_parser.make_with_string (l_wrapped)
				l_parser.parse_content
				Result := l_parser.is_valid

				if not Result then
					capture_parser_errors (l_parser, a_json_text)
				end
			end
		ensure
			valid_implies_no_errors: Result implies not has_errors
		end

feature -- Error Tracking

	has_errors: BOOLEAN
			-- Were there errors during the last parse operation?
		do
			Result := not last_errors.is_empty
		ensure
			definition: Result = not last_errors.is_empty
		end

	last_errors: ARRAYED_LIST [SIMPLE_JSON_ERROR]
			-- Errors from the last parse operation
		attribute
			create Result.make (0)
		ensure
			result_not_void: Result /= Void
		end

	error_count: INTEGER
			-- Number of errors from last parse operation
		do
			Result := last_errors.count
		ensure
			definition: Result = last_errors.count
		end

	first_error: detachable SIMPLE_JSON_ERROR
			-- First error from last parse operation, if any
		do
			if not last_errors.is_empty then
				Result := last_errors.first
			end
		ensure
			has_error_implies_result: has_errors implies Result /= Void
			no_error_implies_void: not has_errors implies Result = Void
		end

	errors_as_string: STRING_32
			-- All errors formatted as a single string
		do
			create Result.make_empty
			across
				last_errors as ic
			loop
				if not Result.is_empty then
					Result.append ("%N")
				end
				Result.append (ic.to_string_with_position)
			end
		ensure
			result_not_void: Result /= Void
		end

	detailed_errors: STRING_32
			-- All errors with detailed position information
		do
			create Result.make_empty
			across
				last_errors as ic
			loop
				if not Result.is_empty then
					Result.append ("%N%N")
				end
				Result.append ("Error ")
				Result.append (ic.out)
				Result.append (":")
				Result.append ("%N")
				Result.append (ic.to_detailed_string)
			end
		ensure
			result_not_void: Result /= Void
		end

	clear_errors
			-- Clear all error information
		do
			last_errors.wipe_out
		ensure
			no_errors: not has_errors
			empty_list: last_errors.is_empty
		end

feature -- Building

	new_object: SIMPLE_JSON_OBJECT
			-- Create a new JSON object builder
		do
			create Result.make
		end

	new_array: SIMPLE_JSON_ARRAY
			-- Create a new JSON array builder
		do
			create Result.make
		end

	string_value (a_string: STRING_32): SIMPLE_JSON_VALUE
			-- Create a JSON string value
		local
			l_json_string: JSON_STRING
		do
			create l_json_string.make_from_string_32 (a_string)
			create Result.make (l_json_string)
		end

	number_value (a_number: DOUBLE): SIMPLE_JSON_VALUE
			-- Create a JSON number value
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_real (a_number)
			create Result.make (l_json_number)
		end

	integer_value (a_integer: INTEGER_64): SIMPLE_JSON_VALUE
			-- Create a JSON integer value
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_integer (a_integer)
			create Result.make (l_json_number)
		end

	boolean_value (a_boolean: BOOLEAN): SIMPLE_JSON_VALUE
			-- Create a JSON boolean value
		local
			l_json_boolean: JSON_BOOLEAN
		do
			create l_json_boolean.make (a_boolean)
			create Result.make (l_json_boolean)
		end

	null_value: SIMPLE_JSON_VALUE
			-- Create a JSON null value
		local
			l_json_null: JSON_NULL
		do
			create l_json_null
			create Result.make (l_json_null)
		end

feature -- JSONPath Queries

	query_string (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): detachable STRING_32
			-- Query for a single string value using JSONPath.
			-- Returns Void if path not found or value is not a string.
			-- Example paths: "$.person.name", "$.person.address.street", "$.hobbies[0]"
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_result_value: detachable SIMPLE_JSON_VALUE
		do
			l_result_value := query_single_value (a_value, a_path)
			if attached l_result_value and then l_result_value.is_string then
				Result := l_result_value.as_string_32
			end
		end

	query_integer (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): INTEGER_64
			-- Query for a single integer value using JSONPath.
			-- Returns 0 if path not found or value is not an integer.
			-- Example paths: "$.person.age", "$.counts[0]"
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_result_value: detachable SIMPLE_JSON_VALUE
		do
			l_result_value := query_single_value (a_value, a_path)
			if attached l_result_value and then l_result_value.is_integer then
				Result := l_result_value.as_integer
			end
		end

	query_strings (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): ARRAYED_LIST [STRING_32]
			-- Query for multiple string values using JSONPath with wildcards.
			-- Returns empty list if path not found or values are not strings.
			-- Example paths: "$.hobbies[*]", "$.people[*].name"
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_values: ARRAYED_LIST [SIMPLE_JSON_VALUE]
		do
			create Result.make (0)
			l_values := query_multiple_values (a_value, a_path)
			across
				l_values as ic
			loop
				if ic.is_string then
					Result.force (ic.as_string_32)
				end
			end
		ensure
			result_not_void: Result /= Void
		end

	query_integers (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): ARRAYED_LIST [INTEGER_64]
			-- Query for multiple integer values using JSONPath with wildcards.
			-- Returns empty list if path not found or values are not integers.
			-- Example paths: "$.counts[*]", "$.people[*].age"
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_values: ARRAYED_LIST [SIMPLE_JSON_VALUE]
		do
			create Result.make (0)
			l_values := query_multiple_values (a_value, a_path)
			across
				l_values as ic
			loop
				if ic.is_integer then
					Result.force (ic.as_integer)
				end
			end
		ensure
			result_not_void: Result /= Void
		end
feature {NONE} -- Implementation

	last_json_text: detachable STRING_32
			-- The JSON text from the last parse operation (for error position calculation)

	add_error (a_error: SIMPLE_JSON_ERROR)
			-- Add an error to the error list
		require
			error_not_void: a_error /= Void
		do
			last_errors.force (a_error)
		ensure
			error_added: last_errors.has (a_error)
			has_errors: has_errors
		end

	capture_parser_errors (a_parser: JSON_PARSER; a_json_text: STRING_32)
			-- Capture errors from JSON_PARSER and convert to structured errors
		require
			parser_not_void: a_parser /= Void
			json_text_not_void: a_json_text /= Void
		local
			l_error: SIMPLE_JSON_ERROR
			l_error_text: STRING_32
			l_position: INTEGER
		do
			across
				a_parser.errors as ic
			loop
				-- Parse error string which is in format: "message (position: N)"
				l_error_text := create {STRING_32}.make_from_string (ic)
				l_position := extract_position_from_error (l_error_text)

				if l_position > 0 then
					-- Create error with position information
					create l_error.make_with_position (
						remove_position_from_message (l_error_text),
						a_json_text,
						l_position
					)
				else
					-- Create error without position
					create l_error.make (l_error_text)
				end

				add_error (l_error)
			end
		end

	extract_position_from_error (a_error_text: STRING_32): INTEGER
			-- Extract position number from error text like "message (position: 42)"
		require
			error_text_not_void: a_error_text /= Void
		local
			l_pos_start: INTEGER
			l_pos_end: INTEGER
			l_pos_string: STRING_32
		do
			-- Look for "(position: N)"
			l_pos_start := a_error_text.substring_index ("(position: ", 1)
			if l_pos_start > 0 then
				l_pos_start := l_pos_start + 11  -- Length of "(position: "
				l_pos_end := a_error_text.index_of (')', l_pos_start)
				if l_pos_end > l_pos_start then
					l_pos_string := a_error_text.substring (l_pos_start, l_pos_end - 1)
					l_pos_string.left_adjust
					l_pos_string.right_adjust
					if l_pos_string.is_integer then
						Result := l_pos_string.to_integer
					end
				end
			end
		ensure
			non_negative: Result >= 0
		end

	remove_position_from_message (a_error_text: STRING_32): STRING_32
			-- Remove " (position: N)" from error message
		require
			error_text_not_void: a_error_text /= Void
		local
			l_pos_start: INTEGER
		do
			l_pos_start := a_error_text.substring_index (" (position: ", 1)
			if l_pos_start > 0 then
				Result := a_error_text.substring (1, l_pos_start - 1)
			else
				Result := a_error_text.twin
			end
		ensure
			result_not_void: Result /= Void
		end

	utf_converter: UTF_CONVERTER
			-- UTF conversion utility
		once
			create Result
		end


	query_single_value (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Navigate path and return single value
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_segments: LIST [STRING_32]
			l_current: detachable SIMPLE_JSON_VALUE
		do
			l_segments := parse_json_path (a_path)
			l_current := a_value
			
			across
				l_segments as ic
			until
				l_current = Void
			loop
				l_current := navigate_segment (l_current, ic)
			end
			
			Result := l_current
		end

	query_multiple_values (a_value: SIMPLE_JSON_VALUE; a_path: STRING_32): ARRAYED_LIST [SIMPLE_JSON_VALUE]
			-- Navigate path with wildcards and return all matching values
		require
			value_not_void: a_value /= Void
			path_not_empty: not a_path.is_empty
		local
			l_segments: LIST [STRING_32]
			l_current_set: ARRAYED_LIST [SIMPLE_JSON_VALUE]
			l_next_set: ARRAYED_LIST [SIMPLE_JSON_VALUE]
			l_result_value: detachable SIMPLE_JSON_VALUE
			l_segment: STRING_32
			l_current_value: SIMPLE_JSON_VALUE
		do
			create Result.make (0)
			l_segments := parse_json_path (a_path)
			
			create l_current_set.make (1)
			l_current_set.force (a_value)
			
			across
				l_segments as ic
			loop
				l_segment := ic
				create l_next_set.make (0)
				
				across
					l_current_set as curr_ic
				loop
					l_current_value := curr_ic
					if is_wildcard_segment (l_segment) then
						-- Expand wildcard
						expand_wildcard (l_current_value, l_next_set)
					else
						-- Navigate single segment
						l_result_value := navigate_segment (l_current_value, l_segment)
						if attached l_result_value then
							l_next_set.force (l_result_value)
						end
					end
				end
				
				l_current_set := l_next_set
			end
			
			Result := l_current_set
		ensure
			result_not_void: Result /= Void
		end

	parse_json_path (a_path: STRING_32): LIST [STRING_32]
			-- Parse JSONPath into segments
			-- Supports: $.key, $.key.nested, $.array[0], $.array[*]
		require
			path_not_empty: not a_path.is_empty
		local
			l_path: STRING_32
			l_segments: ARRAYED_LIST [STRING_32]
			l_segment: STRING_32
			i: INTEGER
			l_bracket_start: INTEGER
		do
			create l_segments.make (5)
			l_path := a_path.twin
			
			-- Remove leading "$." if present
			if l_path.starts_with ("$.") then
				l_path := l_path.substring (3, l_path.count)
			elseif l_path.starts_with ("$") then
				l_path := l_path.substring (2, l_path.count)
			end
			
			-- Split by dots and handle brackets
			create l_segment.make_empty
			from
				i := 1
			until
				i > l_path.count
			loop
				if l_path [i] = '.' then
					if not l_segment.is_empty then
						l_segments.force (l_segment.twin)
						l_segment.wipe_out
					end
				elseif l_path [i] = '[' then
					-- Add segment before bracket
					if not l_segment.is_empty then
						l_segments.force (l_segment.twin)
						l_segment.wipe_out
					end
					
					-- Find closing bracket
					l_bracket_start := i
					from
						i := i + 1
					until
						i > l_path.count or l_path [i] = ']'
					loop
						l_segment.append_character (l_path [i])
						i := i + 1
					end
					
					-- Add bracket content as segment (either index or wildcard)
					if not l_segment.is_empty then
						l_segments.force ("[" + l_segment.twin + "]")
						l_segment.wipe_out
					end
				else
					l_segment.append_character (l_path [i])
				end
				
				i := i + 1
			end
			
			-- Add final segment
			if not l_segment.is_empty then
				l_segments.force (l_segment)
			end
			
			Result := l_segments
		ensure
			result_not_void: Result /= Void
		end

	navigate_segment (a_value: SIMPLE_JSON_VALUE; a_segment: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Navigate one segment of the path
		require
			value_not_void: a_value /= Void
			segment_not_empty: not a_segment.is_empty
		local
			l_index: INTEGER
			l_index_str: STRING_32
		do
			if a_segment.starts_with ("[") and a_segment.ends_with ("]") then
				-- Array access: [0], [1], etc.
				l_index_str := a_segment.substring (2, a_segment.count - 1)
				if l_index_str.is_integer then
					l_index := l_index_str.to_integer
					if a_value.is_array then
						-- Convert from 0-based JSONPath indexing to 1-based Eiffel indexing
						if a_value.as_array.valid_index (l_index + 1) then
							Result := a_value.as_array.item (l_index + 1)
						end
					end
				end
			elseif a_value.is_object then
				-- Object property access
				Result := a_value.as_object.item (a_segment)
			end
		end

	is_wildcard_segment (a_segment: STRING_32): BOOLEAN
			-- Check if segment is a wildcard [*]
		require
			segment_not_empty: not a_segment.is_empty
		do
			Result := a_segment.is_equal ("[*]")
		end

	expand_wildcard (a_value: SIMPLE_JSON_VALUE; a_result_list: ARRAYED_LIST [SIMPLE_JSON_VALUE])
			-- Expand wildcard by adding all array elements to result list
		require
			value_not_void: a_value /= Void
			result_list_not_void: a_result_list /= Void
		local
			i: INTEGER
			l_item: detachable SIMPLE_JSON_VALUE
		do
			if a_value.is_array then
				from
					i := 1  -- Eiffel uses 1-based indexing
				until
					i > a_value.as_array.count
				loop
					if a_value.as_array.valid_index (i) then
						l_item := a_value.as_array.item (i)
						if attached l_item then
							a_result_list.force (l_item)
						end
					end
					i := i + 1
				end
			end
		end


feature -- JSON Patch (RFC 6902)

	create_patch: SIMPLE_JSON_PATCH
			-- Create a new empty JSON Patch
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
			empty: Result.is_empty
		end

	parse_patch (a_patch_json: STRING_32): detachable SIMPLE_JSON_PATCH
			-- Parse JSON Patch document from string
		require
			patch_not_empty: not a_patch_json.is_empty
		local
			l_value: detachable SIMPLE_JSON_VALUE
			l_array: SIMPLE_JSON_ARRAY
			l_op_obj: SIMPLE_JSON_OBJECT
			l_op_name, l_path, l_from: STRING_32
			l_val: detachable SIMPLE_JSON_VALUE
			l_operation: detachable SIMPLE_JSON_PATCH_OPERATION
			i: INTEGER
			l_item: SIMPLE_JSON_VALUE
		do
			-- Parse the JSON
			l_value := parse (a_patch_json)
			
			if attached l_value and then l_value.is_array then
				create Result.make
				l_array := l_value.as_array
				
				-- Parse each operation
				from
					i := 1
				until
					i > l_array.count
				loop
					l_item := l_array.item (i)
					
					if l_item.is_object then
						l_op_obj := l_item.as_object
						
						-- Get operation name
						if attached l_op_obj.string_item ("op") as l_op then
							l_op_name := l_op
							
							-- Get path
							if attached l_op_obj.string_item ("path") as l_p then
								l_path := l_p
								
								-- Get optional value
								l_val := l_op_obj.item ("value")
								
								-- Get optional from
								l_from := ""
								if attached l_op_obj.string_item ("from") as l_f then
									l_from := l_f
								end
								
								-- Create appropriate operation
								l_operation := Void
								if l_op_name.is_equal ("add") and attached l_val then
									create {SIMPLE_JSON_PATCH_ADD} l_operation.make (l_path, l_val)
								elseif l_op_name.is_equal ("remove") then
									create {SIMPLE_JSON_PATCH_REMOVE} l_operation.make (l_path)
								elseif l_op_name.is_equal ("replace") and attached l_val then
									create {SIMPLE_JSON_PATCH_REPLACE} l_operation.make (l_path, l_val)
								elseif l_op_name.is_equal ("test") and attached l_val then
									create {SIMPLE_JSON_PATCH_TEST} l_operation.make (l_path, l_val)
								elseif l_op_name.is_equal ("move") and not l_from.is_empty then
									create {SIMPLE_JSON_PATCH_MOVE} l_operation.make (l_from, l_path)
								elseif l_op_name.is_equal ("copy") and not l_from.is_empty then
									create {SIMPLE_JSON_PATCH_COPY} l_operation.make (l_from, l_path)
								end
								
								-- Add operation to patch if created successfully
								if attached l_operation and then l_operation.is_valid then
									Result.operations.force (l_operation)
								end
							end
						end
					end
					
					i := i + 1
				end
			end
		end

	apply_patch (a_document: SIMPLE_JSON_VALUE; a_patch_json: STRING_32): SIMPLE_JSON_PATCH_RESULT
			-- Parse patch and apply to document
		require
			document_not_void: a_document /= Void
			patch_not_empty: not a_patch_json.is_empty
		do
			if attached parse_patch (a_patch_json) as l_patch then
				Result := l_patch.apply (a_document)
			else
				create Result.make_failure ("Failed to parse patch document")
			end
		ensure
			result_not_void: Result /= Void
		end

end
