note
	description: "Base test class with high-level generic assertions"
	testing: "type/manual"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/testing/test_set_base.html"

deferred class
	TEST_SET_BASE

inherit
	EQA_TEST_SET
		undefine
			assert
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

feature -- Boolean assertions

	refute (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
			-- Assert that `a_condition' is False
		require
			a_tag_not_void: a_tag /= Void
		do
			assert (a_tag, not a_condition)
		end

	assert_true (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
			-- Assert that `a_condition' is True
		require
			a_tag_not_void: a_tag /= Void
		do
			assert (a_tag, a_condition)
		end

	assert_false (a_tag: READABLE_STRING_GENERAL; a_condition: BOOLEAN)
			-- Assert that `a_condition' is False
		require
			a_tag_not_void: a_tag /= Void
		do
			assert (a_tag, not a_condition)
		end

feature -- Numeric comparisons (INTEGER)

	assert_greater_than (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: INTEGER)
			-- Assert that `a_value' > `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" > ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value > a_threshold)
		end

	assert_greater_or_equal (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: INTEGER)
			-- Assert that `a_value' >= `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" >= ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value >= a_threshold)
		end

	assert_less_than (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: INTEGER)
			-- Assert that `a_value' < `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" < ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value < a_threshold)
		end

	assert_less_or_equal (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: INTEGER)
			-- Assert that `a_value' <= `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" <= ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value <= a_threshold)
		end

	assert_in_range (a_tag: READABLE_STRING_GENERAL; a_value, a_min, a_max: INTEGER)
			-- Assert that `a_min' <= `a_value' <= `a_max'
		require
			a_tag_not_void: a_tag /= Void
			valid_range: a_min <= a_max
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" in [")
			msg.append_string_general (a_min.out)
			msg.append_string_general ("..")
			msg.append_string_general (a_max.out)
			msg.append_string_general ("]")
			assert (msg, a_value >= a_min and a_value <= a_max)
		end

	assert_positive (a_tag: READABLE_STRING_GENERAL; a_value: INTEGER)
			-- Assert that `a_value' > 0
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected positive, got ")
			msg.append_string_general (a_value.out)
			assert (msg, a_value > 0)
		end

	assert_negative (a_tag: READABLE_STRING_GENERAL; a_value: INTEGER)
			-- Assert that `a_value' < 0
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected negative, got ")
			msg.append_string_general (a_value.out)
			assert (msg, a_value < 0)
		end

	assert_zero (a_tag: READABLE_STRING_GENERAL; a_value: INTEGER)
			-- Assert that `a_value' = 0
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected zero, got ")
			msg.append_string_general (a_value.out)
			assert (msg, a_value = 0)
		end

	assert_non_zero (a_tag: READABLE_STRING_GENERAL; a_value: INTEGER)
			-- Assert that `a_value' /= 0
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected non-zero, got ")
			msg.append_string_general (a_value.out)
			assert (msg, a_value /= 0)
		end

feature -- Numeric comparisons (REAL)

	assert_reals_equal (a_tag: READABLE_STRING_GENERAL; a_expected, a_actual, a_epsilon: REAL_64)
			-- Assert that |`a_expected' - `a_actual'| <= `a_epsilon'
		require
			a_tag_not_void: a_tag /= Void
			epsilon_positive: a_epsilon >= 0.0
		local
			msg: STRING_32
		do
			create msg.make (80)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_expected.out)
			msg.append_string_general (" ± ")
			msg.append_string_general (a_epsilon.out)
			msg.append_string_general (", got ")
			msg.append_string_general (a_actual.out)
			assert (msg, (a_expected - a_actual).abs <= a_epsilon)
		end

	assert_real_greater_than (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: REAL_64)
			-- Assert that `a_value' > `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" > ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value > a_threshold)
		end

	assert_real_less_than (a_tag: READABLE_STRING_GENERAL; a_value, a_threshold: REAL_64)
			-- Assert that `a_value' < `a_threshold'
		require
			a_tag_not_void: a_tag /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" < ")
			msg.append_string_general (a_threshold.out)
			assert (msg, a_value < a_threshold)
		end

	assert_real_in_range (a_tag: READABLE_STRING_GENERAL; a_value, a_min, a_max: REAL_64)
			-- Assert that `a_min' <= `a_value' <= `a_max'
		require
			a_tag_not_void: a_tag /= Void
			valid_range: a_min <= a_max
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected ")
			msg.append_string_general (a_value.out)
			msg.append_string_general (" in [")
			msg.append_string_general (a_min.out)
			msg.append_string_general ("..")
			msg.append_string_general (a_max.out)
			msg.append_string_general ("]")
			assert (msg, a_value >= a_min and a_value <= a_max)
		end

