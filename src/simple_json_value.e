note
	description: "Abstract base class for all JSON value types"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "1"

deferred class
	SIMPLE_JSON_VALUE

feature -- Type checking

	is_string: BOOLEAN
			-- Is Current a string value?
		deferred
		end

	is_number: BOOLEAN
			-- Is Current a numeric value?
		deferred
		end

	is_integer: BOOLEAN
			-- Is Current an integer value?
		deferred
		end

	is_real: BOOLEAN
			-- Is Current a real number value?
		deferred
		end

	is_boolean: BOOLEAN
			-- Is Current a boolean value?
		deferred
		end

	is_null: BOOLEAN
			-- Is Current a null value?
		deferred
		end

	is_object: BOOLEAN
			-- Is Current an object?
		deferred
		end

	is_array: BOOLEAN
			-- Is Current an array?
		deferred
		end

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		deferred
		ensure
			result_not_void: Result /= Void
		end

end
