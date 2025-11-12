note
	description: "JSON parser with position tracking for detailed error messages"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Use Case: Error Handling",
		 "src=file:///${SYSTEM_PATH}/docs/use-cases/error-handling.html",
		 "protocol=uri",
		 "tag=documentation, parsing, error-handling, use-case"

class
	SIMPLE_JSON_PARSER

create
	make

feature {NONE} -- Initialization

	make (a_input: STRING)
			-- Create parser for `a_input'
		require
			not_empty: not a_input.is_empty
		do
			input := a_input
			pos := 1
			line := 1
			col := 1
		ensure
			input_set: input = a_input
			at_start: pos = 1
			line_one: line = 1
			col_one: col = 1
		end

feature -- Access

	input: STRING
			-- Input JSON string

	line: INTEGER
			-- Current line number (1-based)

	col: INTEGER
			-- Current column number (1-based)

	last_error: detachable STRING
			-- Last error message with position

feature -- Last Error

	last_error_line: INTEGER

	last_error_column: INTEGER

	last_error_position: INTEGER
		-- Error message like:
		-- "Parse error at line 5, column 23: Expected '}' but found ','"

feature -- Parsing

	parse: detachable SIMPLE_JSON_OBJECT
			-- Parse JSON object
		do
			skip_whitespace
			if at_end then
				set_error ("Empty JSON input")
			elseif current_char = '{' then
				Result := parse_object
			else
				set_error ("Expected object, got '" + current_char.out + "'")
			end

			if has_error then
				Result := Void
			end
		end

feature {NONE} -- Implementation: Position tracking

	pos: INTEGER
			-- Current position in input

	advance
			-- Move to next character and update line/col
		require
			not_at_end: not at_end
		local
			ch: CHARACTER
		do
			ch := input [pos]
			if ch = '%N' then
				line := line + 1
				col := 1
			else
				col := col + 1
			end
			pos := pos + 1
		ensure
			advanced: pos = old pos + 1
		end

	at_end: BOOLEAN
			-- At end of input?
		do
			Result := pos > input.count
		end

	current_char: CHARACTER
			-- Current character
		require
			not_at_end: not at_end
		do
			Result := input [pos]
		end

	peek_char (n: INTEGER): CHARACTER
			-- Character at pos + n (or '%U' if out of bounds)
		do
			if pos + n <= input.count then
				Result := input [pos + n]
			else
				Result := '%U'
			end
		end

feature {NONE} -- Implementation: Parsing

	parse_object: detachable SIMPLE_JSON_OBJECT
			-- Parse JSON object
		require
			at_brace: current_char = '{'
		local
			key: STRING
			value: SIMPLE_JSON_VALUE
		do
			create Result.make_empty
			advance -- skip '{'
			skip_whitespace

			if not at_end and then current_char = '}' then
				advance -- empty object
			else
				from
				until
					at_end or else current_char = '}' or else has_error
				loop
					skip_whitespace

					-- Parse key
					if at_end then
						set_error ("Unexpected end of input in object")
					elseif current_char /= '"' then
						set_error ("Expected property name, got '" + current_char.out + "'")
					else
						key := parse_string_content

						if not has_error then
							skip_whitespace

							-- Expect colon
							if at_end then
								set_error ("Expected ':' after property name")
							elseif current_char /= ':' then
								set_error ("Expected ':', got '" + current_char.out + "'")
							else
								advance -- skip ':'
								skip_whitespace

								-- Parse value
								value := parse_value
								if not has_error and attached Result as al_result and attached value as al_value then
									al_result.put_value (key, al_value)
									skip_whitespace

									-- Check for comma or end
									if not at_end then
										if current_char = ',' then
											advance
											skip_whitespace
											if not at_end and then current_char = '}' then
												set_error ("Trailing comma before '}'")
											end
										elseif current_char /= '}' then
											set_error ("Expected ',' or '}', got '" + current_char.out + "'")
										end
									end
								end
							end
						end
					end
				end

				if not has_error then
					if at_end then
						set_error ("Unexpected end of input, expected '}'")
					else
						advance -- skip '}'
					end
				end
			end

			if has_error then
				Result := Void
			end
		end

	parse_value: detachable SIMPLE_JSON_VALUE
			-- Parse any JSON value
		do
			skip_whitespace

			if at_end then
				set_error ("Unexpected end of input")
				create {SIMPLE_JSON_NULL} Result.make
			else
				inspect current_char
				when '{' then
					Result := parse_object
				when '[' then
					Result := parse_array
				when '"' then
					create {SIMPLE_JSON_STRING} Result.make (parse_string_content)
				when 't', 'f' then
					Result := parse_boolean
				when 'n' then
					Result := parse_null
				when '-', '0'..'9' then
					Result := parse_number
				else
					set_error ("Unexpected character '" + current_char.out + "'")
					create {SIMPLE_JSON_NULL} Result.make
				end
			end

			if has_error then
				Result := Void
			end
		end

	parse_array: detachable SIMPLE_JSON_ARRAY
			-- Parse JSON array
		require
			at_bracket: current_char = '['
		local
			value: detachable SIMPLE_JSON_VALUE
		do
			create Result.make_empty
			advance -- skip '['
			skip_whitespace

			if not at_end and then current_char = ']' then
				advance -- empty array
			else
				from
				until
					at_end or else current_char = ']' or else has_error
				loop
					value := parse_value
					if not has_error and attached Result as al_result and attached value as al_value then
						al_result.add_value (al_value)
						skip_whitespace

						if not at_end then
							if current_char = ',' then
								advance
								skip_whitespace
								if not at_end and then current_char = ']' then
									set_error ("Trailing comma before ']'")
								end
							elseif current_char /= ']' then
								set_error ("Expected ',' or ']', got '" + current_char.out + "'")
							end
						end
					end
				end

				if not has_error then
					if at_end then
						set_error ("Unexpected end of input, expected ']'")
					else
						advance -- skip ']'
					end
				end
			end

			if has_error then
				Result := Void
			end
		end

	parse_string_content: STRING
			-- Parse string content (without quotes)
		require
			at_quote: current_char = '"'
		do
			create Result.make_empty
			advance -- skip opening quote

			from
			until
				at_end or else current_char = '"' or else has_error
			loop
				if current_char = '\' then
					advance
					if at_end then
						set_error ("Unexpected end of input in string escape")
					else
						inspect current_char
						when '"', '\', '/' then
							Result.append_character (current_char)
						when 'b' then
							Result.append_character ('%B')
						when 'f' then
							Result.append_character ('%F')
						when 'n' then
							Result.append_character ('%N')
						when 'r' then
							Result.append_character ('%R')
						when 't' then
							Result.append_character ('%T')
						else
							set_error ("Invalid escape sequence '\" + current_char.out + "'")
						end
						advance
					end
				else
					Result.append_character (current_char)
					advance
				end
			end

			if not has_error then
				if at_end then
					set_error ("Unexpected end of input, expected closing quote")
				else
					advance -- skip closing quote
				end
			end
		end

	parse_number: detachable SIMPLE_JSON_VALUE
			-- Parse number (integer or real)
		require
			at_number: current_char = '-' or else current_char.is_digit
		local
			num_str: STRING
			has_decimal: BOOLEAN
			int_val: INTEGER_64
			real_val: REAL_64
		do
			create num_str.make_empty

			-- Optional minus
			if current_char = '-' then
				num_str.append_character (current_char)
				advance
			end

			if at_end or else not current_char.is_digit then
				set_error ("Expected digit after '-'")
			else
				-- Integer part
				from
				until
					at_end or else not current_char.is_digit
				loop
					num_str.append_character (current_char)
					advance
				end

				-- Optional decimal part
				if not at_end and then current_char = '.' then
					has_decimal := True
					num_str.append_character (current_char)
					advance

					if at_end or else not current_char.is_digit then
						set_error ("Expected digit after decimal point")
					else
						from
						until
							at_end or else not current_char.is_digit
						loop
							num_str.append_character (current_char)
							advance
						end
					end
				end

				-- Optional exponent
				if not has_error and not at_end and then (current_char = 'e' or current_char = 'E') then
					has_decimal := True
					num_str.append_character (current_char)
					advance

					if not at_end and then (current_char = '+' or current_char = '-') then
						num_str.append_character (current_char)
						advance
					end

					if at_end or else not current_char.is_digit then
						set_error ("Expected digit in exponent")
					else
						from
						until
							at_end or else not current_char.is_digit
						loop
							num_str.append_character (current_char)
							advance
						end
					end
				end

				-- Convert to number
				if not has_error then
					if has_decimal then
						if num_str.is_double then
							real_val := num_str.to_double
							create {SIMPLE_JSON_REAL} Result.make (real_val)
						else
							set_error ("Invalid number format: " + num_str)
						end
					else
						if num_str.is_integer_64 then
							int_val := num_str.to_integer_64
							create {SIMPLE_JSON_INTEGER} Result.make (int_val.to_integer)
						else
							set_error ("Invalid integer format: " + num_str)
						end
					end
				end
			end

			if has_error then
				Result := Void
			end
		end

	parse_boolean: detachable SIMPLE_JSON_BOOLEAN
			-- Parse boolean
		require
			at_boolean: current_char = 't' or current_char = 'f'
		local
			word: STRING
		do
			create word.make_empty
			from
			until
				at_end or else not current_char.is_alpha
			loop
				word.append_character (current_char)
				advance
			end

			if word.same_string ("true") then
				create Result.make (True)
			elseif word.same_string ("false") then
				create Result.make (False)
			else
				set_error ("Invalid boolean: " + word)
				Result := Void
			end
		end

	parse_null: detachable SIMPLE_JSON_NULL
			-- Parse null
		require
			at_null: current_char = 'n'
		local
			word: STRING
		do
			create word.make_empty
			from
			until
				at_end or else not current_char.is_alpha
			loop
				word.append_character (current_char)
				advance
			end

			if word.same_string ("null") then
				create Result.make
			else
				set_error ("Invalid null: " + word)
				Result := Void
			end
		end

	skip_whitespace
			-- Skip whitespace characters
		do
			from
			until
				at_end or else not is_whitespace (current_char)
			loop
				advance
			end
		end

	is_whitespace (ch: CHARACTER): BOOLEAN
			-- Is character whitespace?
		do
			Result := ch = ' ' or ch = '%T' or ch = '%N' or ch = '%R'
		end

feature {NONE} -- Error handling

	has_error: BOOLEAN
			-- Did an error occur?

	set_error (msg: STRING)
			-- Set error with position information
		local
			err_msg: STRING
		do
			create err_msg.make_from_string ("Error at line ")
			err_msg.append_integer (line)
			err_msg.append_string (", column ")
			err_msg.append_integer (col)
			err_msg.append_string (": ")
			err_msg.append_string (msg)
			last_error := err_msg
			has_error := True
		end

invariant
	valid_position: pos >= 1
	valid_line: line >= 1
	valid_col: col >= 1

end
