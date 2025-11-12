note
	description: "Fluent builder for constructing JSON objects with enhanced operations"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "3"
	EIS: "name=Use Case: Building JSON Programmatically",
		 "src=file:///${SYSTEM_PATH}/docs/use-cases/building-json.html",
		 "protocol=uri",
		 "tag=documentation, builder, use-case, construction"

class
	JSON_BUILDER

create
	make,
	make_from_object

feature {NONE} -- Initialization

	make
			-- Create new builder with empty object
		do
			create json_object.make_empty
		ensure
			empty_object: json_object.is_empty
		end

	make_from_object (a_object: SIMPLE_JSON_OBJECT)
			-- Create builder from existing object
		require
			valid_object: attached a_object
		do
			json_object := a_object
		ensure
			object_set: json_object = a_object
		end

feature -- Building (Basic)

	put_string (a_key: STRING; a_value: STRING): JSON_BUILDER
			-- Add string value (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.put_string (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

	put_integer (a_key: STRING; a_value: INTEGER): JSON_BUILDER
			-- Add integer value (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.put_integer (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

	put_boolean (a_key: STRING; a_value: BOOLEAN): JSON_BUILDER
			-- Add boolean value (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.put_boolean (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

	put_real (a_key: STRING; a_value: REAL_64): JSON_BUILDER
			-- Add real value (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.put_real (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

	put_object (a_key: STRING; a_value: SIMPLE_JSON_OBJECT): JSON_BUILDER
			-- Add nested object (fluent interface)
		require
			not_empty_key: not a_key.is_empty
			valid_object: attached a_value
		do
			json_object.put_object (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

	put_array (a_key: STRING; a_value: SIMPLE_JSON_ARRAY): JSON_BUILDER
			-- Add array (fluent interface)
		require
			not_empty_key: not a_key.is_empty
			valid_array: attached a_value
		do
			json_object.put_array (a_key, a_value)
			Result := Current
		ensure
			returns_self: Result = Current
			has_key: json_object.has_key (a_key)
		end

feature -- Building (Conditional)

	put_string_if (a_condition: BOOLEAN; a_key: STRING; a_value: STRING): JSON_BUILDER
			-- Add string value only if condition is true (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			if a_condition then
				json_object.put_string (a_key, a_value)
			end
			Result := Current
		ensure
			returns_self: Result = Current
			has_key_if_condition: a_condition implies json_object.has_key (a_key)
		end

	put_integer_if (a_condition: BOOLEAN; a_key: STRING; a_value: INTEGER): JSON_BUILDER
			-- Add integer value only if condition is true (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			if a_condition then
				json_object.put_integer (a_key, a_value)
			end
			Result := Current
		ensure
			returns_self: Result = Current
			has_key_if_condition: a_condition implies json_object.has_key (a_key)
		end

	put_boolean_if (a_condition: BOOLEAN; a_key: STRING; a_value: BOOLEAN): JSON_BUILDER
			-- Add boolean value only if condition is true (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			if a_condition then
				json_object.put_boolean (a_key, a_value)
			end
			Result := Current
		ensure
			returns_self: Result = Current
			has_key_if_condition: a_condition implies json_object.has_key (a_key)
		end

	put_real_if (a_condition: BOOLEAN; a_key: STRING; a_value: REAL_64): JSON_BUILDER
			-- Add real value only if condition is true (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			if a_condition then
				json_object.put_real (a_key, a_value)
			end
			Result := Current
		ensure
			returns_self: Result = Current
			has_key_if_condition: a_condition implies json_object.has_key (a_key)
		end

feature -- Operations

	merge (a_other: SIMPLE_JSON_OBJECT): JSON_BUILDER
			-- Merge another object into this builder
			-- Existing keys will be overwritten by values from a_other
		require
			valid_object: attached a_other
		do
			json_object.merge (a_other)
			Result := Current
		ensure
			returns_self: Result = Current
		end

	remove (a_key: STRING): JSON_BUILDER
			-- Remove key from object (fluent interface)
		require
			not_empty_key: not a_key.is_empty
		do
			json_object.remove_key (a_key)
			Result := Current
		ensure
			returns_self: Result = Current
			key_removed: not json_object.has_key (a_key)
		end

	rename_key (a_old_key: STRING; a_new_key: STRING): JSON_BUILDER
			-- Rename a key (fluent interface)
		require
			not_empty_old_key: not a_old_key.is_empty
			not_empty_new_key: not a_new_key.is_empty
			-- Note: has_old_key check removed from precondition to avoid export issues
			-- The check is performed at runtime inside rename_key of SIMPLE_JSON_OBJECT
		do
			json_object.rename_key (a_old_key, a_new_key)
			Result := Current
		ensure
			returns_self: Result = Current
			old_key_removed: not json_object.has_key (a_old_key)
			new_key_exists: json_object.has_key (a_new_key)
		end

	clear: JSON_BUILDER
			-- Clear all entries from the builder
		do
			create json_object.make_empty
			Result := Current
		ensure
			returns_self: Result = Current
			is_empty: json_object.is_empty
		end

feature -- Output

	to_string: STRING
			-- Convert to JSON string
		do
			Result := json_object.to_json_string
		ensure
			result_not_void: Result /= Void
		end

	build: SIMPLE_JSON_OBJECT
			-- Get the underlying JSON object
		do
			Result := json_object
		ensure
			result_not_void: Result /= Void
		end

	clone_object: SIMPLE_JSON_OBJECT
			-- Get an independent copy of the underlying JSON object
		do
			Result := json_object.json_clone
		ensure
			result_not_void: Result /= Void
			independent: Result /= json_object
		end

feature {NONE} -- Implementation

	json_object: SIMPLE_JSON_OBJECT
			-- The object being built

invariant
	has_object: attached json_object

end
