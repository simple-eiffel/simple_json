note
	description: "[
		Simple, high-level wrapper for JSON_OBJECT with fluent API and Unicode support.
		All strings are STRING_32 for proper Unicode/UTF-8 handling.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_OBJECT

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
	make_with_json_object

feature {NONE} -- Initialization

	make
			-- Initialize with empty JSON object
		local
			l_object: JSON_OBJECT
		do
			create l_object.make
			make_value (l_object)
		end

	make_with_json_object (a_object: JSON_OBJECT)
			-- Initialize with existing JSON object
		require
			object_not_void: a_object /= Void
		do
			make_value (a_object)
		end

	make_value (a_value: JSON_VALUE)
			-- Initialize with underlying JSON value
		require else
			value_is_object: attached {JSON_OBJECT} a_value
		do
			check attached {JSON_OBJECT} a_value as l_object then
				json_value := l_object
			end
		ensure then
			value_set: json_value = a_value
		end

feature -- Access

	json_value: JSON_OBJECT
			-- Underlying JSON object

feature -- Measurement

	count: INTEGER
			-- Number of key-value pairs
		do
			Result := json_value.count
		end

	is_empty: BOOLEAN
			-- Is object empty?
		do
			Result := json_value.is_empty
		end

feature -- Status report

	has_key (a_key: STRING_32): BOOLEAN
			-- Does object have key?
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			Result := json_value.has_key (l_json_key)
		end

feature -- Access (Unicode keys)

	item (a_key: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Get value for key (returns Void if key doesn't exist)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			if attached json_value.item (l_json_key) as l_value then
				create Result.make (l_value)
			end
		end

	string_item (a_key: STRING_32): detachable STRING_32
			-- Get string value for key (returns Void if not a string)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_string then
				Result := l_value.as_string_32
			end
		end

	integer_item (a_key: STRING_32): INTEGER_64
			-- Get integer value for key (returns 0 if not found or not a number)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_number then
				Result := l_value.as_integer
			end
		end

	real_item (a_key: STRING_32): DOUBLE
			-- Get real value for key (returns 0.0 if not found or not a number)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_number then
				Result := l_value.as_real
			end
		end

	boolean_item (a_key: STRING_32): BOOLEAN
			-- Get boolean value for key (returns False if not found or not a boolean)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_boolean then
				Result := l_value.as_boolean
			end
		end

	object_item (a_key: STRING_32): detachable SIMPLE_JSON_OBJECT
			-- Get object value for key (returns Void if not an object)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_object then
				Result := l_value.as_object
			end
		end

	array_item (a_key: STRING_32): detachable SIMPLE_JSON_ARRAY
			-- Get array value for key (returns Void if not an array)
		require
			key_not_empty: not a_key.is_empty
		do
			if attached item (a_key) as l_value and then l_value.is_array then
				Result := l_value.as_array
			end
		end

feature -- Element change (Fluent API)

	put_string (a_value: STRING_32; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add string value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
			l_json_value: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			create l_json_value.make_from_string_32 (a_value)
			json_value.replace (l_json_value, l_json_key)
			Result := Current
		end

	put_integer (a_value: INTEGER_64; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add integer value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_integer (a_value, l_json_key)
			Result := Current
		end

	put_real (a_value: DOUBLE; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add real value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_real (a_value, l_json_key)
			Result := Current
		end

	put_boolean (a_value: BOOLEAN; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add boolean value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_boolean (a_value, l_json_key)
			Result := Current
		end

	put_null (a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add null value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
			l_json_null: JSON_NULL
		do
			create l_json_key.make_from_string_32 (a_key)
			create l_json_null
			json_value.replace (l_json_null, l_json_key)
			Result := Current
		end

	put_object (a_value: SIMPLE_JSON_OBJECT; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add object value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			value_not_void: a_value /= Void
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		end

	put_array (a_value: SIMPLE_JSON_ARRAY; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add array value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			value_not_void: a_value /= Void
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		end

	put_value (a_value: SIMPLE_JSON_VALUE; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add any JSON value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			value_not_void: a_value /= Void
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		end

feature -- Removal

	remove (a_key: STRING_32)
			-- Remove key-value pair
		require
			key_not_empty: not a_key.is_empty
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.remove (l_json_key)
		end

	wipe_out
			-- Remove all key-value pairs
		do
			json_value.wipe_out
		end

feature -- Iteration

	keys: ARRAY [STRING_32]
			-- Array of all keys (as STRING_32)
		local
			l_json_keys: ARRAY [JSON_STRING]
			i: INTEGER
		do
			l_json_keys := json_value.current_keys
			create Result.make_filled (create {STRING_32}.make_empty, l_json_keys.lower, l_json_keys.upper)
			from
				i := l_json_keys.lower
			until
				i > l_json_keys.upper
			loop
				Result [i] := l_json_keys [i].unescaped_string_32
				i := i + 1
			end
		end

end
