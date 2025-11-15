note
	description: "[
		JSON Patch 'replace' operation (RFC 6902).
		Replaces the value at the specified path.
		The target location MUST exist.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Replace", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.3"

class
	SIMPLE_JSON_PATCH_REPLACE

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE)
			-- Create replace operation
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
			Result := "replace"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty and value /= Void
		end

	requires_value: BOOLEAN = True
			-- Replace requires a value

	requires_from: BOOLEAN = False
			-- Replace doesn't need a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Replace value at path in document
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_existing: detachable SIMPLE_JSON_VALUE
		do
			create l_pointer
			
			if l_pointer.parse_path (path) then
				-- Check that target exists
				l_existing := l_pointer.navigate (a_document)
				
				if attached l_existing and attached value as l_val then
					-- Target exists, perform replacement (same as add)
					-- Delegate to add operation
					if attached {SIMPLE_JSON_PATCH_ADD} create {SIMPLE_JSON_PATCH_ADD}.make (path, l_val) as l_add then
						Result := l_add.apply (a_document)
					else
						create Result.make_failure ("Internal error in replace operation")
					end
				else
					create Result.make_failure ("Target does not exist at path: " + path)
				end
			else
				create Result.make_failure ("Invalid path: " + path)
			end
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
