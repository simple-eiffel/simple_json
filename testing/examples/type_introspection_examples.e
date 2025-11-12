note
	description: "Examples demonstrating type introspection usage"
	author: "Larry Rix"
	date: "November 12, 2025"

class
	TYPE_INTROSPECTION_EXAMPLES

feature -- Basic Type Checking Examples

	example_basic_type_check
			-- Basic example of checking value type
		local
			str: SIMPLE_JSON_STRING
			int: SIMPLE_JSON_INTEGER
		do
			create str.make ("Hello")
			create int.make (42)

			assert ("value_is_string", str.is_string)
			assert ("value_is_integer", int.is_integer)
			assert ("value_is_number", int.is_number)
		end

	example_distinguishing_numeric_types
			-- Example showing how to distinguish between integers and reals
		local
			int: SIMPLE_JSON_INTEGER
			real: SIMPLE_JSON_REAL
		do
			create int.make (100)
			create real.make (99.5)

				-- Both are numbers
			check int.is_number and real.is_number end

				-- But we can distinguish them
			if int.is_integer then
				print ("Processing integer: " + int.value.out + "%N")
			end

			if real.is_real then
				print ("Processing real with decimals: " + real.value.out + "%N")
			end
		end

feature -- Defensive Programming Examples

	example_safe_value_extraction
			-- Example of using type checks before extraction
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make_empty
			obj.put_string ("name", "Alice")
			obj.put_integer ("age", 30)

				-- Check type before extraction
			if obj.is_object then
				print ("Successfully identified as object%N")
				print ("Name: " + obj.string ("name") + "%N")
				print ("Age: " + obj.integer ("age").out + "%N")
			else
				print ("Error: Expected object but got something else%N")
			end
		end

	example_handling_unknown_values
			-- Example of handling values of unknown type
		local
			value: SIMPLE_JSON_VALUE
			obj: SIMPLE_JSON_OBJECT
			str: SIMPLE_JSON_STRING
		do
				-- Suppose we have a value of unknown type
			create obj.make_empty
			value := obj

				-- Check what it is and handle accordingly
			if value.is_object then
				print ("Value is an object%N")
			elseif value.is_array then
				print ("Value is an array%N")
			elseif value.is_string then
				print ("Value is a string%N")
			elseif value.is_integer then
				print ("Value is an integer%N")
			elseif value.is_real then
				print ("Value is a real number%N")
			elseif value.is_boolean then
				print ("Value is a boolean%N")
			elseif value.is_null then
				print ("Value is null%N")
			end
		end

feature -- Error Handling Examples

	example_type_validation
			-- Example of validating expected types
		local
			obj: SIMPLE_JSON_OBJECT
		do
			create obj.make_empty
			obj.put_string ("config_file", "settings.json")

				-- Validate that we got an object
			if not obj.is_object then
				print ("ERROR: Expected JSON object for configuration%N")
					-- Handle error appropriately
			else
					-- Safe to process as object
				print ("Configuration loaded: " + obj.string ("config_file") + "%N")
			end
		end

	example_providing_meaningful_errors
			-- Example of providing helpful error messages
		local
			value: SIMPLE_JSON_VALUE
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make_empty
			value := arr

				-- Try to process as object, provide clear error if wrong type
			if value.is_object then
					-- Process as object
				print ("Processing object%N")
			else
				if value.is_array then
					print ("Error: Expected object but got array%N")
				elseif value.is_string then
					print ("Error: Expected object but got string%N")
				else
					print ("Error: Unexpected type%N")
				end
			end
		end

feature -- Complex Type Checking Examples

	example_nested_structure_validation
			-- Example of validating nested JSON structures
		local
			obj: SIMPLE_JSON_OBJECT
			nested: detachable SIMPLE_JSON_OBJECT
		do
			create obj.make_empty

				-- Build nested structure
			create nested.make_empty
			nested.put_string ("city", "NYC")
			nested.put_string ("state", "NY")

				-- In real code, we'd add nested to obj
				-- For now, just demonstrate validation

			if obj.is_object then
				print ("Root is object: OK%N")
				if attached nested as n then
					if n.is_object then
						print ("Nested structure is object: OK%N")
					else
						print ("ERROR: Nested structure is not an object%N")
					end
				end
			end
		end

	example_array_element_type_checking
			-- Example of checking types of array elements
		local
			arr: SIMPLE_JSON_ARRAY
		do
			create arr.make_empty

				-- Validate it's an array
			if not arr.is_array then
				print ("ERROR: Expected array%N")
			else
				print ("Array validation: OK%N")
					-- Now we can safely iterate and process elements
			end
		end

feature -- Polymorphic Processing Examples

	example_process_any_value_type
			-- Example of processing any JSON value type polymorphically
		local
			values: ARRAY [SIMPLE_JSON_VALUE]
			i: INTEGER
		do
			create values.make_filled (create {SIMPLE_JSON_NULL}.make, 1, 3)
			values [1] := create {SIMPLE_JSON_STRING}.make ("Hello")
			values [2] := create {SIMPLE_JSON_INTEGER}.make (42)
			values [3] := create {SIMPLE_JSON_BOOLEAN}.make (True)

			from
				i := 1
			until
				i > values.count
			loop
				process_json_value (values [i])
				i := i + 1
			end
		end

	process_json_value (a_value: SIMPLE_JSON_VALUE)
			-- Process a JSON value based on its type
		do
			if a_value.is_string then
				print ("String value%N")
			elseif a_value.is_integer then
				print ("Integer value%N")
			elseif a_value.is_real then
				print ("Real value%N")
			elseif a_value.is_boolean then
				print ("Boolean value%N")
			elseif a_value.is_null then
				print ("Null value%N")
			elseif a_value.is_object then
				print ("Object value%N")
			elseif a_value.is_array then
				print ("Array value%N")
			end
		end

feature -- Pattern Matching Examples

	example_pattern_matching_style
			-- Example of pattern-matching style with type checks
		local
			value: SIMPLE_JSON_VALUE
			result_string: STRING
		do
			value := create {SIMPLE_JSON_STRING}.make ("test")

				-- Pattern-matching style handling
			if value.is_string then
				result_string := "Matched: string"
			elseif value.is_number then
				if value.is_integer then
					result_string := "Matched: integer"
				elseif value.is_real then
					result_string := "Matched: real"
				else
					result_string := "Matched: unknown number type"
				end
			elseif value.is_boolean then
				result_string := "Matched: boolean"
			elseif value.is_null then
				result_string := "Matched: null"
			elseif value.is_object then
				result_string := "Matched: object"
			elseif value.is_array then
				result_string := "Matched: array"
			else
				result_string := "Matched: unknown type"
			end

			print (result_string + "%N")
		end

end
