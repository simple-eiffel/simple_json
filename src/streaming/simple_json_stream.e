note
	description: "[
		A streaming reader for large JSON documents: the elements of one
		array come out one at a time, and the document is never held
		whole. A file is read in chunks (`chunk_size' bytes, 64 KB by
		default); each element's text is cut out by a small structural
		scanner that understands strings, escapes and nesting, and only
		that one element is handed to the parser. Memory is one chunk
		plus one element, whatever the file's size.

		The array may be the document's root ("[...]") or sit under a
		top-level key of a root object ("{... "events": [...] ...}"),
		named with `make_from_file_at' / `make_from_string_at'; the
		members before it are skipped by structure, not parsed.

		Iteration is Eiffel's own: `across stream as ic loop
		ic.value ... ic.index ... end'. A second `across' starts over
		(the file is reopened). An element the parser refuses ends the
		stream with an error in `last_errors'; `has_errors' says so.

		History: the first version of this class parsed the entire
		document and copied the array into a list, and its invariants
		walked that list on every call - streaming in name only.
		Rewritten 2026-09-11 after a 391 KB caption track took 158 s
		of CPU to read through the wrappers.
	]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Streaming JSON", "protocol=URI", "src=https://en.wikipedia.org/wiki/Streaming_JSON"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/streaming/simple_json_stream.html"

class
	SIMPLE_JSON_STREAM

inherit
	ITERABLE [SIMPLE_JSON_STREAM_ELEMENT]

	SIMPLE_JSON_CONSTANTS
		export
			{NONE} all
		end

create
	make_from_file,
	make_from_string,
	make_from_file_at,
	make_from_string_at

feature {NONE} -- Initialization

	make_from_file (a_file_path: STRING_32)
			-- Stream the root array of the file at `a_file_path'.
		require
			not_empty: not a_file_path.is_empty
		do
			make_from_file_at (a_file_path, "")
		ensure
			file_path_set: attached file_path as al_p and then al_p ~ a_file_path
			is_from_file: is_from_file
			root_array: array_key.is_empty
		end

	make_from_string (a_json_text: STRING_32)
			-- Stream the root array of `a_json_text'.
		require
			not_empty: not a_json_text.is_empty
		do
			make_from_string_at (a_json_text, "")
		ensure
			json_text_set: attached json_text as al_t and then al_t ~ a_json_text
			not_from_file: not is_from_file
			root_array: array_key.is_empty
		end

	make_from_file_at (a_file_path: STRING_32; a_key: READABLE_STRING_GENERAL)
			-- Stream the array under top-level key `a_key' of the root
			-- object in the file at `a_file_path'; an empty key means
			-- the root itself is the array.
		require
			not_empty: not a_file_path.is_empty
		do
			file_path := a_file_path
			is_from_file := True
			create array_key.make_from_string_general (a_key)
			create errors.make (Default_error_list_size)
			create buffer.make (Default_chunk_size)
			chunk_size := Default_chunk_size
		ensure
			file_path_set: attached file_path as al_p and then al_p ~ a_file_path
			is_from_file: is_from_file
			key_set: array_key.same_string_general (a_key)
		end

	make_from_string_at (a_json_text: STRING_32; a_key: READABLE_STRING_GENERAL)
			-- Stream the array under top-level key `a_key' of the root
			-- object in `a_json_text'; an empty key means the root
			-- itself is the array.
		require
			not_empty: not a_json_text.is_empty
		do
			json_text := a_json_text
			is_from_file := False
			create array_key.make_from_string_general (a_key)
			create errors.make (Default_error_list_size)
			create buffer.make (0)
			chunk_size := Default_chunk_size
		ensure
			json_text_set: attached json_text as al_t and then al_t ~ a_json_text
			not_from_file: not is_from_file
			key_set: array_key.same_string_general (a_key)
		end

