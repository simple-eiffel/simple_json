note
	description: "[
		Zero-configuration JSON facade for beginners.

		One-liner JSON operations - parse, query, build.
		For full control, use SIMPLE_JSON directly.

		Quick Start Examples:
			create json.make

			-- Parse and query
			if attached json.parse_object (json_string) as obj then
				name := json.string_at (obj, "user.name")
				age := json.integer_at (obj, "user.age")
			end

			-- Build JSON
			result := json.object.put ("name", "Alice").put ("age", 30).to_json

			-- One-liner parse + get
			name := json.get_string (json_string, "$.user.name")
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick JSON facade.
		do
			create json
			
		ensure
			json_exists: json /= Void
		end

feature -- Parsing

	parse (a_json: STRING): detachable SIMPLE_JSON_VALUE
			-- Parse JSON string to value.
		require
			json_not_empty: not a_json.is_empty
		do
			
			Result := json.parse (a_json.to_string_32)
		end

	parse_object (a_json: STRING): detachable SIMPLE_JSON_OBJECT
			-- Parse JSON string to object.
		require
			json_not_empty: not a_json.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := v.as_object
			end
		end

	parse_array (a_json: STRING): detachable SIMPLE_JSON_ARRAY
			-- Parse JSON string to array.
		require
			json_not_empty: not a_json.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := v.as_array
			end
		end

feature -- Path-based Getters (parse + query in one call)

	get_string (a_json: STRING; a_path: STRING): detachable STRING
			-- Parse JSON and get string at JSONPath.
			-- Example: json.get_string (data, "$.user.name")
		require
			json_not_empty: not a_json.is_empty
			path_not_empty: not a_path.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				if attached json.query_string (v, a_path) as l_s then Result := l_s.to_string_8 end
			end
		end

	get_integer (a_json: STRING; a_path: STRING): INTEGER
			-- Parse JSON and get integer at JSONPath.
		require
			json_not_empty: not a_json.is_empty
			path_not_empty: not a_path.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := json.query_integer (v, a_path).to_integer_32
			end
		end

	get_real (a_json: STRING; a_path: STRING): REAL_64
			-- Parse JSON and get real at JSONPath.
		require
			json_not_empty: not a_json.is_empty
			path_not_empty: not a_path.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				-- TODO: implement when SIMPLE_JSON adds query_real
			end
		end

	get_boolean (a_json: STRING; a_path: STRING): BOOLEAN
			-- Parse JSON and get boolean at JSONPath.
		require
			json_not_empty: not a_json.is_empty
			path_not_empty: not a_path.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				-- TODO: implement when SIMPLE_JSON adds query_boolean
			end
		end

