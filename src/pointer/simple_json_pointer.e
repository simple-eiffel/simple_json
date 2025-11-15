note
	description: "[
		JSON Pointer (RFC 6901) - simpler than JSONPath.
		Format: /path/to/element or /array/0
		Used by JSON Patch operations to specify locations.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6901", "protocol=URI", "src=https://tools.ietf.org/html/rfc6901"

class
	SIMPLE_JSON_POINTER

feature -- Access

	segments: ARRAYED_LIST [STRING_32]
			-- Path segments
		attribute
			create Result.make (0)
		end

	last_segment: STRING_32
			-- Last segment of the path (property name or array index)
		require
			has_segments: not segments.is_empty
		do
			Result := segments.last
		ensure
			result_not_void: Result /= Void
		end

feature -- Parsing

	parse_path (a_path: STRING_32): BOOLEAN
			-- Parse JSON Pointer path into segments
			-- Supports: /key, /key/nested, /array/0
		require
			path_not_void: a_path /= Void
		local
			l_path: STRING_32
			l_parts: LIST [STRING_32]
			i: INTEGER
		do
			segments.wipe_out
			Result := True
			
			if a_path.is_empty then
				Result := False
			elseif a_path.is_equal ("/") then
				-- Root path - empty segments
				Result := True
			else
				l_path := a_path.twin
				
				-- Remove leading slash if present
				if l_path.starts_with ("/") then
					l_path := l_path.substring (2, l_path.count)
				end
				
				-- Split by slash
				l_parts := l_path.split ('/')
				
				across
					l_parts as ic
				loop
					if not ic.is_empty then
						-- Unescape special characters
						segments.force (unescape_pointer_token (ic))
					end
				end
				
				Result := True
			end
		ensure
			success_has_segments: Result implies (not a_path.is_equal ("/") implies not segments.is_empty)
		end

feature -- Navigation

	navigate (a_document: SIMPLE_JSON_VALUE): detachable SIMPLE_JSON_VALUE
			-- Navigate to the value at this path
		require
			document_not_void: a_document /= Void
		local
			l_current: detachable SIMPLE_JSON_VALUE
			l_index: INTEGER
		do
			l_current := a_document
			
			across
				segments as ic
			until
				l_current = Void
			loop
				if l_current.is_object then
					-- Object property access
					l_current := l_current.as_object.item (ic)
				elseif l_current.is_array then
					-- Array index access
					if is_array_index (ic) then
						l_index := ic.to_integer
						if l_current.as_array.valid_index (l_index + 1) then  -- 0-based to 1-based
							l_current := l_current.as_array.item (l_index + 1)
						else
							l_current := Void
						end
					else
						l_current := Void
					end
				else
					l_current := Void
				end
			end
			
			Result := l_current
		end

	navigate_to_parent (a_document: SIMPLE_JSON_VALUE): detachable SIMPLE_JSON_VALUE
			-- Navigate to the parent container of the target
		require
			document_not_void: a_document /= Void
			has_parent: segments.count > 0
		local
			l_parent_segments: ARRAYED_LIST [STRING_32]
			l_current: detachable SIMPLE_JSON_VALUE
			l_index: INTEGER
		do
			if segments.count = 1 then
				-- Parent is the document itself
				Result := a_document
			else
				-- Navigate to parent
				create l_parent_segments.make (segments.count - 1)
				from
					l_index := 1
				until
					l_index >= segments.count
				loop
					l_parent_segments.force (segments [l_index])
					l_index := l_index + 1
				end
				
				-- Navigate using parent segments
				l_current := a_document
				across
					l_parent_segments as ic
				until
					l_current = Void
				loop
					if l_current.is_object then
						l_current := l_current.as_object.item (ic)
					elseif l_current.is_array then
						if is_array_index (ic) then
							l_index := ic.to_integer
							if l_current.as_array.valid_index (l_index + 1) then
								l_current := l_current.as_array.item (l_index + 1)
							else
								l_current := Void
							end
						else
							l_current := Void
						end
					else
						l_current := Void
					end
				end
				
				Result := l_current
			end
		end

feature {NONE} -- Implementation

	unescape_pointer_token (a_token: STRING_32): STRING_32
			-- Unescape JSON Pointer special characters
			-- ~1 becomes /, ~0 becomes ~
		require
			token_not_void: a_token /= Void
		do
			Result := a_token.twin
			Result.replace_substring_all ("~1", "/")
			Result.replace_substring_all ("~0", "~")
		ensure
			result_not_void: Result /= Void
		end

	is_array_index (a_segment: STRING_32): BOOLEAN
			-- Is segment a valid array index (non-negative integer)?
		require
			segment_not_void: a_segment /= Void
		do
			Result := a_segment.is_integer and then a_segment.to_integer >= 0
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
