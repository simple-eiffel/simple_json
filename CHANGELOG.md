# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-10-08

### Fixed
- The `simple_json_benchmark` target compiles again (4 VTCT). BENCHMARK_LOGGER used the ISE `TIME`, `DATE`,
  `DATE_TIME` and `DATE_TIME_DURATION`, which the target no longer sees. It now times with the new
  `SIMPLE_MONOTONIC_CLOCK` from simple_datetime (0.1.2) and stamps the header with `SIMPLE_DATE_TIME`. No ISE
  `time` library is added. Operations per second now use at least 1 ms so a sub-millisecond run cannot violate
  its precondition.

## [1.0.2] - 2026-10-08

### Fixed
- **The first add to any array faulted - and under SCOOP it killed the
  process.** Every `SIMPLE_JSON_ARRAY` add feature (`add_string`, `add_integer`,
  `add_real`, `add_decimal`, `add_boolean`, `add_null`, `add_object`,
  `add_array`, `add_value`) carried `previous_kept: old count = 0 or else
  json_value.i_th (old count) = old json_value.i_th (count)`. An `old`
  expression is evaluated on entry whatever guards the clause, so on an
  empty array it ran `i_th (0)`. ejson's `JSON_ARRAY` and base's
  `ARRAYED_LIST` check no preconditions in a client build: the read took the
  storage's block header as a reference and dereferenced it, a segmentation
  fault. One thread at a time the runtime turned it into an
  `OPERATING_SYSTEM_SIGNAL_FAILURE` that the old-expression trap kept and
  never raised, so no test failed. Several SCOOP processors faulting together
  killed simple_chat's server ("PANIC: caught signal #11", or no word at all)
  a few dozen posts into a busy room, 2026-10-08. The clause now takes `old
  last_json_value`, which is Void on an empty array and never indexes outside
  `1..count`. Introduced with the O(1) postconditions of 2026-09-11.
- New `EMPTY_ARRAY_ADD_TESTS` (10 tests) read the runtime's last exception
  around each add to an empty array: 9 failed before the fix, all pass after.
  New target `simple_json_scoop_tests` (SCOOP): eight processors build 20,000
  arrays each from empty. Before the fix it died with a segmentation fault on
  5 runs of 5; after it, 480,000 elements and 0 faults on 5 of 5.

## [1.0.1] - 2026-10-08

### Fixed
- Two documentation examples damaged by the 2026-02-05/06 naming-standards rename are back to their
  original text (`simple_json_serializable.e`: `as n` / `n.to_string_8`; `simple_json_quick.e`: `as obj`).
  Taken from the rename commits' own diffs; text only, no code change.
- **An unterminated string hung the parser for ~34 s and ~2 GB.** ISE's
  `JSON_PARSER.next_json_string` does not stop at end of input, so text like
  `{"t":"hol` (a torn JSONL line after a crash) kept appending NUL to its
  buffer until the INTEGER index overflowed (~2^31 steps) and only then raised.
  `parse` and `is_valid_json` now refuse such text before calling the parser,
  with the error "Unterminated string starting at byte N". The adversarial test
  `test_unclosed_string`, which had been disabled to avoid the hang, is real
  again. Found by simple_prompter's journal replay, 2026-10-05.
- The remaining `model_count` invariants (errors, patch operations, pointer segments, schema results, serializer exclusions) went the same way as the array's and object's: O(1) invariants only.
- **Big documents were quadratic to read under DBC.** `SIMPLE_JSON_ARRAY`'s
  invariants walked every element (and built the MML model) on every
  feature call, `SIMPLE_JSON_OBJECT`'s copied every key, and `keys' re-walked
  its own prefix inside its loop invariant. Reading a 1434-element array
  through `object_item` cost 158 s of CPU (simple_ocr_capture, a 391 KB
  YouTube caption track, 2026-09-11). Invariants are now O(1) - the edges of
  the index range, the count identities - and the per-element facts live in
  the postconditions that establish them. The `prefix_unchanged` /
  `keys_frame` model comparisons on every add/put (O(n) each, quadratic to
  build) became O(1) neighbour checks. Measured in the new
  `BIG_DOCUMENT_TESTS` with assertions on: parse and walk 3000 events 453 ms,
  build a 3000-element array 15 ms, `keys` of a 2000-member object 0 ms.
- **`SIMPLE_JSON_STREAM` now streams.** The old class parsed the whole
  document, copied the array into a list, and checked that list in its
  invariants - streaming in name only. It now reads a file in chunks
  (`chunk_size`, 64 KB by default), cuts each array element out with a
  structural scanner (strings, escapes and nesting honoured), and parses one
  element at a time; memory is one chunk plus one element. `make_from_file_at`
  / `make_from_string_at` stream the array under a top-level key of a root
  object (`"events"` in a caption track) without parsing the rest. A
  multi-byte character split across a chunk boundary arrives whole (tested
  with a 7-byte chunk). 3000 events: 375 ms from a file, 469 ms from a string,
  assertions on.
- Characters beyond the Basic Multilingual Plane (every emoji, e.g. U+1F916) did not survive `put_string` / `add_string` / `json_string`: the underlying ejson escaper wrote a five-digit `\u1F916`, which its own decoder read back as U+1F91 followed by `6`. `SIMPLE_JSON_OBJECT.put_string`'s `value_stored` postcondition caught it (2026-08-29). All string text is now escaped by the new `SIMPLE_JSON_TEXT` (non-ASCII as raw UTF-8 per RFC 8259) and never by ejson.
- Surrogate-pair escapes (`\ud83e\udd16`, as emitted by Python's `json`, older Java and `JSON.stringify`) decoded to two lone surrogates; they are now combined into the one character on every `string_item` / `as_string_32`.

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Migrate to simple_testing library
- Remove redundant result_not_void postconditions
- Add as_json and as_json_32 output features to SIMPLE_JSON_VALUE
- Add friction-free JSON helper methods and serialization pattern
- Added in JSON1 for SQLite
- Fixed obsolete calls using Claude CLI
- Readme.MD update
- json array preconditions/constants
- New constants class and magic-number replacement(s) system wide

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_json/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_json/releases/tag/v1.0.0
