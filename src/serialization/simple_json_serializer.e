note
	description: "[
		Reflection-based JSON serializer for automatic object-to-JSON conversion.
		Uses simple_reflection to introspect objects and convert them to JSON.

		Usage:
			serializer: SIMPLE_JSON_SERIALIZER
			create serializer
			json_obj := serializer.to_json (my_object)

		Supports:
			- Basic types: STRING, INTEGER, REAL, BOOLEAN
			- Nested objects (recursive serialization)
			- Arrays/lists of objects
			- SIMPLE_DATETIME for date/time fields
	]"
	author: "Larry Rix with Claude"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_JSON_SERIALIZER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize serializer.
		do
			create excluded_fields.make (10)
			-- Exclude common internal fields
			excluded_fields.extend ("internal_")
		ensure
			excluded_fields_created: excluded_fields /= Void
		end

feature -- Serialization

	to_json (a_object: ANY): SIMPLE_JSON_OBJECT
			-- Convert `a_object` to JSON using reflection.
		require
			object_exists: a_object /= Void
		local
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field_names: ARRAYED_LIST [STRING_32]
			l_name: STRING_32
			l_value: detachable ANY
			i: INTEGER
		do
			create Result.make
			create l_reflected.make (a_object)
			l_field_names := l_reflected.field_names

			from i := 1 until i > l_field_names.count loop
				l_name := l_field_names [i]
				if not is_excluded (l_name) then
					l_value := l_reflected.field_value (l_name)
					add_field_to_json (Result, l_name, l_value)
				end
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
		end

	to_json_string (a_object: ANY): STRING_32
			-- Convert `a_object` to JSON string.
		require
			object_exists: a_object /= Void
		do
			Result := to_json (a_object).to_json_string
		ensure
			result_exists: Result /= Void
		end

feature -- Configuration

	exclude_field (a_prefix: STRING)
			-- Exclude fields starting with `a_prefix` from serialization.
		require
			prefix_exists: a_prefix /= Void
			prefix_not_empty: not a_prefix.is_empty
		do
			excluded_fields.extend (a_prefix)
		ensure
			field_excluded: excluded_fields.has (a_prefix)
		end

	clear_exclusions
			-- Clear all field exclusions.
		do
			excluded_fields.wipe_out
		ensure
			no_exclusions: excluded_fields.is_empty
		end

feature {NONE} -- Implementation

	excluded_fields: ARRAYED_LIST [STRING]
			-- Field name prefixes to exclude from serialization.

	is_excluded (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Should field `a_name` be excluded?
		local
			l_name_8: STRING_8
		do
			l_name_8 := a_name.to_string_8
			across excluded_fields as ic loop
				if l_name_8.starts_with (ic) then
					Result := True
				end
			end
		end

	add_field_to_json (a_json: SIMPLE_JSON_OBJECT; a_name: READABLE_STRING_GENERAL; a_value: detachable ANY)
			-- Add field `a_name` with `a_value` to `a_json`.
		require
			json_exists: a_json /= Void
			name_exists: a_name /= Void
		local
			l_name: STRING_32
		do
			l_name := a_name.to_string_32
			if a_value = Void then
				a_json.put_null (l_name).do_nothing
			elseif attached {READABLE_STRING_GENERAL} a_value as al_l_str then
				a_json.put_string (l_str.to_string_32, l_name).do_nothing
			elseif attached {INTEGER_64_REF} a_value as al_l_int then
				a_json.put_integer (l_int.item, l_name).do_nothing
			elseif attached {INTEGER_32_REF} a_value as al_l_int32 then
				a_json.put_integer (l_int32.item, l_name).do_nothing
			elseif attached {INTEGER_REF} a_value as al_l_int_ref then
				a_json.put_integer (l_int_ref.item, l_name).do_nothing
			elseif attached {NATURAL_64_REF} a_value as al_l_nat then
				a_json.put_integer (l_nat.item.to_integer_64, l_name).do_nothing
			elseif attached {REAL_64_REF} a_value as al_l_real then
				a_json.put_real (l_real.item, l_name).do_nothing
			elseif attached {REAL_32_REF} a_value as al_l_real32 then
				a_json.put_real (l_real32.item, l_name).do_nothing
			elseif attached {BOOLEAN_REF} a_value as al_l_bool then
				a_json.put_boolean (l_bool.item, l_name).do_nothing
			elseif attached {SIMPLE_DATE_TIME} a_value as al_l_datetime then
				a_json.put_string (l_datetime.to_iso8601, l_name).do_nothing
			elseif attached {SIMPLE_DECIMAL} a_value as al_l_decimal then
				a_json.put_decimal (l_decimal, l_name).do_nothing
			elseif attached {ITERABLE [ANY]} a_value as al_l_iterable then
				a_json.put_array (iterable_to_json_array (l_iterable), l_name).do_nothing
			else
				-- Recursively serialize nested objects
				a_json.put_object (to_json (a_value), l_name).do_nothing
			end
		end

	iterable_to_json_array (a_iterable: ITERABLE [ANY]): SIMPLE_JSON_ARRAY
			-- Convert iterable to JSON array.
		require
			iterable_exists: a_iterable /= Void
		do
			create Result.make
			across a_iterable as ic loop
				if attached ic as al_l_item then
					add_item_to_array (Result, l_item)
				else
					Result.add_null.do_nothing
				end
			end
		ensure
			result_exists: Result /= Void
		end

	add_item_to_array (a_array: SIMPLE_JSON_ARRAY; a_item: ANY)
			-- Add `a_item` to `a_array`.
		require
			array_exists: a_array /= Void
			item_exists: a_item /= Void
		do
			if attached {READABLE_STRING_GENERAL} a_item as al_l_str then
				a_array.add_string (al_l_str.to_string_32).do_nothing
			elseif attached {INTEGER_64_REF} a_item as al_l_int then
				a_array.add_integer (l_int.item).do_nothing
			elseif attached {INTEGER_32_REF} a_item as al_l_int32 then
				a_array.add_integer (l_int32.item).do_nothing
			elseif attached {INTEGER_REF} a_item as al_l_int_ref then
				a_array.add_integer (l_int_ref.item).do_nothing
			elseif attached {REAL_64_REF} a_item as al_l_real then
				a_array.add_real (l_real.item).do_nothing
			elseif attached {BOOLEAN_REF} a_item as al_l_bool then
				a_array.add_boolean (l_bool.item).do_nothing
			elseif attached {SIMPLE_DECIMAL} a_item as al_l_decimal then
				a_array.add_decimal (l_decimal).do_nothing
			elseif attached {ITERABLE [ANY]} a_item as al_l_iterable then
				a_array.add_array (iterable_to_json_array (l_iterable)).do_nothing
			else
				-- Recursively serialize nested objects
				a_array.add_object (to_json (a_item)).do_nothing
			end
		end

invariant
	excluded_fields_exists: excluded_fields /= Void

end
