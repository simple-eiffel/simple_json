note
	description: "Query interface for navigating JSON structures"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	EIS: "name=Use Case: Query Interface for Multiple Extractions",
		 "src=file:///${SYSTEM_PATH}/docs/use-cases/query-interface.html",
		 "protocol=uri",
		 "tag=documentation, query, use-case, performance"

class
	JSON_QUERY

create
	make

feature {NONE} -- Initialization

	make (a_json_string: STRING)
			-- Create query from JSON string
		require
			not_empty: not a_json_string.is_empty
		local
			l_parser: SIMPLE_JSON
		do
			create l_parser
			json_object := l_parser.parse (a_json_string)
		end

feature -- Access

	string (a_key: STRING): detachable STRING
			-- Get string value
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.string (a_key)
			end
		end

	integer (a_key: STRING): INTEGER
			-- Get integer value
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.integer (a_key)
			end
		end

	boolean (a_key: STRING): BOOLEAN
			-- Get boolean value
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.boolean (a_key)
			end
		end

	real (a_key: STRING): REAL_64
			-- Get real value
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.real (a_key)
			end
		end

	object (a_key: STRING): detachable SIMPLE_JSON_OBJECT
			-- Get nested object
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.object (a_key)
			end
		end

	array (a_key: STRING): detachable SIMPLE_JSON_ARRAY
			-- Get array
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.array (a_key)
			end
		end

	exists (a_key: STRING): BOOLEAN
			-- Check if key exists
		require
			not_empty_key: not a_key.is_empty
			-- Removed: parsed: json_object /= Void
		do
			if attached json_object as obj then
				Result := obj.has_key (a_key)
			end
		end

feature {NONE} -- Implementation

	json_object: detachable SIMPLE_JSON_OBJECT
			-- Parsed JSON object

end
