note
	description: "[
		Simple, high-level wrapper for JSON_ARRAY with fluent API and Unicode support.
		All strings are STRING_32 for proper Unicode/UTF-8 handling.

		Model query:
			- model: MML_SEQUENCE [SIMPLE_JSON_VALUE] for specification
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/core/simple_json_array.html"

class
	SIMPLE_JSON_ARRAY

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
	make_with_json_array

feature {NONE} -- Initialization

	make
			-- Initialize with empty JSON array
		local
			l_array: JSON_ARRAY
		do
			create l_array.make_empty
			make_value (l_array)
		end

	make_with_json_array (a_array: JSON_ARRAY)
			-- Initialize with existing JSON array
		require
			array_not_void: a_array /= Void
		do
			make_value (a_array)
		end

	make_value (a_value: JSON_VALUE)
			-- Initialize with underlying JSON value
		require else
			value_is_array: attached {JSON_ARRAY} a_value
		do
			check attached {JSON_ARRAY} a_value as al_l_array then
				json_value := al_l_array
			end
		ensure then
			value_set: json_value = a_value
		end

feature -- Access

	json_value: JSON_ARRAY
			-- Underlying JSON array

feature -- Measurement

	count: INTEGER
			-- Number of items
		do
			Result := json_value.count
		end

	is_empty: BOOLEAN
			-- Is array empty?
		do
			Result := json_value.is_empty
		end

feature -- Access

	item alias "[]" (a_i: INTEGER): SIMPLE_JSON_VALUE
			-- Get item at index (1-based)
		require
			valid_index: valid_index (a_i)
		do
			create Result.make (json_value.i_th (a_i))
		end

	string_item (a_i: INTEGER): detachable STRING_32
			-- Get string value at index (returns Void if not a string)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_string then
				Result := l_value.as_string_32
			end
		end

	integer_item (a_i: INTEGER): INTEGER_64
			-- Get integer value at index (returns 0 if not found or not a number)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_number then
				Result := l_value.as_integer
			end
		end

	real_item (a_i: INTEGER): DOUBLE
			-- Get real value at index (returns 0.0 if not found or not a number)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_number then
				Result := l_value.as_real
			end
		end

	decimal_item (a_i: INTEGER): detachable SIMPLE_DECIMAL
			-- Get decimal value at index (returns Void if not found or not a number).
			-- Use for precise decimal arithmetic without floating-point errors.
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_number then
				Result := l_value.as_decimal
			end
		end

	boolean_item (a_i: INTEGER): BOOLEAN
			-- Get boolean value at index (returns False if not found or not a boolean)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_boolean then
				Result := l_value.as_boolean
			end
		end

	object_item (a_i: INTEGER): detachable SIMPLE_JSON_OBJECT
			-- Get object value at index (returns Void if not an object)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_object then
				Result := l_value.as_object
			end
		end

	array_item (a_i: INTEGER): detachable SIMPLE_JSON_ARRAY
			-- Get array value at index (returns Void if not an array)
		require
			valid_index: valid_index (a_i)
		do
			if attached item (a_i) as l_value and then l_value.is_array then
				Result := l_value.as_array
			end
		end

