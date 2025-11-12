note
	description: "Tests for JSON_BUILDER enhancements"
	author: "Larry Rix"
	date: "November 12, 2025"
	revision: "2"
	testing: "type/manual"

class
	TEST_JSON_BUILDER_ENHANCEMENTS

inherit
	EQA_TEST_SET

feature -- Test: Conditional Building

	test_put_string_if_true
			-- Test conditional string addition when condition is true
		note
			testing: "covers/{JSON_BUILDER}.put_string_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string_if (True, "name", "Alice")
			l_obj := l_builder.build
			
			assert ("has_name_key", l_obj.has_key ("name"))
			assert ("name_is_alice", attached l_obj.string ("name") as n and then n.is_equal ("Alice"))
		end

	test_put_string_if_false
			-- Test conditional string addition when condition is false
		note
			testing: "covers/{JSON_BUILDER}.put_string_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string_if (False, "name", "Alice")
			l_obj := l_builder.build
			
			assert ("no_name_key", not l_obj.has_key ("name"))
			assert ("object_empty", l_obj.is_empty)
		end

	test_put_integer_if
			-- Test conditional integer addition
		note
			testing: "covers/{JSON_BUILDER}.put_integer_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_integer_if (True, "age", 30)
				.put_integer_if (False, "count", 100)
			l_obj := l_builder.build
			
			assert ("has_age", l_obj.has_key ("age"))
			assert ("age_correct", l_obj.integer ("age") = 30)
			assert ("no_count", not l_obj.has_key ("count"))
		end

	test_put_boolean_if
			-- Test conditional boolean addition
		note
			testing: "covers/{JSON_BUILDER}.put_boolean_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_boolean_if (True, "active", True)
				.put_boolean_if (False, "deleted", True)
			l_obj := l_builder.build
			
			assert ("has_active", l_obj.has_key ("active"))
			assert ("no_deleted", not l_obj.has_key ("deleted"))
		end

	test_put_real_if
			-- Test conditional real addition
		note
			testing: "covers/{JSON_BUILDER}.put_real_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_real_if (True, "price", 19.99)
				.put_real_if (False, "discount", 5.5)
			l_obj := l_builder.build
			
			assert ("has_price", l_obj.has_key ("price"))
			assert ("no_discount", not l_obj.has_key ("discount"))
		end

	test_conditional_building_pattern
			-- Test real-world conditional building pattern
		note
			testing: "covers/{JSON_BUILDER}.put_string"
			testing: "covers/{JSON_BUILDER}.put_integer"
			testing: "covers/{JSON_BUILDER}.put_string_if"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
			l_include_email: BOOLEAN
			l_include_phone: BOOLEAN
		do
			l_include_email := True
			l_include_phone := False
			
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Bob")
				.put_integer ("age", 25)
				.put_string_if (l_include_email, "email", "bob@example.com")
				.put_string_if (l_include_phone, "phone", "555-1234")
			l_obj := l_builder.build
			
			assert ("has_name", l_obj.has_key ("name"))
			assert ("has_age", l_obj.has_key ("age"))
			assert ("has_email", l_obj.has_key ("email"))
			assert ("no_phone", not l_obj.has_key ("phone"))
			assert ("count_is_3", l_obj.count = 3)
		end

