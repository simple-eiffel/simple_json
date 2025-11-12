note
	description: "Tests for nested and complex JSON structures"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_NESTED

inherit
	EQA_TEST_SET

feature -- Nested Structure Tests

	test_array_of_objects
			-- Test parsing array containing objects
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.array"
			testing: "covers/{SIMPLE_JSON_ARRAY}.object_at"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_arr: detachable SIMPLE_JSON_ARRAY
			l_person: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"users%": [{%"name%": %"Alice%", %"age%": 30}, {%"name%": %"Bob%", %"age%": 25}]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_arr := obj.array ("users")
				assert ("array_not_void", l_arr /= Void)

				if attached l_arr as users then
					assert ("two_users", users.count = 2)

					-- Check first user
					l_person := users.object_at (1)
					assert ("first_person_not_void", l_person /= Void)
					if attached l_person as p1 then
						assert ("alice_name", attached p1.string ("name") as n and then n.is_equal ("Alice"))
						assert ("alice_age", p1.integer ("age") = 30)
					end

					-- Check second user
					l_person := users.object_at (2)
					assert ("second_person_not_void", l_person /= Void)
					if attached l_person as p2 then
						assert ("bob_name", attached p2.string ("name") as n and then n.is_equal ("Bob"))
						assert ("bob_age", p2.integer ("age") = 25)
					end
				end
			end
		end

	test_deeply_nested_objects
			-- Test parsing deeply nested object structures
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.object"
		local
			l_json: SIMPLE_JSON
			l_obj, l_user, l_address, l_location: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"user%": {%"address%": {%"location%": {%"city%": %"NYC%", %"zip%": 10001}}}}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_user := obj.object ("user")
				assert ("user_not_void", l_user /= Void)

				if attached l_user as user then
					l_address := user.object ("address")
					assert ("address_not_void", l_address /= Void)

					if attached l_address as addr then
						l_location := addr.object ("location")
						assert ("location_not_void", l_location /= Void)

						if attached l_location as loc then
							assert ("city_is_nyc", attached loc.string ("city") as c and then c.is_equal ("NYC"))
							assert ("zip_is_10001", loc.integer ("zip") = 10001)
						end
					end
				end
			end
		end

	test_nested_arrays
			-- Test array containing arrays
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.array"
			testing: "covers/{SIMPLE_JSON_ARRAY}.array_at"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_matrix: detachable SIMPLE_JSON_ARRAY
			l_row: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"matrix%": [[1, 2, 3], [4, 5, 6]]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_matrix := obj.array ("matrix")
				assert ("matrix_not_void", l_matrix /= Void)

				if attached l_matrix as matrix then
					assert ("two_rows", matrix.count = 2)

					-- Check first row
					l_row := matrix.array_at (1)
					assert ("first_row_not_void", l_row /= Void)
					if attached l_row as row1 then
						assert ("first_row_length", row1.count = 3)
						assert ("row1_first", row1.integer_at (1) = 1)
						assert ("row1_second", row1.integer_at (2) = 2)
						assert ("row1_third", row1.integer_at (3) = 3)
					end

					-- Check second row
					l_row := matrix.array_at (2)
					if attached l_row as row2 then
						assert ("second_row_length", row2.count = 3)
						assert ("row2_first", row2.integer_at (1) = 4)
						assert ("row2_last", row2.integer_at (3) = 6)
					end
				end
			end
		end

	test_object_with_nested_array_of_objects
			-- Test complex structure: object → array → objects
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_company: detachable SIMPLE_JSON_OBJECT
			l_employees: detachable SIMPLE_JSON_ARRAY
			l_employee: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"company%": {%"name%": %"TechCorp%", %"employees%": [{%"id%": 1, %"name%": %"Alice%"}, {%"id%": 2, %"name%": %"Bob%"}]}}")

			assert ("root_not_void", l_obj /= Void)
			if attached l_obj as root then
				l_company := root.object ("company")
				assert ("company_not_void", l_company /= Void)

				if attached l_company as comp then
					assert ("company_name", attached comp.string ("name") as n and then n.is_equal ("TechCorp"))

					l_employees := comp.array ("employees")
					assert ("employees_not_void", l_employees /= Void)

					if attached l_employees as emps then
						assert ("two_employees", emps.count = 2)

						l_employee := emps.object_at (1)
						if attached l_employee as emp1 then
							assert ("emp1_id", emp1.integer ("id") = 1)
							assert ("emp1_name", attached emp1.string ("name") as n and then n.is_equal ("Alice"))
						end
					end
				end
			end
		end

	test_array_with_mixed_nested_types
			-- Test array containing both objects and arrays
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_data: detachable SIMPLE_JSON_ARRAY
			l_inner_obj: detachable SIMPLE_JSON_OBJECT
			l_inner_arr: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"data%": [{%"type%": %"obj%"}, [1, 2, 3]]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as root then
				l_data := root.array ("data")
				assert ("data_not_void", l_data /= Void)

				if attached l_data as data then
					assert ("two_elements", data.count = 2)

					-- First element is an object
					l_inner_obj := data.object_at (1)
					assert ("first_is_object", l_inner_obj /= Void)
					if attached l_inner_obj as obj1 then
						assert ("has_type", attached obj1.string ("type") as t and then t.is_equal ("obj"))
					end

					-- Second element is an array
					l_inner_arr := data.array_at (2)
					assert ("second_is_array", l_inner_arr /= Void)
					if attached l_inner_arr as arr then
						assert ("array_has_three", arr.count = 3)
						assert ("first_is_1", arr.integer_at (1) = 1)
					end
				end
			end
		end

	test_three_level_nesting
			-- Test three levels of object nesting
		local
			l_json: SIMPLE_JSON
			l_root, l_level1, l_level2, l_level3: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_root := l_json.parse ("{%"l1%": {%"l2%": {%"l3%": {%"value%": 42}}}}")

			assert ("root_not_void", l_root /= Void)
			if attached l_root as r then
				l_level1 := r.object ("l1")
				if attached l_level1 as l1 then
					l_level2 := l1.object ("l2")
					if attached l_level2 as l2 then
						l_level3 := l2.object ("l3")
						if attached l_level3 as l3 then
							assert ("value_is_42", l3.integer ("value") = 42)
						end
					end
				end
			end
		end

end
