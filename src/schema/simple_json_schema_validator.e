note
	description: "[
		JSON Schema validator (Draft 2020-12 subset).
		Validates JSON instances against JSON Schema definitions.
		
		Supported keywords:
		- type (string, number, integer, object, array, boolean, null)
		- properties, required (for objects)
		- minimum, maximum (for numbers)
		- minLength, maxLength, pattern (for strings)
		- minItems, maxItems, items (for arrays)
	]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/schema/simple_json_schema_validator.html"

class
	SIMPLE_JSON_SCHEMA_VALIDATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Create validator
		do
			-- Nothing to initialize
		end

feature -- Validation

	validate (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA): SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
			-- Validate `a_instance' against `a_schema'
		require
			instance_not_void: a_instance /= Void
			schema_not_void: a_schema /= Void
		local
			l_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR]
			l_array: ARRAY [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR]
			l_schema_type: detachable STRING_32
		do
			create l_errors.make (10)

			validate_type (a_instance, a_schema, "", l_errors)

			-- Determine schema's expected type
			if a_schema.has_type then
				l_schema_type := a_schema.type_value
			end

			-- Only validate type-specific constraints if types match or no type specified
			if a_instance.is_string then
				if l_schema_type = Void or else l_schema_type.same_string_general ("string") then
					validate_string (a_instance, a_schema, "", l_errors)
				end
			elseif a_instance.is_number then
				if l_schema_type = Void or else l_schema_type.same_string_general ("number") or else l_schema_type.same_string_general ("integer") then
					validate_number (a_instance, a_schema, "", l_errors)
				end
			elseif a_instance.is_object then
				if l_schema_type = Void or else l_schema_type.same_string_general ("object") then
					validate_object (a_instance, a_schema, "", l_errors)
				end
			elseif a_instance.is_array then
				if l_schema_type = Void or else l_schema_type.same_string_general ("array") then
					validate_array (a_instance, a_schema, "", l_errors)
				end
			end

			if l_errors.is_empty then
				create Result.make_valid
			else
				create l_array.make_filled (l_errors.first, 1, l_errors.count)
				across
					1 |..| l_errors.count as ic
				loop
					l_array [ic.item] := l_errors [ic.item]
				end
				create Result.make_invalid (l_array)
			end
		ensure
			result_not_void: Result /= Void
		end