feature -- Access

	new_cursor: SIMPLE_JSON_STREAM_CURSOR
			-- A fresh pass over the array, from its first element.
		do
			create Result.make (Current)
		ensure then
			cursor_attached: Result /= Void
		end

	element_count: INTEGER
			-- Elements handed out so far by the current (or last) pass.

	array_key: STRING_32
			-- The top-level key holding the array; empty for a root array.

	chunk_size: INTEGER
			-- Bytes read from the file per refill.

	file_path: detachable STRING_32
			-- Where the document is, when it is a file.

	json_text: detachable STRING_32
			-- The document, when it is a string.

feature -- Status report

	has_errors: BOOLEAN
			-- Did the current (or last) pass hit a fault?
		do
			Result := not errors.is_empty
		end

	is_from_file: BOOLEAN
			-- Is the document a file?

	is_parsed: BOOLEAN
			-- Has a pass reached the array's end (or stopped on a fault)?

	is_open: BOOLEAN
			-- Is a pass in progress?

feature -- Element change

	set_chunk_size (a_bytes: INTEGER)
			-- Read `a_bytes' per refill. Small values exist for tests
			-- that want chunk boundaries inside elements and inside
			-- multi-byte characters.
		require
			positive: a_bytes >= 1
		do
			chunk_size := a_bytes
		ensure
			set: chunk_size = a_bytes
		end

feature -- Error tracking

	last_errors: LIST [SIMPLE_JSON_ERROR]
			-- Faults of the current (or last) pass.
		do
			Result := errors
		ensure
			result_attached: Result /= Void
		end

feature -- Model Queries

	stream_errors_model: MML_SEQUENCE [SIMPLE_JSON_ERROR]
			-- Mathematical model of the faults in order.
		do
			create Result
			across errors as ic loop
				Result := Result & ic
			end
		ensure
			count_matches: Result.count = errors.count
		end

feature {SIMPLE_JSON_STREAM_CURSOR} -- A pass over the array

	open
			-- Start a pass: forget the previous one, open the source,
			-- position just inside the array's '['. On failure the
			-- pass is over before it began, with the reason in
			-- `last_errors'.
		do
			close
			errors.wipe_out
			element_count := 0
			is_parsed := False
			buffer.wipe_out
			position := 1
			is_exhausted := False
			if is_from_file then
				open_file
			else
				load_text
			end
			if not has_errors then
				skip_bom
				if array_key.is_empty then
					find_root_array
				else
					find_keyed_array
				end
			end
			if has_errors then
				is_parsed := True
				close
			else
				is_open := True
			end
		ensure
			counting_from_zero: element_count = 0
			open_or_faulted: is_open or has_errors
		end

	next_element: detachable SIMPLE_JSON_VALUE
			-- The next element of the array, or Void at its end (or on
			-- a fault, which `has_errors' reports).
		require
			open: is_open
		local
			l_text: detachable STRING_8
		do
			l_text := next_element_text
			if attached l_text as al_text then
				Result := parsed (al_text)
				if attached Result then
					element_count := element_count + 1
				end
			end
			if Result = Void then
				is_parsed := True
				close
			end
		ensure
			counted: attached Result implies element_count = old element_count + 1
			ended_when_void: Result = Void implies (is_parsed and not is_open)
		end

	close
			-- End the pass; release the file.
		do
			if attached file as al_file then
				if not al_file.is_closed then
					al_file.close
				end
				file := Void
			end
			is_open := False
		ensure
			closed: not is_open
			no_file: file = Void
		end

feature {NONE} -- Source

	Default_chunk_size: INTEGER = 65_536

	file: detachable RAW_FILE
			-- The open file during a pass.

	buffer: STRING_8
			-- The bytes in hand: one chunk of the file, or the whole
			-- text as UTF-8.

	position: INTEGER
			-- The next byte to look at, 1-based into `buffer'.

	is_exhausted: BOOLEAN
			-- Has the source given its last byte?

	open_file
		local
			l_file: RAW_FILE
		do
			if attached file_path as al_path then
				create l_file.make_with_name (al_path)
				if l_file.exists and then l_file.is_readable then
					l_file.open_read
					file := l_file
				else
					errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Cannot read file: " + al_path))
					is_exhausted := True
				end
			else
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "No file path"))
				is_exhausted := True
			end
		end

	load_text
			-- The whole string as UTF-8 bytes: one buffer, no refills.
		do
			if attached json_text as al_text then
				buffer := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (al_text)
			end
			is_exhausted := True
		end

	has_byte: BOOLEAN
			-- Is there a byte at `position', refilling from the file
			-- when the buffer is spent?
		do
			if position <= buffer.count then
				Result := True
			elseif not is_exhausted and then attached file as al_file then
				al_file.read_stream (chunk_size)
				buffer.wipe_out
				buffer.append (al_file.last_string)
				position := 1
				if buffer.is_empty then
					is_exhausted := True
				else
					Result := True
				end
			end
		ensure
			byte_in_hand: Result implies position <= buffer.count
		end

	current_byte: CHARACTER_8
			-- The byte at `position'.
		require
			has_byte: position <= buffer.count
		do
			Result := buffer.item (position)
		end

	advance
			-- Step past the current byte.
		do
			position := position + 1
		end

	skip_bom
			-- A UTF-8 byte order mark at the very start is not content.
		do
			if has_byte and then current_byte = '%/239/' then
				advance
				if has_byte and then current_byte = '%/187/' then
					advance
					if has_byte and then current_byte = '%/191/' then
						advance
					end
				end
			end
		end

	skip_whitespace
		do
			from
			until
				not has_byte or else not is_json_space (current_byte)
			loop
				advance
			end
		end

	is_json_space (a_byte: CHARACTER_8): BOOLEAN
		do
			Result := a_byte = ' ' or a_byte = '%T' or a_byte = '%N' or a_byte = '%R'
		end

