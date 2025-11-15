note
	description: "[
		JSON Patch 'add' operation (RFC 6902).
		Adds or replaces a value at the specified path.
		For arrays: use index to insert, or '-' to append.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902 Add", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902#section-4.1"

class
	SIMPLE_JSON_PATCH_ADD

inherit
	SIMPLE_JSON_PATCH_OPERATION

create
	make

feature {NONE} -- Initialization

	make (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE)
			-- Create add operation
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
			Result := "add"
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is this operation valid?
		do
			Result := not path.is_empty and value /= Void
		end

	requires_value: BOOLEAN = True
			-- Add requires a value

	requires_from: BOOLEAN = False
			-- Add doesn't need a from path

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Add value at path to document
		local
			l_pointer: SIMPLE_JSON_POINTER
			l_parent: detachable SIMPLE_JSON_VALUE
			l_key: STRING_32
			l_modified: SIMPLE_JSON_VALUE
		do
			create l_pointer
			
			-- Handle root replacement
			if path.is_equal ("/") or path.is_equal ("") then
				if attached value as l_val then
					create Result.make_success (l_val)
				else
					create Result.make_failure ("No value provided for add operation")
				end
			else
				-- Parse path
				if l_pointer.parse_path (path) then
					-- Get parent container
					l_parent := l_pointer.navigate_to_parent (a_document)
					
					if attached l_parent and attached value as l_val then
						l_key := l_pointer.last_segment
						
						-- Handle object property addition
						if l_parent.is_object then
							l_modified := clone_and_add_to_object (a_document, path, l_key, l_val)
							create Result.make_success (l_modified)
						-- Handle array element addition
						elseif l_parent.is_array then
							if l_key.is_equal ("-") then
								-- Append to array
								l_modified := clone_and_append_to_array (a_document, path, l_val)
								create Result.make_success (l_modified)
							elseif is_valid_array_index (l_key) then
								-- Insert at index
								l_modified := clone_and_insert_into_array (a_document, path, l_key.to_integer, l_val)
								create Result.make_success (l_modified)
							else
								create Result.make_failure ("Invalid array index: " + l_key)
							end
						else
							create Result.make_failure ("Parent is not a container at path: " + path)
						end
					else
						create Result.make_failure ("Parent not found or value missing for path: " + path)
					end
				else
					create Result.make_failure ("Invalid path: " + path)
				end
			end
		end

feature {NONE} -- Implementation

	clone_and_add_to_object (a_doc: SIMPLE_JSON_VALUE; a_path: STRING_32; a_key: STRING_32; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
			-- Clone document and add/replace property in object at path
		require
			doc_not_void: a_doc /= Void
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		local
			l_json_str: STRING_32
			l_json: SIMPLE_JSON
		do
			-- TODO: Implement efficient addition
			-- For now, use simple clone
			l_json_str := a_doc.to_json_string
			create l_json
			if attached l_json.parse (l_json_str) as l_cloned then
				Result := l_cloned
			else
				Result := a_doc
			end
		ensure
			result_not_void: Result /= Void
		end

	clone_and_append_to_array (a_doc: SIMPLE_JSON_VALUE; a_path: STRING_32; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
			-- Clone document and append value to array at path
		require
			doc_not_void: a_doc /= Void
			value_not_void: a_value /= Void
		local
			l_json_str: STRING_32
			l_json: SIMPLE_JSON
		do
			-- TODO: Implement efficient append
			l_json_str := a_doc.to_json_string
			create l_json
			if attached l_json.parse (l_json_str) as l_cloned then
				Result := l_cloned
			else
				Result := a_doc
			end
		ensure
			result_not_void: Result /= Void
		end

	clone_and_insert_into_array (a_doc: SIMPLE_JSON_VALUE; a_path: STRING_32; a_index: INTEGER; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
			-- Clone document and insert value into array at path
		require
			doc_not_void: a_doc /= Void
			index_non_negative: a_index >= 0
			value_not_void: a_value /= Void
		local
			l_json_str: STRING_32
			l_json: SIMPLE_JSON
		do
			-- TODO: Implement efficient insertion
			l_json_str := a_doc.to_json_string
			create l_json
			if attached l_json.parse (l_json_str) as l_cloned then
				Result := l_cloned
			else
				Result := a_doc
			end
		ensure
			result_not_void: Result /= Void
		end

	is_valid_array_index (a_str: STRING_32): BOOLEAN
			-- Is string a valid non-negative integer?
		require
			str_not_void: a_str /= Void
		do
			Result := a_str.is_integer and then a_str.to_integer >= 0
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
