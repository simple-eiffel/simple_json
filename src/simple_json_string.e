note
	description: "Wrapper for JSON string values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	SIMPLE_JSON_STRING

inherit
	SIMPLE_JSON_VALUE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_value: STRING)
			-- Create from Eiffel string
		do
			create json_string.make_from_string (a_value)
		end

	make_from_json (a_json_string: JSON_STRING)
			-- Create from eJSON JSON_STRING
		do
			json_string := a_json_string
		ensure
			set: json_string = a_json_string
		end

feature -- Access

	value: STRING
			-- The string value
		do
			Result := json_string.unescaped_string_8
		end

feature -- Type checking

	is_string: BOOLEAN = True
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = False
	is_object: BOOLEAN = False
	is_array: BOOLEAN = False

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_string.representation
		end

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- <Precursor>
		do
			Result := "%"" + value + "%""
		end

feature {NONE} -- Implementation

	json_string: JSON_STRING
			-- Underlying eJSON string

invariant
	has_string: attached json_string

end
