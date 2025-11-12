note
	description: "Wrapper for JSON objects - provides simple access to JSON data with enhanced operations"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "4"

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


	item_at_key (a_key: STRING): detachable SIMPLE_JSON_VALUE
			-- Get value for key wrapped in appropriate SIMPLE_JSON_VALUE type
		require
			not_empty_key: not a_key.is_empty
		do
			if attached json_object.item (a_key) as l_value then
				Result := wrap_json_value (l_value)
			end
		end
feature -- Modification (Basic)

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
			-- Set integer value for key
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
			-- Set boolean value for key
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
			-- Set real value for key
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

	put_object (a_key: STRING; a_value: SIMPLE_JSON_OBJECT)
			-- Set nested object for key
		require
			not_empty_key: not a_key.is_empty
			valid_object: attached a_value
		do
			if has_key (a_key) then
				json_object.replace (a_value.internal_json_object, a_key)
			else
				json_object.put (a_value.internal_json_object, a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

	put_array (a_key: STRING; a_value: SIMPLE_JSON_ARRAY)
			-- Set array for key
		require
			not_empty_key: not a_key.is_empty
			valid_array: attached a_value
		do
			if has_key (a_key) then
				json_object.replace (a_value.internal_json_array, a_key)
			else
				json_object.put (a_value.internal_json_array, a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

feature -- Modification (Advanced)

	merge (a_other: SIMPLE_JSON_OBJECT)
			-- Merge another object into this one
			-- Existing keys will be overwritten by values from a_other
		require
			valid_object: attached a_other
		local
			l_keys: ARRAY [JSON_STRING]
			l_other_obj: JSON_OBJECT
			l_key: JSON_STRING
			l_key_string: STRING
		do
			l_other_obj := a_other.internal_json_object
			l_keys := l_other_obj.current_keys
			across l_keys as ic loop
				l_key := ic.item
				l_key_string := l_key.item
				if attached l_other_obj.item (l_key) as l_value then
					if has_key (l_key_string) then
						json_object.replace (l_value, l_key)
					else
						json_object.put (l_value, l_key)
					end
				end
			end
		end

	remove_key (a_key: STRING)
			-- Remove key from object
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.remove (a_key)
		ensure
			key_removed: not has_key (a_key)
		end

	rename_key (a_old_key: STRING; a_new_key: STRING)
			-- Rename a key
		require
			not_empty_old_key: not a_old_key.is_empty
			not_empty_new_key: not a_new_key.is_empty
			has_old_key: has_key (a_old_key)
		do
			if attached json_object.item (a_old_key) as l_value then
				json_object.put (l_value, a_new_key)
				json_object.remove (a_old_key)
			end
		ensure
			old_key_removed: not has_key (a_old_key)
			new_key_exists: has_key (a_new_key)
		end

	json_clone: SIMPLE_JSON_OBJECT
			-- Create an independent copy of this object
		local
			l_json_string: STRING
			l_parser: JSON_PARSER
		do
			-- Serialize to JSON string then parse back
			l_json_string := to_json_string
			create l_parser.make_with_string (l_json_string)
			l_parser.parse_content

			if l_parser.is_parsed and then l_parser.is_valid then
				if attached {JSON_OBJECT} l_parser.parsed_json_value as l_obj then
					create Result.make_from_json (l_obj)
				else
					-- Fallback to empty object
					create Result.make_empty
				end
			else
				-- Fallback to empty object
				create Result.make_empty
			end
		ensure
			result_exists: attached Result
			independent: Result /= Current
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

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- <Precursor>
		local
			l_first: BOOLEAN
			l_keys: ARRAY [JSON_STRING]
			l_key: JSON_STRING
			l_key_string: STRING
			l_wrapper: SIMPLE_JSON_VALUE
		do
			if json_object.is_empty then
				Result := "{}"
			else
				create Result.make_empty
				Result.append_character ('{')
				Result.append_character ('%N')

				l_keys := json_object.current_keys
				l_first := True
				across l_keys as ic_key loop
					if not l_first then
						Result.append_character (',')
						Result.append_character ('%N')
					end
					Result.append (indent_string (a_indent_level + 1))
					Result.append_character ('%"')
					l_key := ic_key.item
					l_key_string := l_key.item
					Result.append (l_key_string)
					Result.append_character ('%"')
					Result.append_character (':')
					Result.append_character (' ')

					if attached json_object.item (l_key) as l_json_value then
						l_wrapper := wrap_json_value (l_json_value)
						Result.append (l_wrapper.to_pretty_string (a_indent_level + 1))
					end

					l_first := False
				end

				Result.append_character ('%N')
				Result.append (indent_string (a_indent_level))
				Result.append_character ('}')
			end
		end

feature {NONE} -- Implementation

	wrap_json_value (a_json_value: JSON_VALUE): SIMPLE_JSON_VALUE
			-- Wrap a JSON_VALUE in appropriate SIMPLE_JSON_* type
		require
			valid_value: attached a_json_value
		do
			if attached {JSON_OBJECT} a_json_value as l_obj then
				create {SIMPLE_JSON_OBJECT} Result.make_from_json (l_obj)
			elseif attached {JSON_ARRAY} a_json_value as l_arr then
				create {SIMPLE_JSON_ARRAY} Result.make_from_json (l_arr)
			elseif attached {JSON_STRING} a_json_value as l_str then
				create {SIMPLE_JSON_STRING} Result.make (l_str.unescaped_string_8)
			elseif attached {JSON_NUMBER} a_json_value as l_num then
				if l_num.is_integer then
					create {SIMPLE_JSON_INTEGER} Result.make (l_num.integer_64_item.to_integer_32)
				else
					create {SIMPLE_JSON_REAL} Result.make (l_num.real_64_item)
				end
			elseif attached {JSON_BOOLEAN} a_json_value as l_bool then
				create {SIMPLE_JSON_BOOLEAN} Result.make (l_bool.item)
			elseif attached {JSON_NULL} a_json_value then
				create {SIMPLE_JSON_NULL} Result.make
			else
				-- Fallback to null
				create {SIMPLE_JSON_NULL} Result.make
			end
		ensure
			result_exists: attached Result
		end

feature -- Modification

	put_value (a_key: STRING; a_value: SIMPLE_JSON_VALUE)
			-- Set value for key (works with any SIMPLE_JSON_VALUE type)
		require
			not_empty_key: not a_key.is_empty
			valid_value: attached a_value
		local
			ejson_value: JSON_VALUE
		do
			ejson_value := unwrap_value (a_value)
			if has_key (a_key) then
				json_object.replace (ejson_value, a_key)
			else
				json_object.put (ejson_value, a_key)
			end
		ensure
			key_exists: has_key (a_key)
		end

feature {NONE} -- Implementation

	unwrap_value (a_value: SIMPLE_JSON_VALUE): JSON_VALUE
			-- Convert SIMPLE_JSON_VALUE to underlying JSON_VALUE
		require
			valid_value: attached a_value
		do
			if attached {SIMPLE_JSON_OBJECT} a_value as al_obj then
				Result := al_obj.internal_json_object
			elseif attached {SIMPLE_JSON_ARRAY} a_value as al_arr then
				Result := al_arr.internal_json_array
			elseif attached {SIMPLE_JSON_STRING} a_value as al_str then
				create {JSON_STRING} Result.make_from_string (al_str.value)
			elseif attached {SIMPLE_JSON_INTEGER} a_value as al_int then
				create {JSON_NUMBER} Result.make_integer (al_int.value)
			elseif attached {SIMPLE_JSON_REAL} a_value as al_real then
				create {JSON_NUMBER} Result.make_real (al_real.value)
			elseif attached {SIMPLE_JSON_BOOLEAN} a_value as al_bool then
				create {JSON_BOOLEAN} Result.make (al_bool.value)
			elseif attached {SIMPLE_JSON_NULL} a_value then
				create {JSON_NULL} Result
			else
				create {JSON_NULL} Result  -- Fallback
			end
		ensure
			result_exists: attached Result
		end

feature {SIMPLE_JSON_OBJECT, SIMPLE_JSON_ARRAY, JSON_BUILDER, JSON_SCHEMA_VALIDATOR} -- Implementation Access

	internal_json_object: JSON_OBJECT
			-- Direct access to underlying eJSON object for internal use
		do
			Result := json_object
		end

feature {NONE} -- Implementation

	json_object: JSON_OBJECT
			-- Underlying eJSON object

end
