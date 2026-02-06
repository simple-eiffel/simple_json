note
	description: "[
		Simple, high-level wrapper for JSON_OBJECT with fluent API and Unicode support.
		All strings are STRING_32 for proper Unicode/UTF-8 handling.

		Model query:
			- model: MML_MAP [STRING_32, detachable SIMPLE_JSON_VALUE] for specification
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/core/simple_json_object.html"

class
	SIMPLE_JSON_OBJECT

inherit
	SIMPLE_JSON_VALUE
		rename
			make as make_value
		redefine
			json_value,
			make_value
		end

create
	make,
	make_with_json_object

feature {NONE} -- Initialization

	make
			-- Initialize with empty JSON object
		local
			l_object: JSON_OBJECT
		do
			create l_object.make
			make_value (l_object)
		end

	make_with_json_object (a_object: JSON_OBJECT)
			-- Initialize with existing JSON object.
			-- Note: a_object is attached - void check redundant.
		do
			make_value (a_object)
		ensure
			json_set: json_value = a_object
		end

	make_value (a_value: JSON_VALUE)
			-- Initialize with underlying JSON value
		require else
			value_is_object: attached {JSON_OBJECT} a_value
		do
			check attached {JSON_OBJECT} a_value as al_l_object then
				json_value := al_l_object
			end
		ensure then
			value_set: json_value = a_value
		end

feature -- Access

	json_value: JSON_OBJECT
			-- Underlying JSON object

feature -- Measurement

	count: INTEGER
			-- Number of key-value pairs
		do
			Result := json_value.count
		end

	is_empty: BOOLEAN
			-- Is object empty?
		do
			Result := json_value.is_empty
		end

feature -- Status report

	has_key (a_key: STRING_32): BOOLEAN
			-- Does object have key?
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			Result := json_value.has_key (l_json_key)
		end