feature -- Test: Merge Operations

	test_merge_empty_objects
			-- Test merging two empty objects
		note
			testing: "covers/{JSON_BUILDER}.merge"
		local
			l_builder: JSON_BUILDER
			l_other: SIMPLE_JSON_OBJECT
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			create l_other.make_empty
			
			l_builder := l_builder.merge (l_other)
			l_obj := l_builder.build
			
			assert ("still_empty", l_obj.is_empty)
		end

	test_merge_non_overlapping
			-- Test merging objects with non-overlapping keys
		note
			testing: "covers/{JSON_BUILDER}.merge"
		local
			l_builder: JSON_BUILDER
			l_other: SIMPLE_JSON_OBJECT
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string ("key1", "value1")
			
			create l_other.make_empty
			l_other.put_string ("key2", "value2")
			
			l_builder := l_builder.merge (l_other)
			l_obj := l_builder.build
			
			assert ("has_key1", l_obj.has_key ("key1"))
			assert ("has_key2", l_obj.has_key ("key2"))
			assert ("count_is_2", l_obj.count = 2)
		end

	test_merge_overlapping_keys
			-- Test merging with overlapping keys (other wins)
		note
			testing: "covers/{JSON_BUILDER}.merge"
		local
			l_builder: JSON_BUILDER
			l_other: SIMPLE_JSON_OBJECT
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string ("name", "Alice")
			
			create l_other.make_empty
			l_other.put_string ("name", "Bob")
			
			l_builder := l_builder.merge (l_other)
			l_obj := l_builder.build
			
			assert ("name_overwritten", attached l_obj.string ("name") as n and then n.is_equal ("Bob"))
		end

	test_merge_complex_objects
			-- Test merging complex objects with multiple types
		note
			testing: "covers/{JSON_BUILDER}.merge"
		local
			l_builder: JSON_BUILDER
			l_other: SIMPLE_JSON_OBJECT
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.put_integer ("age", 30)
			
			create l_other.make_empty
			l_other.put_boolean ("active", True)
			l_other.put_real ("score", 95.5)
			
			l_builder := l_builder.merge (l_other)
			l_obj := l_builder.build
			
			assert ("has_name", l_obj.has_key ("name"))
			assert ("has_age", l_obj.has_key ("age"))
			assert ("has_active", l_obj.has_key ("active"))
			assert ("has_score", l_obj.has_key ("score"))
			assert ("count_is_4", l_obj.count = 4)
		end

feature -- Test: Remove Operations

	test_remove_existing_key
			-- Test removing an existing key
		note
			testing: "covers/{JSON_BUILDER}.remove"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.put_integer ("age", 30)
				.remove ("name")
			l_obj := l_builder.build
			
			assert ("name_removed", not l_obj.has_key ("name"))
			assert ("age_still_exists", l_obj.has_key ("age"))
			assert ("count_is_1", l_obj.count = 1)
		end

	test_remove_non_existing_key
			-- Test removing a key that doesn't exist (should not error)
		note
			testing: "covers/{JSON_BUILDER}.remove"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.remove ("age")  -- Key doesn't exist
			l_obj := l_builder.build
			
			assert ("name_still_exists", l_obj.has_key ("name"))
		end

	test_remove_fluent_chain
			-- Test remove in fluent chain
		note
			testing: "covers/{JSON_BUILDER}.remove"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("key1", "value1")
				.put_string ("key2", "value2")
				.put_string ("key3", "value3")
				.remove ("key2")
				.put_string ("key4", "value4")
			l_obj := l_builder.build
			
			assert ("has_key1", l_obj.has_key ("key1"))
			assert ("no_key2", not l_obj.has_key ("key2"))
			assert ("has_key3", l_obj.has_key ("key3"))
			assert ("has_key4", l_obj.has_key ("key4"))
			assert ("count_is_3", l_obj.count = 3)
		end

feature -- Test: Rename Operations

	test_rename_key
			-- Test renaming a key
		note
			testing: "covers/{JSON_BUILDER}.rename_key"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("old_name", "value")
				.rename_key ("old_name", "new_name")
			l_obj := l_builder.build
			
			assert ("old_key_gone", not l_obj.has_key ("old_name"))
			assert ("new_key_exists", l_obj.has_key ("new_name"))
			assert ("value_preserved", attached l_obj.string ("new_name") as v and then v.is_equal ("value"))
		end

	test_rename_preserves_value_type
			-- Test that rename preserves the value and its type
		note
			testing: "covers/{JSON_BUILDER}.rename_key"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_integer ("count", 42)
				.rename_key ("count", "total")
			l_obj := l_builder.build
			
			assert ("old_key_gone", not l_obj.has_key ("count"))
			assert ("new_key_exists", l_obj.has_key ("total"))
			assert ("value_preserved", l_obj.integer ("total") = 42)
		end

