note
	description: "Tests for SIMPLE_JSON_PATCH"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_PATCH

inherit
	TEST_SET_BASE

feature -- Test routines: Creation

	test_make_creates_empty_patch
		local
			l_patch: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			assert_true ("is_empty", l_patch.is_empty)
			assert_integers_equal ("count_zero", 0, l_patch.count)
		end

	test_make_from_array_with_operations
		local
			l_patch: SIMPLE_JSON_PATCH
			l_ops: ARRAY [SIMPLE_JSON_PATCH_OPERATION]
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_ops.make_filled (create {SIMPLE_JSON_PATCH_ADD}.make ("/name", l_json.string_value ("Alice")), 1, 2)
			l_ops [2] := create {SIMPLE_JSON_PATCH_REMOVE}.make ("/age")

			create l_patch.make_from_array (l_ops)
			assert_integers_equal ("count_two", 2, l_patch.count)
			assert_false ("not_empty", l_patch.is_empty)
		end

	test_make_from_array_empty
		local
			l_patch: SIMPLE_JSON_PATCH
			l_ops: ARRAY [SIMPLE_JSON_PATCH_OPERATION]
		do
			create l_ops.make_empty
			create l_patch.make_from_array (l_ops)
			assert_true ("is_empty", l_patch.is_empty)
		end

feature -- Test routines: Fluent API

	test_add_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_result := l_patch.add ("/name", l_json.string_value ("Bob"))
			assert_true ("returns_current", l_result = l_patch)
		end

	test_add_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_patch.add ("/name", l_json.string_value ("Bob")).do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_remove_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_result := l_patch.remove ("/name")
			assert_true ("returns_current", l_result = l_patch)
		end

	test_remove_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_patch.remove ("/name").do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_replace_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_result := l_patch.replace ("/name", l_json.string_value ("Charlie"))
			assert_true ("returns_current", l_result = l_patch)
		end

	test_replace_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_patch.replace ("/name", l_json.string_value ("Charlie")).do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_move_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_result := l_patch.move ("/old", "/new")
			assert_true ("returns_current", l_result = l_patch)
		end

	test_move_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_patch.move ("/old", "/new").do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_copy_value_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_result := l_patch.copy_value ("/source", "/dest")
			assert_true ("returns_current", l_result = l_patch)
		end

	test_copy_value_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
		do
			create l_patch.make
			l_patch.copy_value ("/source", "/dest").do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_test_returns_current
		local
			l_patch, l_result: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_result := l_patch.test ("/name", l_json.string_value ("Test"))
			assert_true ("returns_current", l_result = l_patch)
		end

	test_test_increments_count
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make
			l_patch.test ("/name", l_json.string_value ("Test")).do_nothing
			assert_integers_equal ("count_one", 1, l_patch.count)
		end

	test_fluent_chaining
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
		do
			create l_json
			create l_patch.make

			l_patch
				.add ("/name", l_json.string_value ("Alice"))
				.add ("/age", l_json.integer_value (30))
				.remove ("/temp")
				.replace ("/status", l_json.string_value ("active")).do_nothing

			assert_integers_equal ("count_four", 4, l_patch.count)
		end

