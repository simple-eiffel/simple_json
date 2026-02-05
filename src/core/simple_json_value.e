note
	description: "[
		Wrapper around JSON_VALUE providing convenient Unicode/UTF-8 string access.
		All strings are returned as STRING_32 for proper Unicode support.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/core/simple_json_value.html"

class
	SIMPLE_JSON_VALUE

create
	make

feature {NONE} -- Initialization

	make (a_value: JSON_VALUE)
			-- Initialize with underlying JSON value
		require
			value_not_void: a_value /= Void
		do
			json_value := a_value
		ensure
			value_set: json_value = a_value
		end

feature -- Access

	json_value: JSON_VALUE
			-- Underlying JSON value

feature -- Type checking

	is_string: BOOLEAN
			-- Is this a string value?
		do
			Result := json_value.is_string
		end

	is_number: BOOLEAN
			-- Is this a number value?
		do
			Result := json_value.is_number
		end

	is_integer: BOOLEAN
			-- Is this an integer number value?
		do
			if attached {JSON_NUMBER} json_value as al_l_number then
				Result := al_l_number.is_integer
			end
		end

	is_boolean: BOOLEAN
			-- Is this a boolean value?
		do
			Result := attached {JSON_BOOLEAN} json_value
		end

	is_null: BOOLEAN
			-- Is this a null value?
		do
			Result := json_value.is_null
		end

	is_object: BOOLEAN
			-- Is this an object value?
		do
			Result := json_value.is_object
		end

	is_array: BOOLEAN
			-- Is this an array value?
		do
			Result := json_value.is_array
		end

feature -- String access (STRING_32 only)

	as_string_32: STRING_32
			-- Get value as STRING_32 (Unicode)
		require
			is_string: is_string
		do
			if attached {JSON_STRING} json_value as al_l_string then
				Result := al_l_string.unescaped_string_32
			else
				create Result.make_empty
			end
		end

	string_value: STRING_32
			-- Synonym for as_string_32
		require
			is_string: is_string
		do
			Result := as_string_32
		end

feature -- Number access

	as_integer: INTEGER_64
			-- Get value as integer
		require
			is_number: is_number
		do
			if attached {JSON_NUMBER} json_value as al_l_number then
				Result := al_l_number.integer_64_item
			end
		end

	as_natural: NATURAL_64
			-- Get value as natural
		require
			is_number: is_number
		do
			if attached {JSON_NUMBER} json_value as al_l_number then
				Result := al_l_number.natural_64_item
			end
		end

	as_real: DOUBLE
			-- Get value as double
		require
			is_number: is_number
		do
			if attached {JSON_NUMBER} json_value as al_l_number then
				Result := al_l_number.real_64_item
			end
		end

	integer_value: INTEGER_64
			-- Synonym for as_integer
		require
			is_number: is_number
		do
			Result := as_integer
		end

	real_value: DOUBLE
			-- Synonym for as_real
		require
			is_number: is_number
		do
			Result := as_real
		end

feature -- Decimal access

	as_decimal: SIMPLE_DECIMAL
			-- Get value as SIMPLE_DECIMAL for precise arithmetic.
			-- Preserves exact precision from JSON source.
		require
			is_number: is_number
		do
			if attached {JSON_NUMBER} json_value as al_l_number then
				create Result.make (al_l_number.representation)
			else
				create Result.make_zero
			end
		ensure
			result_attached: Result /= Void
		end

	decimal_value: SIMPLE_DECIMAL
			-- Synonym for as_decimal
		require
			is_number: is_number
		do
			Result := as_decimal
		end

feature -- Boolean access

	as_boolean: BOOLEAN
			-- Get value as boolean
		require
			is_boolean: is_boolean
		do
			if attached {JSON_BOOLEAN} json_value as al_l_boolean then
				Result := al_l_boolean.item
			end
		end

	boolean_value: BOOLEAN
			-- Synonym for as_boolean
		require
			is_boolean: is_boolean
		do
			Result := as_boolean
		end

feature -- Object access

	as_object: SIMPLE_JSON_OBJECT
			-- Get value as object
		require
			is_object: is_object
		do
			if attached {JSON_OBJECT} json_value as al_l_object then
				create Result.make_with_json_object (l_object)
			else
				create Result.make -- Empty object
			end
		end

	object_value: SIMPLE_JSON_OBJECT
			-- Synonym for as_object
		require
			is_object: is_object
		do
			Result := as_object
		end

