note
	description: "[
		Pretty printer for JSON values with configurable indentation.
		Produces human-readable JSON output with proper formatting.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/utilities/simple_json_pretty_printer.html"

class
	SIMPLE_JSON_PRETTY_PRINTER

inherit
	JSON_VISITOR

	SIMPLE_JSON_CONSTANTS
		export
			{NONE} all
		end

create
	make,
	make_with_options

feature {NONE} -- Initialization

	make
			-- Initialize with default options (2 spaces for indentation)
		do
			indent_string := Default_two_space_indent
			current_indent_level := 0
			create output.make_empty
		ensure
			two_space_indent: indent_string.same_string (Default_two_space_indent)
			zero_level: current_indent_level = 0
		end

	make_with_options (a_indent: STRING_32)
			-- Initialize with custom indentation string
		require
			indent_not_void: a_indent /= Void
			indent_valid: not a_indent.is_empty
		do
			indent_string := a_indent
			current_indent_level := 0
			create output.make_empty
		ensure
			indent_set: indent_string = a_indent
			zero_level: current_indent_level = 0
		end

feature -- Configuration

	set_indent_string (a_indent: STRING_32)
			-- Set the indentation string
		require
			indent_not_void: a_indent /= Void
			indent_valid: not a_indent.is_empty
		do
			indent_string := a_indent
		ensure
			indent_set: indent_string = a_indent
		end

	use_tabs
			-- Configure to use tabs for indentation
		do
			indent_string := "%T"
		ensure
			uses_tabs: indent_string.same_string ("%T")
		end

	use_spaces (a_count: INTEGER)
			-- Configure to use specified number of spaces for indentation
		require
			positive_count: a_count > 0
			reasonable_count: a_count <= Max_reasonable_indent_count
		do
			create indent_string.make_filled (' ', a_count)
		ensure
			correct_length: indent_string.count = a_count
		end

feature -- Access

	output: STRING_32
			-- Pretty-printed JSON output

	last_result: STRING_32
			-- Get the result of last print operation
		do
			Result := output
		end

feature -- Printing

	print_json_value (a_value: JSON_VALUE): STRING_32
			-- Pretty print a JSON value and return the result
		require
			value_not_void: a_value /= Void
		do
			reset
			a_value.accept (Current)
			Result := output
		end

feature -- Visitor Pattern

	visit_json_array (a_json_array: JSON_ARRAY)
			-- Visit `a_json_array' with pretty formatting
		local
			l_json_array: ARRAYED_LIST [JSON_VALUE]
			l_first: BOOLEAN
		do
			l_json_array := a_json_array.array_representation

			if l_json_array.is_empty then
				output.append (Json_empty_array)
			else
				output.append (Json_open_bracket)
				output.append_character ('%N')

				increase_indent

			from
				l_json_array.start
				l_first := True
			invariant
				-- Cursor validity
				cursor_valid: not l_json_array.off implies l_json_array.item /= Void

				-- Output integrity
				output_attached: output /= Void

				-- First flag consistency
				first_flag_valid: l_first implies l_json_array.index = 1
			until
				l_json_array.off
			loop
				if not l_first then
					output.append (Json_comma)
					output.append_character ('%N')
				end

				append_indent
				l_json_array.item.accept (Current)

				l_json_array.forth
				l_first := False
			end

				decrease_indent

				output.append_character ('%N')
				append_indent
				output.append (Json_close_bracket)
			end
		end

	visit_json_boolean (a_json_boolean: JSON_BOOLEAN)
			-- Visit `a_json_boolean'
		do
			if a_json_boolean.item then
				output.append (Json_true)
			else
				output.append (Json_false)
			end
		end

	visit_json_null (a_json_null: JSON_NULL)
			-- Visit `a_json_null'
		do
			output.append (Json_null_literal)
		end

	visit_json_number (a_json_number: JSON_NUMBER)
			-- Visit `a_json_number'
		do
			output.append (a_json_number.item.to_string_32)
		end

	visit_json_object (a_json_object: JSON_OBJECT)
			-- Visit `a_json_object' with pretty formatting
		local
			l_pairs: HASH_TABLE [JSON_VALUE, JSON_STRING]
			l_first: BOOLEAN
		do
			l_pairs := a_json_object.map_representation

			if l_pairs.is_empty then
				output.append (Json_empty_object)
			else
				output.append (Json_open_brace)
				output.append_character ('%N')

				increase_indent

				from
					l_pairs.start
					l_first := True
				invariant
					-- Cursor validity
					cursor_valid: not l_pairs.off implies
						(l_pairs.key_for_iteration /= Void and l_pairs.item_for_iteration /= Void)

					-- Output integrity
					output_attached: output /= Void
				until
					l_pairs.off
				loop
					if not l_first then
						output.append (Json_comma)
						output.append_character ('%N')
					end

					append_indent
					l_pairs.key_for_iteration.accept (Current)
					output.append (Json_colon_space)
					l_pairs.item_for_iteration.accept (Current)

					l_pairs.forth
					l_first := False
				end

				decrease_indent

				output.append_character ('%N')
				append_indent
				output.append (Json_close_brace)
			end
		end

	visit_json_string (a_json_string: JSON_STRING)
			-- Visit `a_json_string' - translates \uNNNN codes to actual Unicode characters
		local
			l_unescaped: STRING_32
		do
			output.append (Json_quote)

			-- Get unescaped Unicode string (converts \u4f60\u597d → 你好)
			l_unescaped := a_json_string.unescaped_string_32

			-- Re-escape only special JSON characters, preserve Unicode
			output.append (escape_json_string (l_unescaped))

			output.append (Json_quote)
		end

