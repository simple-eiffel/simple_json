note
	description: "[
		Wrapper for a single element from the JSON stream.
		Contains the value plus metadata like index and position.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/streaming/simple_json_stream.html"

class
	SIMPLE_JSON_STREAM_ELEMENT

create
	make

feature {NONE} -- Initialization

	make (a_value: SIMPLE_JSON_VALUE; a_index: INTEGER)
			-- Initialize with value and index
		require
			value_attached: a_value /= Void
			positive_index: a_index > 0
		do
			value := a_value
			index := a_index
		ensure
			value_set: value = a_value
			index_set: index = a_index
		end

feature -- Access

	value: SIMPLE_JSON_VALUE
			-- The JSON value for this element

	index: INTEGER
			-- Position in the array (1-based)

feature -- Conversion

	to_string: STRING_32
			-- String representation for debugging
		do
			create Result.make (50)
			Result.append ("Element #")
			Result.append (index.out)
			Result.append (": ")
			Result.append (value.to_json_string)
		ensure
			result_attached: Result /= Void
		end

invariant
	value_attached: value /= Void
	positive_index: index > 0

note
	copyright: "Copyright (c) 2024, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser implementation
	]"
end
