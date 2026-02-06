note
	description: "[
		Fluent JSON builder for SIMPLE_JSON_QUICK.

		Allows chaining put() calls to build JSON:
			json.object.put ("name", "Alice").put ("age", 30).to_json

		Model queries:
			- object_model: MML_MAP of key-value pairs when in object mode
			- array_model: MML_SEQUENCE of values when in array mode
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_BUILDER

create
	make_object,
	make_array

feature {NONE} -- Initialization

	make_object
			-- Create object builder.
		do
			create json_object.make
			is_object_mode := True
		ensure
			object_mode: is_object_mode
			empty_object: json_object.count = 0
		end

	make_array
			-- Create array builder.
		do
			create json_array.make
			is_object_mode := False
		ensure
			array_mode: not is_object_mode
			empty_array: json_array.count = 0
		end

feature -- Object Building (chainable)

	put (a_key: STRING; a_value: ANY): SIMPLE_JSON_BUILDER
			-- Add key-value pair to object.
		require
			is_object: is_object_mode
			key_not_empty: not a_key.is_empty
		local
			l_old_count: INTEGER
		do
			l_old_count := json_object.count
			if attached {STRING} a_value as al_s then
				json_object := json_object.put_string (al_s, a_key)
			elseif attached {STRING_32} a_value as al_s32 then
				json_object := json_object.put_string (al_s32.to_string_8, a_key)
			elseif attached {INTEGER} a_value as al_i then
				json_object := json_object.put_integer (al_i, a_key)
			elseif attached {INTEGER_64} a_value as al_i64 then
				json_object := json_object.put_integer (al_i64, a_key)
			elseif attached {REAL_64} a_value as al_r then
				json_object := json_object.put_real (al_r, a_key)
			elseif attached {REAL_32} a_value as al_r32 then
				json_object := json_object.put_real (al_r32.to_double, a_key)
			elseif attached {BOOLEAN} a_value as al_b then
				json_object := json_object.put_boolean (al_b, a_key)
			elseif attached {SIMPLE_JSON_VALUE} a_value as al_jv then
				json_object := json_object.put_value (al_jv, a_key)
			elseif attached {SIMPLE_JSON_OBJECT} a_value as al_jo then
				json_object := json_object.put_object (al_jo, a_key)
			elseif attached {SIMPLE_JSON_ARRAY} a_value as al_ja then
				json_object := json_object.put_array (al_ja, a_key)
			end
			Result := Current
		ensure
			result_is_self: Result = Current
			key_exists: json_object.has_key (a_key)
			mode_preserved: is_object_mode
		end

	put_null (a_key: STRING): SIMPLE_JSON_BUILDER
			-- Add null value to object.
		require
			is_object: is_object_mode
			key_not_empty: not a_key.is_empty
		do
			json_object := json_object.put_null (a_key)
			Result := Current
		ensure
			result_is_self: Result = Current
			key_exists: json_object.has_key (a_key)
			mode_preserved: is_object_mode
		end

	put_object (a_key: STRING; a_builder: SIMPLE_JSON_BUILDER): SIMPLE_JSON_BUILDER
			-- Add nested object to object.
		require
			is_object: is_object_mode
			key_not_empty: not a_key.is_empty
			builder_is_object: a_builder.is_object_mode
		do
			json_object := json_object.put_object (a_builder.json_object, a_key)
			Result := Current
		ensure
			result_is_self: Result = Current
			key_exists: json_object.has_key (a_key)
			nested_object_preserved: attached json_object.object_item (a_key) as l_nested implies
				l_nested.count = a_builder.json_object.count
			mode_preserved: is_object_mode
		end

	put_array (a_key: STRING; a_builder: SIMPLE_JSON_BUILDER): SIMPLE_JSON_BUILDER
			-- Add array to object.
		require
			is_object: is_object_mode
			key_not_empty: not a_key.is_empty
			builder_is_array: not a_builder.is_object_mode
		do
			json_object := json_object.put_array (a_builder.json_array, a_key)
			Result := Current
		ensure
			result_is_self: Result = Current
			key_exists: json_object.has_key (a_key)
			nested_array_preserved: attached json_object.array_item (a_key) as l_nested implies
				l_nested.count = a_builder.json_array.count
			mode_preserved: is_object_mode
		end

