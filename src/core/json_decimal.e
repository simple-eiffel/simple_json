note
	description: "[
		JSON number created from SIMPLE_DECIMAL for precise decimal representation.

		Inherits JSON_NUMBER but allows creation from a decimal string,
		preserving exact precision without floating-point artifacts.

		Usage:
			local
				l_decimal: SIMPLE_DECIMAL
				l_json_num: JSON_DECIMAL
			do
				create l_decimal.make ("19.99")
				create l_json_num.make_from_decimal (l_decimal)
				-- JSON output: 19.99 (not 19.989999999999998)
			end
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_DECIMAL

inherit
	JSON_NUMBER
		redefine
			is_real
		end

create
	make_decimal,
	make_from_string

feature {NONE} -- Initialization

	make_decimal (a_decimal: SIMPLE_DECIMAL)
			-- Create from SIMPLE_DECIMAL, preserving exact string representation.
		require
			decimal_not_void: a_decimal /= Void
		do
			item := a_decimal.to_string
			numeric_type := double_type
		ensure
			item_set: item.same_string (a_decimal.to_string)
		end

	make_from_string (a_value: READABLE_STRING_8)
			-- Create from numeric string representation.
			-- Use when you have a precise string like "19.99".
		require
			value_not_empty: not a_value.is_empty
			value_is_numeric: is_valid_number_string (a_value)
		do
			item := a_value
			numeric_type := double_type
		ensure
			item_set: item.same_string (a_value)
		end

feature -- Status

	is_real: BOOLEAN = True
			-- Decimals are treated as real numbers

feature -- Validation

	is_valid_number_string (a_str: READABLE_STRING_8): BOOLEAN
			-- Is `a_str` a valid numeric string?
		local
			i: INTEGER
			c: CHARACTER
			l_has_digit: BOOLEAN
			l_has_dot: BOOLEAN
		do
			Result := True
			from
				i := 1
			until
				i > a_str.count or not Result
			loop
				c := a_str [i]
				if c.is_digit then
					l_has_digit := True
				elseif c = '.' then
					if l_has_dot then
						Result := False -- Multiple dots
					end
					l_has_dot := True
				elseif c = '-' or c = '+' then
					if i /= 1 then
						Result := False -- Sign not at start
					end
				else
					Result := False -- Invalid character
				end
				i := i + 1
			end
			Result := Result and l_has_digit
		end

end
