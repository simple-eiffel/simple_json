note
	description: "[
		JSON Patch document (RFC 6902).
		A sequence of operations to apply to a JSON document.
		Operations are applied atomically - if any fails, none are applied.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC 6902", "protocol=URI", "src=https://tools.ietf.org/html/rfc6902"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/patch/simple_json_patch.html"

class
	SIMPLE_JSON_PATCH

create
	make,
	make_from_array

feature {NONE} -- Initialization

	make
			-- Create empty patch
		do
			create operations.make (0)
		ensure
			empty: operations.is_empty
		end

	make_from_array (a_operations: ARRAY [SIMPLE_JSON_PATCH_OPERATION])
			-- Create patch with operations
		require
			operations_not_void: a_operations /= Void
		do
			create operations.make (a_operations.count)
			across
				a_operations as ic
			loop
				operations.force (ic)
			end
		ensure
			count_set: operations.count = a_operations.count
		end

feature -- Access

	operations: ARRAYED_LIST [SIMPLE_JSON_PATCH_OPERATION]
			-- List of patch operations

	count: INTEGER
			-- Number of operations
		do
			Result := operations.count
		ensure
			definition: Result = operations.count
		end

	is_empty: BOOLEAN
			-- Is patch empty?
		do
			Result := operations.is_empty
		ensure
			definition: Result = operations.is_empty
		end

feature -- Model Queries

	operations_model: MML_SEQUENCE [SIMPLE_JSON_PATCH_OPERATION]
			-- Mathematical model of patch operations in order.
		do
			create Result
			across operations as ic loop
				Result := Result & ic
			end
		ensure
			count_matches: Result.count = operations.count
		end

feature -- Building (Fluent API)

	add (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH
			-- Add an 'add' operation and return Current for chaining
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
			value_not_void: a_value /= Void
		do
			operations.force (create {SIMPLE_JSON_PATCH_ADD}.make (a_path, a_value))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

	remove (a_path: STRING_32): SIMPLE_JSON_PATCH
			-- Add a 'remove' operation and return Current for chaining
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			operations.force (create {SIMPLE_JSON_PATCH_REMOVE}.make (a_path))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

	replace (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH
			-- Add a 'replace' operation and return Current for chaining
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
			value_not_void: a_value /= Void
		do
			operations.force (create {SIMPLE_JSON_PATCH_REPLACE}.make (a_path, a_value))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

	move (a_from: STRING_32; a_to: STRING_32): SIMPLE_JSON_PATCH
			-- Add a 'move' operation and return Current for chaining
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			operations.force (create {SIMPLE_JSON_PATCH_MOVE}.make (a_from, a_to))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

	copy_value (a_from: STRING_32; a_to: STRING_32): SIMPLE_JSON_PATCH
			-- Add a 'copy' operation and return Current for chaining
		require
			from_not_void: a_from /= Void
			from_not_empty: not a_from.is_empty
			to_not_void: a_to /= Void
			to_not_empty: not a_to.is_empty
		do
			operations.force (create {SIMPLE_JSON_PATCH_COPY}.make (a_from, a_to))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

	test (a_path: STRING_32; a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH
			-- Add a 'test' operation and return Current for chaining
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
			value_not_void: a_value /= Void
		do
			operations.force (create {SIMPLE_JSON_PATCH_TEST}.make (a_path, a_value))
			Result := Current
		ensure
			operation_added: operations.count = old operations.count + 1
			returns_current: Result = Current
			prefix_unchanged: operations_model.front (old count) |=| old operations_model
		end

feature -- Operations

	apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
			-- Apply all operations atomically to document
			-- If any operation fails, the entire patch fails
		require
			document_not_void: a_document /= Void
		local
			l_current: SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
			l_op_number: INTEGER
		do
			l_current := a_document
			l_op_number := 1

			across
				operations as ic
			loop
				check operation_not_void: ic /= Void end

				l_result := ic.apply (l_current)

				check operation_result_not_void: l_result /= Void end
				check result_has_status: l_result.is_success or l_result.is_failure end

				if l_result.is_success and attached l_result.modified_document as al_l_doc then
					check success_has_document: l_result.modified_document /= Void end
					-- Continue with modified document
					l_current := al_l_doc
				else
					check operation_failed: l_result.is_failure end
					check failure_has_error: l_result.has_error end
					-- Operation failed - abort patch
					create Result.make_failure (
						"Operation " + l_op_number.out + " (" + ic.op.to_string_8 + ") failed: " + l_result.error_message.to_string_8
					)
					check result_is_failure: Result.is_failure end
				end

				l_op_number := l_op_number + 1
			end

			-- All operations succeeded
			if Result = Void then
				create Result.make_success (l_current)
				check all_succeeded: Result.is_success end
			end
		end

feature -- Conversion

	to_json_array: SIMPLE_JSON_ARRAY
			-- Convert patch to JSON array for serialization
		local
			l_json: SIMPLE_JSON
		do
			create l_json
			Result := l_json.new_array

			across
				operations as ic
			loop
				Result := Result.add_object (ic.to_json_object)
			end
		ensure
			correct_count: Result.count = operations.count
		end

	to_json_string: STRING_32
			-- Convert patch to JSON string
		do
			Result := to_json_array.to_json_string
		end

invariant
	-- Operations list integrity
	operations_attached: operations /= Void

	-- Count consistency
	count_definition: count = operations.count
	is_empty_definition: is_empty = operations.is_empty

	-- Operations quality
	no_void_operations: across operations as ic_op all ic_op /= Void end
	all_operations_valid: across operations as ic_op all ic_op.is_valid end

	-- Model consistency
	model_count: operations_model.count = operations.count

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
