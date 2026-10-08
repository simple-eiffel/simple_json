note
	description: "Logger for benchmark results with file and console output"
	date: "$Date$"
	revision: "$Revision$"

class
	BENCHMARK_LOGGER

create
	make

feature {NONE} -- Initialization

	make (a_filename: STRING)
			-- Initialize logger with output filename
		require
			filename_not_empty: not a_filename.is_empty
		do
			create log_file.make_create_read_write (a_filename)
			benchmark_count := 0
			create clock
			start_nanoseconds := 0
		ensure
			file_created: log_file.exists
		end

feature -- Access

	benchmark_count: INTEGER
			-- Number of benchmarks logged

	log_file: PLAIN_TEXT_FILE
			-- Output file for results (exported for precondition checks)

	current_benchmark_name: detachable STRING
			-- Name of currently running benchmark (exported for precondition checks)

feature -- Logging

	log_header (a_title: STRING)
			-- Write header with title and timestamp
		require
			file_open: log_file.is_open_write
		local
			l_now: SIMPLE_DATE_TIME
		do
			create l_now.make_now

			log_line (create_repeated_string ("=", 70))
			log_line (a_title)
			log_line ("Date: " + l_now.date.to_iso8601)
			log_line ("Time: " + l_now.time.to_iso8601)
			log_line (create_repeated_string ("=", 70))
			log_line ("")
		end

	log_footer
			-- Write footer with summary
		require
			file_open: log_file.is_open_write
		do
			log_line ("")
			log_line (create_repeated_string ("=", 70))
			log_line ("Total Benchmarks: " + benchmark_count.out)
			log_line ("Benchmark completed successfully")
			log_line (create_repeated_string ("=", 70))
		end

	log_section (a_section: STRING)
			-- Write section header
		require
			file_open: log_file.is_open_write
		do
			log_line ("")
			log_line (create_repeated_string ("-", 70))
			log_line (a_section)
			log_line (create_repeated_string ("-", 70))
		end

	log_separator
			-- Write separator line
		require
			file_open: log_file.is_open_write
		do
			log_line ("")
		end

	start_benchmark (a_name: STRING; a_iterations: INTEGER)
			-- Start timing a benchmark
		require
			file_open: log_file.is_open_write
			name_not_empty: not a_name.is_empty
			positive_iterations: a_iterations > 0
			no_active_benchmark: current_benchmark_name = Void
		do
			current_benchmark_name := a_name
			current_iterations := a_iterations
			
			-- Capture start time from the monotonic clock
			start_nanoseconds := clock.nanoseconds
			
			log_line ("Benchmark: " + a_name)
			log_line ("Iterations: " + a_iterations.out)
		ensure
			benchmark_active: current_benchmark_name /= Void
		end

	stop_benchmark
			-- Stop timing and log results
		require
			file_open: log_file.is_open_write
			benchmark_started: current_benchmark_name /= Void
		local
			l_elapsed_ms: INTEGER_64
			l_ops_per_sec: INTEGER
		do
			-- Elapsed milliseconds since `start_benchmark'
			l_elapsed_ms := clock.elapsed_milliseconds (start_nanoseconds)

			l_ops_per_sec := operations_per_second (current_iterations, l_elapsed_ms.max (1))
			
			log_line ("Duration: " + l_elapsed_ms.out + " ms")
			log_line ("Operations/sec: " + format_with_commas (l_ops_per_sec))
			log_line ("")
			
			benchmark_count := benchmark_count + 1
			current_benchmark_name := Void
		ensure
			benchmark_stopped: current_benchmark_name = Void
		end

	close
			-- Close log file
		require
			file_open: log_file.is_open_write
		do
			log_file.close
		ensure
			file_closed: log_file.is_closed
		end

feature {NONE} -- Implementation

	current_iterations: INTEGER
			-- Number of iterations in current benchmark

	clock: SIMPLE_MONOTONIC_CLOCK
			-- Monotonic clock used for timing.

	start_nanoseconds: INTEGER_64
			-- Monotonic clock reading when the current benchmark started.

	log_line (a_message: STRING)
			-- Write message to both file and console
		do
			log_file.put_string (a_message)
			log_file.put_new_line
			io.put_string (a_message)
			io.put_new_line
		end

	create_repeated_string (a_char: STRING; a_count: INTEGER): STRING
			-- Create string with character repeated count times
		require
			char_not_empty: not a_char.is_empty
			positive_count: a_count > 0
		local
			i: INTEGER
		do
			create Result.make_empty
			from
				i := 1
			until
				i > a_count
			loop
				Result.append (a_char)
				i := i + 1
			end
		ensure
			correct_length: Result.count = a_count * a_char.count
		end

	operations_per_second (a_operations: INTEGER; a_milliseconds: INTEGER_64): INTEGER
			-- Calculate operations per second
		require
			positive_operations: a_operations > 0
			positive_time: a_milliseconds > 0
		do
			if a_milliseconds > 0 then
				Result := ((a_operations.to_double / a_milliseconds.to_double) * 1000.0).truncated_to_integer
			end
		ensure
			valid_result: Result >= 0
		end

	format_with_commas (a_number: INTEGER): STRING
			-- Format number with comma separators
		local
			l_str: STRING
			l_len: INTEGER
			i: INTEGER
		do
			l_str := a_number.out
			l_len := l_str.count
			create Result.make_empty
			
			from
				i := 1
			until
				i > l_len
			loop
				Result.append_character (l_str [i])
				if (l_len - i) \\ 3 = 0 and i < l_len then
					Result.append_character (',')
				end
				i := i + 1
			end
		end

invariant
	file_not_void: log_file /= Void
	non_negative_count: benchmark_count >= 0

end
