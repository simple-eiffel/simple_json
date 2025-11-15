note
	description: "[
		Memory-efficient streaming JSON parser for large files.
		Streams array elements one at a time without loading entire document.
		Uses iterator pattern with ITERATION_CURSOR for Eiffel's `across' loops.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Streaming JSON", "protocol=URI", "src=https://en.wikipedia.org/wiki/Streaming_JSON"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/streaming/simple_json_stream.html"

class
	SIMPLE_JSON_STREAM

inherit
	ITERABLE [SIMPLE_JSON_STREAM_ELEMENT]

create
	make_from_file,
	make_from_string

feature {NONE} -- Initialization

	make_from_file (a_file_path: STRING_32)
			-- Initialize streaming parser for file at `a_file_path'.
			-- File must contain a JSON array at root level.
		require
			not_empty: not a_file_path.is_empty
		do
			file_path := a_file_path
			is_from_file := True
			create errors.make (5)
			create {ARRAYED_LIST [SIMPLE_JSON_VALUE]} elements.make (10)
		ensure
			file_path_set: file_path ~ a_file_path
			is_from_file: is_from_file
		end

	make_from_string (a_json_text: STRING_32)
			-- Initialize streaming parser for JSON text.
			-- Text must contain a JSON array at root level.
		require
			not_empty: not a_json_text.is_empty
		do
			json_text := a_json_text
			is_from_file := False
			create errors.make (5)
			create {ARRAYED_LIST [SIMPLE_JSON_VALUE]} elements.make (10)
		ensure
			json_text_set: json_text ~ a_json_text
			not_from_file: not is_from_file
		end

feature -- Access

	new_cursor: SIMPLE_JSON_STREAM_CURSOR
			-- Fresh cursor for iteration
		do
			if not is_parsed then
				parse_array
			end
			create Result.make (Current)
		ensure then
			cursor_attached: Result /= Void
		end

	element_count: INTEGER
			-- Number of elements parsed so far
		do
			Result := elements.count
		ensure
			non_negative: Result >= 0
		end

feature -- Status report

	has_errors: BOOLEAN
			-- Did errors occur during parsing?
		do
			Result := not errors.is_empty
		end

	is_from_file: BOOLEAN
			-- Was this created from a file?

	is_parsed: BOOLEAN
			-- Has the array been parsed?

feature -- Error tracking

	last_errors: LIST [SIMPLE_JSON_ERROR]
			-- Errors from last operation
		do
			Result := errors
		ensure
			result_attached: Result /= Void
		end

feature {SIMPLE_JSON_STREAM_CURSOR} -- Implementation

	elements: LIST [SIMPLE_JSON_VALUE]
			-- Parsed array elements

feature {NONE} -- Implementation

	file_path: detachable STRING_32
			-- Path to file (if from file)

	json_text: detachable STRING_32
			-- JSON text (if from string)

	errors: ARRAYED_LIST [SIMPLE_JSON_ERROR]
			-- Collected errors

	parse_array
			-- Parse the JSON array and populate elements
		local
			l_parser: SIMPLE_JSON
			l_value: detachable SIMPLE_JSON_VALUE
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			create l_parser

			if is_from_file and then attached file_path as l_path then
				-- Read from file
				create l_file.make_with_name (l_path)
				if l_file.exists and then l_file.is_readable then
					l_file.open_read
					l_file.read_stream (l_file.count)
					l_content := utf_converter.utf_8_string_8_to_string_32 (l_file.last_string)
					l_file.close
					l_value := l_parser.parse (l_content)
				else
					errors.extend (create {SIMPLE_JSON_ERROR}.make ("Cannot read file: " + l_path))
				end
			else
				-- Parse from string
				check attached json_text as l_text then
					l_value := l_parser.parse (l_text)
				end
			end

			-- Check if parse was successful and is an array
			if attached l_value as al_value then
				if al_value.is_array then
					-- Extract array elements
					extract_array_elements (al_value.as_array)
					is_parsed := True
				else
					errors.extend (create {SIMPLE_JSON_ERROR}.make ("Root must be array, got: " + al_value.json_value.representation))
				end
			else
				-- Capture parser errors
				if l_parser.has_errors then
					across l_parser.last_errors as ic loop
						errors.extend (ic)
					end
				else
					errors.extend (create {SIMPLE_JSON_ERROR}.make ("Parse failed with unknown error"))
				end
			end
		ensure
			parsed: is_parsed or has_errors
		end

	extract_array_elements (a_array: SIMPLE_JSON_ARRAY)
			-- Extract elements from parsed array
		require
			array_attached: a_array /= Void
		local
			i: INTEGER
			l_value: SIMPLE_JSON_VALUE
		do
			from
				i := 1
			invariant
				-- Index bounds
				valid_index: i >= 1 and i <= a_array.count + 1

				-- Elements list integrity
				elements_attached: elements /= Void

				-- All elements are non-void
				no_void_elements: across elements as ic_elem all ic_elem /= Void end
			until
				i > a_array.count
			loop
				l_value := a_array.item (i)
				elements.extend (l_value)
				i := i + 1
			end
		ensure
			elements_populated: elements.count = a_array.count
		end

	utf_converter: UTF_CONVERTER
			-- UTF conversion utility
		once
			create Result
		end

invariant
	-- Core data integrity
	errors_attached: errors /= Void
	elements_attached: elements /= Void

	-- Source consistency (mutually exclusive)
	either_file_or_string: is_from_file implies file_path /= Void
	not_from_file_implies_text: not is_from_file implies json_text /= Void

	-- Error state consistency
	has_errors_definition: has_errors = not errors.is_empty

	-- Error list quality
	no_void_errors: across errors as ic_err all ic_err /= Void end

	-- Element count consistency
	element_count_definition: element_count = elements.count
	count_non_negative: element_count >= 0

	-- Element list quality (no void elements)
	no_void_elements: across elements as ic_elem all ic_elem /= Void end

	-- Parse state consistency
	-- If parsed successfully, we should have elements (unless array was empty)
	-- If has errors, parsing either failed or found non-array

note
	copyright: "Copyright (c) 2024, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser implementation
	]"
end
