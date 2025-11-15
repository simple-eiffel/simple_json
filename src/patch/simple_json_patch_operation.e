note
	description: "[
		Abstract base class for JSON Patch operations (RFC 6902).
		Each operation modifies a JSON document according to a path.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902"

deferred class
	SIMPLE_JSON_PATCH_OPERATION

feature -- Access

	op: STRING_32
			-- Operation name: "add", "remove", "replace", "move", "copy", "test"
		deferred
		ensure
			result_not_void: Result /= Void
			result_not_empty: not Result.is_empty
		end

	path: STRING_32
			-- JSON Pointer path (RFC 6901) where operation applies
		attribute
			create Result.make_empty
		end

	value: detachable SIMPLE_JSON_VALUE
			-- Value for operations that need it (add, replace, test)

	from_path: detachable STRING_32
			-- Source path for move and copy operations

feature -- Element change

	set_path (a_path: STRING_32)
			-- Set the path where this operation applies
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			path := a_path
		ensure
			path_set: path = a_path
		end

	set_value (a_value: SIMPLE_JSON_VALUE)
			-- Set the value for this operation
		require
			value_not_void: a_value /= Void
		do
			value := a_value
		ensure
			value_set: value = a_value
		end

	set_from_path (a_from: STRING_32)
			-- Set the source path for move/copy operations
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
		do
			from_path := a_from
		ensure
			from_set: from_path = a_from
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid and ready to execute?
		deferred
		end

	requires_value: BOOLEAN
			-- Does this operation require a value?
		deferred
		end

	requires_from: BOOLEAN
			-- Does this operation require a from_path?
		deferred
		end

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Apply this operation to the document
		require
			document_not_void: a_document /= Void
			operation_is_valid: is_valid
		deferred
		ensure
			result_not_void: Result /= Void
		end

feature -- Conversion

	to_json_object: SIMPLE_JSON_OBJECT
			-- Convert this operation to a JSON object for serialization
		local
			l_json: SIMPLE_JSON
		do
			create l_json
			Result := l_json.new_object
				.put_string (op, "op")
				.put_string (path, "path")
			
			if attached value as l_value then
				Result := Result.put_value (l_value, "value")
			end
			
			if attached from_path as l_from then
				Result := Result.put_string (l_from, "from")
			end
		ensure
			result_not_void: Result /= Void
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
