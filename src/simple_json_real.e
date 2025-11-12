note
	description: "Wrapper for JSON real/double values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	SIMPLE_JSON_REAL

inherit
	SIMPLE_JSON_VALUE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_value: REAL_64)
			-- Create from Eiffel real
		do
			create json_number.make_real (a_value)
		end

	make_from_json (a_json_number: JSON_NUMBER)
			-- Create from eJSON JSON_NUMBER
		require
			is_real: a_json_number.is_real
		do
			json_number := a_json_number
		ensure
			set: json_number = a_json_number
		end

feature -- Access

	value: REAL_64
			-- The real value
		do
			Result := json_number.real_64_item
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = True
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = True
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
