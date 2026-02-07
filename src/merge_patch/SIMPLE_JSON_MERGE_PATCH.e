note
	description: "[
		JSON Merge Patch implementation (RFC 7386).
		
		Provides simple merge semantics for JSON documents where
		patch is a JSON document describing changes to make.
		
		Unlike JSON Patch (RFC 6902), Merge Patch:
		- Uses JSON itself as the patch format
		- Has simpler merge semantics
		- Is easier for humans to create
		- Cannot test values or move/copy
	]"
	legal: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=JSON Merge Patch RFC 7386",
		 "src=https://tools.ietf.org/html/rfc7386",
		 "tag=specification, merge-patch"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/merge_patch/simple_json_merge_patch.html"

class
	SIMPLE_JSON_MERGE_PATCH

inherit
	ANY

create
	make,
	make_from_json,
	make_from_string

feature {NONE} -- Initialization

	make
			-- Initialize with empty patch (no-op)
		local
			l_json: SIMPLE_JSON
		do
			create l_json
			patch_document := l_json.new_object
			create validation_errors.make (0)
		ensure
			patch_is_empty_object: patch_document.is_object and then
				patch_document.as_object.is_empty
			no_errors: not has_errors
		end

	make_from_json (a_patch: SIMPLE_JSON_VALUE)
			-- Initialize with JSON patch document
		require
			patch_attached: a_patch /= Void
		do
			patch_document := a_patch
			create validation_errors.make (0)
			validate_patch
		ensure
			patch_set: patch_document = a_patch
		end

	make_from_string (a_json_string: STRING)
			-- Initialize from JSON string
		require
			json_string_attached: a_json_string /= Void
			json_string_not_empty: not a_json_string.is_empty
		local
			l_json: SIMPLE_JSON
			l_parsed: detachable SIMPLE_JSON_VALUE
		do
			create validation_errors.make (0)
			create l_json
			l_parsed := l_json.parse (a_json_string)

			if l_parsed = Void then
				patch_document := l_json.new_object
				validation_errors.force ("Failed to parse JSON patch string")
			else
				patch_document := l_parsed
				validate_patch
			end
		ensure
			has_patch: patch_document /= Void
		end

feature -- Access

	patch_document: SIMPLE_JSON_VALUE
			-- The merge patch document

	validation_errors: ARRAYED_LIST [STRING]
			-- Any validation errors encountered

feature -- Status report

	is_valid: BOOLEAN
			-- Is the patch valid?
		do
			Result := not has_errors
		ensure
			definition: Result = not has_errors
		end

	has_errors: BOOLEAN
			-- Were there validation errors?
		do
			Result := not validation_errors.is_empty
		ensure
			definition: Result = not validation_errors.is_empty
		end

feature -- Model Queries

	validation_errors_model: MML_SEQUENCE [STRING]
			-- Mathematical model of validation errors in order.
		do
			create Result
			across validation_errors as ic loop
				Result := Result & ic
			end
		ensure
			count_matches: Result.count = validation_errors.count
		end

