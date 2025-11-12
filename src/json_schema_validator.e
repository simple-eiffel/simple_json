note
	description: "Validates JSON instances against JSON Schema (Draft-07)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_SCHEMA_VALIDATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize validator
		do
				-- Nothing specific to initialize
		end

feature -- Validation

	validate (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA): JSON_VALIDATION_RESULT
			-- Validate `a_instance' against `a_schema'
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema and then a_schema.is_parsed
		local
			l_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
		do
			create l_errors.make (5)
			validate_at_path (a_instance, a_schema, "", l_errors)

			if l_errors.is_empty then
				create Result.make_valid
			else
				create Result.make_invalid (l_errors)
			end
		ensure
			result_exists: attached Result
		end

feature {NONE} -- Validation Implementation

	validate_at_path (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate `a_instance' against `a_schema' at `a_path', accumulating errors in `a_errors'
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		do
				-- Validate type constraint
			validate_type (a_instance, a_schema, a_path, a_errors)

				-- Validate enum constraint
			validate_enum (a_instance, a_schema, a_path, a_errors)

				-- Validate const constraint
			validate_const (a_instance, a_schema, a_path, a_errors)

				-- Type-specific validation
			if a_instance.is_number or a_instance.is_integer or a_instance.is_real then
				validate_numeric (a_instance, a_schema, a_path, a_errors)
			elseif a_instance.is_string then
				validate_string (a_instance, a_schema, a_path, a_errors)
			elseif a_instance.is_array then
				validate_array (a_instance, a_schema, a_path, a_errors)
			elseif a_instance.is_object then
				validate_object (a_instance, a_schema, a_path, a_errors)
			end

				-- Validate logical combinators
			validate_all_of (a_instance, a_schema, a_path, a_errors)
			validate_any_of (a_instance, a_schema, a_path, a_errors)
			validate_one_of (a_instance, a_schema, a_path, a_errors)
			validate_not (a_instance, a_schema, a_path, a_errors)
		end

	validate_type (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate type constraint
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_expected_type: detachable STRING
			l_actual_type: STRING
			l_error: JSON_VALIDATION_ERROR
		do
			l_expected_type := a_schema.type_constraint
			if attached l_expected_type then
				l_actual_type := get_type_name (a_instance)

					-- Special case: "number" includes "integer"
				if l_expected_type ~ "number" and then (l_actual_type ~ "integer" or l_actual_type ~ "number") then
						-- Valid
				elseif not l_expected_type.is_equal (l_actual_type) then
					create l_error.make (a_path, "Expected type '" + l_expected_type + "' but got '" + l_actual_type + "'", "type")
					a_errors.extend (l_error)
				end
			end
		end

	validate_enum (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate enum constraint
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_error: JSON_VALIDATION_ERROR
			l_found: BOOLEAN
			l_instance_string: STRING
		do
			if attached a_schema.enum_values as al_enum then
				l_instance_string := value_to_comparable_string (a_instance)

				across 1 |..| al_enum.count as ic loop
					if attached al_enum.item_at (ic.item) as al_enum_value then
						if value_to_comparable_string (al_enum_value).is_equal (l_instance_string) then
							l_found := True
						end
					end
				end

				if not l_found then
					create l_error.make (a_path, "Value does not match any enum values", "enum")
					a_errors.extend (l_error)
				end
			end
		end

	validate_const (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate const constraint
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_error: JSON_VALIDATION_ERROR
		do
			if attached a_schema.const_value as al_const then
				if not value_to_comparable_string (a_instance).is_equal (value_to_comparable_string (al_const)) then
					create l_error.make (a_path, "Value does not match const", "const")
					a_errors.extend (l_error)
				end
			end
		end

	validate_numeric (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate numeric constraints
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_value: REAL_64
			l_error: JSON_VALIDATION_ERROR
		do
				-- Get numeric value
			if attached {SIMPLE_JSON_INTEGER} a_instance as al_int then
				l_value := al_int.value.to_double
			elseif attached {SIMPLE_JSON_REAL} a_instance as al_real then
				l_value := al_real.value
			elseif attached {SIMPLE_JSON_DECIMAL} a_instance as al_dec then
				l_value := al_dec.real_value
			end

				-- multipleOf
			if a_schema.schema_object.has_key ("multipleOf") then
				if attached a_schema.multiple_of as al_multiple then
					if al_multiple > 0 and then (l_value / al_multiple - (l_value / al_multiple).floor).abs > 0.0000001 then
						create l_error.make (a_path, "Value is not a multiple of " + al_multiple.out, "multipleOf")
						a_errors.extend (l_error)
					end
				end
			end

				-- maximum
			if a_schema.schema_object.has_key ("maximum") then
				if attached a_schema.maximum as al_max then
					if l_value > al_max then
						create l_error.make (a_path, "Value " + l_value.out + " exceeds maximum " + al_max.out, "maximum")
						a_errors.extend (l_error)
					end
				end
			end

				-- exclusiveMaximum
			if a_schema.schema_object.has_key ("exclusiveMaximum") then
				if attached a_schema.exclusive_maximum as al_max then
					if l_value >= al_max then
						create l_error.make (a_path, "Value " + l_value.out + " is not less than " + al_max.out, "exclusiveMaximum")
						a_errors.extend (l_error)
					end
				end
			end

				-- minimum
			if a_schema.schema_object.has_key ("minimum") then
				if attached a_schema.minimum as al_min then
					if l_value < al_min then
						create l_error.make (a_path, "Value " + l_value.out + " is below minimum " + al_min.out, "minimum")
						a_errors.extend (l_error)
					end
				end
			end

				-- exclusiveMinimum
			if a_schema.schema_object.has_key ("exclusiveMinimum") then
				if attached a_schema.exclusive_minimum as al_min then
					if l_value <= al_min then
						create l_error.make (a_path, "Value " + l_value.out + " is not greater than " + al_min.out, "exclusiveMinimum")
						a_errors.extend (l_error)
					end
				end
			end
		end

	validate_string (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate string constraints
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
			is_string: a_instance.is_string
		local
			l_error: JSON_VALIDATION_ERROR
			l_str_value: STRING
		do
			check attached {SIMPLE_JSON_STRING} a_instance as al_str then
				l_str_value := al_str.value
			end

				-- maxLength
			if a_schema.schema_object.has_key ("maxLength") then
				if attached a_schema.max_length as al_max then
					if l_str_value.count > al_max then
						create l_error.make (a_path, "String length " + l_str_value.count.out + " exceeds maxLength " + al_max.out, "maxLength")
						a_errors.extend (l_error)
					end
				end
			end

				-- minLength
			if a_schema.schema_object.has_key ("minLength") then
				if attached a_schema.min_length as al_min then
					if l_str_value.count < al_min then
						create l_error.make (a_path, "String length " + l_str_value.count.out + " is below minLength " + al_min.out, "minLength")
						a_errors.extend (l_error)
					end
				end
			end

				-- pattern
			if attached a_schema.pattern as al_pattern then
				if not matches_pattern (l_str_value, al_pattern) then
					create l_error.make (a_path, "String does not match pattern: " + al_pattern, "pattern")
					a_errors.extend (l_error)
				end
			end
		end

	validate_array (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate array constraints
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
			is_array: a_instance.is_array
		local
			l_error: JSON_VALIDATION_ERROR
			l_array: SIMPLE_JSON_ARRAY
			l_new_path: STRING
			l_contains_valid: BOOLEAN
			l_temp_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
		do
			check attached {SIMPLE_JSON_ARRAY} a_instance as al_arr then
				l_array := al_arr
			end

				-- maxItems
			if a_schema.schema_object.has_key ("maxItems") then
				if attached a_schema.max_items as al_max then
					if l_array.count > al_max then
						create l_error.make (a_path, "Array length " + l_array.count.out + " exceeds maxItems " + al_max.out, "maxItems")
						a_errors.extend (l_error)
					end
				end
			end

				-- minItems
			if a_schema.schema_object.has_key ("minItems") then
				if attached a_schema.min_items as al_min then
					if l_array.count < al_min then
						create l_error.make (a_path, "Array length " + l_array.count.out + " is below minItems " + al_min.out, "minItems")
						a_errors.extend (l_error)
					end
				end
			end

				-- uniqueItems
			if a_schema.unique_items then
				if not array_has_unique_items (l_array) then
					create l_error.make (a_path, "Array items are not unique", "uniqueItems")
					a_errors.extend (l_error)
				end
			end

				-- items
			if attached a_schema.items_schema as al_items_schema then
				across 1 |..| l_array.count as ic loop
					if attached l_array.item_at (ic.item) as al_item then
						create l_new_path.make_from_string (a_path)
						l_new_path.append ("/")
						l_new_path.append ((ic.item - 1).out)
						validate_at_path (al_item, al_items_schema, l_new_path, a_errors)
					end
				end
			end

				-- contains
			if attached a_schema.contains_schema as al_contains_schema then
				across 1 |..| l_array.count as ic loop
					if attached l_array.item_at (ic.item) as al_item then
						create l_new_path.make_from_string (a_path)
						l_new_path.append ("/")
						l_new_path.append ((ic.item - 1).out)

							-- Check if this item validates against contains schema
						create {ARRAYED_LIST [JSON_VALIDATION_ERROR]} l_temp_errors.make (5)
						validate_at_path (al_item, al_contains_schema, l_new_path, l_temp_errors)
						if l_temp_errors.is_empty then
							l_contains_valid := True
						end
					end
				end

				if not l_contains_valid then
					create l_error.make (a_path, "Array does not contain any items matching the schema", "contains")
					a_errors.extend (l_error)
				end
			end
		end

	validate_object (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate object constraints
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
			is_object: a_instance.is_object
		local
			l_error: JSON_VALIDATION_ERROR
			l_object: SIMPLE_JSON_OBJECT
			l_new_path: STRING
			l_prop_schema: JSON_SCHEMA
			l_property_validated: HASH_TABLE [BOOLEAN, STRING]
			l_key: STRING
			l_prop_schema_obj: detachable SIMPLE_JSON_OBJECT
			l_value_from_obj: detachable SIMPLE_JSON_VALUE
		do
			check attached {SIMPLE_JSON_OBJECT} a_instance as al_obj then
				l_object := al_obj
			end

			create l_property_validated.make (l_object.count)

				-- maxProperties
			if a_schema.schema_object.has_key ("maxProperties") then
				if attached a_schema.max_properties as al_max then
					if l_object.count > al_max then
						create l_error.make (a_path, "Object has " + l_object.count.out + " properties, exceeds maxProperties " + al_max.out, "maxProperties")
						a_errors.extend (l_error)
					end
				end
			end

				-- minProperties
			if a_schema.schema_object.has_key ("minProperties") then
				if attached a_schema.min_properties as al_min then
					if l_object.count < al_min then
						create l_error.make (a_path, "Object has " + l_object.count.out + " properties, below minProperties " + al_min.out, "minProperties")
						a_errors.extend (l_error)
					end
				end
			end
			
				-- required
			if attached a_schema.required_properties as al_required then
				across 1 |..| al_required.count as ic loop
					if attached al_required.string_at (ic.item) as al_prop_name then
						if not l_object.has_key (al_prop_name) then
							create l_error.make (a_path, "Required property '" + al_prop_name + "' is missing", "required")
							a_errors.extend (l_error)
						end
					end
				end
			end

				-- properties
			if attached a_schema.properties as al_properties then
				across get_object_keys (al_properties) as ic_key loop
					l_key := ic_key
					if l_object.has_key (l_key) then
						l_prop_schema_obj := al_properties.object (l_key)
						if attached l_prop_schema_obj as al_prop_schema_obj then
							l_value_from_obj := l_object.item_at_key (l_key)
							if attached l_value_from_obj as al_value_obj then
								create l_new_path.make_from_string (a_path)
								l_new_path.append ("/")
								l_new_path.append (l_key)
								create l_prop_schema.make_from_object (al_prop_schema_obj)
								validate_at_path (al_value_obj, l_prop_schema, l_new_path, a_errors)
								l_property_validated.put (True, l_key)
							end
						end
					end
				end
			end

				-- additionalProperties
			if not a_schema.additional_properties_allowed and then not attached a_schema.additional_properties_schema then
					-- Additional properties are not allowed
				across get_object_keys (l_object) as ic_key loop
					l_key := ic_key
					if not l_property_validated.has (l_key) then
						create l_error.make (a_path, "Additional property '" + l_key + "' is not allowed", "additionalProperties")
						a_errors.extend (l_error)
					end
				end
			elseif attached a_schema.additional_properties_schema as al_add_schema then
					-- Additional properties must validate against schema
				across get_object_keys (l_object) as ic_key loop
					l_key := ic_key
					if not l_property_validated.has (l_key) then
						l_value_from_obj := l_object.item_at_key (l_key)
						if attached l_value_from_obj as al_value_add then
							create l_new_path.make_from_string (a_path)
							l_new_path.append ("/")
							l_new_path.append (l_key)
							validate_at_path (al_value_add, al_add_schema, l_new_path, a_errors)
						end
					end
				end
			end
		end

	validate_all_of (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate allOf constraint - instance must validate against ALL schemas
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		do
			if attached a_schema.all_of_schemas as al_schemas then
				across al_schemas as ic_schema loop
					validate_at_path (a_instance, ic_schema, a_path, a_errors)
				end
			end
		end

	validate_any_of (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate anyOf constraint - instance must validate against AT LEAST ONE schema
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_error: JSON_VALIDATION_ERROR
			l_valid_count: INTEGER
			l_temp_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
		do
			if attached a_schema.any_of_schemas as al_schemas then
				across al_schemas as ic_schema loop
					create l_temp_errors.make (5)
					validate_at_path (a_instance, ic_schema, a_path, l_temp_errors)
					if l_temp_errors.is_empty then
						l_valid_count := l_valid_count + 1
					end
				end

				if l_valid_count = 0 then
					create l_error.make (a_path, "Value does not validate against any of the schemas", "anyOf")
					a_errors.extend (l_error)
				end
			end
		end

	validate_one_of (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate oneOf constraint - instance must validate against EXACTLY ONE schema
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_error: JSON_VALIDATION_ERROR
			l_valid_count: INTEGER
			l_temp_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
		do
			if attached a_schema.one_of_schemas as al_schemas then
				across al_schemas as ic_schema loop
					create l_temp_errors.make (5)
					validate_at_path (a_instance, ic_schema, a_path, l_temp_errors)
					if l_temp_errors.is_empty then
						l_valid_count := l_valid_count + 1
					end
				end

				if l_valid_count /= 1 then
					create l_error.make (a_path, "Value validates against " + l_valid_count.out + " schemas, must validate against exactly one", "oneOf")
					a_errors.extend (l_error)
				end
			end
		end

	validate_not (a_instance: SIMPLE_JSON_VALUE; a_schema: JSON_SCHEMA; a_path: STRING;
			a_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR])
			-- Validate not constraint - instance must NOT validate against schema
		require
			valid_instance: attached a_instance
			valid_schema: attached a_schema
			valid_path: attached a_path
			valid_errors: attached a_errors
		local
			l_error: JSON_VALIDATION_ERROR
			l_temp_errors: ARRAYED_LIST [JSON_VALIDATION_ERROR]
		do
			if attached a_schema.not_schema as al_not_schema then
				create l_temp_errors.make (5)
				validate_at_path (a_instance, al_not_schema, a_path, l_temp_errors)
				if l_temp_errors.is_empty then
					create l_error.make (a_path, "Value validates against the 'not' schema", "not")
					a_errors.extend (l_error)
				end
			end
		end

feature {NONE} -- Helper Features

	get_type_name (a_value: SIMPLE_JSON_VALUE): STRING
			-- Get JSON type name for value
		require
			valid_value: attached a_value
		do
			if a_value.is_string then
				Result := "string"
			elseif a_value.is_integer then
				Result := "integer"
			elseif a_value.is_real or a_value.is_number then
				Result := "number"
			elseif a_value.is_boolean then
				Result := "boolean"
			elseif a_value.is_null then
				Result := "null"
			elseif a_value.is_object then
				Result := "object"
			elseif a_value.is_array then
				Result := "array"
			else
				Result := "unknown"
			end
		ensure
			has_result: not Result.is_empty
		end

	value_to_comparable_string (a_value: SIMPLE_JSON_VALUE): STRING
			-- Convert value to string for comparison
		require
			valid_value: attached a_value
		do
			Result := a_value.to_json_string
		ensure
			has_result: not Result.is_empty
		end

	matches_pattern (a_string: STRING; a_pattern: STRING): BOOLEAN
			-- Does `a_string' match regular expression `a_pattern'?
			-- NOTE: This is a simplified implementation - full regex support would require PCRE library
		require
			valid_string: attached a_string
			valid_pattern: attached a_pattern
		do
				-- Simplified pattern matching - just literal substring for now
				-- A full implementation would use PCRE or equivalent regex library
			Result := a_string.has_substring (a_pattern)
		end

	array_has_unique_items (a_array: SIMPLE_JSON_ARRAY): BOOLEAN
			-- Does array have all unique items?
		require
			valid_array: attached a_array
		local
			l_seen: HASH_TABLE [BOOLEAN, STRING]
			l_item_string: STRING
		do
			create l_seen.make (a_array.count)
			Result := True

			across 1 |..| a_array.count as ic loop
				if attached a_array.item_at (ic.item) as al_item then
					l_item_string := value_to_comparable_string (al_item)
					if l_seen.has (l_item_string) then
						Result := False
					else
						l_seen.put (True, l_item_string)
					end
				end
			end
		end

	get_object_keys (a_object: SIMPLE_JSON_OBJECT): ARRAY [STRING]
			-- Get all keys from object
		require
			valid_object: attached a_object
		local
			l_keys: ARRAYED_LIST [STRING]
			l_json_keys: ARRAY [JSON_STRING]
		do
			create l_keys.make (a_object.count)
			l_json_keys := a_object.internal_json_object.current_keys
			across l_json_keys as ic_key loop
				l_keys.extend (ic_key.item)
			end
			Result := l_keys.to_array
		ensure
			result_exists: attached Result
		end

end
