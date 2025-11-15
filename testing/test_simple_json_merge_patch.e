note
	description: "Tests for SIMPLE_JSON_MERGE_PATCH (RFC 7386)"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_MERGE_PATCH

inherit
	TEST_SET_BASE

feature -- Test routines: RFC 7386 Examples (Appendix A)

	test_rfc_example_1_simple_value_merge
			-- Example from RFC 7386 Appendix A.1
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"b"}
			-- Patch: {"a":"c"}
			-- Result: {"a":"c"}
			l_target := l_json.parse ("{%"a%":%"b%"}")
			l_patch := l_json.parse ("{%"a%":%"c%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_true ("has_key_a", al_merged.as_object.has_key ("a"))

					if attached al_merged.as_object.item ("a") as l_value then
						assert_strings_equal ("value_is_c", "c", l_value.as_string_32)
					else
						assert_false ("value_a_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_2_add_member
			-- Example from RFC 7386 Appendix A.2
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"b"}
			-- Patch: {"b":"c"}
			-- Result: {"a":"b","b":"c"}
			l_target := l_json.parse ("{%"a%":%"b%"}")
			l_patch := l_json.parse ("{%"b%":%"c%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_integers_equal ("has_two_keys", 2, al_merged.as_object.count)
					assert_true ("has_key_a", al_merged.as_object.has_key ("a"))
					assert_true ("has_key_b", al_merged.as_object.has_key ("b"))
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_3_delete_member
			-- Example from RFC 7386 Appendix A.3
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"b"}
			-- Patch: {"a":null}
			-- Result: {}
			l_target := l_json.parse ("{%"a%":%"b%"}")
			l_patch := l_json.parse ("{%"a%":null}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_integers_equal ("is_empty", 0, al_merged.as_object.count)
					assert_false ("key_a_deleted", al_merged.as_object.has_key ("a"))
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_4_delete_nonexistent
			-- Example from RFC 7386 Appendix A.4
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"b"}
			-- Patch: {"a":null,"b":"c"}
			-- Result: {"b":"c"}
			l_target := l_json.parse ("{%"a%":%"b%"}")
			l_patch := l_json.parse ("{%"a%":null,%"b%":%"c%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_integers_equal ("has_one_key", 1, al_merged.as_object.count)
					assert_false ("key_a_deleted", al_merged.as_object.has_key ("a"))
					assert_true ("has_key_b", al_merged.as_object.has_key ("b"))
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_5_replace_array
			-- Example from RFC 7386 Appendix A.5
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":["b"]}
			-- Patch: {"a":"c"}
			-- Result: {"a":"c"}
			l_target := l_json.parse ("{%"a%":[%"b%"]}")
			l_patch := l_json.parse ("{%"a%":%"c%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)

					if attached al_merged.as_object.item ("a") as l_value then
						assert_true ("value_is_string", l_value.is_string)
						assert_strings_equal ("value_is_c", "c", l_value.as_string_32)
					else
						assert_false ("value_a_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_6_replace_string_with_array
			-- Example from RFC 7386 Appendix A.6
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"c"}
			-- Patch: {"a":["b"]}
			-- Result: {"a":["b"]}
			l_target := l_json.parse ("{%"a%":%"c%"}")
			l_patch := l_json.parse ("{%"a%":[%"b%"]}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)

					if attached al_merged.as_object.item ("a") as l_value then
						assert_true ("value_is_array", l_value.is_array)
						assert_integers_equal ("array_has_one_element", 1, l_value.as_array.count)
					else
						assert_false ("value_a_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_7_nested_object_merge
			-- Example from RFC 7386 Appendix A.7
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":{"b":"c"}}
			-- Patch: {"a":{"b":"d","c":null}}
			-- Result: {"a":{"b":"d"}}
			l_target := l_json.parse ("{%"a%":{%"b%":%"c%"}}")
			l_patch := l_json.parse ("{%"a%":{%"b%":%"d%",%"c%":null}}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)

					if attached al_merged.as_object.item ("a") as l_a_value then
						assert_true ("a_is_object", l_a_value.is_object)

						if attached l_a_value.as_object.item ("b") as l_b_value then
							assert_strings_equal ("b_is_d", "d", l_b_value.as_string_32)
						else
							assert_false ("b_value_missing", True)
						end

						assert_false ("c_deleted", l_a_value.as_object.has_key ("c"))
					else
						assert_false ("a_value_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_8_nested_object_delete
			-- Example from RFC 7386 Appendix A.8
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":[{"b":"c"}]}
			-- Patch: {"a":[1]}
			-- Result: {"a":[1]}
			l_target := l_json.parse ("{%"a%":[{%"b%":%"c%"}]}")
			l_patch := l_json.parse ("{%"a%":[1]}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)

					if attached al_merged.as_object.item ("a") as l_value then
						assert_true ("value_is_array", l_value.is_array)
						assert_integers_equal ("array_has_one", 1, l_value.as_array.count)

						if attached l_value.as_array.item (1) as al_item then
						    check value: attached {SIMPLE_JSON_VALUE} al_item as al_value then
						        assert_true ("item_is_number", al_value.is_number)
						        assert_integers_equal ("item_is_one", 1, al_value.as_integer.to_integer_32)
						    end
						else
						    assert_false ("array_item_missing", True)
						end
					else
						assert_false ("value_a_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_9_replace_scalar_with_null
			-- Example from RFC 7386 Appendix A.9
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"e":null}
			-- Patch: {"e":"fox"}
			-- Result: {"e":"fox"}
			l_target := l_json.parse ("{%"e%":null}")
			l_patch := l_json.parse ("{%"e%":%"fox%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)

					if attached al_merged.as_object.item ("e") as l_value then
						assert_true ("value_is_string", l_value.is_string)
						assert_strings_equal ("value_is_fox", "fox", l_value.as_string_32)
					else
						assert_false ("value_e_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_10_complex_merge
			-- Example from RFC 7386 Appendix A.10
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"foo"}
			-- Patch: null
			-- Result: null
			l_target := l_json.parse ("{%"a%":%"foo%"}")
			l_patch := l_json.parse ("null")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("result_is_null", al_merged.is_null)
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_11_replace_object_with_scalar
			-- Example from RFC 7386 Appendix A.11
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"a":"foo"}
			-- Patch: "bar"
			-- Result: "bar"
			l_target := l_json.parse ("{%"a%":%"foo%"}")
			l_patch := l_json.parse ("%"bar%"")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("result_is_string", al_merged.is_string)
					assert_strings_equal ("result_is_bar", "bar", al_merged.as_string_32)
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_12_replace_non_object_target
			-- Example from RFC 7386 Appendix A.12
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {"e":null}
			-- Patch: {"a":"b"}
			-- Result: {"e":null,"a":"b"}
			l_target := l_json.parse ("{%"e%":null}")
			l_patch := l_json.parse ("{%"a%":%"b%"}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_integers_equal ("has_two_keys", 2, al_merged.as_object.count)
					assert_true ("has_key_e", al_merged.as_object.has_key ("e"))
					assert_true ("has_key_a", al_merged.as_object.has_key ("a"))
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_13_array_not_merged
			-- Example from RFC 7386 Appendix A.13
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: [1,2]
			-- Patch: {"a":"b","c":null}
			-- Result: {"a":"b"}
			l_target := l_json.parse ("[1,2]")
			l_patch := l_json.parse ("{%"a%":%"b%",%"c%":null}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_integers_equal ("has_one_key", 1, al_merged.as_object.count)
					assert_true ("has_key_a", al_merged.as_object.has_key ("a"))
					assert_false ("key_c_deleted", al_merged.as_object.has_key ("c"))
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

	test_rfc_example_14_empty_objects
			-- Example from RFC 7386 Appendix A.14
		local
			l_json: SIMPLE_JSON
			l_target, l_patch: detachable SIMPLE_JSON_VALUE
			l_merge: SIMPLE_JSON_MERGE_PATCH
			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
			l_merged: detachable SIMPLE_JSON_VALUE
		do
			create l_json

			-- Original: {}
			-- Patch: {"a":{"bb":{"ccc":null}}}
			-- Result: {"a":{"bb":{}}}
			l_target := l_json.parse ("{}")
			l_patch := l_json.parse ("{%"a%":{%"bb%":{%"ccc%":null}}}")

			if attached l_target as al_target and then
			   attached l_patch as al_patch then

				create l_merge.make_from_json (al_patch)
				l_result := l_merge.apply (al_target)

				assert_true ("merge_succeeded", l_result.is_success)

				l_merged := l_result.merged_document
				if attached l_merged as al_merged then
					assert_true ("is_object", al_merged.is_object)
					assert_true ("has_key_a", al_merged.as_object.has_key ("a"))

					if attached al_merged.as_object.item ("a") as l_a then
						assert_true ("a_is_object", l_a.is_object)
						assert_true ("a_has_bb", l_a.as_object.has_key ("bb"))

						if attached l_a.as_object.item ("bb") as l_bb then
							assert_true ("bb_is_object", l_bb.is_object)
							assert_integers_equal ("bb_is_empty", 0, l_bb.as_object.count)
							assert_false ("ccc_deleted", l_bb.as_object.has_key ("ccc"))
						else
							assert_false ("bb_missing", True)
						end
					else
						assert_false ("a_missing", True)
					end
				else
					assert_false ("no_merged_document", True)
				end
			else
				assert_false ("parse_failed", True)
			end
		end

--feature -- Test routines: Creation

--	test_make_creates_empty_patch
--		local
--			l_merge: SIMPLE_JSON_MERGE_PATCH
--		do
--			create l_merge.make
--			assert_true ("patch_is_object", l_merge.patch_document.is_object)
--			assert_integers_equal ("patch_is_empty", 0, l_merge.patch_document.as_object.count)
--		end

--	test_make_from_json
--		local
--			l_merge: SIMPLE_JSON_MERGE_PATCH
--			l_json: SIMPLE_JSON
--			l_patch: detachable SIMPLE_JSON_VALUE
--		do
--			create l_json
--			l_patch := l_json.parse ("{%"a%":%"b%"}")
--			
--			if attached l_patch as al_patch then
--				create l_merge.make_from_json (al_patch)
--				assert_true ("patch_set", l_merge.patch_document = al_patch)
--			else
--				assert_false ("parse_failed", True)
--			end
--		end

--	test_make_from_string
--		local
--			l_merge: SIMPLE_JSON_MERGE_PATCH
--		do
--			create l_merge.make_from_string ("{%"a%":%"b%"}")
--			assert_true ("patch_is_object", l_merge.patch_document.is_object)
--			assert_true ("has_key_a", l_merge.patch_document.as_object.has ("a"))
--		end

--feature -- Test routines: Edge Cases

--	test_empty_patch_on_empty_target
--		local
--			l_json: SIMPLE_JSON
--			l_target, l_patch: detachable SIMPLE_JSON_VALUE
--			l_merge: SIMPLE_JSON_MERGE_PATCH
--			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
--		do
--			create l_json
--			l_target := l_json.parse ("{}")
--			l_patch := l_json.parse ("{}")
--			
--			if attached l_target as al_target and then
--			   attached l_patch as al_patch then
--				
--				create l_merge.make_from_json (al_patch)
--				l_result := l_merge.apply (al_target)
--				
--				assert_true ("merge_succeeded", l_result.is_success)
--				
--				if attached l_result.merged_document as l_merged then
--					assert_integers_equal ("result_is_empty", 0, l_merged.as_object.count)
--				else
--					assert_false ("no_merged_document", True)
--				end
--			else
--				assert_false ("parse_failed", True)
--			end
--		end

--	test_multiple_nested_objects
--		local
--			l_json: SIMPLE_JSON
--			l_target, l_patch: detachable SIMPLE_JSON_VALUE
--			l_merge: SIMPLE_JSON_MERGE_PATCH
--			l_result: SIMPLE_JSON_MERGE_PATCH_RESULT
--		do
--			create l_json
--			
--			-- Deep nesting with multiple levels
--			l_target := l_json.parse ("{%"a%":{%"b%":{%"c%":{%"d%":%"old%"}}}}")
--			l_patch := l_json.parse ("{%"a%":{%"b%":{%"c%":{%"d%":%"new%"}}}}")
--			
--			if attached l_target as al_target and then
--			   attached l_patch as al_patch then
--				
--				create l_merge.make_from_json (al_patch)
--				l_result := l_merge.apply (al_target)
--				
--				assert_true ("merge_succeeded", l_result.is_success)
--				
--				if attached l_result.merged_document as l_merged then
--					-- Navigate to deeply nested value
--					if attached l_merged.as_object.value ("a") as l_a then
--						if attached l_a.as_object.value ("b") as l_b then
--							if attached l_b.as_object.value ("c") as l_c then
--								if attached l_c.as_object.value ("d") as l_d then
--									assert_strings_equal ("deep_value_updated", "new", l_d.as_string_32)
--								else
--									assert_false ("d_missing", True)
--								end
--							else
--								assert_false ("c_missing", True)
--							end
--						else
--							assert_false ("b_missing", True)
--						end
--					else
--						assert_false ("a_missing", True)
--					end
--				else
--					assert_false ("no_merged_document", True)
--				end
--			else
--				assert_false ("parse_failed", True)
--			end
--		end

note
	copyright: "2025, Larry Rix"
	license: "MIT License"

end