feature {NONE} -- Finding the array

	find_root_array
			-- Expect '[' as the first content byte; step inside it.
		do
			skip_whitespace
			if has_byte and then current_byte = '[' then
				advance
			elseif has_byte then
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Root must be array, got: " + current_byte.out))
			else
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Root must be array, got nothing"))
			end
		end

	find_keyed_array
			-- Walk the root object's members until `array_key' names
			-- an array; step inside its '['. Other members are skipped
			-- by structure, never parsed.
		local
			l_key, l_wanted: STRING_8
			l_found, l_failed: BOOLEAN
		do
			l_wanted := {UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (array_key)
			skip_whitespace
			if not has_byte or else current_byte /= '{' then
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Root must be an object holding %"" + array_key + {STRING_32} "%""))
				l_failed := True
			else
				advance
			end
			from
			until
				l_found or l_failed
			loop
				skip_whitespace
				if not has_byte then
					l_failed := True
				elseif current_byte = '}' then
					l_failed := True
				elseif current_byte = ',' then
					advance
				elseif current_byte = '%"' then
					l_key := raw_string_bytes
					skip_whitespace
					if has_byte and then current_byte = ':' then
						advance
					end
					skip_whitespace
					if l_key.same_string (l_wanted) then
						if has_byte and then current_byte = '[' then
							advance
							l_found := True
						else
							errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Key %"" + array_key + {STRING_32} "%" does not hold an array"))
							l_failed := True
						end
					else
						skip_value
					end
				else
						-- malformed member; step on rather than spin
					advance
				end
			end
			if not l_found and then not has_errors then
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Key %"" + array_key + {STRING_32} "%" not found in the root object"))
			end
		end

	raw_string_bytes: STRING_8
			-- At '"': the bytes between the quotes, escapes left as
			-- written; `position' ends after the closing quote. Enough
			-- to compare a key; element text goes through the parser.
		require
			at_quote: has_byte and then current_byte = '%"'
		local
			l_escaped, l_done: BOOLEAN
			c: CHARACTER_8
		do
			create Result.make (32)
			advance
			from
			until
				l_done or else not has_byte
			loop
				c := current_byte
				if l_escaped then
					Result.extend (c)
					l_escaped := False
				elseif c = '\' then
					Result.extend (c)
					l_escaped := True
				elseif c = '%"' then
					l_done := True
				else
					Result.extend (c)
				end
				advance
			end
		end

	skip_value
			-- Step over the value at `position': a string, a number, a
			-- literal, or a nested object or array with the strings
			-- inside it honoured.
		local
			l_depth: INTEGER
			l_done: BOOLEAN
			l_discard: STRING_8
			c: CHARACTER_8
		do
			if has_byte then
				c := current_byte
				if c = '%"' then
					l_discard := raw_string_bytes
				elseif c = '{' or c = '[' then
					from
					until
						l_done or else not has_byte
					loop
						c := current_byte
						if c = '%"' then
							l_discard := raw_string_bytes
						else
							if c = '{' or c = '[' then
								l_depth := l_depth + 1
							elseif c = '}' or c = ']' then
								l_depth := l_depth - 1
								l_done := l_depth = 0
							end
							advance
						end
					end
				else
					from
					until
						not has_byte or else current_byte = ',' or else current_byte = '}'
							or else current_byte = ']' or else is_json_space (current_byte)
					loop
						advance
					end
				end
			end
		end

feature {NONE} -- Cutting elements

	next_element_text: detachable STRING_8
			-- The bytes of the next element, or Void at the array's
			-- end. Separators are consumed; the element's own closing
			-- byte is included; the array's ']' is consumed at the end.
		local
			l_depth: INTEGER
			l_in_string, l_escaped, l_done: BOOLEAN
			c: CHARACTER_8
		do
			skip_whitespace
			if has_byte and then current_byte = ',' then
				advance
				skip_whitespace
			end
			if not has_byte then
					-- a closed array ends the pass in the call that meets
					-- its ']', so running out of bytes here means the
					-- document ended with the array still open
				errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Array not closed before the end of the document"))
			elseif current_byte = ']' then
				advance
			else
				create Result.make (256)
				from
				until
					l_done or else not has_byte
				loop
					c := current_byte
					if l_in_string then
						Result.extend (c)
						if l_escaped then
							l_escaped := False
						elseif c = '\' then
							l_escaped := True
						elseif c = '%"' then
							l_in_string := False
						end
						advance
					elseif c = '%"' then
						Result.extend (c)
						l_in_string := True
						advance
					elseif c = '{' or c = '[' then
						Result.extend (c)
						l_depth := l_depth + 1
						advance
					elseif c = '}' or c = ']' then
						if l_depth = 0 then
								-- the array's own close: leave it for the next call
							l_done := True
						else
							Result.extend (c)
							l_depth := l_depth - 1
							advance
						end
					elseif c = ',' and then l_depth = 0 then
						l_done := True
					else
						Result.extend (c)
						advance
					end
				end
				Result.right_adjust
				if not l_done and then (l_depth > 0 or l_in_string) then
					errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Element " + (element_count + 1).out + {STRING_32} " is not terminated"))
					Result := Void
				elseif Result.is_empty then
					Result := Void
				end
			end
		end

	parsed (a_utf8: STRING_8): detachable SIMPLE_JSON_VALUE
			-- `a_utf8' as a value, or Void with an error recorded.
		local
			l_parser: SIMPLE_JSON
		do
			create l_parser
			Result := l_parser.parse ({UTF_CONVERTER}.utf_8_string_8_to_string_32 (a_utf8))
			if Result = Void then
				if l_parser.has_errors then
					across l_parser.last_errors as ic loop
						errors.extend (ic)
					end
				else
					errors.extend (create {SIMPLE_JSON_ERROR}.make ({STRING_32} "Element " + (element_count + 1).out + {STRING_32} " is not valid JSON"))
				end
			end
		ensure
			error_on_failure: Result = Void implies has_errors
		end

feature {NONE} -- Implementation

	errors: ARRAYED_LIST [SIMPLE_JSON_ERROR]
			-- Faults of the current (or last) pass.

invariant
	errors_attached: errors /= Void
	buffer_attached: buffer /= Void
	key_attached: array_key /= Void
	either_file_or_string: is_from_file implies file_path /= Void
	not_from_file_implies_text: not is_from_file implies json_text /= Void
	has_errors_definition: has_errors = not errors.is_empty
	count_non_negative: element_count >= 0
	chunk_positive: chunk_size >= 1
	open_has_no_faults: is_open implies not has_errors

note
	copyright: "Copyright (c) 2024-2026, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Streaming parser implementation
	]"

end