feature -- Access (Unicode keys)

	item (a_key: STRING_32): detachable SIMPLE_JSON_VALUE
			-- Get value for key (returns Void if key doesn't exist)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			if attached json_value.item (l_json_key) as al_l_value then
				create Result.make (al_l_value)
			end
		end

	string_item (a_key: STRING_32): detachable STRING_32
			-- Get string value for key (returns Void if not a string)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_string then
				Result := l_value.as_string_32
			end
		end

	integer_item (a_key: STRING_32): INTEGER_64
			-- Get integer value for key (returns 0 if not found or not a number)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_number then
				Result := l_value.as_integer
			end
		end

	real_item (a_key: STRING_32): DOUBLE
			-- Get real value for key (returns 0.0 if not found or not a number)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_number then
				Result := l_value.as_real
			end
		end

	decimal_item (a_key: STRING_32): detachable SIMPLE_DECIMAL
			-- Get decimal value for key (returns Void if not found or not a number).
			-- Use for precise decimal arithmetic without floating-point errors.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_number then
				Result := l_value.as_decimal
			end
		end

	boolean_item (a_key: STRING_32): BOOLEAN
			-- Get boolean value for key (returns False if not found or not a boolean)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_boolean then
				Result := l_value.as_boolean
			end
		end

	object_item (a_key: STRING_32): detachable SIMPLE_JSON_OBJECT
			-- Get object value for key (returns Void if not an object)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_object then
				Result := l_value.as_object
			end
		end

	array_item (a_key: STRING_32): detachable SIMPLE_JSON_ARRAY
			-- Get array value for key (returns Void if not an array)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if attached item (a_key) as l_value and then l_value.is_array then
				Result := l_value.as_array
			end
		end

feature -- Access (convenience - F4 friction fix)

	integer_32_item (a_key: STRING_32): INTEGER_32
			-- Get integer value for key as INTEGER_32 (returns 0 if not found or not a number).
			-- Convenience to avoid `.to_integer_32` after every `integer_item` call.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			Result := integer_item (a_key).to_integer_32
		end

	natural_32_item (a_key: STRING_32): NATURAL_32
			-- Get natural value for key as NATURAL_32 (returns 0 if not found or not a number).
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			Result := integer_item (a_key).to_natural_32
		end

feature -- Access (optional - F5 friction fix)

	optional_string (a_key: STRING_32): detachable STRING_32
			-- Get string value if key exists, Void otherwise.
			-- Same as string_item but name clarifies intent for optional fields.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if has_key (a_key) then
				Result := string_item (a_key)
			end
		end

	optional_integer (a_key: STRING_32; a_default: INTEGER_64): INTEGER_64
			-- Get integer value if key exists, `a_default` otherwise.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if has_key (a_key) then
				Result := integer_item (a_key)
			else
				Result := a_default
			end
		end

	optional_boolean (a_key: STRING_32; a_default: BOOLEAN): BOOLEAN
			-- Get boolean value if key exists, `a_default` otherwise.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		do
			if has_key (a_key) then
				Result := boolean_item (a_key)
			else
				Result := a_default
			end
		end

feature -- Status report (multiple keys - F3 friction fix)

	has_all_keys (a_keys: ARRAY [STRING_32]): BOOLEAN
			-- Does object have all specified keys?
			-- Note: a_keys is attached - void check redundant.
		do
			Result := across a_keys as k all has_key (k) end
		ensure
			definition: Result = across a_keys as k all has_key (k) end
		end

	has_any_key (a_keys: ARRAY [STRING_32]): BOOLEAN
			-- Does object have at least one of the specified keys?
			-- Note: a_keys is attached - void check redundant.
		do
			Result := across a_keys as k some has_key (k) end
		ensure
			definition: Result = across a_keys as k some has_key (k) end
		end

	missing_keys (a_keys: ARRAY [STRING_32]): ARRAYED_LIST [STRING_32]
			-- Which of the specified keys are missing?
			-- Note: a_keys is attached - void check redundant.
		do
			create Result.make (a_keys.count)
			across a_keys as ic_key loop
				if not has_key (ic_key) then
					Result.extend (ic_key)
				end
			end
		ensure
			no_void_elements: across Result as ic_r all ic_r /= Void end
			all_missing: across Result as ic_r all not has_key (ic_r) end
			none_extra: across a_keys as ic_a all has_key (ic_a) or Result.has (ic_a) end
		end

feature -- Model Queries

	entries_model: MML_MAP [STRING_32, detachable SIMPLE_JSON_VALUE]
			-- Mathematical model of all key-value entries.
		local
			l_keys: ARRAY [STRING_32]
			i: INTEGER
		do
			create Result
			l_keys := keys
			from i := l_keys.lower until i > l_keys.upper loop
				Result := Result.updated (l_keys [i], item (l_keys [i]))
				i := i + 1
			end
		ensure
			count_matches: Result.count = count
		end

feature -- Element change (Fluent API)

	put_string (a_value: STRING_32; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add string value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
			value_reasonable_length: a_value.count <= Max_reasonable_string_length
		local
			l_json_key: JSON_STRING
			l_json_value: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			create l_json_value.make_from_string_32 (a_value)
			json_value.replace (l_json_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			value_stored: attached string_item (a_key) as l_stored implies l_stored.same_string (a_value)
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_integer (a_value: INTEGER_64; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add integer value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_integer (a_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			value_stored: integer_item (a_key) = a_value
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_real (a_value: DOUBLE; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add real value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_real (a_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_decimal (a_value: SIMPLE_DECIMAL; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add decimal value with key (fluent).
			-- Use for precise decimal values without floating-point errors.
			-- The decimal's exact string representation is preserved in JSON.
			-- Note: a_value is attached - void check redundant.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
			l_json_decimal: JSON_DECIMAL
		do
			create l_json_key.make_from_string_32 (a_key)
			create l_json_decimal.make_decimal (a_value)
			json_value.replace (l_json_decimal, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_boolean (a_value: BOOLEAN; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add boolean value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace_with_boolean (a_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			value_stored: boolean_item (a_key) = a_value
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_null (a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add null value with key (fluent)
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
			l_json_null: JSON_NULL
		do
			create l_json_key.make_from_string_32 (a_key)
			create l_json_null
			json_value.replace (l_json_null, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			is_null: attached item (a_key) as l_v implies l_v.is_null
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_object (a_value: SIMPLE_JSON_OBJECT; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add object value with key (fluent).
			-- Note: a_value is attached - void check redundant.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			is_object: attached item (a_key) as l_v implies l_v.is_object
			nested_count: attached object_item (a_key) as l_nested implies l_nested.count = a_value.count
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_array (a_value: SIMPLE_JSON_ARRAY; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add array value with key (fluent).
			-- Note: a_value is attached - void check redundant.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			is_array: attached item (a_key) as l_v implies l_v.is_array
			nested_count: attached array_item (a_key) as l_nested implies l_nested.count = a_value.count
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

	put_value (a_value: SIMPLE_JSON_VALUE; a_key: STRING_32): SIMPLE_JSON_OBJECT
			-- Add any JSON value with key (fluent).
			-- Note: a_value is attached - void check redundant.
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.replace (a_value.json_value, l_json_key)
			Result := Current
		ensure
			result_is_current: Result = Current
			key_exists: has_key (a_key)
			keys_frame: entries_model.domain.removed (a_key) |=| old entries_model.domain.removed (a_key)
		end

feature -- Removal

	remove (a_key: STRING_32)
			-- Remove key-value pair
		require
			key_not_empty: not a_key.is_empty
			key_reasonable_length: a_key.count <= Max_reasonable_key_length
		local
			l_json_key: JSON_STRING
		do
			create l_json_key.make_from_string_32 (a_key)
			json_value.remove (l_json_key)
		ensure
			key_removed: not has_key (a_key)
			count_decreased: count <= old count
			model_domain: entries_model.domain |=| old entries_model.domain.removed (a_key)
		end

	wipe_out
			-- Remove all key-value pairs
		do
			json_value.wipe_out
		ensure
			empty: is_empty
			count_zero: count = 0
			model_empty: entries_model.is_empty
		end

feature -- Iteration

	keys: ARRAY [STRING_32]
			-- Array of all keys (as STRING_32)
		local
			l_json_keys: ARRAY [JSON_STRING]
			i: INTEGER
		do
			l_json_keys := json_value.current_keys
			create Result.make_filled (create {STRING_32}.make_empty, l_json_keys.lower, l_json_keys.upper)
			from
				i := l_json_keys.lower
			invariant
				-- Index bounds
				valid_index: i >= l_json_keys.lower and i <= l_json_keys.upper + 1

				-- Progress tracking
				copied_elements: i - l_json_keys.lower <= l_json_keys.count

				-- Result array integrity
				result_attached: Result /= Void
				result_same_bounds: Result.lower = l_json_keys.lower and Result.upper = l_json_keys.upper

				-- All copied elements are non-void
				copied_keys_valid: across l_json_keys.lower |..| (i - 1) as ic all Result [ic] /= Void end
			until
				i > l_json_keys.upper
			loop
				Result [i] := l_json_keys [i].unescaped_string_32
				i := i + 1
			end
		end

feature -- Constants

	Max_reasonable_key_length: INTEGER = 1024
			-- Maximum reasonable length for JSON keys (defense against abuse)

	Max_reasonable_string_length: INTEGER = 10_000_000
			-- Maximum reasonable length for JSON string values (10MB, defense against DoS)

	Max_reasonable_object_size: INTEGER = 100_000
			-- Maximum reasonable number of properties (defense against memory exhaustion)

invariant
	-- Core type stability
	json_value_is_object: attached {JSON_OBJECT} json_value

	-- Count relationships
	count_non_negative: count >= 0
	empty_definition: is_empty = (count = 0)
	keys_match_count: keys.count = count

	-- Key integrity
	no_void_keys: across keys as ic_key all ic_key /= Void end
	no_empty_keys: across keys as ic_key all not ic_key.is_empty end

	-- Key existence and consistency
	every_key_exists: across keys as ic_key all has_key (ic_key) end
	every_key_has_value: across keys as ic_key all item (ic_key) /= Void end

	-- Model consistency
	model_count: entries_model.count = count

end