feature -- Status report

	valid_index (a_i: INTEGER): BOOLEAN
			-- Is `i' a valid index?
		do
			Result := json_value.valid_index (a_i)
		end

feature -- Model Queries

	elements_model: MML_SEQUENCE [SIMPLE_JSON_VALUE]
			-- Mathematical model of array elements in order.
		local
			i: INTEGER
		do
			create Result
			from i := 1 until i > count loop
				Result := Result & item (i)
				i := i + 1
			end
		ensure
			count_matches: Result.count = count
		end

feature -- Element change (Fluent API)

	add_string (a_value: STRING_32): SIMPLE_JSON_ARRAY
			-- Add string value (fluent).
			-- Note: a_value is attached - void check redundant.
		require
			value_reasonable_length: a_value.count <= Max_reasonable_string_length
		local
			l_json_string: JSON_STRING
		do
			create l_json_string.make_from_string_32 (a_value)
			json_value.add (l_json_string)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_string: item (count).is_string
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_integer (a_value: INTEGER_64): SIMPLE_JSON_ARRAY
			-- Add integer value (fluent)
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_integer (a_value)
			json_value.add (l_json_number)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_number: item (count).is_number
			last_value: integer_item (count) = a_value
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_real (a_value: DOUBLE): SIMPLE_JSON_ARRAY
			-- Add real value (fluent)
		local
			l_json_number: JSON_NUMBER
		do
			create l_json_number.make_real (a_value)
			json_value.add (l_json_number)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_number: item (count).is_number
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_decimal (a_value: SIMPLE_DECIMAL): SIMPLE_JSON_ARRAY
			-- Add decimal value (fluent).
			-- Use for precise decimal values without floating-point errors.
			-- The decimal's exact string representation is preserved in JSON.
			-- Note: a_value is attached - void check redundant.
		local
			l_json_decimal: JSON_DECIMAL
		do
			create l_json_decimal.make_decimal (a_value)
			json_value.add (l_json_decimal)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_number: item (count).is_number
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_boolean (a_value: BOOLEAN): SIMPLE_JSON_ARRAY
			-- Add boolean value (fluent)
		local
			l_json_boolean: JSON_BOOLEAN
		do
			create l_json_boolean.make (a_value)
			json_value.add (l_json_boolean)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_boolean: item (count).is_boolean
			last_value: boolean_item (count) = a_value
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_null: SIMPLE_JSON_ARRAY
			-- Add null value (fluent)
		local
			l_json_null: JSON_NULL
		do
			create l_json_null
			json_value.add (l_json_null)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_null: item (count).is_null
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_object (a_value: SIMPLE_JSON_OBJECT): SIMPLE_JSON_ARRAY
			-- Add object value (fluent).
			-- Note: a_value is attached - void check redundant.
		do
			json_value.add (a_value.json_value)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_object: item (count).is_object
			nested_count: attached object_item (count) as l_nested implies l_nested.count = a_value.count
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_array (a_value: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY
			-- Add array value (fluent).
			-- Note: a_value is attached - void check redundant.
		do
			json_value.add (a_value.json_value)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			last_is_array: item (count).is_array
			nested_count: attached array_item (count) as l_nested implies l_nested.count = a_value.count
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

	add_value (a_value: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY
			-- Add any JSON value (fluent).
			-- Note: a_value is attached - void check redundant.
		do
			json_value.add (a_value.json_value)
			Result := Current
		ensure
			result_is_current: Result = Current
			count_increased: count = old count + 1
			prefix_unchanged: elements_model.front (old count) |=| old elements_model
		end

feature -- Removal

	wipe_out
			-- Remove all items
		do
			json_value.wipe_out
		ensure
			empty: is_empty
			count_zero: count = 0
			model_empty: elements_model.is_empty
		end
feature -- Constants

	Max_reasonable_string_length: INTEGER = 10_000_000
			-- Maximum reasonable string value (10MB, defense against DoS)
			-- Public: used in preconditions for string operations

	Max_reasonable_array_size: INTEGER = 1_000_000
			-- Maximum reasonable array size (defense against memory exhaustion)
			-- Public: used in class invariants

invariant
	-- Core type stability
	json_value_is_array: attached {JSON_ARRAY} json_value

	-- Count relationships
	count_non_negative: count >= 0
	empty_definition: is_empty = (count = 0)

	-- Index validity definition
	valid_index_lower_bound: across 1 |..| count as ic all valid_index (ic) end
	invalid_index_zero: not valid_index (0)
	invalid_index_beyond_count: not valid_index (count + 1)

	-- Element existence (every valid index has a value)
	every_index_has_value: across 1 |..| count as ic all
		attached json_value.i_th (ic)
	end

	-- Model consistency
	model_count: elements_model.count = count

end
