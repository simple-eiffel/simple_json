note
	description: "[
		THE EMPTY-ARRAY ASSAULT (1.0.2), under SCOOP. The process-level
		test for the defect simple_chat's server found on 2026-10-08: the
		server died with a segmentation fault - sometimes "PANIC: caught
		signal #11", sometimes no word at all - a few dozen messages into a
		busy room.

		Every first add to a SIMPLE_JSON_ARRAY faulted inside its own
		postcondition (`old json_value.i_th (count)' with count = 0; see
		EMPTY_ARRAY_ADD_TESTS). One processor at a time, the runtime turned
		the fault into an exception the old-expression trap kept, and
		nothing showed. Several processors faulting at once is what the
		server did on every busy page, and the process died.

		Eight processors each build 20,000 arrays from empty while they
		allocate. Before 1.0.2 this target died with a segmentation fault
		on every run (5 of 5, 2026-10-08). The assertion on the recorded
		faults is the same evidence without the death: zero.
	]"
	author: "Larry Rix"

class
	SCOOP_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the assault.
		do
			print ("SIMPLE_JSON empty-array assault (SCOOP): the first add to an array must not fault%N%N")
			run_test (agent test_processors_adding_to_empty_arrays_fault_nothing,
				"eight processors adding to empty arrays fault nothing")
			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")
			if failed > 0 then
				print ("TESTS FAILED%N")
				(create {EXCEPTIONS}).die (1)
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Tests

	test_processors_adding_to_empty_arrays_fault_nothing
			-- `Workers' processors, `Rounds' fresh arrays each, all at once.
		local
			l_workers: ARRAYED_LIST [separate JSON_ARRAY_WORKER]
			l_worker: separate JSON_ARRAY_WORKER
			l_faults, l_elements, i: INTEGER
		do
			create l_workers.make (Workers)
			from
				i := 1
			until
				i > Workers
			loop
				create l_worker.make (Rounds)
				l_workers.extend (l_worker)
				start (l_worker)
				i := i + 1
			variant
				Workers - i + 1
			end
			across l_workers as ic_worker loop
				l_faults := l_faults + faults_when_done (ic_worker)
				l_elements := l_elements + elements_of (ic_worker)
			end
			print ("      " + Workers.out + " processors x " + Rounds.out + " arrays: "
				+ l_elements.out + " elements added, " + l_faults.out + " faults recorded%N")
			assert ("every element arrived", l_elements = Workers * Rounds * 3)
			assert ("no add faulted (" + l_faults.out + " did)", l_faults = 0)
		end

feature {NONE} -- Separate calls

	start (a_worker: separate JSON_ARRAY_WORKER)
			-- Set `a_worker' running on its own processor.
		do
			a_worker.run
		end

	faults_when_done (a_worker: separate JSON_ARRAY_WORKER): INTEGER
			-- `a_worker's fault count, once it has finished.
		require
			finished: a_worker.is_done
		do
			Result := a_worker.faults
		end

	elements_of (a_worker: separate JSON_ARRAY_WORKER): INTEGER
			-- Elements `a_worker' added.
		do
			Result := a_worker.elements
		end

feature {NONE} -- Runner

	passed, failed: INTEGER
			-- Tests that passed and failed.

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run `a_test', counting it under `a_name'.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			if attached (create {EXCEPTION_MANAGER_FACTORY}).exception_manager.last_exception as al_e and then attached al_e.description as al_d then
				print ("        " + al_d.to_string_8 + "%N")
			end
			failed := failed + 1
			l_retried := True
			retry
		end

	assert (a_tag: STRING; a_condition: BOOLEAN)
			-- Fail the running test with `a_tag' unless `a_condition'.
		do
			if not a_condition then
				print ("        FAILED: " + a_tag + "%N")
				(create {EXCEPTIONS}).raise ("empty-array assault: " + a_tag)
			end
		end

feature {NONE} -- Constants

	Workers: INTEGER = 8
			-- Processors at once.

	Rounds: INTEGER = 20_000
			-- Arrays each builds from empty.

end