feature {NONE} -- Implementation

	escape_json_string (a_string: STRING_32): STRING_32
			-- Escape special JSON characters while preserving Unicode characters
			-- The input has already been unescaped (\\uNNNN codes → actual characters)
			-- This function escapes ONLY: quotes, backslash, control characters
			-- Result: 你好 stays as 你好 (not converted back to \\u4f60\\u597d)
		local
			i: INTEGER
			c: CHARACTER_32
			hex: STRING
		do
			create Result.make (a_string.count)
			from
				i := 1
			until
				i > a_string.count
			loop
				c := a_string [i]
				inspect c
				when '%"' then
					Result.append ("\%"")
				when '\' then
					Result.append ("\\")
				when '%N' then
					Result.append ("\n")
				when '%R' then
					Result.append ("\r")
				when '%T' then
					Result.append ("\t")
				when '%F' then
					Result.append ("\f")
				when '%B' then
					Result.append ("\b")
				else
					-- For control characters (0x00-0x1F), use \uXXXX
					if c.code < Ascii_control_char_boundary then
						Result.append ("\u")
						hex := c.code.to_hex_string
						-- Pad with zeros to get 4 digits
						from
						until
							hex.count >= Hex_digit_count
						loop
							hex.prepend (Hex_padding_zero.to_string_8)
						end
						Result.append (hex.substring (hex.count - Hex_last_four_offset, hex.count))
					else
						-- Preserve all other characters including Unicode
						Result.append_character (c)
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	indent_string: STRING_32
			-- String used for one level of indentation

	current_indent_level: INTEGER
			-- Current indentation level

	increase_indent
			-- Increase indentation level
		do
			current_indent_level := current_indent_level + 1
		ensure
			incremented: current_indent_level = old current_indent_level + 1
		end

	decrease_indent
			-- Decrease indentation level
		require
			not_at_zero: current_indent_level > 0
		do
			current_indent_level := current_indent_level - 1
		ensure
			decremented: current_indent_level = old current_indent_level - 1
		end

	append_indent
			-- Append current indentation to output
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > current_indent_level
			loop
				output.append (indent_string)
				i := i + 1
			end
		end

	reset
			-- Reset the printer for a new print operation
		do
			create output.make_empty
			current_indent_level := 0
		ensure
			output_empty: output.is_empty
			zero_level: current_indent_level = 0
		end

invariant
	output_not_void: output /= Void
	indent_string_not_void: indent_string /= Void
	indent_string_not_empty: not indent_string.is_empty
	non_negative_indent: current_indent_level >= 0

end
