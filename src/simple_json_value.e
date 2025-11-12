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

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- Pretty-printed JSON string with `a_indent_level' indentation.
			-- Each indent level adds one tab character.
		require
			non_negative_indent: a_indent_level >= 0
		deferred
		ensure
			has_result: not Result.is_empty
		end

feature {NONE} -- Implementation

	indent_string (a_level: INTEGER): STRING
			-- Create indentation string with `a_level' tabs
		require
			non_negative: a_level >= 0
		local
			l_index: INTEGER
		do
			create Result.make_empty
			from
				l_index := 1
			until
				l_index > a_level
			loop
				Result.append_character ('%T')
				l_index := l_index + 1
			end
		ensure
			correct_length: Result.count = a_level
		end
		
end
