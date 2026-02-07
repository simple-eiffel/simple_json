note
	description: "[
		Result of JSON Schema validation.
		Contains validity status and any validation errors.
	]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/schema/simple_json_schema_validator.html"

class
	SIMPLE_JSON_SCHEMA_VALIDATION_RESULT

create
	make_valid,
	make_invalid

feature {NONE} -- Initialization

	make_valid
			-- Create successful validation result
		do
			is_valid := True
			create errors.make_empty
		ensure
			is_valid: is_valid
			no_errors: errors.is_empty
		end

	make_invalid (a_errors: ARRAY [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Create failed validation result with `a_errors'
		require
			errors_not_void: a_errors /= Void
			has_errors: not a_errors.is_empty
		do
			is_valid := False
			errors := a_errors
		ensure
			not_valid: not is_valid
			errors_set: errors = a_errors
		end

feature -- Status

	is_valid: BOOLEAN
			-- Did validation succeed?

feature -- Access

	errors: ARRAY [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR]
			-- Validation errors (empty if valid)

	error_count: INTEGER
			-- Number of validation errors
		do
			Result := errors.count
		ensure
			valid_count: Result >= 0
			no_errors_if_valid: is_valid implies Result = 0
		end

feature -- Model Queries

	errors_model: MML_SEQUENCE [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR]
			-- Mathematical model of validation errors in order.
		local
			i: INTEGER
		do
			create Result
			from i := errors.lower until i > errors.upper loop
				Result := Result & errors [i]
				i := i + 1
			end
		ensure
			count_matches: Result.count = error_count
		end

feature -- Conversion

	error_messages: ARRAY [STRING_32]
			-- Human-readable error messages
		local
			l_index: INTEGER
		do
			create Result.make_empty
			from
				l_index := errors.lower
			invariant
				-- Index bounds
				valid_index: l_index >= errors.lower and l_index <= errors.upper + 1

				-- Result array integrity
				result_attached: Result /= Void

				-- Progress tracking - messages built matches elements processed
				messages_built: Result.count = l_index - errors.lower

				-- All messages are non-void and non-empty
				all_messages_valid: across Result as ic_msg all
					ic_msg /= Void and then not ic_msg.is_empty
				end
			until
				l_index > errors.upper
			loop
				Result.force (errors [l_index].to_string, Result.upper + 1)
				l_index := l_index + 1
			end
		ensure
			same_count: Result.count = error_count
		end

invariant
	-- Core data integrity
	errors_not_void: errors /= Void

	-- Validity state consistency
	valid_implies_no_errors: is_valid implies errors.is_empty
	invalid_implies_has_errors: not is_valid implies not errors.is_empty

	-- Error count consistency
	error_count_definition: error_count = errors.count
	count_non_negative: error_count >= 0

	-- Error array quality (no void errors)
	no_void_errors: across errors as ic_err all ic_err /= Void end

	-- Model consistency
	model_count: errors_model.count = error_count

end
