note
	description: "[
		Represents a JSON Schema for validation.
		Wraps a SIMPLE_JSON_OBJECT containing schema definition.
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_SCHEMA

create
	make,
	make_from_string

feature {NONE} -- Initialization

	make (a_schema: SIMPLE_JSON_OBJECT)
			-- Create schema from object
		require
			schema_not_void: a_schema /= Void
		do
			schema_object := a_schema
		ensure
			schema_set: schema_object = a_schema
		end

	make_from_string (a_json_string: READABLE_STRING_GENERAL)
			-- Create schema from JSON string
		require
			string_not_void: a_json_string /= Void
			string_not_empty: not a_json_string.is_empty
		local
			l_json: SIMPLE_JSON
			l_parsed: detachable SIMPLE_JSON_VALUE
		do
			create l_json
			l_parsed := l_json.parse (a_json_string)
			
			if attached l_parsed as al_parsed then
				if al_parsed.is_object then
					if attached {JSON_OBJECT} al_parsed.json_value as l_json_obj then
						create schema_object.make_with_json_object (l_json_obj)
					else
						create schema_object.make  -- Empty schema
					end
				else
					create schema_object.make  -- Empty schema
				end
			else
				create schema_object.make  -- Empty schema
			end
		ensure
			schema_object_not_void: schema_object /= Void
		end

feature -- Access

	schema_object: SIMPLE_JSON_OBJECT
			-- The schema definition as JSON object