feature -- Test: Clear Operations

	test_clear_empty
			-- Test clearing empty builder
		note
			testing: "covers/{JSON_BUILDER}.clear"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.clear
			l_obj := l_builder.build
			
			assert ("is_empty", l_obj.is_empty)
		end

	test_clear_populated
			-- Test clearing populated builder
		note
			testing: "covers/{JSON_BUILDER}.clear"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("key1", "value1")
				.put_integer ("key2", 42)
				.clear
			l_obj := l_builder.build
			
			assert ("is_empty", l_obj.is_empty)
			assert ("count_zero", l_obj.count = 0)
		end

	test_clear_and_rebuild
			-- Test clearing and then rebuilding
		note
			testing: "covers/{JSON_BUILDER}.clear"
		local
			l_builder: JSON_BUILDER
			l_obj: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("old", "data")
				.clear
				.put_string ("new", "data")
			l_obj := l_builder.build
			
			assert ("no_old_key", not l_obj.has_key ("old"))
			assert ("has_new_key", l_obj.has_key ("new"))
			assert ("count_is_1", l_obj.count = 1)
		end

feature -- Test: Clone Operations

	test_clone_empty_object
			-- Test cloning empty object
		note
			testing: "covers/{JSON_BUILDER}.clone_object"
		local
			l_builder: JSON_BUILDER
			l_clone: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_clone := l_builder.clone_object
			
			assert ("clone_exists", l_clone /= Void)
			assert ("clone_empty", l_clone.is_empty)
			assert ("independent", l_clone /= l_builder.build)
		end

	test_clone_simple_object
			-- Test cloning simple object
		note
			testing: "covers/{JSON_BUILDER}.clone_object"
		local
			l_builder: JSON_BUILDER
			l_clone: SIMPLE_JSON_OBJECT
			l_original: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.put_integer ("age", 30)
			
			l_original := l_builder.build
			l_clone := l_builder.clone_object
			
			assert ("clone_has_name", l_clone.has_key ("name"))
			assert ("clone_has_age", l_clone.has_key ("age"))
			assert ("independent", l_clone /= l_original)
		end

	test_clone_independence
			-- Test that clone is independent of original
		note
			testing: "covers/{JSON_BUILDER}.clone_object"
		local
			l_builder: JSON_BUILDER
			l_clone: SIMPLE_JSON_OBJECT
			l_original: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string ("key", "original")
			
			l_clone := l_builder.clone_object
			l_original := l_builder.build
			
			-- Modify original
			l_original.put_string ("key", "modified")
			
			-- Clone should still have original value
			assert ("clone_unchanged", attached l_clone.string ("key") as v and then v.is_equal ("original"))
			assert ("original_changed", attached l_original.string ("key") as v and then v.is_equal ("modified"))
		end

feature -- Test: Make from Object

	test_make_from_object
			-- Test creating builder from existing object
		note
			testing: "covers/{JSON_BUILDER}.make_from_object"
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_builder: JSON_BUILDER
			l_result: SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			l_obj.put_string ("name", "Alice")
			l_obj.put_integer ("age", 30)
			
			create l_builder.make_from_object (l_obj)
			l_result := l_builder.build
			
			assert ("same_object", l_result = l_obj)
			assert ("has_name", l_result.has_key ("name"))
			assert ("has_age", l_result.has_key ("age"))
		end

	test_make_from_object_and_modify
			-- Test creating from object and continuing to build
		note
			testing: "covers/{JSON_BUILDER}.make_from_object"
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_builder: JSON_BUILDER
			l_result: SIMPLE_JSON_OBJECT
		do
			create l_obj.make_empty
			l_obj.put_string ("name", "Alice")
			
			create l_builder.make_from_object (l_obj)
			l_builder := l_builder.put_integer ("age", 30)
			
			l_result := l_builder.build
			
			assert ("has_name", l_result.has_key ("name"))
			assert ("has_age", l_result.has_key ("age"))
			assert ("count_is_2", l_result.count = 2)
		end

