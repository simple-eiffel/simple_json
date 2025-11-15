note
	description: "[
		JSON Patch 'copy' operation (RFC 6902).
		Copies the value at 'from' location to the target location.
		Source value remains unchanged.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Copy", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.5"

class
	SIMPLE_JSON_PATCH_COPY

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_from: STRING_32; a_to: STRING_32)
			-- Create copy operation
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			set_from_path (a_from)
			set_path (a_to)
		ensure
			from_set: from_path = a_from
			path_set: path = a_to
		end

feature -- Access

	op: STRING_32
			-- Operation name
		once
			Result := "copy"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty and attached from_path as l_from and then not l_from.is_empty
		end

	requires_value: BOOLEAN = False
			-- Copy doesn't need an explicit value (gets it from source)

	requires_from: BOOLEAN = True
			-- Copy requires a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Copy value from 'from' path to 'path'
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_source_value: detachable SIMPLE_JSON_VALUE
		do
			if attached from_path as l_from then
				-- Get the value at source location
				create l_pointer
				if l_pointer.parse_path (l_from) then
					l_source_value := l_pointer.navigate (a_document)
					
					if attached l_source_value as l_val then
						-- Add to destination (source remains unchanged)
						if attached {SIMPLE_JSON_PATCH_ADD} create {SIMPLE_JSON_PATCH_ADD}.make (path, l_val) as l_add then
							Result := l_add.apply (a_document)
						else
							create Result.make_failure ("Internal error creating add operation")
						end
					else
						create Result.make_failure ("Source value not found at path: " + l_from)
					end
				else
					create Result.make_failure ("Invalid from path: " + l_from)
				end
			else
				create Result.make_failure ("No from path specified for copy operation")
			end
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