feature -- String assertions

	assert_string_contains (a_tag: READABLE_STRING_GENERAL; a_string, a_substring: READABLE_STRING_GENERAL)
			-- Assert that `a_string' contains `a_substring'
		require
			a_tag_not_void: a_tag /= Void
			a_string_attached: a_string /= Void
			a_substring_attached: a_substring /= Void
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected string to contain '")
			msg.append_string_general (a_substring)
			msg.append_character ('%'')
			assert (msg, a_string.has_substring (a_substring))
		end

	assert_string_starts_with (a_tag: READABLE_STRING_GENERAL; a_string, a_prefix: READABLE_STRING_GENERAL)
			-- Assert that `a_string' starts with `a_prefix'
		require
			a_tag_not_void: a_tag /= Void
			a_string_attached: a_string /= Void
			a_prefix_attached: a_prefix /= Void
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected string to start with '")
			msg.append_string_general (a_prefix)
			msg.append_character ('%'')
			assert (msg, a_string.starts_with (a_prefix))
		end

	assert_string_ends_with (a_tag: READABLE_STRING_GENERAL; a_string, a_suffix: READABLE_STRING_GENERAL)
			-- Assert that `a_string' ends with `a_suffix'
		require
			a_tag_not_void: a_tag /= Void
			a_string_attached: a_string /= Void
			a_suffix_attached: a_suffix /= Void
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected string to end with '")
			msg.append_string_general (a_suffix)
			msg.append_character ('%'')
			assert (msg, a_string.ends_with (a_suffix))
		end

	assert_string_empty (a_tag: READABLE_STRING_GENERAL; a_string: READABLE_STRING_GENERAL)
			-- Assert that `a_string' is empty
		require
			a_tag_not_void: a_tag /= Void
			a_string_attached: a_string /= Void
		local
			msg: STRING_32
		do
			create msg.make (60)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected empty string, got '")
			msg.append_string_general (a_string)
			msg.append_character ('%'')
			assert (msg, a_string.is_empty)
		end

	assert_string_not_empty (a_tag: READABLE_STRING_GENERAL; a_string: READABLE_STRING_GENERAL)
			-- Assert that `a_string' is not empty
		require
			a_tag_not_void: a_tag /= Void
			a_string_attached: a_string /= Void
		local
			msg: STRING_32
		do
			create msg.make (50)
			msg.append_string_general (a_tag)
			msg.append_string_general (": expected non-empty string")
			assert (msg, not a_string.is_empty)
		end

	assert_strings_equal_diff (a_tag: READABLE_STRING_GENERAL; a_expected, a_actual: STRING_32)
			-- Assert strings are equal with detailed character-by-character diff
			-- Shows special characters, position of first difference, and metrics
		require
			a_tag_not_void: a_tag /= Void
			a_expected_attached: a_expected /= Void
			a_actual_attached: a_actual /= Void
		local
			msg: STRING_32
		do
			if not a_expected.same_string (a_actual) then
				msg := build_string_diff (a_tag, a_expected, a_actual)
				assert (msg, False)
			end
		end

feature {NONE} -- String diff implementation

	build_string_diff (a_tag: READABLE_STRING_GENERAL; a_expected, a_actual: READABLE_STRING_GENERAL): STRING_32
			-- Build detailed diff message showing character differences
		local
			i, first_diff: INTEGER
			exp_len, act_len: INTEGER
			c_exp, c_act: CHARACTER_32
		do
			create Result.make (200)

			-- Header
			Result.append_string_general (a_tag)
			Result.append_string_general ("%N")
			Result.append_string_general ("================================================================================")
			Result.append_string_general ("%N")

			-- Metrics
			exp_len := a_expected.count
			act_len := a_actual.count
			Result.append_string_general ("Expected length: ")
			Result.append_integer (exp_len)
			Result.append_string_general ("%N")
			Result.append_string_general ("Actual length:   ")
			Result.append_integer (act_len)
			Result.append_string_general ("%N")

			-- Find first difference
			first_diff := 0
			from
				i := 1
			until
				i > exp_len.min (act_len) or first_diff > 0
			loop
				if a_expected.item (i) /= a_actual.item (i) then
					first_diff := i
				end
				i := i + 1
			end

			if first_diff = 0 and exp_len /= act_len then
				first_diff := exp_len.min (act_len) + 1
			end

			Result.append_string_general ("First diff at:   position ")
			Result.append_integer (first_diff)
			Result.append_string_general ("%N")
			Result.append_string_general ("================================================================================")
			Result.append_string_general ("%N")

			-- Expected string with special chars
			Result.append_string_general ("EXPECTED:%N  ")
			Result.append_string_general (printable_string (a_expected))
			Result.append_string_general ("%N")

			-- Actual string with special chars
			Result.append_string_general ("ACTUAL:%N  ")
			Result.append_string_general (printable_string (a_actual))
			Result.append_string_general ("%N")

			-- Character-by-character comparison around first difference
			if first_diff > 0 then
				Result.append_string_general ("================================================================================")
				Result.append_string_general ("%N")
				Result.append_string_general ("Character-by-character at difference position ")
				Result.append_integer (first_diff)
				Result.append_string_general (":%N")

				from
					i := (first_diff - 2).max (1)
				until
					i > (first_diff + 2).min (exp_len.max (act_len))
				loop
					Result.append_string_general ("  Position ")
					Result.append_integer (i)
					Result.append_string_general (": ")

					if i <= exp_len then
						c_exp := a_expected.item (i)
						Result.append_string_general ("Expected=")
						Result.append_string_general (printable_char (c_exp))
						Result.append_string_general (" (")
						Result.append_integer (c_exp.code)
						Result.append_string_general (")")
					else
						Result.append_string_general ("Expected=<END>")
					end

					Result.append_string_general ("  ")

					if i <= act_len then
						c_act := a_actual.item (i)
						Result.append_string_general ("Actual=")
						Result.append_string_general (printable_char (c_act))
						Result.append_string_general (" (")
						Result.append_integer (c_act.code)
						Result.append_string_general (")")
					else
						Result.append_string_general ("Actual=<END>")
					end

					if i = first_diff then
						Result.append_string_general (" <-- FIRST DIFFERENCE")
					end

					Result.append_string_general ("%N")
					i := i + 1
				end
			end

			Result.append_string_general ("================================================================================")
		end

	printable_string (a_string: READABLE_STRING_GENERAL): STRING_32
			-- Convert string to printable form showing special characters
		local
			i: INTEGER
		do
			create Result.make (a_string.count * 2)
			from
				i := 1
			until
				i > a_string.count
			loop
				Result.append_string_general (printable_char (a_string.item (i)))
				i := i + 1
			end
		end

	printable_char (c: CHARACTER_32): STRING_32
			-- Convert character to printable representation
		do
			create Result.make (6)
			inspect c
			when '%N' then
				Result.append_string_general ("\n")
			when '%R' then
				Result.append_string_general ("\r")
			when '%T' then
				Result.append_string_general ("\t")
			when '%B' then
				Result.append_string_general ("\b")
			when '%F' then
				Result.append_string_general ("\f")
			when '%'' then
				Result.append_string_general ("\'")
			when '%"' then
				Result.append_string_general ("\%"")
			when '%%' then
				Result.append_string_general ("\\")
			else
				if c.code >= 32 and c.code <= 126 then
					-- Printable ASCII
					Result.append_character (c)
				elseif c.code < 32 then
					-- Control character
					Result.append_string_general ("\x")
					Result.append_string_general (c.code.to_hex_string)
				else
					-- Unicode
					Result.append_string_general ("\u")
					Result.append_string_general (c.code.to_hex_string)
				end
			end
		end

end
