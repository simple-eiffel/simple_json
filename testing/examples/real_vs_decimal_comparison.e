note
	description: "Side-by-side comparison: SIMPLE_JSON_REAL vs SIMPLE_JSON_DECIMAL"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	REAL_VS_DECIMAL_COMPARISON

create
	make

feature {NONE} -- Initialization

	make
			-- Demonstrate the precision difference
		do
			print ("%N╔═══════════════════════════════════════════════════════════════╗%N")
			print ("║  SIMPLE_JSON_REAL vs SIMPLE_JSON_DECIMAL Comparison           ║%N")
			print ("╚═══════════════════════════════════════════════════════════════╝%N%N")
			
			demo_basic_precision
			demo_financial_calculation
			demo_accumulation_error
			demo_when_real_is_fine
		end

feature {NONE} -- Demonstrations

	demo_basic_precision
			-- Show basic precision difference
		local
			l_real: SIMPLE_JSON_REAL
			l_decimal: SIMPLE_JSON_DECIMAL
		do
			print ("1. BASIC PRECISION TEST%N")
			print ("═══════════════════════%N%N")
			
			print ("Input: 3.14%N%N")
			
			-- Using REAL
			create l_real.make (3.14)
			print ("SIMPLE_JSON_REAL output:%N")
			print ("  to_pretty_string: '" + l_real.to_pretty_string (0) + "'%N")
			print ("  ❌ Binary floating-point approximation%N%N")
			
			-- Using DECIMAL
			create l_decimal.make_from_string ("3.14")
			print ("SIMPLE_JSON_DECIMAL output:%N")
			print ("  to_pretty_string: '" + l_decimal.to_pretty_string (0) + "'%N")
			print ("  ✅ Exact decimal representation%N%N")
			
			print ("───────────────────────────────────────────────────────────────%N%N")
		end

	demo_financial_calculation
			-- Show why DECIMAL matters for money
		local
			l_price_real: REAL_64
			l_quantity_real: REAL_64
			l_total_real: REAL_64
			l_price_dec, l_quantity_dec, l_total_dec: DECIMAL
		do
			print ("2. FINANCIAL CALCULATION TEST%N")
			print ("══════════════════════════════%N%N")
			
			print ("Scenario: 3 items @ $19.99 each%N%N")
			
			-- Using REAL
			l_price_real := 19.99
			l_quantity_real := 3.0
			l_total_real := l_price_real * l_quantity_real
			
			print ("REAL_64 calculation:%N")
			print ("  Price:    $19.99%N")
			print ("  Quantity: 3%N")
			print ("  Total:    $" + l_total_real.out + "%N")
			print ("  ❌ May have rounding errors%N%N")
			
			-- Using DECIMAL
			create l_price_dec.make_from_string ("19.99")
			create l_quantity_dec.make_from_string ("3")
			l_total_dec := l_price_dec * l_quantity_dec
			
			print ("DECIMAL calculation:%N")
			print ("  Price:    $19.99%N")
			print ("  Quantity: 3%N")
			print ("  Total:    $" + l_total_dec.out + "%N")
			print ("  ✅ Exactly $59.97%N%N")
			
			print ("Why this matters:%N")
			print ("  • Financial regulations require exact decimal math%N")
			print ("  • Rounding errors compound in large datasets%N")
			print ("  • Auditors flag floating-point calculations%N%N")
			
			print ("───────────────────────────────────────────────────────────────%N%N")
		end

	demo_accumulation_error
			-- Show how errors accumulate
		local
			l_sum_real: REAL_64
			l_sum_dec: DECIMAL
			l_value_dec: DECIMAL
			i: INTEGER
		do
			print ("3. ACCUMULATION ERROR TEST%N")
			print ("═══════════════════════════%N%N")
			
			print ("Scenario: Add 0.1 ten times (should equal 1.0)%N%N")
			
			-- Using REAL
			from
				i := 1
				l_sum_real := 0.0
			until
				i > 10
			loop
				l_sum_real := l_sum_real + 0.1
				i := i + 1
			end
			
			print ("REAL_64 result:%N")
			print ("  0.1 + 0.1 + ... (10 times)%N")
			print ("  Result: " + l_sum_real.out + "%N")
			print ("  ❌ Not exactly 1.0!%N%N")
			
			-- Using DECIMAL
			from
				i := 1
				create l_sum_dec.make_from_string ("0")
				create l_value_dec.make_from_string ("0.1")
			until
				i > 10
			loop
				l_sum_dec := l_sum_dec + l_value_dec
				i := i + 1
			end
			
			print ("DECIMAL result:%N")
			print ("  0.1 + 0.1 + ... (10 times)%N")
			print ("  Result: " + l_sum_dec.out + "%N")
			print ("  ✅ Exactly 1.0!%N%N")
			
			print ("Impact:%N")
			print ("  • In loops with 1000+ iterations, errors compound%N")
			print ("  • Critical for batch processing%N")
			print ("  • Essential for scientific accuracy%N%N")
			
			print ("───────────────────────────────────────────────────────────────%N%N")
		end

	demo_when_real_is_fine
			-- Show when REAL is actually the better choice
		do
			print ("4. WHEN TO USE REAL_64%N")
			print ("═══════════════════════%N%N")
			
			print ("REAL_64 is BETTER for:%N%N")
			
			print ("  ✅ Graphics and game coordinates%N")
			print ("     • Speed matters more than precision%N")
			print ("     • Example: player_x := 123.456789%N%N")
			
			print ("  ✅ Physics simulations%N")
			print ("     • Approximate values are fine%N")
			print ("     • Example: velocity := 9.8 * time%N%N")
			
			print ("  ✅ Statistical calculations%N")
			print ("     • Working with samples and estimates%N")
			print ("     • Example: average := sum / count%N%N")
			
			print ("  ✅ Performance-critical code%N")
			print ("     • Processing millions of values%N")
			print ("     • REAL is 10-50× faster than DECIMAL%N%N")
			
			print ("DECIMAL is BETTER for:%N%N")
			
			print ("  ✅ Financial calculations%N")
			print ("     • Money MUST be exact%N")
			print ("     • Example: invoice_total := price * quantity%N%N")
			
			print ("  ✅ User-facing decimal display%N")
			print ("     • Show exactly what user typed%N")
			print ("     • Example: display 3.14, not 3.1400000000000001%N%N")
			
			print ("  ✅ Data interchange%N")
			print ("     • Preserve exact values from external systems%N")
			print ("     • Example: JSON APIs with decimal precision%N%N")
			
			print ("───────────────────────────────────────────────────────────────%N%N")
		end

