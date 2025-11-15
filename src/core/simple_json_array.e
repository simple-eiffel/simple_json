note
	description: "[
		Simple, high-level wrapper for JSON_ARRAY with fluent API and Unicode support.
		All strings are STRING_32 for proper Unicode/UTF-8 handling.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_ARRAY

inherit
	SIMPLE_JSON_VALUE
		rename
			make as make_value
		redefine
			json_value,
			make_value
		end

create
	make,
	make_with_json_array

feature {NONE} -- Initialization

	make
			-- Initialize with empty JSON array
		local
			l_array: JSON_ARRAY
		do
			create l_array.make_empty
			make_value (l_array)
		end

	make_with_json_array (a_array: JSON_ARRAY)
			-- Initialize with existing JSON array
		require
			array_not_void: a_array /= Void
		do
			make_value (a_array)
		end

	make_value (a_value: JSON_VALUE)
			-- Initialize with underlying JSON value
		require else
			value_is_array: attached {JSON_ARRAY} a_value
		do
			check attached {JSON_ARRAY} a_value as l_array then
				json_value := l_array
			end
		ensure then
			value_set: json_value = a_value
		end

feature -- Access

	json_value: JSON_ARRAY
			-- Underlying JSON array

feature -- Measurement

	count: INTEGER
			-- Number of items
		do
			Result := json_value.count
		end

	is_empty: BOOLEAN
			-- Is array empty?
		do
			Result := json_value.is_empty
		end

feature -- Access

	item alias "[]" (i: INTEGER): SIMPLE_JSON_VALUE
			-- Get item at index (1-based)
		require
			valid_index: valid_index (i)
		do
			create Result.make (json_value.i_th (i))
		end

	string_item (i: INTEGER): detachable STRING_32
			-- Get string value at index (returns Void if not a string)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_string then
				Result := l_value.as_string_32
			end
		end

	integer_item (i: INTEGER): INTEGER_64
			-- Get integer value at index (returns 0 if not found or not a number)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_number then
				Result := l_value.as_integer
			end
		end

	real_item (i: INTEGER): DOUBLE
			-- Get real value at index (returns 0.0 if not found or not a number)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_number then
				Result := l_value.as_real
			end
		end

	boolean_item (i: INTEGER): BOOLEAN
			-- Get boolean value at index (returns False if not found or not a boolean)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_boolean then
				Result := l_value.as_boolean
			end
		end

	object_item (i: INTEGER): detachable SIMPLE_JSON_OBJECT
			-- Get object value at index (returns Void if not an object)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_object then
				Result := l_value.as_object
			end
		end

	array_item (i: INTEGER): detachable SIMPLE_JSON_ARRAY
			-- Get array value at index (returns Void if not an array)
		require
			valid_index: valid_index (i)
		do
			if attached item (i) as l_value and then l_value.is_array then
				Result := l_value.as_array
			end
		end

feature -- Status report

	valid_index (i: INTEGER): BOOLEAN
			-- Is `i' a valid index?
		do
			Result := json_value.valid_index (i)
		end

feature -- Element change (Fluent API)

	add_string (a_value: STRING_32): SIMPLE_JSON_ARRAY
			-- Add string value (fluent)
		local
			l_json_string: JSON_STRING
		do
			create l_json_string.make_from_string_32 (a_value)
			json_value.add (l_json_string)
			Result := Current
		end

	add_integer (a_value: INTEGER_64): SIMPLE_JSON_ARRAY
			-- Add integer value (fluent)
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_integer (a_value)
			json_value.add (l_json_number)
			Result := Current
		end

	add_real (a_value: DOUBLE): SIMPLE_JSON_ARRAY
			-- Add real value (fluent)
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_real (a_value)
			json_value.add (l_json_number)
			Result := Current
		end

	add_boolean (a_value: BOOLEAN): SIMPLE_JSON_ARRAY
			-- Add boolean value (fluent)
		local
			l_json_boolean: JSON_BOOLEAN
		do
			create l_json_boolean.make (a_value)
			json_value.add (l_json_boolean)
			Result := Current
		end

	add_null: SIMPLE_JSON_ARRAY
			-- Add null value (fluent)
		local
			l_json_null: JSON_NULL
		do
			create l_json_null
			json_value.add (l_json_null)
			Result := Current
		end

	add_object (a_value: SIMPLE_JSON_OBJECT): SIMPLE_JSON_ARRAY
			-- Add object value (fluent)
		require
			value_not_void: a_value /= Void
		do
			json_value.add (a_value.json_value)
			Result := Current
		end

	add_array (a_value: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY
			-- Add array value (fluent)
		require
			value_not_void: a_value /= Void
		do
			json_value.add (a_value.json_value)
			Result := Current
		end

	add_value (a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY
			-- Add any JSON value (fluent)
		require
			value_not_void: a_value /= Void
		do
			json_value.add (a_value.json_value)
			Result := Current
		end

feature -- Removal

	wipe_out
			-- Remove all items
		do
			json_value.wipe_out
		end

end
