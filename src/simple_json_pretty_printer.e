note
	description: "[
		Pretty printer for JSON values with configurable indentation.
		Produces human-readable JSON output with proper formatting.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_PRETTY_PRINTER

inherit
	JSON_VISITOR

create
	make,
	make_with_options

feature {NONE} -- Initialization

	make
			-- Initialize with default options (2 spaces for indentation)
		do
			indent_string := "  "
			current_indent_level := 0
			create output.make_empty
		ensure
			two_space_indent: indent_string.same_string ("  ")
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
			reasonable_count: a_count <= 8
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
		ensure
			result_not_void: Result /= Void
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
				output.append ("[]")
			else
				output.append ("[")
				output.append_character ('%N')

				increase_indent

				from
					l_json_array.start
					l_first := True
				until
					l_json_array.off
				loop
					if not l_first then
						output.append (",")
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
				output.append ("]")
			end
		end

	visit_json_boolean (a_json_boolean: JSON_BOOLEAN)
			-- Visit `a_json_boolean'
		do
			if a_json_boolean.item then
				output.append ("true")
			else
				output.append ("false")
			end
		end

	visit_json_null (a_json_null: JSON_NULL)
			-- Visit `a_json_null'
		do
			output.append ("null")
		end

	visit_json_number (a_json_number: JSON_NUMBER)
			-- Visit `a_json_number'
		do
			output.append (a_json_number.item)
		end

	visit_json_object (a_json_object: JSON_OBJECT)
			-- Visit `a_json_object' with pretty formatting
		local
			l_pairs: HASH_TABLE [JSON_VALUE, JSON_STRING]
			l_first: BOOLEAN
		do
			l_pairs := a_json_object.map_representation

			if l_pairs.is_empty then
				output.append ("{}")
			else
				output.append ("{")
				output.append_character ('%N')

				increase_indent

				from
					l_pairs.start
					l_first := True
				until
					l_pairs.off
				loop
					if not l_first then
						output.append (",")
						output.append_character ('%N')
					end

					append_indent
					l_pairs.key_for_iteration.accept (Current)
					output.append (": ")
					l_pairs.item_for_iteration.accept (Current)

					l_pairs.forth
					l_first := False
				end

				decrease_indent

				output.append_character ('%N')
				append_indent
				output.append ("}")
			end
		end

	visit_json_string (a_json_string: JSON_STRING)
			-- Visit `a_json_string'
		do
			output.append ("%"")
			output.append (a_json_string.item)
			output.append ("%"")
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
