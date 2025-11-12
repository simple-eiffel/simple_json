note
	description: "Wrapper for JSON arrays - provides simple access to array elements with enhanced operations"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "4"

class
	SIMPLE_JSON_ARRAY

inherit
	SIMPLE_JSON_VALUE

create
	make_empty,
	make_from_json

feature {NONE} -- Initialization

	make_empty
			-- Create an empty JSON array
		do
			create json_array.make_empty
		end

	make_from_json (a_json_array: JSON_ARRAY)
			-- Create from an eJSON JSON_ARRAY
		do
			json_array := a_json_array
		ensure
			set: json_array = a_json_array
		end

feature -- Status Report

	count: INTEGER
			-- Number of elements in array
		do
			Result := json_array.count
		ensure
			non_negative: Result >= 0
		end

	is_empty: BOOLEAN
			-- Is array empty?
		do
			Result := (count = 0)
		ensure
			definition: Result = (count = 0)
		end

	valid_index (a_index: INTEGER): BOOLEAN
			-- Is index valid for this array?
		do
			Result := a_index >= 1 and a_index <= count
		ensure
			definition: Result = (a_index >= 1 and a_index <= count)
		end

feature -- Access

	string_at (a_index: INTEGER): detachable STRING
			-- Get string value at index (1-based)
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_STRING} l_value as l_str then
					Result := l_str.unescaped_string_8
				end
			end
		end

	real_at (a_index: INTEGER): REAL_64
			-- Get real value at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_real then
						Result := l_num.real_64_item
					elseif l_num.is_integer then
						Result := l_num.integer_64_item.to_double
					end
				end
			end
		end

	integer_at (a_index: INTEGER): INTEGER
			-- Get integer value at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_NUMBER} l_value as l_num then
					if l_num.is_integer then
						Result := l_num.integer_64_item.to_integer_32
					elseif l_num.is_real then
						Result := l_num.real_64_item.truncated_to_integer
					end
				end
			end
		end

	boolean_at (a_index: INTEGER): BOOLEAN
			-- Get boolean value at index (1-based)
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_BOOLEAN} l_value as l_bool then
					Result := l_bool.item
				end
			end
		end

feature -- Access - Nested Structures

	object_at (a_index: INTEGER): detachable SIMPLE_JSON_OBJECT
			-- Get object at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_OBJECT} l_value as l_obj then
					create Result.make_from_json (l_obj)
				end
			end
		end

	array_at (a_index: INTEGER): detachable SIMPLE_JSON_ARRAY
			-- Get array at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			if attached json_array.i_th (a_index) as l_value then
				if attached {JSON_ARRAY} l_value as l_arr then
					create Result.make_from_json (l_arr)
				end
			end
		end

feature -- Modification (Append/Prepend)

	append_string (a_value: STRING)
			-- Append string value to end of array
		do
			json_array.add (create {JSON_STRING}.make_from_string (a_value))
		ensure
			count_increased: count = old count + 1
		end

	append_integer (a_value: INTEGER)
			-- Append integer value to end of array
		do
			json_array.add (create {JSON_NUMBER}.make_integer (a_value))
		ensure
			count_increased: count = old count + 1
		end

	append_real (a_value: REAL_64)
			-- Append real value to end of array
		do
			json_array.add (create {JSON_NUMBER}.make_real (a_value))
		ensure
			count_increased: count = old count + 1
		end

	append_boolean (a_value: BOOLEAN)
			-- Append boolean value to end of array
		do
			json_array.add (create {JSON_BOOLEAN}.make (a_value))
		ensure
			count_increased: count = old count + 1
		end

	append_object (a_value: SIMPLE_JSON_OBJECT)
			-- Append object to end of array
		require
			valid_object: attached a_value
		do
			json_array.add (a_value.internal_json_object)
		ensure
			count_increased: count = old count + 1
		end

	append_array (a_value: SIMPLE_JSON_ARRAY)
			-- Append array to end of array
		require
			valid_array: attached a_value
		do
			json_array.add (a_value.internal_json_array)
		ensure
			count_increased: count = old count + 1
		end

feature -- Modification (Insert/Remove)

	insert_string_at (a_index: INTEGER; a_value: STRING)
			-- Insert string value at index (1-based)
			-- All elements at and after a_index will be shifted right
		require
			valid_index: a_index >= 1 and a_index <= count + 1
		local
			l_new_array: JSON_ARRAY
			i: INTEGER
		do
			-- Create a new array and rebuild with insertion
			create l_new_array.make_empty
			from i := 1
			until i > count + 1
			loop
				if i = a_index then
					l_new_array.add (create {JSON_STRING}.make_from_string (a_value))
				end
				if i <= count then
					l_new_array.add (json_array.i_th (i))
				end
				i := i + 1
			end
			json_array := l_new_array
		ensure
			count_increased: count = old count + 1
		end

	insert_integer_at (a_index: INTEGER; a_value: INTEGER)
			-- Insert integer value at index (1-based)
			-- All elements at and after a_index will be shifted right
		require
			valid_index: a_index >= 1 and a_index <= count + 1
		local
			l_new_array: JSON_ARRAY
			i: INTEGER
		do
			-- Create a new array and rebuild with insertion
			create l_new_array.make_empty
			from i := 1
			until i > count + 1
			loop
				if i = a_index then
					l_new_array.add (create {JSON_NUMBER}.make_integer (a_value))
				end
				if i <= count then
					l_new_array.add (json_array.i_th (i))
				end
				i := i + 1
			end
			json_array := l_new_array
		ensure
			count_increased: count = old count + 1
		end

	remove_at (a_index: INTEGER)
			-- Remove element at index (1-based)
		require
			valid_index: valid_index (a_index)
		local
			l_new_array: JSON_ARRAY
			i: INTEGER
		do
			-- Create a new array and rebuild without the removed element
			create l_new_array.make_empty
			from i := 1
			until i > count
			loop
				if i /= a_index then
					l_new_array.add (json_array.i_th (i))
				end
				i := i + 1
			end
			json_array := l_new_array
		ensure
			count_decreased: count = old count - 1
		end

	clear
			-- Remove all elements from array
		do
			create json_array.make_empty
		ensure
			is_empty: is_empty
		end