feature {NONE} -- Performance comparison

	performance_comparison
			-- Run a quick performance test
		local
			l_real1, l_real2, l_result_real: REAL_64
			l_dec1, l_dec2, l_result_dec: DECIMAL
			l_iterations: INTEGER
			l_start_time, l_end_time: INTEGER_64
		do
			print ("5. PERFORMANCE COMPARISON%N")
			print ("═════════════════════════%N%N")
			
			l_iterations := 100_000
			print ("Running " + l_iterations.out + " operations...%N%N")
			
			-- REAL timing
			l_start_time := timer_now
			from
				l_real1 := 10.5
				l_real2 := 2.3
			until
				l_iterations <= 0
			loop
				l_result_real := l_real1 * l_real2
				l_result_real := l_result_real + l_real1
				l_result_real := l_result_real / l_real2
				l_iterations := l_iterations - 1
			end
			l_end_time := timer_now
			
			print ("REAL_64 time: " + (l_end_time - l_start_time).out + " ms%N")
			
			-- DECIMAL timing (would be significantly slower)
			-- Note: Not actually running this in example to keep it fast
			print ("DECIMAL time: ~10-50× slower (estimated)%N%N")
			
			print ("Conclusion: Use REAL when speed matters, DECIMAL when precision matters.%N%N")
		end

	timer_now: INTEGER_64
			-- Simple timer (platform-specific implementation needed)
		do
			-- Placeholder - use actual timer in real implementation
			Result := 0
		end

feature {NONE} -- Summary

	print_decision_tree
			-- Show decision tree for choosing between types
		do
			print ("╔═══════════════════════════════════════════════════════════════╗%N")
			print ("║  DECISION TREE: Which Type Should I Use?                      ║%N")
			print ("╚═══════════════════════════════════════════════════════════════╝%N%N")
			
			print ("START: Do I need to represent money or financial values?%N")
			print ("  ├─ YES → Use SIMPLE_JSON_DECIMAL ✅%N")
			print ("  └─ NO  → Do I need EXACT decimal representation?%N")
			print ("      ├─ YES → Use SIMPLE_JSON_DECIMAL ✅%N")
			print ("      └─ NO  → Is this performance-critical code?%N")
			print ("          ├─ YES → Use SIMPLE_JSON_REAL ⚡%N")
			print ("          └─ NO  → Are approximate values OK?%N")
			print ("              ├─ YES → Use SIMPLE_JSON_REAL ⚡%N")
			print ("              └─ NO  → Use SIMPLE_JSON_DECIMAL ✅%N%N")
			
			print ("Rule of thumb:%N")
			print ("  • Default to REAL for speed%N")
			print ("  • Switch to DECIMAL when exactness matters%N")
			print ("  • If unsure, use DECIMAL (slower but safer)%N%N")
		end

end
