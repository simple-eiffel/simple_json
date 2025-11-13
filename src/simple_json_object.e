note
    description: "Wrapper for JSON objects - provides simple access to JSON data with enhanced operations"
    author: "Larry Rix"
    date: "November 12, 2025"
    revision: "5"
	EIS: "name=SIMPLE_JSON User Guide",
		 "src=file:///${SYSTEM_PATH}/docs/user-guide.html",
		 "protocol=uri",
		 "tag=documentation, user-guide, api"

class
    SIMPLE_JSON_OBJECT

inherit
    SIMPLE_JSON_CONTAINER

    JSON_TYPE_OBJECT

create
    make_empty,
    make_from_json

feature {NONE} -- Initialization

    make_empty
            -- Create an empty JSON object
        do
            create json_object.make_with_capacity (10)
        end

    make_from_json (a_json_object: JSON_OBJECT)
            -- Create from an eJSON JSON_OBJECT
        require
            valid_object: a_json_object /= Void
        do
            json_object := a_json_object
        ensure
            set: json_object = a_json_object
        end

feature -- Status Report

    has_key (a_key: STRING): BOOLEAN
            -- Does object contain this key?
        require
            not_empty_key: not a_key.is_empty
        do
            Result := json_object.has_key (a_key)
        end

    count: INTEGER
            -- Number of key-value pairs
        do
            Result := json_object.count
        end

feature -- Access

    string (a_key: STRING): detachable STRING
            -- Get string value for key
        require
            valid_key: a_key /= Void and then not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_STRING} l_value as l_str then
                    Result := l_str.unescaped_string_8
                end
            end
        end

    integer (a_key: STRING): INTEGER
            -- Get integer value for key
        require
            not_empty_key: not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_NUMBER} l_value as l_num then
                    if l_num.is_integer then
                        Result := l_num.integer_64_item.to_integer_32
                    elseif l_num.is_real then
                        -- Convert real to integer (truncate)
                        Result := l_num.real_64_item.truncated_to_integer
                    end
                end
            end
        end

    boolean (a_key: STRING): BOOLEAN
            -- Get boolean value for key
        require
            valid_key: a_key /= Void and then not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_BOOLEAN} l_value as l_bool then
                    Result := l_bool.item
                end
            end
        end

    real (a_key: STRING): REAL_64
            -- Get real/double value for key
        require
            not_empty_key: not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_NUMBER} l_value as l_num then
                    if l_num.is_real then
                        Result := l_num.real_64_item
                    elseif l_num.is_integer then
                            -- Convert integer to real
                        Result := l_num.integer_64_item.to_double
                    end
                end
            end
        end

    array (a_key: STRING): detachable SIMPLE_JSON_ARRAY
            -- Get array value for key
        require
            valid_key: a_key /= Void and then not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_ARRAY} l_value as l_arr then
                    create Result.make_from_json (l_arr)
                end
            end
        end

    object (a_key: STRING): detachable SIMPLE_JSON_OBJECT
            -- Get nested object for key
        require
            valid_key: a_key /= Void and then not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                if attached {JSON_OBJECT} l_value as l_obj then
                    create Result.make_from_json (l_obj)
                end
            end
        end

    item_at_key (a_key: STRING): detachable SIMPLE_JSON_VALUE
            -- Get value for key wrapped in appropriate SIMPLE_JSON_VALUE type
        require
            not_empty_key: not a_key.is_empty
        do
            if attached json_object.item (a_key) as l_value then
                Result := wrap_json_value (l_value)
            end
        end