feature -- Test routines: Apply operations

	test_apply_empty_patch_returns_success
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
				assert_true ("has_document", l_result.has_document)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_add_to_object
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch.add ("/age", l_json.integer_value (30)).do_nothing
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
				if attached l_result.modified_document as l_modified then
					assert_true ("is_object", l_modified.is_object)
				else
					assert_false ("no_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_remove_from_object
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch.remove ("/age").do_nothing
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
				if attached l_result.modified_document as l_modified then
					assert_true ("is_object", l_modified.is_object)
				else
					assert_false ("no_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_replace_in_object
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch.replace ("/name", l_json.string_value ("Bob")).do_nothing
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
				if attached l_result.modified_document as l_modified then
					assert_true ("is_object", l_modified.is_object)
				else
					assert_false ("no_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_multiple_operations
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch
					.add ("/city", l_json.string_value ("NYC"))
					.replace ("/age", l_json.integer_value (31))
					.remove ("/name").do_nothing

				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_with_test_operation_success
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch
					.test ("/name", l_json.string_value ("Alice"))
					.add ("/age", l_json.integer_value (30)).do_nothing

				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_with_test_operation_failure
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch
					.test ("/name", l_json.string_value ("Bob"))
					.add ("/age", l_json.integer_value (30)).do_nothing

				l_result := l_patch.apply (al_doc)

				assert_true ("is_failure", l_result.is_failure)
				assert_true ("has_error", l_result.has_error)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_atomic_failure_first_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch
					.remove ("/nonexistent")
					.add ("/age", l_json.integer_value (30)).do_nothing

				l_result := l_patch.apply (al_doc)

				assert_true ("is_failure", l_result.is_failure)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_atomic_failure_middle_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch
					.add ("/age", l_json.integer_value (30))
					.remove ("/nonexistent")
					.add ("/city", l_json.string_value ("NYC")).do_nothing

				l_result := l_patch.apply (al_doc)

				assert_true ("is_failure", l_result.is_failure)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_move_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch.move ("/name", "/fullName").do_nothing
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
			else
				assert_false ("parse_failed", True)
			end
		end

	test_apply_copy_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_doc: detachable SIMPLE_JSON_VALUE
			l_result: SIMPLE_JSON_PATCH_RESULT
		do
			create l_json
			l_doc := l_json.parse ("{%"name%": %"Alice%"}")
			create l_patch.make

			if attached l_doc as al_doc then
				l_patch.copy_value ("/name", "/displayName").do_nothing
				l_result := l_patch.apply (al_doc)

				assert_true ("is_success", l_result.is_success)
			else
				assert_false ("parse_failed", True)
			end
		end

feature -- Test routines: Conversion

	test_to_json_array_empty
		local
			l_patch: SIMPLE_JSON_PATCH
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_patch.make
			l_array := l_patch.to_json_array

			assert_true ("is_empty", l_array.is_empty)
			assert_integers_equal ("count_zero", 0, l_array.count)
		end

	test_to_json_array_single_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_json
			create l_patch.make
			l_patch.add ("/name", l_json.string_value ("Alice")).do_nothing

			l_array := l_patch.to_json_array

			assert_integers_equal ("count_one", 1, l_array.count)
		end

	test_to_json_array_multiple_operations
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_json
			create l_patch.make

			l_patch
				.add ("/name", l_json.string_value ("Alice"))
				.remove ("/age")
				.replace ("/status", l_json.string_value ("active")).do_nothing

			l_array := l_patch.to_json_array

			assert_integers_equal ("count_three", 3, l_array.count)
		end

	test_to_json_array_contains_objects
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_array: SIMPLE_JSON_ARRAY
		do
			create l_json
			create l_patch.make
			l_patch.add ("/name", l_json.string_value ("Alice")).do_nothing

			l_array := l_patch.to_json_array

			if l_array.count > 0 then
				if attached l_array.item (1) as l_item then
					assert_true ("first_is_object", l_item.is_object)
				else
					assert_false ("no_first_item", True)
				end
			else
				assert_false ("array_empty", True)
			end
		end

	test_to_json_string_empty
		local
			l_patch: SIMPLE_JSON_PATCH
			l_str: STRING_32
		do
			create l_patch.make
			l_str := l_patch.to_json_string

			assert_true ("not_empty", not l_str.is_empty)
			assert_true ("is_array", l_str.starts_with ("["))
		end

	test_to_json_string_with_operations
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_str: STRING_32
		do
			create l_json
			create l_patch.make

			l_patch
				.add ("/name", l_json.string_value ("Alice"))
				.remove ("/age").do_nothing

			l_str := l_patch.to_json_string

			assert_true ("not_empty", not l_str.is_empty)
			assert_true ("is_array", l_str.starts_with ("["))
			assert_true ("contains_add", l_str.has_substring ("add"))
			assert_true ("contains_remove", l_str.has_substring ("remove"))
		end

	test_to_json_string_add_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_str: STRING_32
		do
			create l_json
			create l_patch.make
			l_patch.add ("/test", l_json.string_value ("value")).do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_add", l_str.has_substring ("add"))
			assert_true ("contains_path", l_str.has_substring ("path"))
			assert_true ("contains_value", l_str.has_substring ("value"))
		end

	test_to_json_string_remove_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_str: STRING_32
		do
			create l_patch.make
			l_patch.remove ("/test").do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_remove", l_str.has_substring ("remove"))
			assert_true ("contains_path", l_str.has_substring ("path"))
		end

	test_to_json_string_replace_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_str: STRING_32
		do
			create l_json
			create l_patch.make
			l_patch.replace ("/test", l_json.string_value ("newvalue")).do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_replace", l_str.has_substring ("replace"))
			assert_true ("contains_path", l_str.has_substring ("path"))
			assert_true ("contains_value", l_str.has_substring ("value"))
		end

	test_to_json_string_move_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_str: STRING_32
		do
			create l_patch.make
			l_patch.move ("/old", "/new").do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_move", l_str.has_substring ("move"))
			assert_true ("contains_from", l_str.has_substring ("from"))
			assert_true ("contains_path", l_str.has_substring ("path"))
		end

	test_to_json_string_copy_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_str: STRING_32
		do
			create l_patch.make
			l_patch.copy_value ("/source", "/dest").do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_copy", l_str.has_substring ("copy"))
			assert_true ("contains_from", l_str.has_substring ("from"))
			assert_true ("contains_path", l_str.has_substring ("path"))
		end

	test_to_json_string_test_operation
		local
			l_patch: SIMPLE_JSON_PATCH
			l_json: SIMPLE_JSON
			l_str: STRING_32
		do
			create l_json
			create l_patch.make
			l_patch.test ("/test", l_json.string_value ("expected")).do_nothing

			l_str := l_patch.to_json_string

			assert_true ("contains_op", l_str.has_substring ("op"))
			assert_true ("contains_test", l_str.has_substring ("test"))
			assert_true ("contains_path", l_str.has_substring ("path"))
			assert_true ("contains_value", l_str.has_substring ("value"))
		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