feature {NONE} -- Type validation

	validate_type (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate instance type
		require
			instance_not_void: a_instance /= Void
			schema_not_void: a_schema /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_type: detachable STRING_32
			l_expected: STRING_32
			l_actual: STRING_32
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
		do
			if a_schema.has_type then
				l_type := a_schema.type_value
				if attached l_type as al_type then
					l_expected := al_type
					l_actual := get_instance_type (a_instance)

					if not types_match (al_type, a_instance) then
						create l_msg.make (50)
						l_msg.append_string_general ("Type mismatch: expected '")
						l_msg.append (l_expected)
						l_msg.append_string_general ("' but got '")
						l_msg.append (l_actual)
						l_msg.append_character ('%'')

						create l_error.make (a_path, l_msg)
						a_errors.extend (l_error)
					end
				end
			end
		end

	types_match (a_type: STRING_32; a_instance: SIMPLE_JSON_VALUE): BOOLEAN
			-- Does instance match the expected type?
		require
			type_not_void: a_type /= Void
			instance_not_void: a_instance /= Void
		do
			if a_type.same_string_general ("string") then
				Result := a_instance.is_string
			elseif a_type.same_string_general ("number") then
				Result := a_instance.is_number
			elseif a_type.same_string_general ("integer") then
				Result := a_instance.is_integer
			elseif a_type.same_string_general ("object") then
				Result := a_instance.is_object
			elseif a_type.same_string_general ("array") then
				Result := a_instance.is_array
			elseif a_type.same_string_general ("boolean") then
				Result := a_instance.is_boolean
			elseif a_type.same_string_general ("null") then
				Result := a_instance.is_null
			end
		end

	get_instance_type (a_instance: SIMPLE_JSON_VALUE): STRING_32
			-- Get type name of instance
		require
			instance_not_void: a_instance /= Void
		do
			if a_instance.is_string then
				Result := "string"
			elseif a_instance.is_integer then
				Result := "integer"
			elseif a_instance.is_number then
				Result := "number"
			elseif a_instance.is_boolean then
				Result := "boolean"
			elseif a_instance.is_null then
				Result := "null"
			elseif a_instance.is_object then
				Result := "object"
			elseif a_instance.is_array then
				Result := "array"
			else
				Result := "unknown"
			end
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- String validation

	validate_string (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate string instance
		require
			instance_not_void: a_instance /= Void
			instance_is_string: a_instance.is_string
			schema_not_void: a_schema /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_string: STRING_32
			l_length: INTEGER
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
		do
			l_string := a_instance.as_string_32
			l_length := l_string.count

			-- minLength
			if a_schema.has_min_length then
				if l_length < a_schema.min_length then
					create l_msg.make (50)
					l_msg.append_string_general ("String too short: length ")
					l_msg.append_integer (l_length)
					l_msg.append_string_general (" < minLength ")
					l_msg.append_integer (a_schema.min_length)

					create l_error.make (a_path, l_msg)
					a_errors.extend (l_error)
				end
			end

			-- maxLength
			if a_schema.has_max_length then
				if l_length > a_schema.max_length then
					create l_msg.make (50)
					l_msg.append_string_general ("String too long: length ")
					l_msg.append_integer (l_length)
					l_msg.append_string_general (" > maxLength ")
					l_msg.append_integer (a_schema.max_length)

					create l_error.make (a_path, l_msg)
					a_errors.extend (l_error)
				end
			end

			-- pattern (using RX_PCRE_REGULAR_EXPRESSION)
			if a_schema.has_pattern then
				if attached a_schema.pattern as l_pattern then
					validate_pattern (l_string, l_pattern, a_path, a_errors)
				end
			end
		end

	validate_pattern (a_string: STRING_32; a_pattern: STRING_32; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate string against regex pattern using Gobo regexp library
		require
			string_not_void: a_string /= Void
			pattern_not_void: a_pattern /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_regex: RX_PCRE_REGULAR_EXPRESSION
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
		do
			create l_regex.make
			l_regex.compile (a_pattern)

			if l_regex.is_compiled then
				if not l_regex.matches (a_string) then
					create l_msg.make (50)
					l_msg.append_string_general ("String does not match pattern: ")
					l_msg.append (a_pattern)

					create l_error.make (a_path, l_msg)
					a_errors.extend (l_error)
				end
			else
				-- Invalid regex pattern in schema
				create l_msg.make (50)
				l_msg.append_string_general ("Invalid regex pattern in schema: ")
				l_msg.append (a_pattern)

				create l_error.make (a_path, l_msg)
				a_errors.extend (l_error)
			end
		end

feature {NONE} -- Number validation

	validate_number (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate number instance
		require
			instance_not_void: a_instance /= Void
			instance_is_number: a_instance.is_number
			schema_not_void: a_schema /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_value: DOUBLE
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
		do
			-- Get numeric value as DOUBLE
			-- NOTE: Must handle integers separately because JSON_NUMBER.real_64_item
			-- has precondition that requires is_real (not is_integer)
			if a_instance.is_integer then
				l_value := a_instance.as_integer.to_double
			else
				l_value := a_instance.as_real
			end

			-- minimum
			if a_schema.has_minimum then
				if l_value < a_schema.minimum then
					create l_msg.make (50)
					l_msg.append_string_general ("Number too small: ")
					l_msg.append_double (l_value)
					l_msg.append_string_general (" < minimum ")
					l_msg.append_double (a_schema.minimum)

					create l_error.make (a_path, l_msg)
					a_errors.extend (l_error)
				end
			end

			-- maximum
			if a_schema.has_maximum then
				if l_value > a_schema.maximum then
					create l_msg.make (50)
					l_msg.append_string_general ("Number too large: ")
					l_msg.append_double (l_value)
					l_msg.append_string_general (" > maximum ")
					l_msg.append_double (a_schema.maximum)

					create l_error.make (a_path, l_msg)
					a_errors.extend (l_error)
				end
			end
		end

feature {NONE} -- Object validation

		validate_object (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate object instance
		require
			instance_not_void: a_instance /= Void
			instance_is_object: a_instance.is_object
			schema_not_void: a_schema /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_object: SIMPLE_JSON_OBJECT
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
			l_prop_name: STRING_32
			l_nested_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			if attached {JSON_OBJECT} a_instance.json_value as l_json_obj then
				create l_object.make_with_json_object (l_json_obj)

				-- required properties
				if a_schema.has_required then
					if attached a_schema.required as l_required then
						across
							1 |..| l_required.count as ic
						loop
							if attached l_required.string_item (ic.item) as l_req_prop then
								if not l_object.has_key (l_req_prop) then
									create l_msg.make (50)
									l_msg.append_string_general ("Required property missing: ")
									l_msg.append (l_req_prop)

									create l_error.make (a_path, l_msg)
									a_errors.extend (l_error)
								end
							end
						end
					end
				end

				-- properties validation (recursive)
				if a_schema.has_properties then
					if attached a_schema.properties as l_props then
						across
							l_object.keys as ic_key
						loop
							l_prop_name := ic_key
							if attached l_props.item (l_prop_name) as l_prop_schema_value then
								if l_prop_schema_value.is_object then
									if attached {JSON_OBJECT} l_prop_schema_value.json_value as l_prop_schema_obj then
										if attached l_object.item (l_prop_name) as l_prop_value then
											-- Create nested schema and validate recursively
											l_nested_result := validate (l_prop_value, create {SIMPLE_JSON_SCHEMA}.make (create {SIMPLE_JSON_OBJECT}.make_with_json_object (l_prop_schema_obj)))
											-- Collect errors from nested validation
											if not l_nested_result.is_valid then
												across
													l_nested_result.errors as ic_err
												loop
													create l_error.make (build_path (a_path, l_prop_name), ic_err.message)
													a_errors.extend (l_error)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end

feature {NONE} -- Array validation

	validate_array (a_instance: SIMPLE_JSON_VALUE; a_schema: SIMPLE_JSON_SCHEMA; a_path: READABLE_STRING_GENERAL; a_errors: ARRAYED_LIST [SIMPLE_JSON_SCHEMA_VALIDATION_ERROR])
			-- Validate array instance
		require
			instance_not_void: a_instance /= Void
			instance_is_array: a_instance.is_array
			schema_not_void: a_schema /= Void
			path_not_void: a_path /= Void
			errors_not_void: a_errors /= Void
		local
			l_array: SIMPLE_JSON_ARRAY
			l_count: INTEGER
			l_msg: STRING_32
			l_error: SIMPLE_JSON_SCHEMA_VALIDATION_ERROR
			l_item_path: STRING_32
			l_nested_result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
		do
			if attached {JSON_ARRAY} a_instance.json_value as l_json_arr then
				create l_array.make_with_json_array (l_json_arr)
				l_count := l_array.count

				-- minItems
				if a_schema.has_min_items then
					if l_count < a_schema.min_items then
						create l_msg.make (50)
						l_msg.append_string_general ("Array too short: length ")
						l_msg.append_integer (l_count)
						l_msg.append_string_general (" < minItems ")
						l_msg.append_integer (a_schema.min_items)

						create l_error.make (a_path, l_msg)
						a_errors.extend (l_error)
					end
				end

				-- maxItems
				if a_schema.has_max_items then
					if l_count > a_schema.max_items then
						create l_msg.make (50)
						l_msg.append_string_general ("Array too long: length ")
						l_msg.append_integer (l_count)
						l_msg.append_string_general (" > maxItems ")
						l_msg.append_integer (a_schema.max_items)

						create l_error.make (a_path, l_msg)
						a_errors.extend (l_error)
					end
				end

				-- items validation (recursive)
				if a_schema.has_items then
					if attached a_schema.items_schema as l_item_schema then
						across
							1 |..| l_count as ic
						loop
							create l_item_path.make (20)
							l_item_path.append_string_general (a_path)
							l_item_path.append_character ('/')
							l_item_path.append_integer (ic.item - 1)

							-- Validate item recursively
							l_nested_result := validate (l_array [ic.item], l_item_schema)
							-- Collect errors from nested validation
							if not l_nested_result.is_valid then
								across
									l_nested_result.errors as ic_err
								loop
									create l_error.make (l_item_path, ic_err.message)
									a_errors.extend (l_error)
								end
							end
						end
					end
				end
			end
		end

feature {NONE} -- Path building

	build_path (a_base: READABLE_STRING_GENERAL; a_property: READABLE_STRING_GENERAL): STRING_32
			-- Build JSON Pointer path
		require
			base_not_void: a_base /= Void
			property_not_void: a_property /= Void
		do
			create Result.make (a_base.count + a_property.count + 1)
			Result.append_string_general (a_base)
			Result.append_character ('/')
			Result.append_string_general (a_property)
		ensure
			result_not_void: Result /= Void
		end

end
