note
	description: "[
		JSON Patch 'move' operation (RFC 6902).
		Removes the value at 'from' location and adds it to the target location.
		Equivalent to: remove from source + add to destination.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Move", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.4"

class
	SIMPLE_JSON_PATCH_MOVE

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_from: STRING_32; a_to: STRING_32)
			-- Create move operation
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
			Result := "move"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty and attached from_path as l_from and then not l_from.is_empty
		end

	requires_value: BOOLEAN = False
			-- Move doesn't need an explicit value (gets it from source)

	requires_from: BOOLEAN = True
			-- Move requires a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Move value from 'from' path to 'path'
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_source_value: detachable SIMPLE_JSON_VALUE
			l_remove_result: SIMPLE_JSON_PATCH_RESULT
			l_add_result: SIMPLE_JSON_PATCH_RESULT
		do
			if attached from_path as l_from then
				-- First, get the value at source location
				create l_pointer
				if l_pointer.parse_path (l_from) then
					l_source_value := l_pointer.navigate (a_document)
					
					if attached l_source_value as l_val then
						-- Remove from source
						if attached {SIMPLE_JSON_PATCH_REMOVE} create {SIMPLE_JSON_PATCH_REMOVE}.make (l_from) as l_remove then
							l_remove_result := l_remove.apply (a_document)
							
							if l_remove_result.is_success and attached l_remove_result.modified_document as l_doc_after_remove then
								-- Add to destination
								if attached {SIMPLE_JSON_PATCH_ADD} create {SIMPLE_JSON_PATCH_ADD}.make (path, l_val) as l_add then
									l_add_result := l_add.apply (l_doc_after_remove)
									Result := l_add_result
								else
									create Result.make_failure ("Internal error creating add operation")
								end
							else
								Result := l_remove_result  -- Propagate remove failure
							end
						else
							create Result.make_failure ("Internal error creating remove operation")
						end
					else
						create Result.make_failure ("Source value not found at path: " + l_from)
					end
				else
					create Result.make_failure ("Invalid from path: " + l_from)
				end
			else
				create Result.make_failure ("No from path specified for move operation")
			end
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