feature -- Array Building (chainable)

	add (a_value: ANY): SIMPLE_JSON_BUILDER
			-- Add value to array.
		require
			is_array: not is_object_mode
		local
			l_old_count: INTEGER
		do
			l_old_count := json_array.count
			if attached {STRING} a_value as al_s then
				json_array := json_array.add_string (al_s)
			elseif attached {STRING_32} a_value as al_s32 then
				json_array := json_array.add_string (al_s32.to_string_8)
			elseif attached {INTEGER} a_value as al_i then
				json_array := json_array.add_integer (al_i)
			elseif attached {INTEGER_64} a_value as al_i64 then
				json_array := json_array.add_integer (al_i64)
			elseif attached {REAL_64} a_value as al_r then
				json_array := json_array.add_real (al_r)
			elseif attached {REAL_32} a_value as al_r32 then
				json_array := json_array.add_real (al_r32.to_double)
			elseif attached {BOOLEAN} a_value as al_b then
				json_array := json_array.add_boolean (al_b)
			elseif attached {SIMPLE_JSON_VALUE} a_value as al_jv then
				json_array := json_array.add_value (al_jv)
			end
			Result := Current
		ensure
			result_is_self: Result = Current
			count_increased: json_array.count = old json_array.count + 1
			mode_preserved: not is_object_mode
		end

	add_null: SIMPLE_JSON_BUILDER
			-- Add null to array.
		require
			is_array: not is_object_mode
		do
			json_array := json_array.add_null
			Result := Current
		ensure
			result_is_self: Result = Current
			count_increased: json_array.count = old json_array.count + 1
			mode_preserved: not is_object_mode
		end

	add_object (a_builder: SIMPLE_JSON_BUILDER): SIMPLE_JSON_BUILDER
			-- Add nested object to array.
		require
			is_array: not is_object_mode
			builder_is_object: a_builder.is_object_mode
		do
			json_array := json_array.add_object (a_builder.json_object)
			Result := Current
		ensure
			result_is_self: Result = Current
			count_increased: json_array.count = old json_array.count + 1
			nested_object_preserved: attached json_array.object_item (json_array.count) as l_nested implies
				l_nested.count = a_builder.json_object.count
			mode_preserved: not is_object_mode
		end

	add_array (a_builder: SIMPLE_JSON_BUILDER): SIMPLE_JSON_BUILDER
			-- Add nested array to array.
		require
			is_array: not is_object_mode
			builder_is_array: not a_builder.is_object_mode
		do
			json_array := json_array.add_array (a_builder.json_array)
			Result := Current
		ensure
			result_is_self: Result = Current
			count_increased: json_array.count = old json_array.count + 1
			nested_array_preserved: attached json_array.array_item (json_array.count) as l_nested implies
				l_nested.count = a_builder.json_array.count
			mode_preserved: not is_object_mode
		end

feature -- Output

	to_json: STRING
			-- Get JSON string.
		do
			if is_object_mode then
				Result := json_object.to_json_string.to_string_8
			else
				Result := json_array.to_json_string.to_string_8
			end
		ensure
			result_not_empty: not Result.is_empty
			object_starts_with_brace: is_object_mode implies Result.starts_with ("{")
			array_starts_with_bracket: (not is_object_mode) implies Result.starts_with ("[")
		end

	to_value: SIMPLE_JSON_VALUE
			-- Get JSON value.
		do
			if is_object_mode then
				Result := json_object
			else
				Result := json_array
			end
		ensure
			object_result_is_object: is_object_mode implies Result.is_object
			array_result_is_array: (not is_object_mode) implies Result.is_array
		end

feature -- Status

	is_object_mode: BOOLEAN
			-- Are we building an object (vs array)?

feature -- Access

	json_object: SIMPLE_JSON_OBJECT
			-- The object being built.
		attribute
			create Result.make
		end

	json_array: SIMPLE_JSON_ARRAY
			-- The array being built.
		attribute
			create Result.make
		end

feature -- Model queries

	object_model: MML_MAP [STRING, detachable SIMPLE_JSON_VALUE]
			-- Model of current object state as a map from keys to values.
		require
			is_object: is_object_mode
		local
			l_keys: ARRAY [STRING_32]
			i: INTEGER
		do
			create Result
			l_keys := json_object.keys
			from i := l_keys.lower until i > l_keys.upper loop
				Result := Result.updated (l_keys [i].to_string_8, json_object.item (l_keys [i]))
				i := i + 1
			end
		ensure
			count_matches: Result.count = json_object.count
		end

	array_model: MML_SEQUENCE [SIMPLE_JSON_VALUE]
			-- Model of current array state as a sequence of values.
		require
			is_array: not is_object_mode
		local
			i: INTEGER
		do
			create Result
			from i := 1 until i > json_array.count loop
				Result := Result & json_array.item (i)
				i := i + 1
			end
		ensure
			count_matches: Result.count = json_array.count
		end

	object_key_count: INTEGER
			-- Number of keys in the object (for postconditions).
		require
			is_object: is_object_mode
		do
			Result := json_object.count
		end

	array_element_count: INTEGER
			-- Number of elements in the array (for postconditions).
		require
			is_array: not is_object_mode
		do
			Result := json_array.count
		end

invariant
	-- Mode consistency: exactly one mode must be active
	mode_exclusive: is_object_mode xor (not is_object_mode)

	-- Object state when in object mode
	object_valid_in_object_mode: is_object_mode implies json_object /= Void

	-- Array state when in array mode
	array_valid_in_array_mode: (not is_object_mode) implies json_array /= Void

end
