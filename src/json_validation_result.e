note
	description: "Result of JSON schema validation containing success status and errors"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_VALIDATION_RESULT

create
	make_valid,
	make_invalid

feature {NONE} -- Initialization

	make_valid
			-- Create successful validation result
		do
			is_valid := True
			create {ARRAYED_LIST [JSON_VALIDATION_ERROR]} errors.make (0)
		ensure
			valid: is_valid
			no_errors: errors.is_empty
		end

	make_invalid (a_errors: LIST [JSON_VALIDATION_ERROR])
			-- Create failed validation result with `a_errors'
		require
			has_errors: attached a_errors and then not a_errors.is_empty
		do
			is_valid := False
			create {ARRAYED_LIST [JSON_VALIDATION_ERROR]} errors.make (a_errors.count)
			across a_errors as ic_err loop
				errors.extend (ic_err)
			end
		ensure
			invalid: not is_valid
			has_errors: not errors.is_empty
			count_matches: errors.count = a_errors.count
		end

feature -- Status Report

	is_valid: BOOLEAN
			-- Was validation successful?

feature -- Access

	errors: LIST [JSON_VALIDATION_ERROR]
			-- Collection of validation errors (empty if valid)

	error_count: INTEGER
			-- Number of errors
		do
			Result := errors.count
		ensure
			non_negative: Result >= 0
			valid_implies_zero: is_valid implies Result = 0
		end

feature -- Output

	error_message: STRING
			-- Combined error message from all errors
		do
			create Result.make_empty
			if not is_valid then
				across errors as ic_err loop
					if not Result.is_empty then
						Result.append_character ('%N')
					end
					Result.append (ic_err.to_string)
				end
			end
		ensure
			empty_when_valid: is_valid implies Result.is_empty
		end

invariant
	errors_attached: attached errors
	valid_implies_no_errors: is_valid implies errors.is_empty
	invalid_implies_has_errors: not is_valid implies not errors.is_empty

end