feature -- Schema properties

	has_type: BOOLEAN
			-- Does schema specify a type that is a string?
		do
			if schema_object.has_key ("type") then
				if attached schema_object.item ("type") as l_val then
					Result := l_val.is_string
				end
			end
		end

	type_value: detachable STRING_32
			-- The "type" value if present
		require
			has_type: has_type
		do
			if attached schema_object.item ("type") as l_type then
				check is_string: l_type.is_string end
				Result := l_type.as_string_32
			end
		end

	has_properties: BOOLEAN
			-- Does schema have properties that is an object?
		do
			if schema_object.has_key ("properties") then
				if attached schema_object.item ("properties") as l_val then
					Result := l_val.is_object
				end
			end
		end

	properties: detachable SIMPLE_JSON_OBJECT
			-- Object properties schema
		require
			has_properties: has_properties
		do
			if attached schema_object.item ("properties") as l_props then
				check is_object: l_props.is_object end
				if attached {JSON_OBJECT} l_props.json_value as l_json_obj then
					create Result.make_with_json_object (l_json_obj)
				end
			end
		end

	has_required: BOOLEAN
			-- Does schema specify required properties that is an array?
		do
			if schema_object.has_key ("required") then
				if attached schema_object.item ("required") as l_val then
					Result := l_val.is_array
				end
			end
		end

	required: detachable SIMPLE_JSON_ARRAY
			-- Required properties list
		require
			has_required: has_required
		do
			if attached schema_object.item ("required") as l_req then
				check is_array: l_req.is_array end
				if attached {JSON_ARRAY} l_req.json_value as l_json_arr then
					create Result.make_with_json_array (l_json_arr)
				end
			end
		end

	has_minimum: BOOLEAN
			-- Does schema specify minimum value that is a number?
		do
			if schema_object.has_key ("minimum") then
				if attached schema_object.item ("minimum") as l_val then
					Result := l_val.is_number
				end
			end
		end

	minimum: DOUBLE
			-- Minimum value for numbers
		require
			has_minimum: has_minimum
		do
			if attached schema_object.item ("minimum") as l_min then
				check is_number: l_min.is_number end
				-- Handle integers separately to avoid precondition violation
				if l_min.is_integer then
					Result := l_min.as_integer.to_double
				else
					Result := l_min.as_real
				end
			end
		end

	has_maximum: BOOLEAN
			-- Does schema specify maximum value that is a number?
		do
			if schema_object.has_key ("maximum") then
				if attached schema_object.item ("maximum") as l_val then
					Result := l_val.is_number
				end
			end
		end

	maximum: DOUBLE
			-- Maximum value for numbers
		require
			has_maximum: has_maximum
		do
			if attached schema_object.item ("maximum") as l_max then
				check is_number: l_max.is_number end
				-- Handle integers separately to avoid precondition violation
				if l_max.is_integer then
					Result := l_max.as_integer.to_double
				else
					Result := l_max.as_real
				end
			end
		end

	has_min_length: BOOLEAN
			-- Does schema specify minLength that is a number?
		do
			if schema_object.has_key ("minLength") then
				if attached schema_object.item ("minLength") as l_val then
					Result := l_val.is_number
				end
			end
		end

	min_length: INTEGER
			-- Minimum string length
		require
			has_min_length: has_min_length
		do
			if attached schema_object.item ("minLength") as l_min then
				check is_number: l_min.is_number end
				-- Handle reals by converting to integer
				if l_min.is_integer then
					Result := l_min.as_integer.to_integer_32
				else
					Result := l_min.as_real.truncated_to_integer
				end
			end
		end

	has_max_length: BOOLEAN
			-- Does schema specify maxLength that is a number?
		do
			if schema_object.has_key ("maxLength") then
				if attached schema_object.item ("maxLength") as l_val then
					Result := l_val.is_number
				end
			end
		end

	max_length: INTEGER
			-- Maximum string length
		require
			has_max_length: has_max_length
		do
			if attached schema_object.item ("maxLength") as l_max then
				check is_number: l_max.is_number end
				-- Handle reals by converting to integer
				if l_max.is_integer then
					Result := l_max.as_integer.to_integer_32
				else
					Result := l_max.as_real.truncated_to_integer
				end
			end
		end

	has_pattern: BOOLEAN
			-- Does schema specify a regex pattern that is a string?
		do
			if schema_object.has_key ("pattern") then
				if attached schema_object.item ("pattern") as l_val then
					Result := l_val.is_string
				end
			end
		end

	pattern: detachable STRING_32
			-- Regular expression pattern for strings
		require
			has_pattern: has_pattern
		do
			if attached schema_object.item ("pattern") as l_pattern then
				check is_string: l_pattern.is_string end
				Result := l_pattern.as_string_32
			end
		end

	has_min_items: BOOLEAN
			-- Does schema specify minItems that is a number?
		do
			if schema_object.has_key ("minItems") then
				if attached schema_object.item ("minItems") as l_val then
					Result := l_val.is_number
				end
			end
		end

	min_items: INTEGER
			-- Minimum array length
		require
			has_min_items: has_min_items
		do
			if attached schema_object.item ("minItems") as l_min then
				check is_number: l_min.is_number end
				-- Handle reals by converting to integer
				if l_min.is_integer then
					Result := l_min.as_integer.to_integer_32
				else
					Result := l_min.as_real.truncated_to_integer
				end
			end
		end

	has_max_items: BOOLEAN
			-- Does schema specify maxItems that is a number?
		do
			if schema_object.has_key ("maxItems") then
				if attached schema_object.item ("maxItems") as l_val then
					Result := l_val.is_number
				end
			end
		end

	max_items: INTEGER
			-- Maximum array length
		require
			has_max_items: has_max_items
		do
			if attached schema_object.item ("maxItems") as l_max then
				check is_number: l_max.is_number end
				-- Handle reals by converting to integer
				if l_max.is_integer then
					Result := l_max.as_integer.to_integer_32
				else
					Result := l_max.as_real.truncated_to_integer
				end
			end
		end

	has_items: BOOLEAN
			-- Does schema specify items schema that is an object?
		do
			if schema_object.has_key ("items") then
				if attached schema_object.item ("items") as l_val then
					Result := l_val.is_object
				end
			end
		end

	items_schema: detachable SIMPLE_JSON_SCHEMA
			-- Schema for array items
		require
			has_items: has_items
		local
			l_json: SIMPLE_JSON
		do
			if attached schema_object.item ("items") as l_items then
				check is_object: l_items.is_object end
				if attached {JSON_OBJECT} l_items.json_value as l_json_obj then
					create Result.make (create {SIMPLE_JSON_OBJECT}.make_with_json_object (l_json_obj))
				end
			end
		end

invariant
	schema_object_not_void: schema_object /= Void

end