feature -- Object Value Getters (dot-path navigation)

	string_at (a_object: SIMPLE_JSON_OBJECT; a_path: STRING): detachable STRING
			-- Get string at dot-separated path.
			-- Example: json.string_at (obj, "user.address.city")
		require
			object_not_void: a_object /= Void
			path_not_empty: not a_path.is_empty
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			l_parts := a_path.split ('.')
			l_current := a_object
			from i := 1 until i > l_parts.count - 1 or l_current = Void loop
				if attached l_current.object_item (l_parts [i]) as next_obj then
					l_current := next_obj
				else
					l_current := Void
				end
				i := i + 1
			end
			if attached l_current and then i = l_parts.count then
				if attached l_current.string_item (l_parts [i]) as l_s then Result := l_s.to_string_8 end
			end
		end

	integer_at (a_object: SIMPLE_JSON_OBJECT; a_path: STRING): INTEGER
			-- Get integer at dot-separated path.
		require
			object_not_void: a_object /= Void
			path_not_empty: not a_path.is_empty
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			l_parts := a_path.split ('.')
			l_current := a_object
			from i := 1 until i > l_parts.count - 1 or l_current = Void loop
				if attached l_current.object_item (l_parts [i]) as next_obj then
					l_current := next_obj
				else
					l_current := Void
				end
				i := i + 1
			end
			if attached l_current and then i = l_parts.count then
				Result := l_current.integer_item (l_parts [i]).to_integer_32
			end
		end

	real_at (a_object: SIMPLE_JSON_OBJECT; a_path: STRING): REAL_64
			-- Get real at dot-separated path.
		require
			object_not_void: a_object /= Void
			path_not_empty: not a_path.is_empty
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			l_parts := a_path.split ('.')
			l_current := a_object
			from i := 1 until i > l_parts.count - 1 or l_current = Void loop
				if attached l_current.object_item (l_parts [i]) as next_obj then
					l_current := next_obj
				else
					l_current := Void
				end
				i := i + 1
			end
			if attached l_current and then i = l_parts.count then
				Result := l_current.real_item (l_parts [i])
			end
		end

	boolean_at (a_object: SIMPLE_JSON_OBJECT; a_path: STRING): BOOLEAN
			-- Get boolean at dot-separated path.
		require
			object_not_void: a_object /= Void
			path_not_empty: not a_path.is_empty
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_JSON_OBJECT
			i: INTEGER
		do
			l_parts := a_path.split ('.')
			l_current := a_object
			from i := 1 until i > l_parts.count - 1 or l_current = Void loop
				if attached l_current.object_item (l_parts [i]) as next_obj then
					l_current := next_obj
				else
					l_current := Void
				end
				i := i + 1
			end
			if attached l_current and then i = l_parts.count then
				Result := l_current.boolean_item (l_parts [i])
			end
		end

feature -- Building

	object: SIMPLE_JSON_BUILDER
			-- Start building a JSON object.
		do
			create Result.make_object
		ensure
			result_exists: Result /= Void
		end

	array: SIMPLE_JSON_BUILDER
			-- Start building a JSON array.
		do
			create Result.make_array
		ensure
			result_exists: Result /= Void
		end

	from_pairs (a_pairs: ARRAY [TUPLE [key: STRING; value: ANY]]): STRING
			-- Build JSON object from key-value pairs.
			-- Example: json.from_pairs (<<["name", "Alice"], ["age", 30]>>)
		require
			pairs_not_empty: a_pairs.count > 0
		local
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_obj.make
			across a_pairs as p loop
				if attached {STRING} p.value as s then
					l_obj := l_obj.put_string (s, p.key)
				elseif attached {INTEGER} p.value as i then
					l_obj := l_obj.put_integer (i, p.key)
				elseif attached {REAL_64} p.value as r then
					l_obj := l_obj.put_real (r, p.key)
				elseif attached {BOOLEAN} p.value as b then
					l_obj := l_obj.put_boolean (b, p.key)
				end
			end
			Result := l_obj.to_json_string.to_string_8
		ensure
			result_not_empty: not Result.is_empty
		end

feature -- Conversion

	to_string (a_value: SIMPLE_JSON_VALUE): STRING
			-- Convert JSON value to string.
		require
			value_not_void: a_value /= Void
		do
			Result := a_value.to_json_string.to_string_8
		ensure
			result_not_empty: not Result.is_empty
		end

	prettify (a_json: STRING): STRING
			-- Pretty-print JSON string.
		require
			json_not_empty: not a_json.is_empty
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := v.to_pretty_json.to_string_8
			else
				Result := a_json
			end
		end

feature -- Validation

	is_valid (a_json: STRING): BOOLEAN
			-- Is string valid JSON?
		do
			Result := attached json.parse (a_json.to_string_32)
		end

	is_object (a_json: STRING): BOOLEAN
			-- Does string parse to JSON object?
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := v.is_object
			end
		end

	is_array (a_json: STRING): BOOLEAN
			-- Does string parse to JSON array?
		do
			if attached json.parse (a_json.to_string_32) as v then
				Result := v.is_array
			end
		end

feature -- Advanced Access

	json: SIMPLE_JSON
			-- Access underlying JSON handler for advanced operations.

feature {NONE} -- Implementation


invariant
	json_exists: json /= Void

end