feature -- Modification (Basic)

    put_string (a_key: STRING; a_value: STRING)
            -- Set string value for key (adds new or updates existing)
        require
            not_empty_key: not a_key.is_empty
        do
            put_or_replace (a_key, create {JSON_STRING}.make_from_string (a_value))
        ensure
            key_exists: has_key (a_key)
            value_set: attached string (a_key) as s implies s.is_equal (a_value)
        end

    put_integer (a_key: STRING; a_value: INTEGER)
            -- Set integer value for key
        require
            not_empty_key: not a_key.is_empty
        do
            put_or_replace (a_key, create {JSON_NUMBER}.make_integer (a_value))
        ensure
            key_exists: has_key (a_key)
        end

    put_boolean (a_key: STRING; a_value: BOOLEAN)
            -- Set boolean value for key
        require
            not_empty_key: not a_key.is_empty
        do
            put_or_replace (a_key, create {JSON_BOOLEAN}.make (a_value))
        ensure
            key_exists: has_key (a_key)
        end

    put_real (a_key: STRING; a_value: REAL_64)
            -- Set real value for key
        require
            not_empty_key: not a_key.is_empty
        do
            put_or_replace (a_key, create {JSON_NUMBER}.make_real (a_value))
        ensure
            key_exists: has_key (a_key)
        end

    put_object (a_key: STRING; a_value: SIMPLE_JSON_OBJECT)
            -- Set nested object for key
        require
            not_empty_key: not a_key.is_empty
            valid_object: attached a_value
        do
            put_or_replace (a_key, a_value.internal_json_object)
        ensure
            key_exists: has_key (a_key)
        end

    put_array (a_key: STRING; a_value: SIMPLE_JSON_ARRAY)
            -- Set array for key
        require
            not_empty_key: not a_key.is_empty
            valid_array: attached a_value
        do
            put_or_replace (a_key, a_value.internal_json_array)
        ensure
            key_exists: has_key (a_key)
        end

    put_value (a_key: STRING; a_value: SIMPLE_JSON_VALUE)
            -- Set value for key (works with any SIMPLE_JSON_VALUE type)
        require
            not_empty_key: not a_key.is_empty
            valid_value: attached a_value
        do
            put_or_replace (a_key, unwrap_value (a_value))
        ensure
            key_exists: has_key (a_key)
        end

feature -- Modification (Advanced)

    merge (a_other: SIMPLE_JSON_OBJECT)
            -- Merge another object into this one
            -- Existing keys will be overwritten by values from a_other
        require
            valid_object: attached a_other
        local
            l_keys: ARRAY [JSON_STRING]
            l_other_obj: JSON_OBJECT
            l_key: JSON_STRING
            l_key_string: STRING
        do
            l_other_obj := a_other.internal_json_object
            l_keys := l_other_obj.current_keys
            across l_keys as ic loop
                l_key := ic.item
                l_key_string := l_key.item
                if attached l_other_obj.item (l_key) as l_value then
                    put_or_replace (l_key_string, l_value)
                end
            end
        end

    remove_key (a_key: STRING)
            -- Remove key from object
        require
            not_empty_key: not a_key.is_empty
        do
            json_object.remove (a_key)
        ensure
            key_removed: not has_key (a_key)
        end

    rename_key (a_old_key: STRING; a_new_key: STRING)
            -- Rename a key
        require
            not_empty_old_key: not a_old_key.is_empty
            not_empty_new_key: not a_new_key.is_empty
            has_old_key: has_key (a_old_key)
        do
            if attached json_object.item (a_old_key) as l_value then
                json_object.put (l_value, a_new_key)
                json_object.remove (a_old_key)
            end
        ensure
            old_key_removed: not has_key (a_old_key)
            new_key_exists: has_key (a_new_key)
        end

feature -- Conversion

    to_json_string: STRING
            -- Convert to JSON string representation
        do
            Result := json_object.representation
        end

feature -- Output

    to_pretty_string (a_indent_level: INTEGER): STRING
            -- <Precursor>
        local
            l_first: BOOLEAN
            l_keys: ARRAY [JSON_STRING]
            l_key: JSON_STRING
            l_key_string: STRING
            l_wrapper: SIMPLE_JSON_VALUE
        do
            if json_object.is_empty then
                Result := "{}"
            else
                create Result.make_empty
                Result.append_character ('{')
                Result.append_character ('%N')

                l_keys := json_object.current_keys
                l_first := True
                across l_keys as ic_key loop
                    if not l_first then
                        Result.append_character (',')
                        Result.append_character ('%N')
                    end
                    Result.append (indent_string (a_indent_level + 1))
                    Result.append_character ('%"')
                    l_key := ic_key.item
                    l_key_string := l_key.item
                    Result.append (l_key_string)
                    Result.append_character ('%"')
                    Result.append_character (':')
                    Result.append_character (' ')

                    if attached json_object.item (l_key) as l_json_value then
                        l_wrapper := wrap_json_value (l_json_value)
                        Result.append (l_wrapper.to_pretty_string (a_indent_level + 1))
                    end

                    l_first := False
                end

                Result.append_character ('%N')
                Result.append (indent_string (a_indent_level))
                Result.append_character ('}')
            end
        end

