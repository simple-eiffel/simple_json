note
	description: "[
		Fluent JSON builder for SIMPLE_JSON_QUICK.

		Allows chaining put() calls to build JSON:
			json.object.put ("name", "Alice").put ("age", 30).to_json
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
		end

	make_array
			-- Create array builder.
		do
			create json_array.make
			is_object_mode := False
		ensure
			array_mode: not is_object_mode
		end

feature -- Object Building (chainable)

	put (a_key: STRING; a_value: ANY): SIMPLE_JSON_BUILDER
			-- Add key-value pair to object.
		require
			is_object: is_object_mode
			key_not_empty: not a_key.is_empty
		do
			if attached {STRING} a_value as s then
				json_object := json_object.put_string (s, a_key)
			elseif attached {STRING_32} a_value as s32 then
				json_object := json_object.put_string (s32.to_string_8, a_key)
			elseif attached {INTEGER} a_value as i then
				json_object := json_object.put_integer (i, a_key)
			elseif attached {INTEGER_64} a_value as i64 then
				json_object := json_object.put_integer (i64, a_key)
			elseif attached {REAL_64} a_value as r then
				json_object := json_object.put_real (r, a_key)
			elseif attached {REAL_32} a_value as r32 then
				json_object := json_object.put_real (r32.to_double, a_key)
			elseif attached {BOOLEAN} a_value as b then
				json_object := json_object.put_boolean (b, a_key)
			elseif attached {SIMPLE_JSON_VALUE} a_value as jv then
				json_object := json_object.put_value (jv, a_key)
			elseif attached {SIMPLE_JSON_OBJECT} a_value as jo then
				json_object := json_object.put_object (jo, a_key)
			elseif attached {SIMPLE_JSON_ARRAY} a_value as ja then
				json_object := json_object.put_array (ja, a_key)
			end
			Result := Current
		ensure
			result_is_self: Result = Current
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
		end

feature -- Array Building (chainable)

	add (a_value: ANY): SIMPLE_JSON_BUILDER
			-- Add value to array.
		require
			is_array: not is_object_mode
		do
			if attached {STRING} a_value as s then
				json_array := json_array.add_string (s)
			elseif attached {STRING_32} a_value as s32 then
				json_array := json_array.add_string (s32.to_string_8)
			elseif attached {INTEGER} a_value as i then
				json_array := json_array.add_integer (i)
			elseif attached {INTEGER_64} a_value as i64 then
				json_array := json_array.add_integer (i64)
			elseif attached {REAL_64} a_value as r then
				json_array := json_array.add_real (r)
			elseif attached {REAL_32} a_value as r32 then
				json_array := json_array.add_real (r32.to_double)
			elseif attached {BOOLEAN} a_value as b then
				json_array := json_array.add_boolean (b)
			elseif attached {SIMPLE_JSON_VALUE} a_value as jv then
				json_array := json_array.add_value (jv)
			end
			Result := Current
		ensure
			result_is_self: Result = Current
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
			result_exists: Result /= Void
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

end
