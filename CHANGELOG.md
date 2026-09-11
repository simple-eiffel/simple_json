# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
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
