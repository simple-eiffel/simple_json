note
	description: "Represents a JSON Schema (Draft-07) for validation"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Use Case: JSON Schema Validation",
		 "src=file:///${SYSTEM_PATH}/docs/use-cases/validation.html",
		 "protocol=uri",
		 "tag=documentation, validation, schema, use-case"

class
	JSON_SCHEMA

create
	make_from_string,
	make_from_object

feature {NONE} -- Initialization

	make_from_string (a_schema_string: STRING)
			-- Create schema from JSON string
		require
			valid_string: attached a_schema_string and then not a_schema_string.is_empty
		local
			l_parser: SIMPLE_JSON
		do
			create l_parser
			if attached l_parser.parse (a_schema_string) as al_obj then
				schema_object := al_obj
				is_parsed := True
			else
				create schema_object.make_empty
				is_parsed := False
			end
		ensure
			parsed_set: is_parsed = (schema_object.count > 0 or else a_schema_string ~ "{}")
		end

	make_from_object (a_schema_object: SIMPLE_JSON_OBJECT)
			-- Create schema from existing JSON object
		require
			valid_object: attached a_schema_object
		do
			schema_object := a_schema_object
			is_parsed := True
		ensure
			object_set: schema_object = a_schema_object
			is_parsed: is_parsed
		end

feature -- Status Report

	is_parsed: BOOLEAN
			-- Was schema successfully parsed?

feature -- Access: Type Constraints

	type_constraint: detachable STRING
			-- Required type ("string", "number", "integer", "boolean", "null", "object", "array")
		do
			Result := schema_object.string ("type")
		end

	enum_values: detachable SIMPLE_JSON_ARRAY
			-- Allowed enumeration values
		do
			Result := schema_object.array ("enum")
		end

	const_value: detachable SIMPLE_JSON_VALUE
			-- Constant value constraint
		local
			l_str: detachable STRING
			l_int: INTEGER
			l_bool: BOOLEAN
		do
			if schema_object.has_key ("const") then
				-- Try to determine type and wrap appropriately
				l_str := schema_object.string ("const")
				if attached l_str then
					create {SIMPLE_JSON_STRING} Result.make (l_str)
				else
					l_int := schema_object.integer ("const")
					if l_int /= 0 or else schema_object.has_key ("const") then
						create {SIMPLE_JSON_INTEGER} Result.make (l_int)
					else
						l_bool := schema_object.boolean ("const")
						if l_bool or else schema_object.has_key ("const") then
							create {SIMPLE_JSON_BOOLEAN} Result.make (l_bool)
						end
					end
				end
			end
		end

feature -- Access: Numeric Constraints

	multiple_of: detachable REAL_64
			-- Number must be multiple of this value
		do
			if schema_object.has_key ("multipleOf") then
				Result := schema_object.real ("multipleOf")
			end
		end

	maximum: detachable REAL_64
			-- Maximum value (inclusive)
		do
			if schema_object.has_key ("maximum") then
				Result := schema_object.real ("maximum")
			end
		ensure
			only_when_present: attached Result implies schema_object.has_key ("maximum")
		end

	exclusive_maximum: detachable REAL_64
			-- Maximum value (exclusive)
		do
			if schema_object.has_key ("exclusiveMaximum") then
				Result := schema_object.real ("exclusiveMaximum")
			end
		end

	minimum: detachable REAL_64
			-- Minimum value (inclusive)
		do
			if schema_object.has_key ("minimum") then
				Result := schema_object.real ("minimum")
			end
		end

	exclusive_minimum: detachable REAL_64
			-- Minimum value (exclusive)
		do
			if schema_object.has_key ("exclusiveMinimum") then
				Result := schema_object.real ("exclusiveMinimum")
			end
		end

feature -- Access: String Constraints

	max_length: detachable INTEGER
			-- Maximum string length
		do
			if schema_object.has_key ("maxLength") then
				Result := schema_object.integer ("maxLength")
			end
		end

	min_length: detachable INTEGER
			-- Minimum string length
		do
			if schema_object.has_key ("minLength") then
				Result := schema_object.integer ("minLength")
			end
		end

	pattern: detachable STRING
			-- Regular expression pattern string must match
		do
			Result := schema_object.string ("pattern")
		end

feature -- Access: Array Constraints

	max_items: detachable INTEGER
			-- Maximum array length
		do
			if schema_object.has_key ("maxItems") then
				Result := schema_object.integer ("maxItems")
			end
		end

	min_items: detachable INTEGER
			-- Minimum array length
		do
			if schema_object.has_key ("minItems") then
				Result := schema_object.integer ("minItems")
			end
		end

	unique_items: BOOLEAN
			-- Must array items be unique?
		do
			Result := schema_object.boolean ("uniqueItems")
		end

	items_schema: detachable JSON_SCHEMA
			-- Schema for array items
		do
			if attached schema_object.object ("items") as al_items then
				create Result.make_from_object (al_items)
			end
		end

	contains_schema: detachable JSON_SCHEMA
			-- Schema that at least one item must match
		do
			if attached schema_object.object ("contains") as al_contains then
				create Result.make_from_object (al_contains)
			end
		end

