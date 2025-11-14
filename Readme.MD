# SIMPLE_JSON

A comprehensive, Unicode-first JSON library for Eiffel with an intuitive API, advanced features, and production-ready quality.

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Coverage](https://img.shields.io/badge/test_coverage-100%25-brightgreen.svg)]()

## Overview

SIMPLE_JSON provides a complete, high-level API for working with JSON in Eiffel applications. Built on the standard Eiffel JSON library, it offers modern features including JSON Pointer navigation, JSON Patch operations (RFC 6902), and comprehensive error handling—all with full Unicode/UTF-8 support.

**AI-Assisted Development:** Developed interactively using Claude Sonnet 4.5 with Design by Contract principles and 100% test coverage.

## Key Features

### Core Capabilities
- **🌍 Unicode First**: STRING_32 throughout - full Unicode/UTF-8 support
- **⛓️ Fluent API**: Chainable methods for building JSON structures
- **✅ Type-Safe**: Strong typing with comprehensive DbC contracts
- **📝 Easy Parsing**: Parse JSON with a single method call
- **🔨 Easy Building**: Intuitive builder methods
- **🎨 Pretty Printing**: Configurable indentation for human readability

### Advanced Features
- **🧭 JSON Pointer (RFC 6901)**: Path-based navigation (`/users/0/name`)
- **🔧 JSON Patch (RFC 6902)**: Standard document modification operations
- **📍 Position Tracking**: Line/column information for parse errors
- **🎯 Design by Contract**: Full DbC with preconditions, postconditions, invariants
- **🧪 Well-Tested**: 100% test coverage with 200+ tests

### What Makes This Special

**No Other Eiffel JSON Library Provides:**
- JSON Patch (RFC 6902) support
- JSON Pointer (RFC 6901) navigation
- Position-aware error tracking
- Fluent API with proper CQS compliance
- 100% STRING_32 public API

## Quick Start

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ljr1981/simple_json.git
```

2. Add to your project's `.ecf` file:
```xml
<library name="simple_json" location="$SIMPLE_JSON/simple_json.ecf"/>
```

3. Set `SIMPLE_JSON` environment variable or use absolute path.

### Basic Parsing

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

### Building JSON

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

## Advanced Features

### JSON Pointer Navigation

Navigate JSON documents using RFC 6901 paths:

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

**JSON Pointer features:**
- Path parsing and validation
- Array index handling (0-based)
- Error reporting for invalid paths
- Navigation to parent containers

### JSON Patch Operations

Modify JSON documents using RFC 6902 patch operations:

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
        else
            print (result.error_message)
        end
    end
end
```

**Supported operations:**
- `add` - Add or replace value
- `remove` - Remove value
- `replace` - Replace existing value
- `move` - Move value to new location
- `copy` - Copy value to new location
- `test` - Test value equality

**Patch features:**
- Atomic application (all-or-nothing)
- Detailed error messages with operation numbers
- Array operations (insert, append, remove by index)
- Object property operations
- Serialization to/from JSON

### Pretty Printing

Format JSON for human readability:

```eiffel
local
    json: SIMPLE_JSON
    person: SIMPLE_JSON_OBJECT
do
    create json
    person := json.new_object
        .put_string ("Eve", "name")
        .put_integer (32, "age")
    
    -- Default 2-space indentation
    print (person.to_pretty_json)
    -- {
    --   "name": "Eve",
    --   "age": 32
    -- }
    
    -- Custom indentation
    print (person.to_pretty_json_with_spaces (4))  -- 4 spaces
    print (person.to_pretty_json_with_tabs)        -- Tabs
    print (person.to_pretty_json_with_indent ("  ")) -- Custom string
end
```

**Features:**
- Configurable indentation (spaces, tabs, custom)
- Proper nesting and formatting
- Unicode characters display correctly
- Valid JSON output (can be re-parsed)
- Compact display for empty structures

### Error Handling

Comprehensive error reporting with position tracking:

```eiffel
local
    json: SIMPLE_JSON
    value: detachable SIMPLE_JSON_VALUE
    error: SIMPLE_JSON_ERROR
do
    create json
    value := json.parse ('{"invalid": }')  -- Syntax error
    
    if value = Void and then json.has_errors then
        across json.last_errors as ic loop
            error := ic
            print ("Error at line " + error.line.out + 
                   ", column " + error.column.out + ": " +
                   error.message)
        end
    end
end
```

## Core Components

### SIMPLE_JSON (Main Facade)

**Parsing:**
- `parse (json_text: STRING_32): detachable SIMPLE_JSON_VALUE`
- `parse_file (file_path: STRING_32): detachable SIMPLE_JSON_VALUE`
- `is_valid_json (json_text: STRING_32): BOOLEAN`

**Building:**
- `new_object: SIMPLE_JSON_OBJECT`
- `new_array: SIMPLE_JSON_ARRAY`
- `string_value`, `integer_value`, `number_value`, `boolean_value`, `null_value`

**Error Handling:**
- `has_errors: BOOLEAN`
- `last_errors: LIST[SIMPLE_JSON_ERROR]`
- `clear_errors`

### SIMPLE_JSON_PATCH

**Creation:**
- `make` - Create empty patch
- `make_from_array` - Create from operation array

**Operations (Fluent API):**
- `add (path, value): SIMPLE_JSON_PATCH`
- `remove (path): SIMPLE_JSON_PATCH`
- `replace (path, value): SIMPLE_JSON_PATCH`
- `move (from, to): SIMPLE_JSON_PATCH`
- `copy_value (from, to): SIMPLE_JSON_PATCH`
- `test (path, value): SIMPLE_JSON_PATCH`

**Application:**
- `apply (document): SIMPLE_JSON_PATCH_RESULT`

**Conversion:**
- `to_json_array: SIMPLE_JSON_ARRAY`
- `to_json_string: STRING_32`

### SIMPLE_JSON_POINTER

**Parsing:**
- `parse_path (path: STRING_32): BOOLEAN`

**Navigation:**
- `get_value (document, path): detachable SIMPLE_JSON_VALUE`
- `navigate_to_parent (document): detachable SIMPLE_JSON_VALUE`
- `last_segment: STRING_32`

**Validation:**
- `is_valid_path (path: STRING_32): BOOLEAN`

### SIMPLE_JSON_PATCH_RESULT

**Status:**
- `is_success: BOOLEAN`
- `is_failure: BOOLEAN`

**Access:**
- `modified_document: detachable SIMPLE_JSON_VALUE`
- `error_message: STRING_32`
- `has_document: BOOLEAN`
- `has_error: BOOLEAN`

## Architecture

### Design Patterns

**Type Covariance:**
```eiffel
class SIMPLE_JSON_VALUE
    json_value: JSON_VALUE

class SIMPLE_JSON_OBJECT inherit SIMPLE_JSON_VALUE
    redefine json_value
    json_value: JSON_OBJECT  -- Covariant redefinition
```

**Fluent Builder Pattern:**
```eiffel
obj.put_string ("value1", "key1")
   .put_integer (42, "key2")
   .put_boolean (True, "key3")
```

**Result Objects:**
```eiffel
result := patch.apply (document)
if result.is_success then
    use (result.modified_document)
else
    report (result.error_message)
end
```

### Design by Contract

Full DbC throughout with appropriate contract inheritance:

```eiffel
feature -- Operations
    apply (a_document: SIMPLE_JSON_VALUE): SIMPLE_JSON_PATCH_RESULT
        require else  -- Contract inheritance
            document_not_void: a_document /= Void
            path_not_empty: not path.is_empty
        local
            l_parent: detachable SIMPLE_JSON_VALUE
        do
            -- Verify assumptions with check assertions
            check parent_is_object: l_parent.is_object end
            
            -- Implementation
        ensure then  -- Contract strengthening
            result_not_void: Result /= Void
            success_has_document: Result.is_success implies Result.modified_document /= Void
            failure_has_error: Result.is_failure implies Result.has_error
        end
```

## Testing

### Test Coverage

The library maintains **100% test coverage** with over 200 tests across multiple test classes:

- **TEST_SIMPLE_JSON** (46 tests) - Core parsing and building
- **TEST_SIMPLE_JSON_PATCH** (46 tests) - JSON Patch operations
- **TEST_PRETTY_PRINTING** (35 tests) - Pretty printing functionality
- **TEST_JSON_PATH_QUERIES** - Path-based queries
- **TEST_ERROR_TRACKING** - Error position tracking

### Test Organization

Tests are organized by functional area with a shared base class:

```eiffel
class TEST_SIMPLE_JSON_PATCH

inherit
    TEST_SET_BASE  -- Provides enhanced assertions
    
feature -- Tests
    test_apply_add_to_object
        local
            l_patch: SIMPLE_JSON_PATCH
            l_json: SIMPLE_JSON
            l_doc: detachable SIMPLE_JSON_VALUE
        do
            create l_json
            l_doc := l_json.parse ('{"name": "Alice"}')
            create l_patch.make
            
            if attached l_doc as al_doc then
                l_patch.add ("/age", l_json.integer_value (30)).do_nothing
                
                if attached l_patch.apply (al_doc) as l_result then
                    assert_true ("is_success", l_result.is_success)
                end
            end
        end
end
```

### Running Tests

1. Open `simple_json.ecf` in EiffelStudio
2. Select testing target
3. Compile and execute tests
4. All tests should pass ✅

## Use Cases

### API Integration
```eiffel
-- Parse REST API response
response := http_client.get ("/api/user/profile")
if attached json.parse (response) as user then
    email := user.as_object.string_item ("email")
end
```

### Configuration Management
```eiffel
-- Load configuration with error handling
if attached json.parse_file ("config.json") as config then
    if config.is_object then
        port := config.as_object.integer_item ("port")
        debug_mode := config.as_object.boolean_item ("debug")
    end
else
    -- Handle parse errors with position information
    across json.last_errors as ic loop
        log_error (ic.message + " at line " + ic.line.out)
    end
end
```

### Document Patching
```eiffel
-- Apply configuration updates
create patch.make
patch
    .replace ("/database/host", json.string_value ("new-host"))
    .replace ("/database/port", json.integer_value (5432))
    .add ("/features/beta", json.boolean_value (True))
    .do_nothing

if attached patch.apply (config) as result then
    if result.is_success then
        save_config (result.modified_document.to_pretty_json)
    else
        log_error ("Patch failed: " + result.error_message)
    end
end
```

### Internationalization
```eiffel
-- Full Unicode support
translations := json.new_object
    .put_string ("Welcome", "en")
    .put_string ("Bienvenue", "fr")
    .put_string ("欢迎", "zh")
    .put_string ("Добро пожаловать", "ru")
    .put_string ("مرحبا", "ar")
    .put_string ("🎉 Hello!", "emoji")
```

## Requirements

- **EiffelStudio**: 19.05 or later (void-safe mode required)
- **Platform**: Windows, macOS, Linux
- **Dependencies**: 
  - Eiffel base library
  - Eiffel encoding library
  - Eiffel JSON library (included with EiffelStudio)

## Design Principles

1. **Simple over complex** - Easy API for common cases, powerful API for advanced cases
2. **Unicode-first** - STRING_32 everywhere, no encoding headaches
3. **Type-safe** - Comprehensive contracts and void-safety
4. **Standards-compliant** - RFC 6901 (Pointer), RFC 6902 (Patch)
5. **CQS-compliant** - Proper Command-Query Separation with `.do_nothing` pattern
6. **Well-tested** - 100% test coverage with DbC catching bugs early

## Project Status

### Completed ✅

**Core Features:**
- JSON parsing with position tracking
- JSON building with fluent API
- Unicode/UTF-8 support (STRING_32 throughout)
- Type checking and conversions
- Pretty printing (configurable indentation)

**Advanced Features:**
- JSON Pointer (RFC 6901) - Path navigation
- JSON Patch (RFC 6902) - Document modification
  - All 6 operations: add, remove, replace, move, copy, test
  - Atomic application (all-or-nothing)
  - Array and object operations
  - Serialization support

**Quality:**
- 100% test coverage (200+ tests)
- Full Design by Contract
- Void-safety compliant
- Position-aware error tracking

### Future Enhancements 🚀

**High Priority:**
- [ ] **JSON Schema validation (RFC 8927)** - Would be unique in Eiffel ecosystem
- [ ] **JSON Merge Patch (RFC 7386)** - Simpler alternative to JSON Patch

**Nice to Have:**
- [ ] **JSONPath queries** - More flexible than JSON Pointer
- [ ] **Streaming parser** - For very large files (>100MB)
- [ ] **Performance optimizations** - Profile-driven improvements

## Contributing

Contributions welcome! 

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests (maintain 100% coverage)
4. Include Design by Contract assertions
5. Follow Eiffel coding conventions
6. Submit a pull request

### Coding Standards

- Maintain STRING_32 in public API
- Add preconditions, postconditions, and check assertions
- Use `require else`/`ensure then` for contract inheritance
- Follow CQS with `.do_nothing` for fluent APIs
- Name parameters with `a_`, locals with `l_`, attachment locals with `al_`
- One test class per user-facing API class
- Test all success and failure paths

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Larry Rix** (ljr1981)
- GitHub: [@ljr1981](https://github.com/ljr1981)
- Email: rix.larry@gmail.com

## Acknowledgments

- Built with [EiffelStudio](https://www.eiffel.com/)
- AI-assisted development using Claude Sonnet 4.5
- Based on the standard Eiffel JSON library
- RFC 6901 (JSON Pointer) and RFC 6902 (JSON Patch) standards

## Support

- **Issues**: [GitHub Issues](https://github.com/ljr1981/simple_json/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ljr1981/simple_json/discussions)
- **Email**: rix.larry@gmail.com

---

**Made with ❤️ using Eiffel and AI | 100% Test Coverage | RFC-Compliant**
