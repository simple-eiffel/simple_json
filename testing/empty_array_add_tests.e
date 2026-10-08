note
	description: "[
		The first add to an array must not fault.

		Every add feature of SIMPLE_JSON_ARRAY carried the postcondition
		`previous_kept: old count = 0 or else json_value.i_th (old count) =
		old json_value.i_th (count)'. An `old' expression is evaluated on
		ENTRY, whatever guard the clause that uses it carries, so on an
		empty array it ran `i_th (0)'. Neither ejson's JSON_ARRAY nor base's
		ARRAYED_LIST checks its preconditions in a client build: the read
		took the word before the list's storage (its block header) as a
		reference and dereferenced it - a segmentation fault on every first
		add. The runtime turned the fault into an
		OPERATING_SYSTEM_SIGNAL_FAILURE that the old-expression trap kept
		and never raised, so a single-threaded run never failed. The runtime
		still records it as the last exception, and that is what these
		tests read. Under SCOOP the same fault, taken on several processors
		at once, killed simple_chat's server (2026-10-08); the process-level
		assault is the simple_json_scoop_tests target.
	]"
	author: "Larry Rix"
	testing: "covers"

class
	EMPTY_ARRAY_ADD_TESTS

inherit
	TEST_SET_BASE

feature -- Tests

	test_add_string_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_string"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_string ({STRING_32} "one").do_nothing
			assert_nothing_raised ("add_string", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_integer_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_integer"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_integer (1).do_nothing
			assert_nothing_raised ("add_integer", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_real_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_real"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_real (1.5).do_nothing
			assert_nothing_raised ("add_real", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_decimal_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_decimal"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_decimal (create {SIMPLE_DECIMAL}.make ("3.14159")).do_nothing
			assert_nothing_raised ("add_decimal", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_boolean_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_boolean"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_boolean (True).do_nothing
			assert_nothing_raised ("add_boolean", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_null_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_null"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_null.do_nothing
			assert_nothing_raised ("add_null", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_object_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_object"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_object (create {SIMPLE_JSON_OBJECT}.make).do_nothing
			assert_nothing_raised ("add_object", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_array_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_array"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_array (create {SIMPLE_JSON_ARRAY}.make).do_nothing
			assert_nothing_raised ("add_array", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_add_value_to_empty_array_faults_nothing
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_value"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_before := last_raised
			l_array.add_value (create {SIMPLE_JSON_VALUE}.make (create {JSON_NULL})).do_nothing
			assert_nothing_raised ("add_value", l_before)
			assert_integers_equal ("one element", 1, l_array.count)
		end

	test_second_add_keeps_the_first
			-- The repaired `previous_kept' still bites where it should: after
			-- a second add the first element is the one that was there.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_string"
		local
			l_array: SIMPLE_JSON_ARRAY
			l_before: detachable EXCEPTION
		do
			create l_array.make
			l_array.add_string ({STRING_32} "first").do_nothing
			l_before := last_raised
			l_array.add_string ({STRING_32} "second").do_nothing
			assert_nothing_raised ("a second add_string", l_before)
			assert_integers_equal ("two elements", 2, l_array.count)
			assert_true ("first kept", attached l_array.string_item (1) as al_s and then al_s.same_string ({STRING_32} "first"))
		end

feature {NONE} -- Implementation

	last_raised: detachable EXCEPTION
			-- What the runtime raised last, whether or not anything rescued or kept it.
		do
			Result := (create {EXCEPTION_MANAGER_FACTORY}).exception_manager.last_exception
		end

	assert_nothing_raised (a_what: READABLE_STRING_8; a_before: detachable EXCEPTION)
			-- Nothing raised since `a_before' was the last exception.
		local
			l_tag: STRING_32
			l_raised: detachable EXCEPTION
		do
			if attached last_raised as al_e and then al_e /= a_before then
				l_raised := al_e
			end
			create l_tag.make_from_string_general (a_what)
			l_tag.append_string_general (" raised nothing")
			if attached l_raised as al_r then
				l_tag.append_string_general (" - it raised ")
				l_tag.append_string_general (al_r.generating_type.name)
				l_tag.append_string_general (": ")
				l_tag.append_string_general (al_r.tag)
			end
			assert_void (l_tag, l_raised)
		end

end
