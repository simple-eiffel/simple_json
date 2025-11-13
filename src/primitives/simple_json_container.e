deferred class
    SIMPLE_JSON_CONTAINER

inherit
    SIMPLE_JSON_VALUE

feature -- Status Report

    count: INTEGER
            -- Number of elements
        deferred
        ensure
            non_negative: Result >= 0
        end

    is_empty: BOOLEAN
            -- Is container empty?
        do
            Result := count = 0
        ensure
            definition: Result = (count = 0)
        end

feature -- Operations

    json_clone: like Current
            -- Create independent copy via serialization
        local
            l_json_string: STRING
            l_parser: JSON_PARSER
        do
            l_json_string := to_json_string
            create l_parser.make_with_string (l_json_string)
            l_parser.parse_content

            if l_parser.is_parsed and then l_parser.is_valid then
                if attached l_parser.parsed_json_value as al_parsed then
                    Result := create_from_parsed_value (al_parsed)
                else
                    Result := create_empty_container
                end
            else
                Result := create_empty_container
            end
        ensure
            result_exists: attached Result
            independent: Result /= Current
        end

feature {NONE} -- Factory (Deferred)

    create_from_parsed_value (a_parsed: JSON_VALUE): like Current
            -- Factory method to create container from parsed JSON
        require
            valid_parsed: attached a_parsed
        deferred
        ensure
            result_exists: attached Result
        end

    create_empty_container: like Current
            -- Factory method to create empty container
        deferred
        ensure
            result_exists: attached Result
        end

feature -- Iteration

    do_all (action: PROCEDURE [SIMPLE_JSON_VALUE])
            -- Apply action to all items
        deferred
        end

    do_if (action: PROCEDURE [SIMPLE_JSON_VALUE];
           test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN])
            -- Apply action to items matching test
        deferred
        end

    for_all (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
            -- Do all items satisfy test?
        deferred
        end

    there_exists (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
            -- Does at least one item satisfy test?
        deferred
        end

feature {SIMPLE_JSON_VALUE, JSON_BUILDER, JSON_SCHEMA_VALIDATOR} -- Implementation

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
                create {SIMPLE_JSON_NULL} Result.make
            end
        ensure
            result_exists: attached Result
        end

    unwrap_value (a_value: SIMPLE_JSON_VALUE): JSON_VALUE
            -- Convert SIMPLE_JSON_VALUE to underlying JSON_VALUE
        require
            valid_value: attached a_value
        do
            if attached {SIMPLE_JSON_OBJECT} a_value as al_obj then
                Result := al_obj.internal_json_object
            elseif attached {SIMPLE_JSON_ARRAY} a_value as al_arr then
                Result := al_arr.internal_json_array
            elseif attached {SIMPLE_JSON_STRING} a_value as al_str then
                create {JSON_STRING} Result.make_from_string (al_str.value)
            elseif attached {SIMPLE_JSON_INTEGER} a_value as al_int then
                create {JSON_NUMBER} Result.make_integer (al_int.value)
            elseif attached {SIMPLE_JSON_REAL} a_value as al_real then
                create {JSON_NUMBER} Result.make_real (al_real.value)
            elseif attached {SIMPLE_JSON_BOOLEAN} a_value as al_bool then
                create {JSON_BOOLEAN} Result.make (al_bool.value)
            elseif attached {SIMPLE_JSON_NULL} a_value then
                create {JSON_NULL} Result
            else
                create {JSON_NULL} Result
            end
        ensure
            result_exists: attached Result
        end

end
