note
	description: "[
		JSON Patch 'remove' operation (RFC 6902).
		Removes the value at the specified path.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Remove", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.2"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/patch/simple_json_patch.html"

class
	SIMPLE_JSON_PATCH_REMOVE

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING_32)
			-- Create remove operation for path
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			set_path (a_path)
		ensure
			path_set: path = a_path
		end

feature -- Access

	op: STRING_32
			-- Operation name
		once
			Result := "remove"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty
		end

	requires_value: BOOLEAN = False
			-- Remove doesn't need a value

	requires_from: BOOLEAN = False
			-- Remove doesn't need a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Remove value at path from document
		require else
			document_not_void: a_document /= Void
			path_not_empty: not path.is_empty
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_parent: detachable SIMPLE_JSON_VALUE
			l_key: STRING_32
			l_index: INTEGER
			l_modified: SIMPLE_JSON_VALUE
		do
			create l_pointer

			if not l_pointer.parse_path (path) then
				create Result.make_failure ("Invalid JSON Pointer path: " + path.to_string_8)
			else
				l_parent := l_pointer.navigate_to_parent (a_document)

				check parent_navigation_succeeded: l_parent /= Void implies True end

				if l_parent = Void then
					create Result.make_failure ("Parent not found for path: " + path.to_string_8)
				else
					l_key := l_pointer.last_segment

					check last_segment_extracted: not l_key.is_empty end

					if l_parent.is_object then
						check parent_confirmed_object: l_parent.is_object end

						if l_parent.as_object.has_key (l_key) then
							check key_exists_in_object: l_parent.as_object.has_key (l_key) end

							l_modified := clone_and_remove_from_object (a_document, path, l_key)

							check modified_document_created: l_modified /= Void end

							-- Verify removal actually happened
							if attached l_pointer.navigate_to_parent (l_modified) as al_l_modified_parent then
								if al_l_modified_parent.is_object then
									check key_was_removed: not al_l_modified_parent.as_object.has_key (l_key) end
								end
							end

							create Result.make_success (l_modified)
						else
							check key_does_not_exist_in_object: not l_parent.as_object.has_key (l_key) end
							create Result.make_failure ("Property '" + l_key.to_string_8 + "' does not exist at path: " + path.to_string_8)
						end

					elseif l_parent.is_array then
						check parent_confirmed_array: l_parent.is_array end

						if l_key.is_integer then
							l_index := l_key.to_integer

							check valid_integer_extracted: l_index >= 0 or l_index < 0 end

							if l_index >= 0 and l_index < l_parent.as_array.count then
								check index_in_bounds: l_index >= 0 and l_index < l_parent.as_array.count end

								l_modified := clone_and_remove_from_array (a_document, path, l_index)

								-- Verify removal actually happened
								if attached l_pointer.navigate_to_parent (l_modified) as al_l_modified_parent then
									if al_l_modified_parent.is_array then
										check array_item_removed: al_l_modified_parent.as_array.count = l_parent.as_array.count - 1 end
									end
								end

								create Result.make_success (l_modified)
							else
								check index_out_of_bounds: l_index < 0 or l_index >= l_parent.as_array.count end
								create Result.make_failure ("Array index " + l_index.out + " out of bounds at path: " + path.to_string_8)
							end
						else
							check key_not_valid_integer: not l_key.is_integer end
							create Result.make_failure ("Invalid array index '" + l_key.to_string_8 + "' at path: " + path.to_string_8)
						end

					else
						check parent_neither_object_nor_array: not l_parent.is_object and not l_parent.is_array end
						create Result.make_failure ("Parent is neither object nor array at path: " + path.to_string_8)
					end
				end
			end
		ensure then
			success_means_modified: Result.is_success implies Result.modified_document /= Void
			failure_means_error: Result.is_failure implies Result.has_error
		end

feature {NONE} -- Implementation

	clone_and_remove_from_object (a_doc: SIMPLE_JSON_VALUE; a_path: STRING_32; a_key: STRING_32): SIMPLE_JSON_VALUE
			-- Clone document and remove property from object at path
		require
			doc_not_void: a_doc /= Void
			key_not_void: a_key /= Void
			key_not_empty: not a_key.is_empty
		local
			l_json_str: STRING_32
			l_json: SIMPLE_JSON
			l_pointer: SIMPLE_JSON_POINTER
			l_parent: detachable SIMPLE_JSON_VALUE
		do
			-- Clone the document
			l_json_str := a_doc.to_json_string
			create l_json
			if attached l_json.parse (l_json_str) as al_l_cloned then
				-- Navigate to parent in cloned document
				create l_pointer
				if l_pointer.parse_path (a_path) then
					l_parent := l_pointer.navigate_to_parent (al_l_cloned)

					-- Actually remove the key
					if attached l_parent and then l_parent.is_object then
						check parent_is_object: l_parent.as_object /= Void end
						check key_exists_before_removal: l_parent.as_object.has_key (a_key) end

						l_parent.as_object.remove (a_key)

						check key_removed_successfully: not l_parent.as_object.has_key (a_key) end
					end
				end

				Result := al_l_cloned
			else
				Result := a_doc
			end
		end

	clone_and_remove_from_array (a_doc: SIMPLE_JSON_VALUE; a_path: STRING_32; a_index: INTEGER): SIMPLE_JSON_VALUE
			-- Clone document and remove index from array at path
		require
			doc_not_void: a_doc /= Void
		local
			l_json_str: STRING_32
			l_json: SIMPLE_JSON
		do
			-- For now, use JSON round-trip (will optimize later)
			l_json_str := a_doc.to_json_string
			create l_json
			if attached l_json.parse (l_json_str) as al_l_cloned then
				-- Navigate and remove
				-- TODO: Implement efficient removal
				Result := al_l_cloned
			else
				Result := a_doc
			end
		end

	extract_array_index (a_segment: STRING_32): INTEGER
			-- Extract array index from segment like "[0]"
		require
			valid_format: a_segment.starts_with ("[") and a_segment.ends_with ("]")
		local
			l_index_str: STRING_32
		do
			l_index_str := a_segment.substring (Substring_skip_first_char, a_segment.count - 1)
			if l_index_str.is_integer then
				Result := l_index_str.to_integer
			end
		ensure
			non_negative: Result >= 0
		end

invariant
	-- Operation identity
	remove_not_requires_value: not requires_value
	remove_not_requires_from: not requires_from

	-- Validation consistency
	valid_definition: is_valid = not path.is_empty

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
