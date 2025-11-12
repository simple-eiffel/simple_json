note
	description: "Wrapper for JSON integer values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	SIMPLE_JSON_INTEGER

inherit
	SIMPLE_JSON_VALUE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_value: INTEGER)
			-- Create from Eiffel integer
		do
			create json_number.make_integer (a_value)
		end

	make_from_json (a_json_number: JSON_NUMBER)
			-- Create from eJSON JSON_NUMBER
		require
			is_integer: a_json_number.is_integer
		do
			json_number := a_json_number
		ensure
			set: json_number = a_json_number
		end

feature -- Access

	value: INTEGER
			-- The integer value
		do
			Result := json_number.integer_64_item.to_integer_32
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = True
	is_integer: BOOLEAN = True
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = False
	is_object: BOOLEAN = False
	is_array: BOOLEAN = False

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_number.representation
		end

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- <Precursor>
		do
			Result := value.out
		end

feature {NONE} -- Implementation

	json_number: JSON_NUMBER
			-- Underlying eJSON number

invariant
	has_number: attached json_number

end