feature -- Array access

	as_array: SIMPLE_JSON_ARRAY
			-- Get value as array
		require
			is_array: is_array
		do
			if attached {JSON_ARRAY} json_value as al_l_array then
				create Result.make_with_json_array (l_array)
			else
				create Result.make -- Empty array
			end
		end

	array_value: SIMPLE_JSON_ARRAY
			-- Synonym for as_array
		require
			is_array: is_array
		do
			Result := as_array
		end

feature -- Output

	as_json: STRING
			-- JSON string representation (STRING_8)
		do
			Result := json_value.representation
		ensure
			result_attached: Result /= Void
		end

	as_json_32: STRING_32
			-- JSON string representation (STRING_32)
		do
			Result := utf_8_to_string_32 (json_value.representation)
		ensure
			result_attached: Result /= Void
		end

feature -- Conversion

	to_json_string: STRING_32
			-- Convert to JSON string representation (STRING_32)
		local
			l_utf8: STRING_8
		do
			l_utf8 := json_value.representation
			Result := utf_8_to_string_32 (l_utf8)
		end

	representation: STRING_32
			-- Synonym for to_json_string
		do
			Result := to_json_string
		end

feature -- Pretty Printing

	to_pretty_json: STRING_32
			-- Convert to pretty-printed JSON with 2-space indentation
		local
			l_printer: SIMPLE_JSON_PRETTY_PRINTER
		do
			create l_printer.make
			Result := l_printer.print_json_value (json_value)
		end

	to_pretty_json_with_indent (a_indent: STRING_32): STRING_32
			-- Convert to pretty-printed JSON with custom indentation
		require
			indent_not_void: a_indent /= Void
			indent_not_empty: not a_indent.is_empty
		local
			l_printer: SIMPLE_JSON_PRETTY_PRINTER
		do
			create l_printer.make_with_options (a_indent)
			Result := l_printer.print_json_value (json_value)
		end

	to_pretty_json_with_tabs: STRING_32
			-- Convert to pretty-printed JSON with tab indentation
		local
			l_printer: SIMPLE_JSON_PRETTY_PRINTER
		do
			create l_printer.make
			l_printer.use_tabs
			Result := l_printer.print_json_value (json_value)
		end

	to_pretty_json_with_spaces (a_count: INTEGER): STRING_32
			-- Convert to pretty-printed JSON with specified number of spaces
		require
			positive_count: a_count > 0
			reasonable_count: a_count <= 8
		local
			l_printer: SIMPLE_JSON_PRETTY_PRINTER
		do
			create l_printer.make
			l_printer.use_spaces (a_count)
			Result := l_printer.print_json_value (json_value)
		end

feature {NONE} -- Implementation

	utf_8_to_string_32 (a_utf8: STRING_8): STRING_32
			-- Convert UTF-8 encoded STRING_8 to STRING_32
		local
			l_zstring: SIMPLE_ZSTRING
		do
			create l_zstring.make_from_utf_8 (a_utf8)
			Result := l_zstring.to_string_32
		end

invariant
	-- Core data stability
	json_value_attached: json_value /= Void

	-- Type consistency: Exactly one type must be true
	valid_json_type:
		is_string or is_number or is_boolean or is_null or is_object or is_array

	-- Type exclusivity: Only ONE type can be true at a time
	string_excludes_others: is_string implies
		(not is_number and not is_boolean and not is_null and not is_object and not is_array)
	number_excludes_others: is_number implies
		(not is_string and not is_boolean and not is_null and not is_object and not is_array)
	boolean_excludes_others: is_boolean implies
		(not is_string and not is_number and not is_null and not is_object and not is_array)
	null_excludes_others: is_null implies
		(not is_string and not is_number and not is_boolean and not is_object and not is_array)
	object_excludes_others: is_object implies
		(not is_string and not is_number and not is_boolean and not is_null and not is_array)
	array_excludes_others: is_array implies
		(not is_string and not is_number and not is_boolean and not is_null and not is_object)

	-- Type verification: Underlying json_value type matches our type queries
	string_type_accurate: is_string = (attached {JSON_STRING} json_value)
	number_type_accurate: is_number = json_value.is_number
	boolean_type_accurate: is_boolean = (attached {JSON_BOOLEAN} json_value)
	null_type_accurate: is_null = json_value.is_null
	object_type_accurate: is_object = json_value.is_object
	array_type_accurate: is_array = json_value.is_array
	
end
