note
	description: "Wrapper for JSON null values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	SIMPLE_JSON_NULL

inherit
	SIMPLE_JSON_VALUE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make
			-- Create null value
		do
			create json_null
		end

	make_from_json (a_json_null: JSON_NULL)
			-- Create from eJSON JSON_NULL
		do
			json_null := a_json_null
		ensure
			set: json_null = a_json_null
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = True
	is_object: BOOLEAN = False
	is_array: BOOLEAN = False

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_null.representation
		end

feature {NONE} -- Implementation

	json_null: JSON_NULL
			-- Underlying eJSON null

invariant
	has_null: attached json_null

end
