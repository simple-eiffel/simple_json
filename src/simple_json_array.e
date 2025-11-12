note
	description: "Wrapper for JSON arrays - provides simple access to array elements"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "2"

class
	SIMPLE_JSON_ARRAY

inherit
	SIMPLE_JSON_VALUE

create
	make_empty,
	make_from_json

feature {NONE} -- Initialization

	make_empty
			-- Create an empty JSON array
		do
			create json_array.make_empty
		end

	make_from_json (a_json_array: JSON_ARRAY)
			-- Create from an eJSON JSON_ARRAY
		do
			json_array := a_json_array
		ensure
			set: json_array = a_json_array
		end

feature -- Status Report

	count: INTEGER
			-- Number of elements in array
		do
			Result := json_array.count
		ensure
			non_negative: Result >= 0
		end

	is_empty: BOOLEAN
			-- Is array empty?
		do
			Result := (count = 0)
		ensure
			definition: Result = (count = 0)
		end

	valid_index (a_index: INTEGER): BOOLEAN
			-- Is index valid for this array?
		do
			Result := a_index >= 1 and a_index <= count
		ensure
			definition: Result = (a_index >= 1 and a_index <= count)
		end

feature -- Access

	string_at (a_index: INTEGER): detachable STRING
			-- Get string value at index (1-based)
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_STRING} l_value as l_str then
					Result := l_str.unescaped_string_8
				end
			end
		end

	real_at (a_index: INTEGER): REAL_64
			-- Get real value at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_real then
						Result := l_num.real_64_item
					elseif l_num.is_integer then
						Result := l_num.integer_64_item.to_double
					end
				end
			end
		end

	integer_at (a_index: INTEGER): INTEGER
			-- Get integer value at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_integer then
						Result := l_num.integer_64_item.to_integer_32
					elseif l_num.is_real then
						Result := l_num.real_64_item.truncated_to_integer
					end
				end
			end
		end

	boolean_at (a_index: INTEGER): BOOLEAN
			-- Get boolean value at index (1-based)
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_BOOLEAN} l_value as l_bool then
					Result := l_bool.item
				end
			end
		end

feature -- Access - Nested Structures

	object_at (a_index: INTEGER): detachable SIMPLE_JSON_OBJECT
			-- Get object at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_OBJECT} l_value as l_obj then
					create Result.make_from_json (l_obj)
				end
			end
		end

	array_at (a_index: INTEGER): detachable SIMPLE_JSON_ARRAY
			-- Get array at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_ARRAY} l_value as l_arr then
					create Result.make_from_json (l_arr)
				end
			end
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = False
	is_object: BOOLEAN = False
	is_array: BOOLEAN = True

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_array.representation
		end

feature {NONE} -- Implementation

	json_array: JSON_ARRAY
			-- Underlying eJSON array

invariant
	has_array: attached json_array

end
