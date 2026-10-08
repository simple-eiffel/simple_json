note
	description: "[
		One SCOOP processor that adds to fresh SIMPLE_JSON_ARRAYs - every
		round starts from an EMPTY array, the case that faulted - while it
		allocates, so the collector runs under it. It counts the faults
		the runtime recorded on its own processor (the exception manager's
		last exception changing during an add) for the root to assert on.
	]"
	author: "Larry Rix"

class
	JSON_ARRAY_WORKER

create
	make

feature {NONE} -- Initialization

	make (a_rounds: INTEGER)
			-- A worker that will run `a_rounds' rounds.
		require
			rounds_positive: a_rounds > 0
		do
			rounds := a_rounds
		ensure
			rounds_set: rounds = a_rounds
			not_yet: not is_done
		end

feature -- Access

	rounds: INTEGER
			-- Rounds `run' makes.

	faults: INTEGER
			-- Adds during which the runtime recorded an exception.

	elements: INTEGER
			-- Elements added in all.

feature -- Status report

	is_done: BOOLEAN
			-- Has `run' finished?

feature -- Basic operations

	run
			-- Every round: a fresh array, three adds (the first to it EMPTY), and some garbage.
		local
			l_array: SIMPLE_JSON_ARRAY
			l_object: SIMPLE_JSON_OBJECT
			l_keep: ARRAYED_LIST [STRING_8]
			l_before: detachable EXCEPTION
			i: INTEGER
		do
			create l_keep.make (Kept)
			from
				i := 1
			until
				i > rounds
			loop
				l_before := last_raised
				create l_array.make
				create l_object.make
				l_array.add_object (l_object).do_nothing
				l_array.add_integer (i).do_nothing
				l_array.add_string ({STRING_32} "three").do_nothing
				if last_raised /= l_before then
					faults := faults + 1
				end
				elements := elements + l_array.count
				l_keep.extend (create {STRING_8}.make_filled ('x', Garbage_bytes))
				if l_keep.count >= Kept then
					l_keep.wipe_out
				end
				i := i + 1
			variant
				rounds - i + 1
			end
			is_done := True
		ensure
			done: is_done
		end

feature {NONE} -- Implementation

	last_raised: detachable EXCEPTION
			-- What the runtime raised last on this processor.
		do
			Result := (create {EXCEPTION_MANAGER_FACTORY}).exception_manager.last_exception
		end

	Kept: INTEGER = 64
			-- Strings held at once, so the heap grows and the collector really runs.

	Garbage_bytes: INTEGER = 256
			-- Size of each.

invariant
	rounds_positive: rounds > 0
	faults_bounded: faults >= 0 and faults <= rounds

end
