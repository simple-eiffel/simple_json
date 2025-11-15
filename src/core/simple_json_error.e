note
	description: "[
		Represents a JSON error with detailed position information.
		Provides line, column, and character position tracking for precise error reporting.
	]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Error Handling Best Practices", "protocol=URI", "src=https://www.eiffel.org/doc/solutions/Error_Handling"

class
	SIMPLE_JSON_ERROR

create
	make,
	make_with_position

feature {NONE} -- Initialization

	make (a_message: STRING_32)
			-- Initialize with error message only
		require
			message_not_empty: not a_message.is_empty
		do
			message := a_message
			line := 0
			column := 0
			position := 0
		ensure
			message_set: message = a_message
			no_position: line = 0 and column = 0 and position = 0
		end

	make_with_position (a_message: STRING_32; a_json_text: STRING_32; a_position: INTEGER)
			-- Initialize with error message and calculate line/column from position
		require
			message_not_empty: not a_message.is_empty
			json_text_not_void: a_json_text /= Void
			valid_position: a_position > 0 and a_position <= a_json_text.count + 1
		do
			message := a_message
			position := a_position
			calculate_line_and_column (a_json_text, a_position)
		ensure
			message_set: message = a_message
			position_set: position = a_position
			line_positive: line > 0
			column_positive: column > 0
		end

feature -- Access

	message: STRING_32
			-- Error message

	line: INTEGER
			-- Line number (1-based, 0 if not calculated)

	column: INTEGER
			-- Column number (1-based, 0 if not calculated)

	position: INTEGER
			-- Character position in JSON text (1-based, 0 if not set)

feature -- Status report

	has_position: BOOLEAN
			-- Does this error have position information?
		do
			Result := position > 0
		ensure
			definition: Result = (position > 0)
		end

	has_line_column: BOOLEAN
			-- Does this error have line/column information?
		do
			Result := line > 0 and column > 0
		ensure
			definition: Result = (line > 0 and column > 0)
		end

feature -- Output

	to_string: STRING_32
			-- Human-readable error message
		do
			create Result.make_from_string (message)
		ensure
			result_not_void: Result /= Void
			contains_message: Result.has_substring (message)
		end

	to_string_with_position: STRING_32
			-- Error message with position information
		do
			if has_line_column then
				create Result.make_from_string (message)
				Result.append (" (line: ")
				Result.append (line.out)
				Result.append (", column: ")
				Result.append (column.out)
				Result.append (")")
			elseif has_position then
				create Result.make_from_string (message)
				Result.append (" (position: ")
				Result.append (position.out)
				Result.append (")")
			else
				Result := to_string
			end
		ensure
			result_not_void: Result /= Void
		end

	to_detailed_string: STRING_32
			-- Detailed error message with all available information
		do
			create Result.make_from_string (message)
			if has_line_column then
				Result.append ("%N  Line: ")
				Result.append (line.out)
				Result.append ("%N  Column: ")
				Result.append (column.out)
				Result.append ("%N  Position: ")
				Result.append (position.out)
			elseif has_position then
				Result.append ("%N  Position: ")
				Result.append (position.out)
			end
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	calculate_line_and_column (a_json_text: STRING_32; a_position: INTEGER)
			-- Calculate line and column from character position
		require
			json_text_not_void: a_json_text /= Void
			valid_position: a_position > 0 and a_position <= a_json_text.count + 1
		local
			i: INTEGER
			l_line: INTEGER
			l_column: INTEGER
		do
			l_line := 1
			l_column := 1
			
			from
				i := 1
			until
				i >= a_position or i > a_json_text.count
			loop
				if a_json_text [i] = '%N' then
					l_line := l_line + 1
					l_column := 1
				elseif a_json_text [i] = '%R' then
					-- Handle CR - don't increment column, next char might be LF
				else
					l_column := l_column + 1
				end
				i := i + 1
			end
			
			line := l_line
			column := l_column
		ensure
			line_positive: line > 0
			column_positive: column > 0
		end

invariant
	message_not_void: message /= Void
	line_non_negative: line >= 0
	column_non_negative: column >= 0
	position_non_negative: position >= 0
	position_implies_line_column: has_line_column implies has_position

note
	copyright: "2024, Larry Rix"
	license: "MIT License"
	EIS: "name=JSON Error Reporting", "protocol=URI", "src=https://www.json.org"

end
