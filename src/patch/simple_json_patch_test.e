note
	description: "[
		JSON Patch 'test' operation (RFC 6902).
		Tests that a value at the target location is equal to a specified value.
		Used for atomic operations and optimistic locking.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Test", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.6"

class
	SIMPLE_JSON_PATCH_TEST

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE)
			-- Create test operation
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
			value_not_void: a_value /= Void
		do
			set_path (a_path)
			set_value (a_value)
		ensure
			path_set: path = a_path
			value_set: value = a_value
		end

feature -- Access

	op: STRING_32
			-- Operation name
		once
			Result := "test"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty and value /= Void
		end

	requires_value: BOOLEAN = True
			-- Test requires a value to compare

	requires_from: BOOLEAN = False
			-- Test doesn't need a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Test that value at path equals the specified value
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_existing: detachable SIMPLE_JSON_VALUE
			l_match: BOOLEAN
		do
			create l_pointer
			
			if l_pointer.parse_path (path) and attached value as l_val then
				-- Navigate to target
				l_existing := l_pointer.navigate (a_document)
				
				if attached l_existing then
					-- Compare values
					l_match := values_equal (l_existing, l_val)
					
					if l_match then
						-- Test passed - return unchanged document
						create Result.make_success (a_document)
					else
						create Result.make_failure ("Test failed: value at '" + path + "' does not match expected value")
					end
				else
					create Result.make_failure ("Test failed: no value found at path: " + path)
				end
			else
				create Result.make_failure ("Invalid path or value for test operation")
			end
		end

feature {NONE} -- Implementation

	values_equal (a_val1, a_val2: SIMPLE_JSON_VALUE): BOOLEAN
			-- Are two JSON values equal?
		require
			val1_not_void: a_val1 /= Void
			val2_not_void: a_val2 /= Void
		do
			-- Compare JSON string representations
			-- This handles all types uniformly
			Result := a_val1.to_json_string.is_equal (a_val2.to_json_string)
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
