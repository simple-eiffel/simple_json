note
	description: "[
		The cursor of a SIMPLE_JSON_STREAM: one element in hand at a
		time, pulled from the stream on demand. Creating it starts a
		pass over the array; `forth' asks the stream for the next
		element; `after' turns True when the array ends or the stream
		faults. Nothing is buffered beyond the element in hand.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/streaming/simple_json_stream.html"

class
	SIMPLE_JSON_STREAM_CURSOR

inherit
	ITERATION_CURSOR [SIMPLE_JSON_STREAM_ELEMENT]

create
	make

feature {NONE} -- Initialization

	make (a_stream: SIMPLE_JSON_STREAM)
			-- Begin a pass over `a_stream' and stand on its first element.
		do
			stream := a_stream
			start
		ensure
			stream_set: stream = a_stream
		end

feature -- Access

	item: SIMPLE_JSON_STREAM_ELEMENT
			-- The element in hand.
		require else
			not_after: not after
		do
			check in_hand: attached current_value as al_value then
				create Result.make (al_value, index)
			end
		end

	index: INTEGER
			-- Position of the element in hand, 1-based; 0 before the first.

feature -- Status report

	after: BOOLEAN
			-- Is the pass over?

feature -- Cursor movement

	start
			-- Open (or reopen) the pass and take the first element.
		do
			stream.open
			index := 0
			after := False
			pull
		ensure
			at_first_or_done: index = 1 or after
		end

	forth
			-- Take the next element.
		do
			pull
		ensure then
			advanced: after or index = old index + 1
		end

feature {NONE} -- Implementation

	stream: SIMPLE_JSON_STREAM
			-- The stream being read.

	current_value: detachable SIMPLE_JSON_VALUE
			-- The element in hand; Void once `after'.

	pull
			-- Ask the stream for one more element.
		do
			if stream.is_open then
				current_value := stream.next_element
			else
				current_value := Void
			end
			if attached current_value then
				index := index + 1
			else
				after := True
			end
		ensure
			value_iff_not_after: (current_value /= Void) = not after
		end

invariant
	stream_attached: stream /= Void
	index_non_negative: index >= 0
	value_iff_not_after: (current_value /= Void) = not after
	index_matches_stream: not after implies index = stream.element_count

note
	copyright: "Copyright (c) 2024-2026, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser implementation
	]"

end
