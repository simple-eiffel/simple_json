note
	description: "[
		Represents a single JSON Schema validation error.
		Contains the JSON Pointer to the location that failed validation
		and a message describing what failed.
	]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/schema/simple_json_schema_validator.html"

class
	SIMPLE_JSON_SCHEMA_VALIDATION_ERROR

create
	make

feature {NONE} -- Initialization

	make (a_path: READABLE_STRING_GENERAL; a_message: READABLE_STRING_GENERAL)
			-- Create error at `a_path' with `a_message'
		require
			path_not_void: a_path /= Void
			message_not_void: a_message /= Void
		do
			create path.make_from_string_general (a_path)
			create message.make_from_string_general (a_message)
		ensure
			path_set: path.same_string_general (a_path)
			message_set: message.same_string_general (a_message)
		end

feature -- Access

	path: STRING_32
			-- JSON Pointer to the location that failed validation

	message: STRING_32
			-- Human-readable error message

	to_string: STRING_32
			-- Formatted error string
		do
			create Result.make (path.count + message.count + 3)
			Result.append (path)
			Result.append_string_general (": ")
			Result.append (message)
		ensure
			result_not_void: Result /= Void
			contains_path: Result.has_substring (path)
			contains_message: Result.has_substring (message)
		end

invariant
	path_not_void: path /= Void
	message_not_void: message /= Void

end