feature -- Access: Object Constraints

	max_properties: detachable INTEGER
			-- Maximum number of properties
		do
			if schema_object.has_key ("maxProperties") then
				Result := schema_object.integer ("maxProperties")
			end
		end

	min_properties: detachable INTEGER
			-- Minimum number of properties
		do
			if schema_object.has_key ("minProperties") then
				Result := schema_object.integer ("minProperties")
			end
		end

	required_properties: detachable SIMPLE_JSON_ARRAY
			-- Array of required property names
		do
			Result := schema_object.array ("required")
		end

	properties: detachable SIMPLE_JSON_OBJECT
			-- Object containing property schemas
		do
			Result := schema_object.object ("properties")
		end

	additional_properties_allowed: BOOLEAN
			-- Are additional properties allowed?
		do
			-- If not specified or set to true, additional properties are allowed
			-- If set to false, they are not allowed
			if schema_object.has_key ("additionalProperties") then
				Result := schema_object.boolean ("additionalProperties")
			else
				Result := True  -- Default is to allow additional properties
			end
		end

	additional_properties_schema: detachable JSON_SCHEMA
			-- Schema for additional properties (if additionalProperties is an object)
		do
			if attached schema_object.object ("additionalProperties") as al_schema then
				create Result.make_from_object (al_schema)
			end
		end

feature -- Access: Logical Combinators

	all_of_schemas: detachable LIST [JSON_SCHEMA]
			-- Array of schemas - instance must validate against ALL
		local
			l_array: detachable SIMPLE_JSON_ARRAY
			l_item: detachable SIMPLE_JSON_VALUE
		do
			l_array := schema_object.array ("allOf")
			
			if attached l_array then
				create {ARRAYED_LIST [JSON_SCHEMA]} Result.make (0)
				across 1 |..| l_array.count as ic loop
					l_item := l_array.item_at (ic.item)
					check item_exists: attached l_item then
						check item_is_object: l_item.is_object end
					end
					
					if attached {SIMPLE_JSON_OBJECT} l_item as al_obj then
						Result.extend (create {JSON_SCHEMA}.make_from_object (al_obj))
					else
						check must_be_object: False then
							-- Item in allOf array must be an object
						end
					end
				end
			end
		ensure
			all_parsed: attached Result implies across Result as ic_schema all ic_schema.is_parsed end
		end

	any_of_schemas: detachable LIST [JSON_SCHEMA]
			-- Array of schemas - instance must validate against AT LEAST ONE
		local
			l_array: detachable SIMPLE_JSON_ARRAY
			l_item: detachable SIMPLE_JSON_VALUE
		do
			l_array := schema_object.array ("anyOf")
			
			if attached l_array then
				create {ARRAYED_LIST [JSON_SCHEMA]} Result.make (0)
				across 1 |..| l_array.count as ic loop
					l_item := l_array.item_at (ic.item)
					check item_exists: attached l_item then
						check item_is_object: l_item.is_object end
					end
					
					if attached {SIMPLE_JSON_OBJECT} l_item as al_obj then
						Result.extend (create {JSON_SCHEMA}.make_from_object (al_obj))
					else
						check must_be_object: False then
							-- Item in anyOf array must be an object
						end
					end
				end
			end
		ensure
			all_parsed: attached Result implies across Result as ic_schema all ic_schema.is_parsed end
		end

	one_of_schemas: detachable LIST [JSON_SCHEMA]
			-- Array of schemas - instance must validate against EXACTLY ONE
		local
			l_array: detachable SIMPLE_JSON_ARRAY
			l_item: detachable SIMPLE_JSON_VALUE
		do
			l_array := schema_object.array ("oneOf")
			
			if attached l_array then
				create {ARRAYED_LIST [JSON_SCHEMA]} Result.make (0)
				across 1 |..| l_array.count as ic loop
					l_item := l_array.item_at (ic.item)
					check item_exists: attached l_item then
						check item_is_object: l_item.is_object end
					end
					
					if attached {SIMPLE_JSON_OBJECT} l_item as al_obj then
						Result.extend (create {JSON_SCHEMA}.make_from_object (al_obj))
					else
						check must_be_object: False then
							-- Item in oneOf array must be an object
						end
					end
				end
			end
		ensure
			all_parsed: attached Result implies across Result as ic_schema all ic_schema.is_parsed end
		end

	not_schema: detachable JSON_SCHEMA
			-- Schema that instance must NOT validate against
		do
			if attached schema_object.object ("not") as al_not then
				create Result.make_from_object (al_not)
			end
		end

feature {JSON_SCHEMA_VALIDATOR} -- Implementation

	schema_object: SIMPLE_JSON_OBJECT
			-- Underlying JSON object containing schema definition

invariant
	schema_attached: attached schema_object

end
