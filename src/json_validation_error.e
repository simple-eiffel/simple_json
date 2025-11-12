note
	description: "Represents a JSON schema validation error with path and message"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_VALIDATION_ERROR

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING; a_message: STRING; a_keyword: detachable STRING)
			-- Create validation error with `a_path', `a_message', and optional `a_keyword'
		require
			valid_path: attached a_path
			valid_message: attached a_message and then not a_message.is_empty
		do
			path := a_path
			message := a_message
			keyword := a_keyword
		ensure
			path_set: path = a_path
			message_set: message = a_message
			keyword_set: keyword = a_keyword
		end

feature -- Access

	path: STRING
			-- JSON path where error occurred (e.g., "/properties/name")

	message: STRING
			-- Human-readable error message

	keyword: detachable STRING
			-- Schema keyword that failed (e.g., "type", "minLength", "required")

feature -- Conversion

	to_string: STRING
			-- Format error as string
		do
			create Result.make_empty
			Result.append ("Path: ")
			Result.append (path)
			if attached keyword as al_keyword then
				Result.append (" (")
				Result.append (al_keyword)
				Result.append (")")
			end
			Result.append (" - ")
			Result.append (message)
		ensure
			has_result: not Result.is_empty
		end

invariant
	valid_path: attached path
	valid_message: attached message and then not message.is_empty

end
