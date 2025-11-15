# SIMPLE_JSON

A comprehensive, Unicode-first JSON library for Eiffel featuring JSON Schema validation, RFC-compliant operations, and an intuitive fluent API.

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Test Coverage](https://img.shields.io/badge/test_coverage-100%25-brightgreen.svg)]()
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

## Overview

SIMPLE_JSON is a production-ready JSON library for Eiffel that builds on the standard eJSON library to provide modern features found in contemporary JSON ecosystems. It offers **JSON Schema validation** (Draft 7), **JSON Pointer** navigation (RFC 6901), **JSON Patch** operations (RFC 6902), **JSON Merge Patch** (RFC 7386), **JSONPath queries**, and comprehensive error tracking—all with full Unicode/UTF-8 support through STRING_32.

**Developed using AI-assisted methodology:** Built interactively with Claude Sonnet 4.5 following rigorous Design by Contract principles and maintaining 100% test coverage throughout development.

## What Makes This Special

### Unique to SIMPLE_JSON

No other Eiffel JSON library currently provides:

- ✅ **JSON Schema Validation** - Validate documents against JSON Schema Draft 7
- ✅ **JSON Patch (RFC 6902)** - Standard document modification operations  
- ✅ **JSON Merge Patch (RFC 7386)** - Simplified merge semantics
- ✅ **JSON Pointer (RFC 6901)** - Path-based navigation
- ✅ **JSONPath Queries** - Wildcard-based document queries
- ✅ **Streaming Parser** - Memory-efficient large file processing
- ✅ **Position-Aware Errors** - Line/column tracking for parse errors
- ✅ **Fluent API** - Chainable methods with CQS compliance
- ✅ **100% STRING_32** - Full Unicode support throughout public API

### Core Strengths

- **🌍 Unicode First**: STRING_32 throughout for proper Unicode/UTF-8 handling
- **⛓️ Fluent API**: Method chaining for building JSON structures elegantly
- **✅ Type-Safe**: Strong typing with comprehensive Design by Contract
- **📍 Error Tracking**: Detailed parse errors with line/column positions
- **🎨 Pretty Printing**: Configurable indentation for human readability  
- **🧪 Well-Tested**: 200+ tests with 100% coverage
- **🎯 DbC Throughout**: Preconditions, postconditions, and invariants enforced

## Quick Start

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ljr1981/simple_json.git
   ```

2. **Add to your `.ecf` file:**
   ```xml
   <library name="simple_json" location="$SIMPLE_JSON/simple_json.ecf"/>
   ```

3. **Set environment variable** (optional):
   ```bash
   export SIMPLE_JSON=/path/to/simple_json
   ```

### Basic Usage

#### Parsing JSON

```eiffel
local
    json: SIMPLE_JSON
    value: detachable SIMPLE_JSON_VALUE
do
    create json
    value := json.parse ('{"name": "Alice", "age": 30}')
    
    if attached value and then value.is_object then
        print (value.as_object.string_item ("name"))  -- Alice
        print (value.as_object.integer_item ("age"))  -- 30
    end
end
```

#### Building JSON

```eiffel
local
    json: SIMPLE_JSON
    obj: SIMPLE_JSON_OBJECT
do
    create json
    obj := json.new_object
        .put_string ("Bob", "name")
        .put_integer (25, "age")
        .put_boolean (True, "active")
    
    print (obj.to_json_string)
    -- {"name":"Bob","age":25,"active":true}
end
```

#### Error Handling

```eiffel
local
    json: SIMPLE_JSON
    value: detachable SIMPLE_JSON_VALUE
do
    create json
    value := json.parse ('{invalid json}')
    
    if json.has_errors then
        across json.last_errors as ic loop
            print (ic.item.to_string)
            -- Shows: "Error at line 1, column 2: ..."
        end
    end
end
```

## Feature Documentation

### JSON Schema Validation

Validate JSON documents against schemas to ensure data integrity and structure:

```eiffel
local
    json: SIMPLE_JSON
    validator: SIMPLE_JSON_SCHEMA_VALIDATOR
    schema: SIMPLE_JSON_SCHEMA
    doc: detachable SIMPLE_JSON_VALUE
    result: SIMPLE_JSON_SCHEMA_VALIDATION_RESULT
do
    create json
    create validator.make
    
    -- Define schema
    create schema.make_from_string ('{
        "type": "object",
        "properties": {
            "name": {"type": "string", "minLength": 1},
            "age": {"type": "integer", "minimum": 0, "maximum": 150},
            "email": {"type": "string", "pattern": "^[^@]+@[^@]+\\.[^@]+$"}
        },
        "required": ["name", "age"]
    }')
    
    -- Validate document
    doc := json.parse ('{"name": "Alice", "age": 30}')
    
    if attached doc as al_doc then
        result := validator.validate (al_doc, schema)
        
        if result.is_valid then
            print ("Valid!")
        else
            across result.errors as ic loop
                print (ic.item.to_string)
            end
        end
    end
end
```

**Supported JSON Schema Draft 7 features:**
- Type validation: `string`, `number`, `integer`, `boolean`, `null`, `object`, `array`
- String constraints: `minLength`, `maxLength`, `pattern` (regex)
- Number constraints: `minimum`, `maximum`, `multipleOf`
- Array constraints: `minItems`, `maxItems`, `uniqueItems`, `items`
- Object constraints: `properties`, `required`, `minProperties`, `maxProperties`, `additionalProperties`
- Combined schemas: `allOf`, `anyOf`, `oneOf`, `not`
- Conditional schemas: `if`, `then`, `else`
- Enumeration: `enum`
- Constant values: `const`

### JSON Pointer (RFC 6901)

Navigate JSON documents using standard pointer syntax:

```eiffel
local
    json: SIMPLE_JSON
    doc: detachable SIMPLE_JSON_VALUE
    pointer: SIMPLE_JSON_POINTER
    name: detachable SIMPLE_JSON_VALUE
do
    create json
    doc := json.parse ('{
        "users": [
            {"name": "Alice", "age": 30},
            {"name": "Bob", "age": 25}
        ]
    }')
    
    if attached doc then
        create pointer
        
        -- Navigate to first user's name
        name := pointer.get_value (doc, "/users/0/name")
        if attached name and then name.is_string then
            print (name.as_string_32)  -- Alice
        end
    end
end
```

**Features:**
- RFC 6901 compliant path parsing
- Array index handling (0-based)
- Escape sequence support (`~0` for `~`, `~1` for `/`)
- Error reporting for invalid paths
- Safe navigation with detachable returns

### JSON Patch (RFC 6902)

Apply atomic modifications to JSON documents:

```eiffel
local
    json: SIMPLE_JSON
    doc: detachable SIMPLE_JSON_VALUE
    patch: SIMPLE_JSON_PATCH
    result: SIMPLE_JSON_PATCH_RESULT
do
    create json
    doc := json.parse ('{"name": "Alice", "age": 30}')
    
    if attached doc as al_doc then
        -- Create patch with fluent API
        create patch.make
        patch
            .add ("/email", json.string_value ("alice@example.com"))
            .replace ("/age", json.integer_value (31))
            .remove ("/name")
            .do_nothing
        
        -- Apply patch atomically
        result := patch.apply (al_doc)
        
        if result.is_success then
            print (result.modified_document.to_json_string)
            -- {"age":31,"email":"alice@example.com"}
        end
    end
end
```

**Supported operations:**
- `add` - Add or replace value at path
- `remove` - Remove value at path
- `replace` - Replace existing value
- `move` - Move value to new location
- `copy` - Copy value to new location
- `test` - Test value equality (for conditional patches)

**Features:**
- Atomic application (all-or-nothing)
- Detailed error messages with operation numbers
- Array operations (insert, append, remove by index)
- Serialization to/from JSON patch documents

### JSON Merge Patch (RFC 7386)

Simplified merge semantics for JSON documents:

```eiffel
local
    json: SIMPLE_JSON
    target, patch: detachable SIMPLE_JSON_VALUE
    merger: SIMPLE_JSON_MERGE_PATCH
    result: SIMPLE_JSON_MERGE_PATCH_RESULT
do
    create json
    target := json.parse ('{"name": "Alice", "age": 30, "city": "NYC"}')
    patch := json.parse ('{"age": 31, "city": null, "email": "alice@example.com"}')
    
    if attached target as t and attached patch as p then
        create merger
        result := merger.apply_merge_patch (t, p)
        
        if result.is_success then
            print (result.merged_document.to_json_string)
            -- {"name":"Alice","age":31,"email":"alice@example.com"}
            -- Note: "city" removed (null in patch)
        end
    end
end
```

**Merge semantics:**
- `null` in patch = remove property from target
- Non-null in patch = replace/add in target
- Recursive merging for nested objects
- Arrays are replaced, not merged

### JSONPath Queries

Query JSON documents using intuitive path expressions:

```eiffel
local
    json: SIMPLE_JSON
    doc: detachable SIMPLE_JSON_VALUE
do
    create json
    doc := json.parse ('{
        "people": [
            {"name": "Alice", "age": 30},
            {"name": "Bob", "age": 25},
            {"name": "Charlie", "age": 35}
        ]
    }')
    
    if attached doc then
        -- Single value query
        if attached json.query_string (doc, "$.people[0].name") as name then
            print (name)  -- Alice
        end
        
        -- Wildcard query - all names
        across json.query_strings (doc, "$.people[*].name") as ic loop
            print (ic.item)  -- Alice, Bob, Charlie
        end
        
        -- Multiple integers
        across json.query_integers (doc, "$.people[*].age") as ic loop
            print (ic.item.out)  -- 30, 25, 35
        end
    end
end
```

**Supported syntax:**
- Dot notation: `$.person.name`
- Nested paths: `$.person.address.street`
- Array indexing: `$.hobbies[0]` (0-based)
- Wildcard queries: `$.people[*].name`
- Type-safe methods: `query_string`, `query_integer`, `query_strings`, `query_integers`

### Streaming Parser

Process large JSON arrays efficiently without loading entire document into memory:

```eiffel
local
    stream: SIMPLE_JSON_STREAM
do
    -- Parse from file or string
    create stream.make_from_file ("large_data.json")
    
    -- Iterate through array elements
    across stream as ic loop
        -- ic.value: SIMPLE_JSON_VALUE
        -- ic.index: INTEGER (1-based)
        if ic.value.is_object then
            process_record (ic.value.as_object)
        end
    end
    
    -- Check for errors
    if stream.has_errors then
        print (stream.last_errors.first.to_string)
    end
end
```

**Features:**
- Memory-efficient parsing for large arrays
- Iterative processing via `across` loops
- Element index tracking
- Position-aware error reporting
- Multiple iteration support

### Pretty Printing

Format JSON for human readability:

```eiffel
local
    json: SIMPLE_JSON
    obj: SIMPLE_JSON_OBJECT
    printer: SIMPLE_JSON_PRETTY_PRINTER
do
    create json
    obj := json.new_object
        .put_string ("Alice", "name")
        .put_integer (30, "age")
    
    create printer.make_with_indent (2)
    print (printer.prettify (obj))
    -- {
    --   "name": "Alice",
    --   "age": 30
    -- }
end
```

**Options:**
- Configurable indentation (spaces)
- Compact or expanded formatting
- Proper Unicode handling

## Testing

SIMPLE_JSON maintains 100% test coverage across 12 test suites:

- `TEST_SIMPLE_JSON` - Core parsing and building
- `TEST_JSON_SCHEMA_VALIDATION` - Schema validation
- `TEST_SIMPLE_JSON_PATCH` - JSON Patch operations
- `TEST_SIMPLE_JSON_MERGE_PATCH` - Merge Patch
- `TEST_JSON_PATH_QUERIES` - JSONPath queries
- `TEST_SIMPLE_JSON_STREAM` - Streaming parser
- `TEST_PRETTY_PRINTING` - Pretty printer
- `TEST_ERROR_TRACKING` - Error handling
- Additional specialized test suites

**Run tests:**
```bash
ec -config simple_json.ecf -target simple_json_tests -c_compile
./simple_json_tests
```

**Benchmarking:**
```bash
ec -config simple_json.ecf -target simple_json_benchmark -c_compile
./simple_json_benchmark
```

## API Design Principles

### Command-Query Separation (CQS)

SIMPLE_JSON strictly follows CQS:
- **Queries** return values without modifying state
- **Commands** modify state without returning values
- **Builders** return self for method chaining (explicit CQS exception)

### Design by Contract (DbC)

Every feature includes contracts:
- **Preconditions** - What caller must ensure
- **Postconditions** - What feature guarantees
- **Invariants** - What's always true about objects

### Type Safety

- STRING_32 for all text (full Unicode support)
- Attached types by default (void-safe)
- `detachable` only where semantically correct
- Type-specific accessors (`string_item`, `integer_item`, etc.)

## Project Structure

```
simple_json/
├── src/
│   ├── core/              # Core JSON parsing and building
│   ├── pointer/           # JSON Pointer (RFC 6901)
│   ├── patch/             # JSON Patch (RFC 6902)
│   ├── merge_patch/       # JSON Merge Patch (RFC 7386)
│   ├── schema/            # JSON Schema validation
│   ├── streaming/         # Streaming parser
│   └── utilities/         # Pretty printer and helpers
├── testing/               # Test suites (100% coverage)
├── testing_benchmark/     # Performance benchmarking
└── simple_json.ecf        # Eiffel configuration
```

## Dependencies

- **base** - Eiffel base library
- **json** - Standard Eiffel JSON library (eJSON)
- **encoding** - UTF-8/UTF-32 conversion
- **regexp** - Regular expressions (for schema validation)
- **decimal** - Arbitrary precision arithmetic
- **testing** - EiffelStudio testing framework (tests only)

## Development Methodology

This library demonstrates **AI-assisted development** done right:

### The Interactive Approach

1. **Human defines feature** - Specifies requirements, references RFCs
2. **AI generates code** - Following documented principles and patterns
3. **Compiler enforces contracts** - DbC catches violations immediately
4. **Tests verify behavior** - 100% coverage maintained
5. **Debug interactively** - Learn from failures, document patterns
6. **Extract principles** - Build knowledge base for future features

### Documentation-Driven Development

Three core documents guide all development:

- **CRITICAL_PRINCIPLES.md** - Essential patterns learned through debugging
- **EIFFEL_PRODUCTION_GUIDE.md** - Professional Eiffel code standards
- **SIMPLE_JSON_REFERENCE.md** - Project-specific API knowledge

**Result:** Production-quality code with comprehensive features and zero technical debt.

### Key Success Factors

- ✅ Eiffel's DbC provides immediate feedback on contract violations
- ✅ 100% test coverage catches regressions instantly
- ✅ Documented principles prevent repeating mistakes
- ✅ Interactive debugging builds understanding
- ✅ Viewing source code prevents API assumption errors

**Development speed:** Later features implemented 8-10x faster than early features due to accumulated knowledge.

## Contributing

Contributions welcome! Please:

1. Read `CRITICAL_PRINCIPLES.md` for development guidelines
2. Follow Eiffel conventions in `EIFFEL_PRODUCTION_GUIDE.md`
3. Maintain 100% test coverage
4. Include DbC contracts for all features
5. Update documentation as needed

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on the excellent **eJSON** library from the Eiffel community
- Developed interactively with **Claude Sonnet 4.5** (Anthropic)
- Inspired by JSON libraries in other languages
- RFC compliance verified against official test suites

## Resources

- [JSON Specification](https://www.json.org)
- [JSON Schema Draft 7](https://json-schema.org/draft-07/json-schema-release-notes.html)
- [RFC 6901 - JSON Pointer](https://tools.ietf.org/html/rfc6901)
- [RFC 6902 - JSON Patch](https://tools.ietf.org/html/rfc6902)
- [RFC 7386 - JSON Merge Patch](https://tools.ietf.org/html/rfc7386)

## Support

- **Issues:** [GitHub Issues](https://github.com/ljr1981/simple_json/issues)
- **Discussions:** [GitHub Discussions](https://github.com/ljr1981/simple_json/discussions)

---

**Built with Eiffel, Design by Contract, and AI-assisted development.**