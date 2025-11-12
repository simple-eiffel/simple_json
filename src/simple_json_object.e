note
	description: "Wrapper for JSON objects - provides simple access to JSON data"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "2"

class
	SIMPLE_JSON_OBJECT

inherit
	SIMPLE_JSON_VALUE

create
	make_empty,
	make_from_json

feature {NONE} -- Initialization

	make_empty
			-- Create an empty JSON object
		do
			create json_object.make_with_capacity (10)
		end

	make_from_json (a_json_object: JSON_OBJECT)
			-- Create from an eJSON JSON_OBJECT
		require
			valid_object: a_json_object /= Void
		do
			json_object := a_json_object
		ensure
			set: json_object = a_json_object
		end

feature -- Status Report

	has_key (a_key: STRING): BOOLEAN
			-- Does object contain this key?
		require
			not_empty_key: not a_key.is_empty
		do
			Result := json_object.has_key (a_key)
		end

	count: INTEGER
			-- Number of key-value pairs
		do
			Result := json_object.count
		ensure
			non_negative: Result >= 0
		end

	is_empty: BOOLEAN
			-- Is this object empty?
		do
			Result := json_object.is_empty
		ensure
			definition: Result = (count = 0)
		end

feature -- Access

	string (a_key: STRING): detachable STRING
			-- Get string value for key
		require
			valid_key: a_key /= Void and then not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_STRING} l_value as l_str then
					Result := l_str.unescaped_string_8
				end
			end
		end

	integer (a_key: STRING): INTEGER
			-- Get integer value for key
		require
			not_empty_key: not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_integer then
						Result := l_num.integer_64_item.to_integer_32
					elseif l_num.is_real then
						-- Convert real to integer (truncate)
						Result := l_num.real_64_item.truncated_to_integer
					end
				end
			end
		end

	boolean (a_key: STRING): BOOLEAN
			-- Get boolean value for key
		require
			valid_key: a_key /= Void and then not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_BOOLEAN} l_value as l_bool then
					Result := l_bool.item
				end
			end
		end

	real (a_key: STRING): REAL_64
			-- Get real/double value for key
		require
			not_empty_key: not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_real then
						Result := l_num.real_64_item
					elseif l_num.is_integer then
							-- Convert integer to real
						Result := l_num.integer_64_item.to_double
					end
				end
			end
		end

	array (a_key: STRING): detachable SIMPLE_JSON_ARRAY
			-- Get array value for key
		require
			valid_key: a_key /= Void and then not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_ARRAY} l_value as l_arr then
					create Result.make_from_json (l_arr)
				end
			end
		end

	object (a_key: STRING): detachable SIMPLE_JSON_OBJECT
			-- Get nested object for key
		require
			valid_key: a_key /= Void and then not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				if attached {JSON_OBJECT} l_value as l_obj then
					create Result.make_from_json (l_obj)
				end
			end
		end

feature -- Modification

	put_string (a_key: STRING; a_value: STRING)
			-- Set string value for key (adds new or updates existing)
		require
			not_empty_key: not a_key.is_empty
		do
			if has_key (a_key) then
				json_object.replace (create {JSON_STRING}.make_from_string (a_value), a_key)
			else
				json_object.put (create {JSON_STRING}.make_from_string (a_value), a_key)
			end
		ensure
			key_exists: has_key (a_key)
			value_set: attached string (a_key) as s implies s.is_equal (a_value)
		end

	put_integer (a_key: STRING; a_value: INTEGER)
		require
			not_empty_key: not a_key.is_empty
		do
			if has_key (a_key) then
				json_object.replace (create {JSON_NUMBER}.make_integer (a_value), a_key)
			else
				json_object.put (create {JSON_NUMBER}.make_integer (a_value), a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

	put_boolean (a_key: STRING; a_value: BOOLEAN)
		require
			not_empty_key: not a_key.is_empty
		do
			if has_key (a_key) then
				json_object.replace (create {JSON_BOOLEAN}.make (a_value), a_key)
			else
				json_object.put (create {JSON_BOOLEAN}.make (a_value), a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

	put_real (a_key: STRING; a_value: REAL_64)
		require
			not_empty_key: not a_key.is_empty
		do
			if has_key (a_key) then
				json_object.replace (create {JSON_NUMBER}.make_real (a_value), a_key)
			else
				json_object.put (create {JSON_NUMBER}.make_real (a_value), a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = False
	is_object: BOOLEAN = True
	is_array: BOOLEAN = False

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_object.representation
		end

feature {NONE} -- Implementation

	json_object: JSON_OBJECT
			-- Underlying eJSON object

end