feature -- Test: Nested Object/Array Support

	test_put_nested_object
			-- Test adding nested object
		note
			testing: "covers/{JSON_BUILDER}.put_object"
		local
			l_builder: JSON_BUILDER
			l_nested: SIMPLE_JSON_OBJECT
			l_result: SIMPLE_JSON_OBJECT
		do
			create l_nested.make_empty
			l_nested.put_string ("city", "NYC")
			l_nested.put_string ("state", "NY")
			
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.put_object ("address", l_nested)
			
			l_result := l_builder.build
			
			assert ("has_name", l_result.has_key ("name"))
			assert ("has_address", l_result.has_key ("address"))
			
			if attached l_result.object ("address") as addr then
				assert ("has_city", addr.has_key ("city"))
				assert ("has_state", addr.has_key ("state"))
			else
				assert ("address_should_exist", False)
			end
		end

	test_put_array
			-- Test adding array
		note
			testing: "covers/{JSON_BUILDER}.put_array"
		local
			l_builder: JSON_BUILDER
			l_array: SIMPLE_JSON_ARRAY
			l_result: SIMPLE_JSON_OBJECT
		do
			create l_array.make_empty
			l_array.append_string ("value1")
			l_array.append_string ("value2")
			
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Test")
				.put_array ("items", l_array)
			
			l_result := l_builder.build
			
			assert ("has_name", l_result.has_key ("name"))
			assert ("has_items", l_result.has_key ("items"))
			
			if attached l_result.array ("items") as items then
				assert ("items_count", items.count = 2)
			else
				assert ("items_should_exist", False)
			end
		end

feature -- Test: Integration

	test_complex_builder_pattern
			-- Test complex real-world builder pattern
		note
			testing: "covers/{JSON_BUILDER}.put_string"
			testing: "covers/{JSON_BUILDER}.put_integer"
			testing: "covers/{JSON_BUILDER}.put_boolean"
			testing: "covers/{JSON_BUILDER}.put_string_if"
			testing: "covers/{JSON_BUILDER}.put_real"
		local
			l_builder: JSON_BUILDER
			l_include_optional: BOOLEAN
			l_result: SIMPLE_JSON_OBJECT
			l_json_string: STRING
		do
			l_include_optional := True
			
			create l_builder.make
			l_builder := l_builder
				.put_string ("name", "Alice")
				.put_integer ("age", 30)
				.put_boolean ("active", True)
				.put_string_if (l_include_optional, "email", "alice@example.com")
				.put_real ("score", 95.5)
			
			-- Add more conditionally
			if l_include_optional then
				l_builder := l_builder.put_string ("phone", "555-1234")
			end
			
			l_result := l_builder.build
			l_json_string := l_result.to_json_string
			
			assert ("has_all_keys", l_result.count = 6)
			assert ("has_name", l_result.has_key ("name"))
			assert ("has_email", l_result.has_key ("email"))
			assert ("has_phone", l_result.has_key ("phone"))
			assert ("json_not_empty", not l_json_string.is_empty)
		end

	test_builder_reuse
			-- Test reusing builder after getting result
		note
			testing: "covers/{JSON_BUILDER}.build"
		local
			l_builder: JSON_BUILDER
			l_result1, l_result2: SIMPLE_JSON_OBJECT
		do
			create l_builder.make
			l_builder := l_builder.put_string ("key", "value1")
			l_result1 := l_builder.build
			
			-- Continue using builder
			l_builder := l_builder.put_string ("key2", "value2")
			l_result2 := l_builder.build
			
			-- Both results should have updates
			assert ("result1_has_key", l_result1.has_key ("key"))
			assert ("result2_has_key", l_result2.has_key ("key"))
			assert ("result2_has_key2", l_result2.has_key ("key2"))
			assert ("same_object", l_result1 = l_result2)
		end

end
