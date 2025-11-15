note
	description: "[
		Result of applying a JSON Patch operation or patch document.
		Contains success status, the modified document (if successful),
		and error information (if failed).
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_PATCH_RESULT

create
	make_success,
	make_failure

feature {NONE} -- Initialization

	make_success (a_document: SIMPLE_JSON_VALUE)
			-- Create successful result with modified document
		require
			document_not_void: a_document /= Void
		do
			is_success := True
			modified_document := a_document
			create error_message.make_empty
		ensure
			success: is_success
			document_set: modified_document = a_document
		end

	make_failure (a_error: STRING_32)
			-- Create failed result with error message
		require
			error_not_void: a_error /= Void
			error_not_empty: not a_error.is_empty
		do
			is_success := False
			error_message := a_error
		ensure
			failure: not is_success
			error_set: error_message = a_error
		end

feature -- Status

	is_success: BOOLEAN
			-- Did the patch operation succeed?

	is_failure: BOOLEAN
			-- Did the patch operation fail?
		do
			Result := not is_success
		ensure
			definition: Result = not is_success
		end

feature -- Access

	modified_document: detachable SIMPLE_JSON_VALUE
			-- The modified document (Void if operation failed)

	error_message: STRING_32
			-- Error message (empty if operation succeeded)
		attribute
			create Result.make_empty
		ensure
			result_not_void: Result /= Void
		end

feature -- Status report

	has_document: BOOLEAN
			-- Is there a modified document available?
		do
			Result := modified_document /= Void
		ensure
			definition: Result = (modified_document /= Void)
		end

	has_error: BOOLEAN
			-- Is there an error message?
		do
			Result := not error_message.is_empty
		ensure
			definition: Result = not error_message.is_empty
		end

invariant
	success_has_document: is_success implies modified_document /= Void
	failure_has_error: is_failure implies has_error

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
