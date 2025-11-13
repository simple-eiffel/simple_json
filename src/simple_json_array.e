note
    description: "Wrapper for JSON arrays - provides simple access to array elements with enhanced operations"
    author: "Larry Rix"
    date: "November 12, 2025"
    revision: "5"

class
    SIMPLE_JSON_ARRAY

inherit
    SIMPLE_JSON_CONTAINER

    JSON_TYPE_ARRAY

create
    make_empty,
    make_from_json_array

feature {NONE} -- Initialization

    make_empty
            -- Create an empty JSON array
        do
            create json_array.make_empty
        end

    make_from_json_array (a_json_array: JSON_ARRAY)
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
                    create Result.make_from_json_object (l_obj)
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
                    create Result.make_from_json_array (l_arr)
                end
            end
        end

    item_at (a_index: INTEGER): detachable SIMPLE_JSON_VALUE
            -- Get value at index wrapped in appropriate SIMPLE_JSON_VALUE type
        require
            valid_index: valid_index (a_index)
        do
            if attached json_array.i_th (a_index) as l_value then
                Result := wrap_json_value (l_value)
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

    add_value (a_value: SIMPLE_JSON_VALUE)
            -- Add value to end of array (works with any SIMPLE_JSON_VALUE type)
        require
            valid_value: attached a_value
        do
            json_array.add (unwrap_value (a_value))
        ensure
            count_increased: count = old count + 1
        end

feature -- Modification (Insert/Remove)

    insert_string_at (a_index: INTEGER; a_value: STRING)
            -- Insert string value at index (1-based)
            -- All elements at and after a_index will be shifted right
        require
            valid_index: a_index >= 1 and a_index <= count + 1
        do
            insert_json_value_at (a_index, create {JSON_STRING}.make_from_string (a_value))
        ensure
            count_increased: count = old count + 1
        end

    insert_integer_at (a_index: INTEGER; a_value: INTEGER)
            -- Insert integer value at index (1-based)
            -- All elements at and after a_index will be shifted right
        require
            valid_index: a_index >= 1 and a_index <= count + 1
        do
            insert_json_value_at (a_index, create {JSON_NUMBER}.make_integer (a_value))
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

feature {NONE} -- Factory Implementation (from SIMPLE_JSON_CONTAINER)

    create_from_parsed_value (a_parsed: JSON_VALUE): SIMPLE_JSON_ARRAY
            -- Factory method to create array from parsed JSON
        do
            if attached {JSON_ARRAY} a_parsed as l_arr then
                create Result.make_from_json_array (l_arr)
            else
                create Result.make_empty
            end
        end

    create_empty_container: SIMPLE_JSON_ARRAY
            -- Factory method to create empty array
        do
            create Result.make_empty
        end

feature {NONE} -- Implementation Helpers

    insert_json_value_at (a_index: INTEGER; a_json_value: JSON_VALUE)
            -- Insert JSON value at index
        require
            valid_index: a_index >= 1 and a_index <= count + 1
            valid_value: attached a_json_value
        local
            l_new_array: JSON_ARRAY
            i: INTEGER
        do
            create l_new_array.make_empty
            from i := 1
            until i > count + 1
            loop
                if i = a_index then
                    l_new_array.add (a_json_value)
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

feature {SIMPLE_JSON_OBJECT, SIMPLE_JSON_ARRAY, SIMPLE_JSON_CONTAINER, JSON_BUILDER, JSON_SCHEMA_VALIDATOR} -- Implementation Access

    internal_json_array: JSON_ARRAY
            -- Direct access to underlying eJSON array for internal use
        do
            Result := json_array
        end

feature -- Iteration (Agent-based traversal)

	do_all (action: PROCEDURE [SIMPLE_JSON_VALUE])
			-- Apply action to all items in this array
		require else
			action_exists: action /= Void
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > count
			loop
				if attached item_at (i) as al_item then
					action.call ([al_item])
				end
				i := i + 1
			end
		end

	do_if (action: PROCEDURE [SIMPLE_JSON_VALUE];
	       test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN])
			-- Apply action to items that satisfy test
		require else
			action_exists: action /= Void
			test_exists: test /= Void
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > count
			loop
				if attached item_at (i) as al_item then
					if test.item ([al_item]) then
						action.call ([al_item])
					end
				end
				i := i + 1
			end
		end

	for_all (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
			-- Do all items satisfy test?
		require else
			test_exists: test /= Void
		local
			i: INTEGER
		do
			Result := True
			from
				i := 1
			until
				i > count or not Result
			loop
				if attached item_at (i) as al_item then
					Result := test.item ([al_item])
				end
				i := i + 1
			end
		end

	there_exists (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
			-- Does at least one item satisfy test?
		require else
			test_exists: test /= Void
		local
			i: INTEGER
		do
			Result := False
			from
				i := 1
			until
				i > count or Result
			loop
				if attached item_at (i) as al_item then
					Result := test.item ([al_item])
				end
				i := i + 1
			end
		end


    json_array: JSON_ARRAY
            -- Underlying eJSON array

invariant
    has_array: attached json_array

end