feature {NONE} -- Factory Implementation (from SIMPLE_JSON_CONTAINER)

    create_from_parsed_value (a_parsed: JSON_VALUE): SIMPLE_JSON_OBJECT
            -- Factory method to create object from parsed JSON
        do
            if attached {JSON_OBJECT} a_parsed as l_obj then
                create Result.make_from_json (l_obj)
            else
                create Result.make_empty
            end
        end

    create_empty_container: SIMPLE_JSON_OBJECT
            -- Factory method to create empty object
        do
            create Result.make_empty
        end

feature {NONE} -- Implementation Helpers

    put_or_replace (a_key: STRING; a_json_value: JSON_VALUE)
            -- Put or replace value in internal object
        require
            not_empty_key: not a_key.is_empty
            valid_value: attached a_json_value
        do
            if has_key (a_key) then
                json_object.replace (a_json_value, a_key)
            else
                json_object.put (a_json_value, a_key)
            end
        ensure
            key_exists: has_key (a_key)
        end

feature {SIMPLE_JSON_OBJECT, SIMPLE_JSON_ARRAY, SIMPLE_JSON_CONTAINER, JSON_BUILDER, JSON_SCHEMA_VALIDATOR} -- Implementation Access

    internal_json_object: JSON_OBJECT
            -- Direct access to underlying eJSON object for internal use
        do
            Result := json_object
        end

feature -- Iteration (Agent-based traversal)

	do_all (action: PROCEDURE [SIMPLE_JSON_VALUE])
			-- Apply action to all values in this object
		require else
			action_exists: action /= Void
		local
			l_keys: ARRAY [JSON_STRING]
			l_key: STRING
		do
			l_keys := json_object.current_keys
			across l_keys as ic_key loop
				l_key := ic_key.item  -- JSON_STRING.item gives the STRING
				if attached item_at_key (l_key) as al_value then
					action.call ([al_value])
				end
			end
		end

	do_if (action: PROCEDURE [SIMPLE_JSON_VALUE];
	       test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN])
			-- Apply action to values that satisfy test
		require else
			action_exists: action /= Void
			test_exists: test /= Void
		local
			l_keys: ARRAY [JSON_STRING]
			l_key: STRING
		do
			l_keys := json_object.current_keys
			across l_keys as ic_key loop
				l_key := ic_key.item  -- JSON_STRING.item gives the STRING
				if attached item_at_key (l_key) as al_value then
					if test.item ([al_value]) then
						action.call ([al_value])
					end
				end
			end
		end

	for_all (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
			-- Do all values satisfy test?
		require else
			test_exists: test /= Void
		local
			l_keys: ARRAY [JSON_STRING]
			l_key: STRING
		do
			Result := True
			l_keys := json_object.current_keys
			across l_keys as ic_key loop
				l_key := ic_key.item
				if attached item_at_key (l_key) as al_value then
					if not test.item ([al_value]) then
						Result := False
					end
				end
			end
		ensure then
--			definition: Result implies (across current_keys as ic loop
--				attached item_at_key (ic.item) as al_v implies test.item ([al_v]) end)
		end

	there_exists (test: FUNCTION [SIMPLE_JSON_VALUE, BOOLEAN]): BOOLEAN
			-- Does at least one value satisfy test?
		require else
			test_exists: test /= Void
		local
			l_keys: ARRAY [JSON_STRING]
			l_key: STRING
		do
			Result := False
			l_keys := json_object.current_keys
			across l_keys as ic_key loop
				l_key := ic_key.item
				if attached item_at_key (l_key) as al_value then
					if test.item ([al_value]) then
						Result := True
					end
				end
			end
		end

feature -- Access (helpers for traversal)

	current_keys: ARRAY [STRING]
			-- All keys in this object as strings
		local
			l_json_keys: ARRAY [JSON_STRING]
			l_result: ARRAYED_LIST [STRING]
		do
			l_json_keys := json_object.current_keys
			create l_result.make (l_json_keys.count)
			across l_json_keys as ic_key loop
				l_result.extend (ic_key.item)
			end
			Result := l_result.to_array
		ensure
			result_exists: Result /= Void
			count_matches: Result.count = count
		end


    json_object: JSON_OBJECT
            -- Underlying eJSON object

end