feature -- Operations

	apply (a_target: SIMPLE_JSON_VALUE): SIMPLE_JSON_MERGE_PATCH_RESULT
			-- Apply this merge patch to target document
		require
			target_attached: a_target /= Void
			patch_valid: is_valid
		local
			l_merged: SIMPLE_JSON_VALUE
		do
			l_merged := merge_value (a_target, patch_document)
			create Result.make_success (l_merged)
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	validate_patch
			-- Validate the patch document
		do
			validation_errors.wipe_out
		end

	merge_value (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
			-- Merge patch into target according to RFC 7386 top-level rules
			-- QUERY: Creates new merged value without modifying parameters
		require
			target_attached: a_target /= Void
			patch_attached: a_patch /= Void
		local
			l_result_obj: SIMPLE_JSON_OBJECT
		do
			-- RFC 7386: If both are objects, merge recursively
			if a_patch.is_object and then a_target.is_object then
				Result := merge_objects (a_target, a_patch)
			else
				-- RFC 7386: Otherwise, patch replaces target entirely
				if a_patch.is_object then
					-- CRITICAL: Even when replacing, must remove null values
					l_result_obj := remove_null_values_from_object (a_patch.as_object)
					create Result.make (l_result_obj.json_value)
				else
					-- Primitive values replace target as-is
					Result := a_patch
				end
			end
		ensure
			result_attached: Result /= Void
			original_target_unchanged: a_target ~ old a_target
			original_patch_unchanged: a_patch ~ old a_patch
		end

	merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
			-- Merge two JSON objects according to RFC 7386 object merge rules
		require
			target_is_object: a_target.is_object
			patch_is_object: a_patch.is_object
		local
			l_working_copy: SIMPLE_JSON_OBJECT
		do
			-- Create working copy (new local object, not modifying a_target)
			l_working_copy := deep_copy_target_object (a_target.as_object)

			-- Apply all patch values to working copy
			l_working_copy := apply_patches_to_object (l_working_copy, a_patch.as_object)

			-- Wrap result in SIMPLE_JSON_VALUE
			create Result.make (l_working_copy.json_value)
		ensure
			result_is_object: Result.is_object
		end

	deep_copy_target_object (a_target_obj: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
			-- Create and return deep copy of target object
		require
			target_attached: a_target_obj /= Void
		local
			l_keys: ARRAY [STRING_32]
		do
			-- Create NEW local object (not modifying a_target_obj)
			create Result.make
			l_keys := a_target_obj.keys

			-- Build up our new object with deep copied values
			across l_keys as ic loop
				if attached a_target_obj.item (ic) as al_value then
					if al_value.is_object then
						Result.put_object (deep_copy_object (al_value.as_object), ic).do_nothing
					elseif al_value.is_array then
						Result.put_array (deep_copy_array (al_value.as_array), ic).do_nothing
					else
						Result.put_value (al_value, ic).do_nothing
					end
				end
			end
		ensure
			result_attached: Result /= Void
		end

	apply_patches_to_object (a_working_copy: SIMPLE_JSON_OBJECT; a_patch_obj: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
			-- Apply all patches to working copy and return it
			-- Note: Modifies a_working_copy, which must be a local working copy, not an external object
		require
			working_copy_attached: a_working_copy /= Void
			patch_attached: a_patch_obj /= Void
		local
			l_keys: ARRAY [STRING_32]
		do
			Result := a_working_copy
			l_keys := a_patch_obj.keys

			-- Apply each patch value to our working copy
			across l_keys as ic loop
				if attached a_patch_obj.item (ic) as al_patch_value then
					Result := apply_single_patch_to_object (Result, ic, al_patch_value)
				end
			end
		ensure
			result_attached: Result /= Void
		end

	apply_single_patch_to_object (a_working_copy: SIMPLE_JSON_OBJECT; a_key: STRING_32; a_patch_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_OBJECT
			-- Apply single patch value to working copy according to RFC 7386 and return it
			-- Note: Modifies a_working_copy, which must be a local working copy, not an external object
		require
			working_copy_attached: a_working_copy /= Void
			key_attached: a_key /= Void
			patch_value_attached: a_patch_value /= Void
		local
			l_target_value: detachable SIMPLE_JSON_VALUE
			l_merged_value: SIMPLE_JSON_VALUE
		do
			Result := a_working_copy

			-- RFC 7386: null means delete the key
			if a_patch_value.is_null then
				Result.remove (a_key)
			else
				-- Get existing value if present
				l_target_value := Result.item (a_key)

				-- If both are objects, recursively merge
				if l_target_value /= Void and then
				   l_target_value.is_object and then
				   a_patch_value.is_object then
					l_merged_value := merge_objects (l_target_value, a_patch_value)
					Result.put_value (l_merged_value, a_key).do_nothing
				else
					-- Otherwise, patch value replaces target value
					if a_patch_value.is_object then
						-- When replacing with object, must remove nulls
						Result.put_object (
							remove_null_values_from_object (a_patch_value.as_object),
							a_key
						).do_nothing
					else
						-- Primitives and arrays replace as-is
						Result.put_value (a_patch_value, a_key).do_nothing
					end
				end
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation: Null handling

	result_object_has_null_values (a_obj: SIMPLE_JSON_OBJECT): BOOLEAN
			-- Does object contain any null values?
		require
			object_attached: a_obj /= Void
		local
			l_keys: ARRAY [STRING_32]
			l_value: detachable SIMPLE_JSON_VALUE
		do
			Result := False
			l_keys := a_obj.keys
			across l_keys as ic until Result loop
				l_value := a_obj.item (ic)
				if attached l_value as al_value then
					Result := al_value.is_null
				end
			end
		ensure
			definition: Result = across a_obj.keys as ic some
				attached a_obj.item (ic) as al_val and then al_val.is_null
			end
		end

	remove_null_values_from_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
			-- Create new object with all null values removed
			-- QUERY: Builds new object, does not modify parameter
		require
			object_attached: a_object /= Void
		local
			l_result: SIMPLE_JSON_OBJECT
			l_keys: ARRAY [STRING_32]
			l_value: detachable SIMPLE_JSON_VALUE
		do
			create l_result.make
			l_keys := a_object.keys

			across l_keys as ic loop
				l_value := a_object.item (ic)

				check value_attached: attached l_value as al_value then
					-- Only add non-null values
					if not al_value.is_null then
						if al_value.is_object then
							-- Recursively remove nulls from nested objects
							l_result.put_object (
								remove_null_values_from_object (al_value.as_object),
								ic
							).do_nothing
						elseif al_value.is_array then
							-- Arrays are kept as-is (nulls in arrays are preserved per RFC 7386)
							l_result.put_array (al_value.as_array, ic).do_nothing
						else
							-- Primitive values
							l_result.put_value (al_value, ic).do_nothing
						end
					end
					-- Skip null values entirely - they are omitted from result
				end
			end

			Result := l_result
		ensure
			result_attached: Result /= Void
			original_unchanged: a_object ~ old a_object
			no_nulls: not result_object_has_null_values (Result)
		end

feature {NONE} -- Implementation: Deep copy

	deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
			-- Create deep copy of object
		require
			object_attached: a_object /= Void
		local
			l_json: SIMPLE_JSON
			l_keys: ARRAY [STRING_32]
			l_value: detachable SIMPLE_JSON_VALUE
		do
			create l_json
			create Result.make
			l_keys := a_object.keys

			across l_keys as ic loop
				l_value := a_object.item (ic)

				check l_value_attached: attached l_value as al_value then
					if al_value.is_object then
						Result.put_value (deep_copy_object (al_value.as_object), ic).do_nothing
					elseif al_value.is_array then
						Result.put_value (deep_copy_array (al_value.as_array), ic).do_nothing
					else
						Result.put_value (al_value, ic).do_nothing
					end
				end

			end
		ensure
			result_attached: Result /= Void
		end

	deep_copy_array (a_array: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY
			-- Create deep copy of array
		require
			array_attached: a_array /= Void
		local
			l_json: SIMPLE_JSON
			l_value: detachable SIMPLE_JSON_VALUE
		do
			create l_json
			create Result.make

			across 1 |..| a_array.count as ic loop
				l_value := a_array.item (ic)

				check l_value_attached: attached l_value as al_value then
					if al_value.is_object then
						Result.add_object (deep_copy_object (al_value.as_object)).do_nothing
					elseif al_value.is_array then
						Result.add_array (deep_copy_array (al_value.as_array)).do_nothing
					else
						Result.add_value (al_value).do_nothing
					end
				end
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	-- Core data integrity
	patch_document_attached: patch_document /= Void
	validation_errors_attached: validation_errors /= Void

	-- Error state consistency
	is_valid_definition: is_valid = not has_errors
	has_errors_definition: has_errors = not validation_errors.is_empty

	-- Error list quality
	no_void_error_messages: across validation_errors as ic_err all ic_err /= Void end

	-- Model consistency
	model_count: validation_errors_model.count = validation_errors.count

note
	copyright: "2025, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		https://github.com/ljr1981/simple_json
	]"

end
