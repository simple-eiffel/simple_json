note
	description: "[
		Big documents, timed. A wrapper library that is correct on ten
		elements and unusable on ten thousand is not finished; these
		tests build a document shaped like a real one (a YouTube json3
		caption track: an object holding an events array of small
		objects) at a few thousand elements and time each way through
		it. The elapsed milliseconds are printed so a regression is
		visible in the test log, and each test also asserts a ceiling
		generous enough to pass on any machine but far below the
		quadratic case (the 1434-event track that cost 158 s of CPU in
		simple_ocr_capture on 2026-09-11).
	]"
	author: "Larry Rix"
	testing: "covers"

class
	BIG_DOCUMENT_TESTS

inherit
	TEST_SET_BASE

feature -- Test: DOM parse and walk

	test_parse_and_walk_events
			-- Parse a 3000-event document and read every event's
			-- fields through the wrappers.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.object_item, covers/{SIMPLE_JSON_OBJECT}.integer_item"
		local
			l_json: SIMPLE_JSON
			l_events: detachable SIMPLE_JSON_ARRAY
			i, l_words: INTEGER
			l_started, l_elapsed: INTEGER_64
		do
			create l_json
			l_started := now_ms
			if attached l_json.parse (events_document (Event_count)) as al_value and then al_value.is_object then
				l_events := al_value.as_object.array_item ("events")
			end
			assert_attached ("parsed", l_events)
			if attached l_events as al_events then
				assert_integers_equal ("all events", Event_count, al_events.count)
				from
					i := 1
				until
					i > al_events.count
				loop
					if attached al_events.object_item (i) as al_event then
						l_words := l_words + al_event.integer_item ("tStartMs").to_integer_32 \\ 7
						if attached al_event.array_item ("segs") as al_segs and then attached al_segs.object_item (1) as al_seg
							and then attached al_seg.string_item ("utf8") as al_text
						then
							l_words := l_words + al_text.count
						end
					end
					i := i + 1
				end
			end
			l_elapsed := now_ms - l_started
			print ("    parse + walk " + Event_count.out + " events: " + l_elapsed.out + " ms%N")
			assert_true ("walked something", l_words > 0)
			assert_true ("under the ceiling (" + l_elapsed.out + " ms)", l_elapsed < Ceiling_ms)
		end

	test_keys_of_wide_object
			-- `keys' on an object with 2000 members must be linear.
		note
			testing: "covers/{SIMPLE_JSON_OBJECT}.keys"
		local
			l_json: SIMPLE_JSON
			l_object: SIMPLE_JSON_OBJECT
			i: INTEGER
			l_started, l_elapsed: INTEGER_64
		do
			create l_json
			l_object := l_json.new_object
			from
				i := 1
			until
				i > 2000
			loop
				l_object := l_object.put_integer (i, "k" + i.out)
				i := i + 1
			end
			l_started := now_ms
			assert_integers_equal ("all keys", 2000, l_object.keys.count)
			assert_true ("has last", l_object.has_key ("k2000"))
			l_elapsed := now_ms - l_started
			print ("    keys of 2000-member object: " + l_elapsed.out + " ms%N")
			assert_true ("under the ceiling (" + l_elapsed.out + " ms)", l_elapsed < Ceiling_ms)
		end

feature -- Test: building

	test_build_wide_array
			-- Append 3000 elements through the fluent API.
		note
			testing: "covers/{SIMPLE_JSON_ARRAY}.add_integer"
		local
			l_json: SIMPLE_JSON
			l_array: SIMPLE_JSON_ARRAY
			i: INTEGER
			l_started, l_elapsed: INTEGER_64
		do
			create l_json
			l_array := l_json.new_array
			l_started := now_ms
			from
				i := 1
			until
				i > Event_count
			loop
				l_array := l_array.add_integer (i)
				i := i + 1
			end
			l_elapsed := now_ms - l_started
			print ("    build " + Event_count.out + "-element array: " + l_elapsed.out + " ms%N")
			assert_integers_equal ("all added", Event_count, l_array.count)
			assert_integers_equal ("last kept", Event_count, l_array.integer_item (Event_count).to_integer_32)
			assert_true ("under the ceiling (" + l_elapsed.out + " ms)", l_elapsed < Ceiling_ms)
		end

feature -- Test: streaming

	test_stream_events_from_string
			-- Stream the events array out of the document one element
			-- at a time, never holding the whole array.
		note
			testing: "covers/{SIMPLE_JSON_STREAM}.new_cursor"
		local
			l_stream: SIMPLE_JSON_STREAM
			l_count, l_last_start: INTEGER
			l_started, l_elapsed: INTEGER_64
		do
			l_started := now_ms
			create l_stream.make_from_string_at (events_document (Event_count), "events")
			across
				l_stream as ic
			loop
				l_count := l_count + 1
				if ic.value.is_object then
					l_last_start := ic.value.as_object.integer_item ("tStartMs").to_integer_32
				end
			end
			l_elapsed := now_ms - l_started
			print ("    stream " + Event_count.out + " events from a string: " + l_elapsed.out + " ms%N")
			assert_false ("no errors", l_stream.has_errors)
			assert_integers_equal ("all events streamed", Event_count, l_count)
			assert_integers_equal ("last event seen", (Event_count - 1) * 2000, l_last_start)
			assert_true ("under the ceiling (" + l_elapsed.out + " ms)", l_elapsed < Ceiling_ms)
		end

	test_stream_events_from_file
			-- The same through a file, read in chunks.
		note
			testing: "covers/{SIMPLE_JSON_STREAM}.make_from_file_at"
		local
			l_stream: SIMPLE_JSON_STREAM
			l_file: RAW_FILE
			l_count: INTEGER
			l_started, l_elapsed: INTEGER_64
		do
			create l_file.make_create_read_write ("big_document_test.json")
			l_file.put_string ({UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (events_document (Event_count)))
			l_file.close
			l_started := now_ms
			create l_stream.make_from_file_at ("big_document_test.json", "events")
			across
				l_stream as ic
			loop
				l_count := l_count + 1
			end
			l_elapsed := now_ms - l_started
			print ("    stream " + Event_count.out + " events from a file: " + l_elapsed.out + " ms%N")
			l_file.delete
			assert_false ("no errors", l_stream.has_errors)
			assert_integers_equal ("all events streamed", Event_count, l_count)
			assert_integers_equal ("count reported", Event_count, l_stream.element_count)
			assert_true ("under the ceiling (" + l_elapsed.out + " ms)", l_elapsed < Ceiling_ms)
		end

	test_stream_root_array_of_strings_with_brackets
			-- Brackets and quotes inside strings must not fool the
			-- element scanner.
		note
			testing: "covers/{SIMPLE_JSON_STREAM}.new_cursor"
		local
			l_stream: SIMPLE_JSON_STREAM
			l_texts: ARRAYED_LIST [STRING_32]
		do
			create l_texts.make (4)
			create l_stream.make_from_string ("[ %"a ] b%", %"c \%" [ d%", {%"k%": %"}%"}, [1, [2, 3]] ]")
			across
				l_stream as ic
			loop
				l_texts.extend (ic.value.to_json_string)
			end
			assert_false ("no errors", l_stream.has_errors)
			assert_integers_equal ("four elements", 4, l_texts.count)
			assert_true ("first", l_texts.i_th (1).same_string_general ("%"a ] b%""))
			assert_true ("second", l_texts.i_th (2).same_string_general ("%"c \%" [ d%""))
			assert_true ("third is object", l_texts.i_th (3).has_substring ({STRING_32} "%"k%""))
			assert_true ("fourth is nested", l_texts.i_th (4).has_substring ({STRING_32} "[2,3]") or l_texts.i_th (4).has_substring ({STRING_32} "[2, 3]"))
		end

	test_stream_unicode_survives_chunking
			-- A multi-byte character split across two read chunks must
			-- arrive whole; the file test forces small chunks.
		note
			testing: "covers/{SIMPLE_JSON_STREAM}.set_chunk_size"
		local
			l_stream: SIMPLE_JSON_STREAM
			l_file: RAW_FILE
			l_doc: STRING_32
			i: INTEGER
			l_ok: BOOLEAN
		do
			create l_doc.make (2000)
			l_doc.append_string_general ("[")
			from
				i := 1
			until
				i > 60
			loop
				if i > 1 then
					l_doc.append_character (',')
				end
				l_doc.append_string_general ("{%"t%": %"")
				l_doc.append_code (0x5D0) -- Hebrew alef
				l_doc.append_code (0x1F600) -- emoji, four UTF-8 bytes
				l_doc.append_string_general ("%"}")
				i := i + 1
			end
			l_doc.append_character (']')
			create l_file.make_create_read_write ("big_document_unicode.json")
			l_file.put_string ({UTF_CONVERTER}.utf_32_string_to_utf_8_string_8 (l_doc))
			l_file.close
			create l_stream.make_from_file ("big_document_unicode.json")
			l_stream.set_chunk_size (7)
			l_ok := True
			i := 0
			across
				l_stream as ic
			loop
				i := i + 1
				if not (ic.value.is_object and then attached ic.value.as_object.string_item ("t") as al_t
					and then al_t.count = 2 and then al_t.code (1) = 0x5D0 and then al_t.code (2) = 0x1F600)
				then
					l_ok := False
				end
			end
			l_file.delete
			assert_false ("no errors", l_stream.has_errors)
			assert_integers_equal ("sixty elements", 60, i)
			assert_true ("every character whole", l_ok)
		end

feature {NONE} -- Fixtures

	Event_count: INTEGER = 3000

	Ceiling_ms: INTEGER_64 = 8000
			-- Generous: the quadratic version needs minutes.

	events_document (a_count: INTEGER): STRING_32
			-- A json3-shaped document with `a_count' events, each two
			-- segments, 2 s apart.
		local
			i: INTEGER
		do
			create Result.make (a_count * 120)
			Result.append_string_general ("{%"wireMagic%": %"pb3%", %"events%": [")
			from
				i := 0
			until
				i >= a_count
			loop
				if i > 0 then
					Result.append_character (',')
				end
				Result.append_string_general ("{%"tStartMs%": ")
				Result.append_string_general ((i * 2000).out)
				Result.append_string_general (", %"dDurationMs%": 1990, %"wWinId%": 1, %"segs%": [{%"utf8%": %"word")
				Result.append_string_general (i.out)
				Result.append_string_general ("%"}, {%"utf8%": %" more%", %"tOffsetMs%": 400}]}")
				i := i + 1
			end
			Result.append_string_general ("]}")
		end

	now_ms: INTEGER_64
			-- Milliseconds since boot; only differences are used.
		external
			"C inline use <windows.h>"
		alias
			"return (EIF_INTEGER_64) GetTickCount64 ();"
		end

end
