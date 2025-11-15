note
	description: "[
		Iterator cursor for streaming JSON array elements.
		Implements ITERATION_CURSOR for use with Eiffel's `across' loops.
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
			-- Initialize cursor for stream
		require
			stream_attached: a_stream /= Void
		do
			stream := a_stream
			current_index := 0
			start
		ensure
			stream_set: stream = a_stream
			at_start: current_index = 1 or else stream.element_count = 0
		end

feature -- Access

	item: SIMPLE_JSON_STREAM_ELEMENT
			-- Current element
		require else
			not_after: not after
		local
			l_value: detachable SIMPLE_JSON_VALUE
		do
			-- Get the current element from the stream
			l_value := stream.elements.i_th (current_index)

			check value_attached: attached l_value as al_value then
				create Result.make (al_value, current_index)
			end
		end

feature -- Status report

	after: BOOLEAN
			-- Is cursor past the last element?
		do
			Result := current_index > stream.element_count or else
					  stream.element_count = 0
		end

feature -- Cursor movement

	forth
			-- Move to next element
		do
			current_index := current_index + 1
		end

	start
			-- Move to first element
		do
			if stream.element_count > 0 then
				current_index := 1
			else
				current_index := 0
			end
		end

feature {NONE} -- Implementation

	stream: SIMPLE_JSON_STREAM
			-- The stream being iterated

	current_index: INTEGER
			-- Current position in stream (1-based, 0 means not started)

invariant
	stream_attached: stream /= Void
	valid_index: current_index >= 0

note
	copyright: "Copyright (c) 2024, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser implementation
	]"
end