feature -- Operations

	json_clone: SIMPLE_JSON_ARRAY
			-- Create an independent copy of this array
		local
			l_json_string: STRING
			l_parser: JSON_PARSER
		do
			-- Serialize to JSON string then parse back
			l_json_string := to_json_string
			create l_parser.make_with_string (l_json_string)
			l_parser.parse_content

			if l_parser.is_parsed and then l_parser.is_valid then
				if attached {JSON_ARRAY} l_parser.parsed_json_value as l_arr then
					create Result.make_from_json (l_arr)
				else
					-- Fallback to empty array
					create Result.make_empty
				end
			else
				-- Fallback to empty array
				create Result.make_empty
			end
		ensure
			result_exists: attached Result
			independent: Result /= Current
		end

feature -- Type checking

	is_string: BOOLEAN = False
	is_number: BOOLEAN = False
	is_integer: BOOLEAN = False
	is_real: BOOLEAN = False
	is_boolean: BOOLEAN = False
	is_null: BOOLEAN = False
	is_object: BOOLEAN = False
	is_array: BOOLEAN = True

feature -- Conversion

	to_json_string: STRING
			-- Convert to JSON string representation
		do
			Result := json_array.representation
		end

feature -- Output

	to_pretty_string (a_indent_level: INTEGER): STRING
			-- <Precursor>
		local
			l_first: BOOLEAN
			l_index: INTEGER
			l_wrapper: SIMPLE_JSON_VALUE
		do
			if json_array.is_empty then
				Result := "[]"
			else
				create Result.make_empty
				Result.append_character ('[')
				Result.append_character ('%N')

				l_first := True
				from
					l_index := 1
				until
					l_index > json_array.count
				loop
					if not l_first then
						Result.append_character (',')
						Result.append_character ('%N')
					end
					Result.append (indent_string (a_indent_level + 1))

					-- Wrap the JSON_VALUE and call its pretty print
					l_wrapper := wrap_json_value (json_array.i_th (l_index))
					Result.append (l_wrapper.to_pretty_string (a_indent_level + 1))

					l_first := False
					l_index := l_index + 1
				end

				Result.append_character ('%N')
				Result.append (indent_string (a_indent_level))
				Result.append_character (']')
			end
		end

feature {NONE} -- Implementation

	wrap_json_value (a_json_value: JSON_VALUE): SIMPLE_JSON_VALUE
			-- Wrap a JSON_VALUE in appropriate SIMPLE_JSON_* type
		require
			valid_value: attached a_json_value
		do
			if attached {JSON_OBJECT} a_json_value as l_obj then
				create {SIMPLE_JSON_OBJECT} Result.make_from_json (l_obj)
			elseif attached {JSON_ARRAY} a_json_value as l_arr then
				create {SIMPLE_JSON_ARRAY} Result.make_from_json (l_arr)
			elseif attached {JSON_STRING} a_json_value as l_str then
				create {SIMPLE_JSON_STRING} Result.make (l_str.unescaped_string_8)
			elseif attached {JSON_NUMBER} a_json_value as l_num then
				if l_num.is_integer then
					create {SIMPLE_JSON_INTEGER} Result.make (l_num.integer_64_item.to_integer_32)
				else
					create {SIMPLE_JSON_REAL} Result.make (l_num.real_64_item)
				end
			elseif attached {JSON_BOOLEAN} a_json_value as l_bool then
				create {SIMPLE_JSON_BOOLEAN} Result.make (l_bool.item)
			elseif attached {JSON_NULL} a_json_value then
				create {SIMPLE_JSON_NULL} Result.make
			else
				-- Fallback to null
				create {SIMPLE_JSON_NULL} Result.make
			end
		ensure
			result_exists: attached Result
		end

feature {SIMPLE_JSON_OBJECT, SIMPLE_JSON_ARRAY, JSON_BUILDER} -- Implementation Access

	internal_json_array: JSON_ARRAY
			-- Direct access to underlying eJSON array for internal use
		do
			Result := json_array
		end

feature {NONE} -- Implementation

	json_array: JSON_ARRAY
			-- Underlying eJSON array

invariant
	has_array: attached json_array

end
