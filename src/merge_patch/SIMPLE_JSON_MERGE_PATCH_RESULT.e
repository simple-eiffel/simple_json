note
	description: "[
		Result of a JSON Merge Patch operation.
		
		Encapsulates the outcome of applying a merge patch,
		including success/failure status, the merged document,
		and any error messages.
	]"
	legal: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/merge_patch/simple_json_merge_patch.html"

class
	SIMPLE_JSON_MERGE_PATCH_RESULT

inherit
	ANY

create
	make_success,
	make_failure

feature {NONE} -- Initialization

	make_success (a_merged_document: SIMPLE_JSON_VALUE)
			-- Initialize with successful merge
		require
			merged_document_attached: a_merged_document /= Void
		do
			merged_document := a_merged_document
			error_message := ""
			is_success := True
		ensure
			success: is_success
			document_set: merged_document = a_merged_document
			no_error: error_message.is_empty
		end

	make_failure (a_error_message: STRING)
			-- Initialize with failure
		require
			error_message_attached: a_error_message /= Void
			error_message_not_empty: not a_error_message.is_empty
		local
			l_json: SIMPLE_JSON
		do
			create l_json
			merged_document := l_json.null_value
			error_message := a_error_message
			is_success := False
		ensure
			failure: not is_success
			error_set: error_message ~ a_error_message
		end

feature -- Access

	merged_document: SIMPLE_JSON_VALUE
			-- The merged document (if successful)
			-- Null value if failed

	error_message: STRING
			-- Error message (if failed)
			-- Empty string if successful

feature -- Status report

	is_success: BOOLEAN
			-- Did the merge succeed?

	has_error: BOOLEAN
			-- Was there an error?
		do
			Result := not is_success
		ensure
			definition: Result = not is_success
		end

invariant
	-- Core data integrity
	merged_document_attached: merged_document /= Void
	error_message_attached: error_message /= Void

	-- Success state consistency
	success_implies_no_error: is_success implies error_message.is_empty
	success_excludes_has_error: is_success implies not has_error

	-- Failure state consistency
	failure_implies_error_message: not is_success implies not error_message.is_empty
	failure_has_error: has_error implies not error_message.is_empty

	-- Query definition consistency
	has_error_definition: has_error = not is_success

	-- State exclusivity
	success_and_error_exclusive: is_success = error_message.is_empty

note
	copyright: "2025, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		https://github.com/ljr1981/simple_json
	]"

end
