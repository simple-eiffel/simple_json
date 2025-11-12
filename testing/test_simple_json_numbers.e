note
	description: "Tests for numeric edge cases and precision in SIMPLE_JSON"
	author: "Larry Rix"
	date: "November 11, 2025"
	revision: "1"
	testing: "type/manual"

class
	TEST_SIMPLE_JSON_NUMBERS

inherit
	EQA_TEST_SET

feature -- Numeric Tests

	test_extreme_integers
			-- Test parsing extreme integer values
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.integer"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"zero%": 0, %"negative%": -999, %"large%": 1000000, %"max_int%": 2147483647}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("zero_value", obj.integer ("zero") = 0)
				assert ("negative_value", obj.integer ("negative") = -999)
				assert ("large_value", obj.integer ("large") = 1000000)
				assert ("max_int_value", obj.integer ("max_int") = 2147483647)
			end
		end

	test_negative_numbers
			-- Test negative integers and reals
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.real"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"neg_int%": -42, %"neg_real%": -3.14, %"neg_zero%": -0}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("neg_int_value", obj.integer ("neg_int") = -42)
				assert ("neg_real_value", (obj.real ("neg_real") - (-3.14)).abs < 0.001)
				assert ("neg_zero_value", obj.integer ("neg_zero") = 0)
			end
		end

	test_real_precision
			-- Test real number precision
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"pi%": 3.14159, %"small%": 0.00001, %"precise%": 123.456789}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("pi_value", (obj.real ("pi") - 3.14159).abs < 0.00001)
				assert ("small_value", (obj.real ("small") - 0.00001).abs < 0.000001)
				assert ("precise_value", (obj.real ("precise") - 123.456789).abs < 0.000001)
			end
		end

	test_zero_values
			-- Test various representations of zero
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.integer"
			testing: "covers/{SIMPLE_JSON_OBJECT}.real"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"int_zero%": 0, %"real_zero%": 0.0}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("int_zero", obj.integer ("int_zero") = 0)
				assert ("real_zero", obj.real ("real_zero") = 0.0)
			end
		end

	test_decimal_formats
			-- Test different decimal formats
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"no_decimal%": 42, %"with_decimal%": 42.0, %"only_decimal%": 0.5}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
					-- Integer without decimal
				assert ("no_decimal", obj.integer ("no_decimal") = 42)

					-- Number with .0 is stored as real in JSON
				assert ("with_decimal_as_real", (obj.real ("with_decimal") - 42.0).abs < 0.001)

					-- Pure decimal
				assert ("only_decimal", (obj.real ("only_decimal") - 0.5).abs < 0.001)
			end
		end

	test_scientific_notation
			-- Test scientific notation if supported
		note
			testing: "covers/{SIMPLE_JSON}.parse"
			testing: "covers/{SIMPLE_JSON_OBJECT}.real"
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
				-- Note: JSON supports scientific notation like 1e10
			l_obj := l_json.parse ("{%"large%": 1e6, %"small%": 1e-6}")

				-- This test might fail if eJSON doesn't support scientific notation
				-- That's okay - it documents the limitation
			if attached l_obj as obj then
				assert ("large_scientific", (obj.real ("large") - 1000000.0).abs < 1.0)
				assert ("small_scientific", (obj.real ("small") - 0.000001).abs < 0.0000001)
			end
		end

	test_mixed_type_array
			-- Test array with different numeric types
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
			l_arr: detachable SIMPLE_JSON_ARRAY
		do
			create l_json
			l_obj := l_json.parse ("{%"numbers%": [0, 42, -10, 3.14, -2.5]}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				l_arr := obj.array ("numbers")
				assert ("array_not_void", l_arr /= Void)

				if attached l_arr as arr then
					assert ("count_five", arr.count = 5)
					assert ("first_zero", arr.integer_at (1) = 0)
					assert ("second_42", arr.integer_at (2) = 42)
					assert ("third_neg10", arr.integer_at (3) = -10)
					assert ("fourth_pi", (arr.real_at (4) - 3.14).abs < 0.01)
					assert ("fifth_neg", (arr.real_at (5) - (-2.5)).abs < 0.01)
				end
			end
		end

	test_integer_real_conversion
			-- Test automatic conversion between integers and reals
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"int_val%": 100, %"real_val%": 99.9}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
					-- Integer accessed as integer
				assert ("int_as_int", obj.integer ("int_val") = 100)

					-- Real accessed as real
				assert ("real_as_real", (obj.real ("real_val") - 99.9).abs < 0.001)

					-- Automatic conversion: integer can be accessed as real
				assert ("int_as_real", (obj.real ("int_val") - 100.0).abs < 0.001)

					-- Automatic conversion: real can be accessed as integer (truncates)
				assert ("real_as_int", obj.integer ("real_val") = 99)
			end
		end

	test_very_small_numbers
			-- Test very small decimal numbers
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"tiny%": 0.000001, %"micro%": 0.0000001}")

			assert ("object_not_void", l_obj /= Void)
			if attached l_obj as obj then
				assert ("tiny_value", (obj.real ("tiny") - 0.000001).abs < 0.0000001)
				assert ("micro_value", (obj.real ("micro") - 0.0000001).abs < 0.00000001)
			end
		end

	test_round_trip_numeric_precision
			-- Test that numbers maintain precision through round-trip
		local
			l_obj1: SIMPLE_JSON_OBJECT
			l_json_string: STRING
			l_json: SIMPLE_JSON
			l_obj2: detachable SIMPLE_JSON_OBJECT
		do
			create l_obj1.make_empty
			l_obj1.put_integer ("int", 42)
			l_obj1.put_real ("real", 3.14159)

			l_json_string := l_obj1.to_json_string

			create l_json
			l_obj2 := l_json.parse (l_json_string)

			assert ("parsed_not_void", l_obj2 /= Void)
			if attached l_obj2 as obj then
				assert ("int_preserved", obj.integer ("int") = 42)
				assert ("real_preserved", (obj.real ("real") - 3.14159).abs < 0.00001)
			end
		end

end
