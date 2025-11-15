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

	error_messages: ARRAY [STRING_32]
			-- Human-readable error messages
		local
			l_index: INTEGER
		do
			create Result.make_empty
			from
				l_index := errors.lower
			until
				l_index > errors.upper
			loop
				Result.force (errors [l_index].to_string, Result.upper + 1)
				l_index := l_index + 1
			end
		ensure
			result_not_void: Result /= Void
			same_count: Result.count = error_count
		end

invariant
	errors_not_void: errors /= Void
	valid_implies_no_errors: is_valid implies errors.is_empty

end
