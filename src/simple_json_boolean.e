note
	description: "Wrapper for JSON boolean values"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

class
	SIMPLE_JSON_BOOLEAN

inherit
	SIMPLE_JSON_VALUE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_value: BOOLEAN)
			-- Create from Eiffel boolean
		do
			create json_boolean.make (a_value)
		end

	make_from_json (a_json_boolean: JSON_BOOLEAN)
			-- Create from eJSON JSON_BOOLEAN
		do
			json_boolean := a_json_boolean
		ensure
			set: json_boolean = a_json_boolean
		end

feature -- Access

	value: BOOLEAN
			-- The boolean value
		do
			Result := json_boolean.item
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = True
	is_null: BOOLEAN = False
	is_object: BOOLEAN = False
	is_array: BOOLEAN = False

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_boolean.representation
		end

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- <Precursor>
		do
			if value then
				Result := "true"
			else
				Result := "false"
			end
		end

feature {NONE} -- Implementation

	json_boolean: JSON_BOOLEAN
			-- Underlying eJSON boolean

invariant
	has_boolean: attached json_boolean

end
