# SIMPLE_JSON
### Modern JSON Library for Eiffel with RFC Compliance

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Test Coverage](https://img.shields.io/badge/test_coverage-100%25-brightgreen.svg)]()
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()
[![Documentation](https://img.shields.io/badge/docs-HTML-purple.svg)](docs/index.html)
[![EIS](https://img.shields.io/badge/EIS-enabled-blue.svg)]()

---

## Overview

SIMPLE_JSON is a production-ready JSON library for Eiffel that builds on the standard eJSON library to provide modern features found in contemporary JSON ecosystems. It offers **JSON Schema validation** (Draft 7), **JSON Pointer** navigation (RFC 6901), **JSON Patch** operations (RFC 6902), **JSON Merge Patch** (RFC 7386), **JSONPath queries**, and comprehensive error tracking—all with full Unicode/UTF-8 support through STRING_32.

The library includes **complete HTML documentation** (29 files) covering every class, feature, and test case, making it easy to learn and use. **Every source and test file includes EIS (Eiffel Information System) links** that provide F1 context-sensitive help directly in EiffelStudio—press F1 on any class to instantly view its documentation.

**Developed using AI-assisted methodology:** Built interactively with Claude Sonnet 4.5 following rigorous Design by Contract principles and maintaining 100% test coverage throughout development.

---

## 📚 Documentation

The project includes comprehensive HTML documentation with **integrated EIS links** in all source files:

### Accessing Documentation

1. **In EiffelStudio (Recommended)**: Press **F1** on any SIMPLE_JSON class or feature for instant context-sensitive help
   - All 38 source and test files include embedded EIS links
   - Documentation opens automatically in your default browser
   - Links are relative to `$(SYSTEM_PATH)` for portability

2. **In Browser**: Open `docs/index.html` in your web browser
   - Complete library reference
   - Feature-by-feature API documentation
   - Code examples and use cases

3. **Quick Reference**: Browse individual HTML files in `docs/` subfolders
   - Core classes: `docs/core/`
   - RFC features: `docs/pointer/`, `docs/patch/`, `docs/merge_patch/`
   - Advanced: `docs/schema/`, `docs/streaming/`
   - Tests: `docs/testing/`

### Documentation Coverage

**All documentation includes:**
- Detailed class descriptions with EIS links
- Feature-by-feature API reference
- Code examples and use cases
- Design by Contract specifications
- Test case documentation

**EIS-Enabled Files:**
- **25 source files** (`src/` directory)
- **13 test files** (`testing/` directory)
- **29 HTML documentation files** (`docs/` directory)

---

## Why SIMPLE_JSON?

### The Only Eiffel Library with JSON Schema Validation

**SIMPLE_JSON is the only Eiffel JSON library that implements JSON Schema validation.** This industry-standard feature (Draft 7) enables you to:

- **Validate** JSON documents against schemas before processing
- **Ensure** data integrity with type, format, and constraint checking
- **Catch errors early** with comprehensive validation reporting
- **Support** complex schemas with nested objects, arrays, and references

### Complete RFC Compliance

- ✅ **JSON Pointer** (RFC 6901) - Navigate JSON documents with path expressions
- ✅ **JSON Patch** (RFC 6902) - Apply standardized modifications to JSON
- ✅ **JSON Merge Patch** (RFC 7386) - Merge JSON documents declaratively
- ✅ **JSON Schema** (Draft 7) - Validate structure and constraints

### Modern Features

- **Streaming Parser** - Process large JSON files with minimal memory
- **JSONPath Queries** - SQL-like queries for JSON data
- **Unicode Support** - Full UTF-8/UTF-16 through STRING_32
- **Position Tracking** - Precise error locations in source text
- **EIS Integration** - F1 context-sensitive help throughout
- **100% Test Coverage** - 216 tests across all features

---

## Quick Start

### Installation

1. Add to your ECF file:

```xml
<library name="simple_json" location="$ISE_LIBRARY/contrib/library/text/parser/json/library/simple_json.ecf"/>
```

2. Or clone from GitHub:

```bash
git clone https://github.com/ljr1981/simple_json.git
```

### Basic Usage

```eiffel
class
    MY_APPLICATION

inherit
    SHARED_SIMPLE_JSON

feature

    parse_example
        local
            json_text: STRING
            value: detachable SIMPLE_JSON_VALUE
        do
            json_text := "{%"name%": %"Alice%", %"age%": 30}"
            value := json.parse (json_text)
            
            if attached value as v and then v.is_object then
                -- Use parsed object
                print (v.as_object.item ("name"))
            end
        end

end
```

**Tip:** Press **F1** on `SIMPLE_JSON` or any other class name in EiffelStudio to view its documentation instantly.

---

## Features

### 1. JSON Schema Validation ⭐ Unique Feature

Validate JSON documents against JSON Schema Draft 7:

```eiffel
schema_text: STRING_32
    do
        Result := "{%
            %"type%": %"object%",%
            %"properties%": {%
                %"name%": {%"type%": %"string%"},%
                %"age%": {%"type%": %"integer%", %"minimum%": 0}%
            %},%
            %"required%": [%"name%"]%
        %}"
    end

validate_person (data: STRING_32)
    local
        validator: SIMPLE_JSON_SCHEMA_VALIDATOR
        result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
    do
        create validator.make_from_string (schema_text)
        result := validator.validate_string (data)
        
        if result.is_valid then
            print ("Valid!%N")
        else
            across result.errors as ic loop
                print (ic.to_string + "%N")
            end
        end
    end
```

**Supports:**
- Type validation (string, number, integer, boolean, array, object, null)
- Numeric constraints (minimum, maximum, multipleOf)
- String constraints (minLength, maxLength, pattern)
- Array constraints (minItems, maxItems, uniqueItems)
- Object constraints (required, properties, additionalProperties)
- Schema composition (allOf, anyOf, oneOf, not)
- References ($ref) for schema reuse

### 2. JSON Pointer (RFC 6901)

Navigate JSON with path expressions:

```eiffel
pointer_example
    local
        json_text: STRING_32
        value: detachable SIMPLE_JSON_VALUE
        pointer: SIMPLE_JSON_POINTER
    do
        json_text := "{%"users%": [{%"name%": %"Alice%"}]}"
        value := json.parse (json_text)
        
        if attached value as v then
            create pointer.make_from_string ("/users/0/name")
            if attached pointer.value_at (v) as name_value then
                print (name_value.as_string_32)  -- Prints: Alice
            end
        end
    end
```

### 3. JSON Patch (RFC 6902)

Apply standardized modifications:

```eiffel
patch_example
    local
        doc: STRING_32
        patch: STRING_32
        patcher: SIMPLE_JSON_PATCH
        result: detachable SIMPLE_JSON_VALUE
    do
        doc := "{%"name%": %"Alice%", %"age%": 30}"
        patch := "[{%"op%": %"replace%", %"path%": %"/age%", %"value%": 31}]"
        
        create patcher.make_from_string (patch)
        result := patcher.apply_to_string (doc)
    end
```

**Operations:** add, remove, replace, move, copy, test

### 4. JSON Merge Patch (RFC 7386)

Declarative document merging:

```eiffel
merge_example
    local
        target: STRING_32
        patch: STRING_32
        merger: SIMPLE_JSON_MERGE_PATCH
        result: detachable SIMPLE_JSON_VALUE
    do
        target := "{%"name%": %"Alice%", %"age%": 30}"
        patch := "{%"age%": 31, %"city%": %"NYC%"}"
        
        create merger
        result := merger.apply_from_strings (target, patch)
        -- Result: {"name": "Alice", "age": 31, "city": "NYC"}
    end
```

### 5. Streaming Parser

Process large files efficiently:

```eiffel
stream_example
    local
        stream: SIMPLE_JSON_STREAM
    do
        create stream.make_from_file ("large_array.json")
        
        across stream as ic loop
            -- ic.value: SIMPLE_JSON_VALUE
            -- ic.index: INTEGER position
            process_element (ic.value)
        end
        
        if stream.has_errors then
            -- Handle errors
        end
    end
```

### 6. JSONPath Queries

SQL-like queries for JSON data:

```eiffel
query_example
    local
        json_text: STRING_32
        value: detachable SIMPLE_JSON_VALUE
        query: SIMPLE_JSON_PATH_QUERY
        results: ARRAYED_LIST [SIMPLE_JSON_VALUE]
    do
        json_text := "{%"users%": [{%"name%": %"Alice%"}, {%"name%": %"Bob%"}]}"
        value := json.parse (json_text)
        
        if attached value as v then
            create query
            results := query.execute (v, "$.users[*].name")
            -- Results: ["Alice", "Bob"]
        end
    end
```

### 7. Pretty Printing

Format JSON for readability:

```eiffel
pretty_example
    local
        obj: SIMPLE_JSON_OBJECT
        pretty: SIMPLE_JSON_PRETTY_PRINT_VISITOR
    do
        create obj.make
        obj.put_string ("Alice", "name")
           .put_integer (30, "age")
        
        create pretty.make_with_indent (2)
        obj.accept (pretty)
        print (pretty.formatted_output)
    end
```

---

## Building & Testing

### Build Library

```bash
cd simple_json
ec -config simple_json.ecf -target simple_json
```

### Run Tests

```bash
ec -config simple_json.ecf -target test_simple_json
```

**Test Coverage:** 100% (216 tests)

Test suites cover:
- Core JSON parsing and generation
- JSON Schema validation (all keywords)
- JSON Pointer navigation
- JSON Patch operations
- JSON Merge Patch
- Streaming parser
- JSONPath queries
- Error handling and edge cases

---

## API Design

### Abstraction Levels

SIMPLE_JSON provides multiple ways to work with JSON:

1. **One-liners** - Quick value extraction
2. **Path navigation** - Dot notation access  
3. **Query interface** - Type-safe checks
4. **Fluent builder** - Method chaining
5. **Full API** - Complete JSON_VALUE access

### Design by Contract

Every feature includes:
- **Preconditions** - What callers must ensure
- **Postconditions** - What the feature guarantees
- **Invariants** - What's always true

Example:

```eiffel
put_value (v: SIMPLE_JSON_VALUE; k: STRING_32): SIMPLE_JSON_OBJECT
    require
        value_attached: v /= Void
        key_attached: k /= Void
        key_not_empty: not k.is_empty
    do
        -- implementation
    ensure
        value_stored: item (k) = v
    end
```

### Void Safety

All types properly declared as attached or detachable:

```eiffel
-- Attached (cannot be void)
json_object: SIMPLE_JSON_OBJECT

-- Detachable (can be void)
optional_value: detachable SIMPLE_JSON_VALUE
```

---

## EIS Documentation System

### What is EIS?

EIS (Eiffel Information System) provides **context-sensitive documentation** directly in EiffelStudio. Every class in SIMPLE_JSON includes embedded documentation links.

### Using EIS

1. **Open any SIMPLE_JSON class** in EiffelStudio
2. **Press F1** on the class name or feature
3. **Documentation opens automatically** in your browser

### EIS Link Format

All EIS links use the `$(SYSTEM_PATH)` variable for portability:

```eiffel
note
    description: "Class description here"
    EIS: "name=Documentation", 
         "protocol=URI", 
         "src=file://$(SYSTEM_PATH)/docs/docs/core/simple_json.html"
```

### Configuring EIS

The `$(SYSTEM_PATH)` variable is defined in `simple_json.ecf`:

```xml
<variable name="SYSTEM_PATH" value="D:\prod\simple_json"/>
```

Update this path to match your local installation directory.

---

## Project Structure

```
simple_json/
├── docs/                       # HTML Documentation (29 files)
│   ├── index.html             # Documentation home page
│   ├── core/                  # Core class documentation
│   ├── pointer/               # JSON Pointer docs
│   ├── patch/                 # JSON Patch docs
│   ├── merge_patch/           # Merge Patch docs
│   ├── schema/                # Schema validation docs
│   ├── streaming/             # Streaming parser docs
│   ├── utilities/             # Utility class docs
│   └── testing/               # Test documentation
├── src/                       # Source code (25 files with EIS)
│   ├── core/                  # Core JSON types
│   ├── pointer/               # JSON Pointer (RFC 6901)
│   ├── patch/                 # JSON Patch (RFC 6902)
│   ├── merge_patch/           # Merge Patch (RFC 7386)
│   ├── schema/                # Schema validation
│   ├── streaming/             # Streaming parser
│   └── utilities/             # Helper classes
├── testing/                   # Test suites (13 files with EIS)
├── simple_json.ecf           # Library configuration
├── README.md                 # This file
└── LICENSE                   # MIT License
```

---

## Dependencies

- **Eiffel eJSON library** - Base JSON parsing (included with EiffelStudio)
- **Gobo Regular Expressions** - For pattern validation
- **EiffelStudio 23.09+** - Development environment

---

## Development Methodology

### AI-Assisted Development

SIMPLE_JSON was developed using an innovative AI-assisted methodology:

- **Interactive Design:** Features designed through conversation with Claude Sonnet 4.5
- **Iterative Implementation:** Code generated, tested, and refined collaboratively  
- **Continuous Validation:** 100% test coverage maintained throughout
- **Design by Contract:** All features include comprehensive contracts
- **RFC Compliance:** Standards verified against official specifications
- **EIS Integration:** Documentation embedded in source code for immediate access

This approach enabled:
- Rapid feature implementation with high quality
- Comprehensive test coverage from the start
- Clear documentation generated alongside code
- Consistent design patterns across the library
- Integrated context-sensitive help system

### Development Principles

1. **Test-First:** Tests written before or alongside implementation
2. **Contract-Driven:** Preconditions, postconditions, invariants mandatory
3. **Void-Safe:** All types properly declared
4. **Unicode-First:** STRING_32 for all text handling
5. **RFC-Compliant:** Standards strictly followed
6. **EIS-Enabled:** Documentation accessible via F1

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Ensure 100% test coverage
5. Follow Eiffel coding conventions
6. Include Design by Contract assertions
7. Add EIS documentation links
8. Update HTML documentation
9. Submit a pull request

---

## Future Work Roadmap

SIMPLE_JSON is a production-ready library with comprehensive JSON support. The following enhancements represent opportunities to further strengthen and extend the library's capabilities. Contributions in these areas are welcome.

### Phase 1: Quality Hardening (Priority: High)

**1.1 Design by Contract Enhancement**

Systematic review and strengthening of contracts across the library:

- **Scope:** Review all 25 source files for contract completeness
- **Focus Areas:**
  - Strengthen preconditions (numeric bounds, string constraints, state validation)
  - Enhance postconditions (relationship preservation, side effects)
  - Add loop invariants to iterative features
  - Verify class invariants comprehensively cover object state
- **Expected Benefits:**
  - Early detection of edge cases and potential bugs
  - Improved runtime verification in finalized mode
  - Better documentation of feature contracts
  - Stronger guarantees for library users
- **Estimated Effort:** 1-2 days
- **Impact:** Prevents entire categories of bugs, improves long-term maintainability

**1.2 Test Suite Optimization**

Migrate appropriate test assertions into production contracts:

- **Scope:** Review 216 tests across 13 test files
- **Strategy:**
  - Identify assertions verifying properties that should ALWAYS hold
  - Move invariant relationships into class contracts
  - Move state change verification into postconditions
  - Retain integration tests, edge cases, and error scenarios as tests
- **Expected Benefits:**
  - Reduced test code maintenance (15-25% reduction expected)
  - Stronger runtime verification
  - Clearer contract specifications
  - More focused test suite on integration scenarios
- **Estimated Effort:** 1.5-2 days
- **Impact:** Improves code quality while reducing test maintenance burden

### Phase 2: Standards Completion (Priority: Medium-High)

**2.1 JSON Canonicalization Scheme (RFC 8785)**

Implement deterministic JSON representation for cryptographic operations:

- **Use Cases:**
  - Digital signatures over JSON documents
  - Content-addressable storage (hash-based identification)
  - Blockchain and distributed ledger applications
  - Secure configuration management
- **Implementation Requirements:**
  - Lexicographic ordering of object keys
  - Normalized whitespace handling
  - Unicode escape sequence normalization
  - Standardized number formatting
  - Minimal string escaping
- **Deliverables:**
  - `SIMPLE_JSON_CANONICALIZER` class (~200-300 lines)
  - Test suite with RFC-provided test vectors
  - Round-trip verification tests
  - EIS documentation and examples
- **Estimated Effort:** 0.5-1 day
- **Impact:** Completes RFC suite, enables cryptographic JSON use cases

### Phase 3: User Experience (Priority: Medium)

**3.1 Expanded Documentation Examples**

Create comprehensive use case gallery demonstrating real-world scenarios:

- **Proposed Additions:**
  - **Use Case Gallery** (10-15 scenarios):
    - API response validation
    - Configuration management
    - Document transformation pipelines
    - Large file streaming
    - Schema-driven data entry
    - Cryptographic signatures (with RFC 8785)
  - **Anti-Patterns Guide:**
    - Common mistakes and their solutions
    - Type-checking pitfalls
    - Memory management best practices
  - **Cookbook Recipes:**
    - Quick-reference solutions for common tasks
    - Copy-paste ready code examples
    - Error handling patterns
- **Estimated Effort:** 1-1.5 days
- **Impact:** Significantly improves library adoption and user success

### Phase 4: Future Considerations (Priority: Low-Medium)

**4.1 JSON Schema Draft 2020-12**

Upgrade from Draft 7 to latest specification:

- **Current Status:** Draft 7 implementation is comprehensive and stable
- **Considerations:**
  - Draft 7 covers 95% of real-world validation needs
  - Draft 2020-12 adds complexity with marginal benefit for most users
  - Significant implementation effort (1+ week)
- **Recommendation:** Evaluate based on user demand
- **Estimated Effort:** 1-2 weeks if pursued

**4.2 JSON-LD (Linked Data)**

Semantic web capabilities for JSON:

- **Scope:** W3C Recommendation for linking JSON data
- **Complexity:** Very high (context resolution, compaction, expansion, framing)
- **Recommendation:** Consider as separate library (`SIMPLE_JSON_LD`) building on SIMPLE_JSON
- **Rationale:** Fundamentally different use case (semantics vs. structure)
- **Estimated Effort:** 4-5 days for comprehensive implementation

**4.3 JSON Lines Format Support**

Newline-delimited JSON streams:

- **Current Status:** Streaming parser handles this use case
- **Consideration:** Explicit JSON Lines support may improve clarity
- **Estimated Effort:** Minimal (few hours)
- **Priority:** Low (existing capabilities sufficient)

### Development Timeline

For contributors working at typical development pace:

- **Quality Hardening (Phase 1):** 2.5-4 days
- **RFC 8785 (Phase 2):** 0.5-1 day
- **Documentation (Phase 3):** 1-1.5 days

**Total for high-priority items:** 4.5-6.5 days

### Contributing to Roadmap Items

Contributors interested in implementing roadmap items should:

1. Open an issue discussing the specific enhancement
2. Review existing code patterns and conventions
3. Maintain 100% test coverage for new features
4. Follow Design by Contract principles
5. Add EIS documentation links
6. Update HTML documentation
7. Submit pull request with comprehensive tests

The library maintainer is available to provide guidance and review contributions.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Resources

### Documentation
- [HTML Documentation](docs/index.html) - Complete library reference
- **EIS Links** - Press F1 in EiffelStudio on any SIMPLE_JSON class
- [JSON Specification](https://www.json.org/) - JSON standard
- [JSON Schema](https://json-schema.org/) - Schema validation spec
- [RFC 6901](https://tools.ietf.org/html/rfc6901) - JSON Pointer
- [RFC 6902](https://tools.ietf.org/html/rfc6902) - JSON Patch
- [RFC 7386](https://tools.ietf.org/html/rfc7386) - JSON Merge Patch
- [RFC 8785](https://tools.ietf.org/html/rfc8785) - JSON Canonicalization Scheme

### Eiffel Resources
- [Eiffel Software](https://www.eiffel.org/) - Official Eiffel site
- [EiffelStudio](https://www.eiffel.org/downloads) - Download IDE
- [Eiffel Documentation](https://www.eiffel.org/doc/) - Language reference
- [EIS Documentation](https://www.eiffel.org/doc/eiffelstudio/EIS) - Eiffel Information System

---

## Contact

- **Author:** Larry Rix
- **Repository:** https://github.com/ljr1981/simple_json
- **Issues:** https://github.com/ljr1981/simple_json/issues

---

## Acknowledgments

- Built on the eJSON library (ISE Eiffel)
- Developed with Claude Sonnet 4.5 (Anthropic)
- JSON Schema implementation follows Draft 7 specification
- RFC compliance validated against official test suites
- EIS documentation system for integrated help

---

**Note:** This library demonstrates the potential of AI-assisted software development while maintaining professional quality standards through rigorous testing, Design by Contract principles, and integrated documentation via EIS.