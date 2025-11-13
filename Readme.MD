# SIMPLE_JSON

A simple, Unicode-first JSON library for Eiffel with an intuitive API.

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

SIMPLE_JSON provides a clean, high-level API for working with JSON in Eiffel applications. Built on top of the standard Eiffel JSON library, it offers a simple interface with full Unicode/UTF-8 support using STRING_32 throughout.

**AI NOTE:** Most code was generated interactively using Claude Sonnet 4.5 with minor modifications applied by hand. Additional development will use the same method.

## Key Features

- **🌍 Unicode First**: All strings are STRING_32 - full Unicode/UTF-8 support out of the box
- **🚫 No STRING_8**: Completely eliminates STRING_8 from the public API
- **⛓️ Fluent API**: Chainable methods for building JSON structures
- **✅ Type-Safe**: Strong typing with proper preconditions and postconditions
- **📝 Easy Parsing**: Parse JSON with a single method call
- **🔨 Easy Building**: Build JSON structures with intuitive methods
- **🎨 Pretty Printing**: Format JSON with indentation for human readability
- **🧪 Well-Tested**: Comprehensive test suite covering all features
- **🎯 Design by Contract**: Full DbC with preconditions, postconditions, and invariants

## What Makes This Special

### Unicode/UTF-8 Everywhere
```eiffel
-- All strings are STRING_32 - Unicode just works!
obj := json.new_object
    .put_string ("Hello, 世界! 🌍", "greeting")
    .put_string ("Здравствуй", "russian")
    .put_string ("مرحبا", "arabic")
```

### Simple Over Complex
```eiffel
-- One line to parse
value := json.parse ('{"name": "Alice", "age": 30}')

-- One line to build
obj := json.new_object.put_string ("Bob", "name").put_integer (25, "age")
```

### No Encoding Headaches
- Public API only uses STRING_32
- All UTF-8 conversion handled internally
- Never think about encodings

## Installation

### Using EiffelStudio

1. Clone or download the repository:
```bash
git clone https://github.com/ljr1981/simple_json.git
```

2. Add the library to your project's `.ecf` file:
```xml
<library name="simple_json" location="$SIMPLE_JSON/simple_json.ecf"/>
```

3. Set the `SIMPLE_JSON` environment variable to point to your clone location, or use an absolute path.

## Quick Start

### Parsing JSON

```eiffel
local
    json: SIMPLE_JSON
    value: detachable SIMPLE_JSON_VALUE
do
    create json
    value := json.parse ('{"name": "Alice", "age": 30}')
    
    if attached value and then value.is_object then
        print (value.as_object.string_item ("name"))  -- Prints: Alice
        print (value.as_object.integer_item ("age"))  -- Prints: 30
    end
end
```

### Building JSON Objects

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
    -- Output: {"name":"Bob","age":25,"active":true}
end
```

### Building JSON Arrays

```eiffel
local
    json: SIMPLE_JSON
    arr: SIMPLE_JSON_ARRAY
do
    create json
    arr := json.new_array
        .add_string ("apple")
        .add_string ("banana")
        .add_integer (42)
        .add_boolean (True)
    
    print (arr.to_json_string)
    -- Output: ["apple","banana",42,true]
end
```

### Nested Structures

```eiffel
local
    json: SIMPLE_JSON
    person: SIMPLE_JSON_OBJECT
    address: SIMPLE_JSON_OBJECT
    hobbies: SIMPLE_JSON_ARRAY
do
    create json
    
    -- Create address object
    address := json.new_object
        .put_string ("123 Main St", "street")
        .put_string ("Springfield", "city")
    
    -- Create hobbies array
    hobbies := json.new_array
        .add_string ("reading")
        .add_string ("coding")
    
    -- Create person with nested structures
    person := json.new_object
        .put_string ("Charlie", "name")
        .put_integer (35, "age")
        .put_object (address, "address")
        .put_array (hobbies, "hobbies")
    
    print (person.to_json_string)
end
```

### Pretty Printing

```eiffel
local
    json: SIMPLE_JSON
    person: SIMPLE_JSON_OBJECT
    address: SIMPLE_JSON_OBJECT
do
    create json
    
    address := json.new_object
        .put_string ("123 Main St", "street")
        .put_string ("Springfield", "city")
    
    person := json.new_object
        .put_string ("Eve", "name")
        .put_integer (32, "age")
        .put_object (address, "address")
    
    -- Compact JSON (single line)
    print (person.to_json_string)
    -- Output: {"name":"Eve","age":32,"address":{"street":"123 Main St","city":"Springfield"}}
    
    -- Pretty JSON with 2-space indentation (default)
    print (person.to_pretty_json)
    -- Output:
    -- {
    --   "name": "Eve",
    --   "age": 32,
    --   "address": {
    --     "street": "123 Main St",
    --     "city": "Springfield"
    --   }
    -- }
    
    -- Pretty JSON with 4 spaces
    print (person.to_pretty_json_with_spaces (4))
    
    -- Pretty JSON with tabs
    print (person.to_pretty_json_with_tabs)
    
    -- Pretty JSON with custom indentation
    print (person.to_pretty_json_with_indent ("  "))  -- 2 spaces
end
```

#### Unicode in Pretty Printing

Pretty printing properly displays Unicode characters:

```eiffel
local
    json: SIMPLE_JSON
    greetings: SIMPLE_JSON_OBJECT
do
    create json
    greetings := json.new_object
        .put_string ("Hello", "english")
        .put_string ("你好", "chinese")
        .put_string ("Здравствуй", "russian")
        .put_string ("مرحبا", "arabic")
    
    print (greetings.to_pretty_json)
    -- Output shows actual Unicode characters:
    -- {
    --   "english": "Hello",
    --   "chinese": "你好",
    --   "russian": "Здравствуй",
    --   "arabic": "مرحبا"
    -- }
end
```

### Accessing Values

```eiffel
local
    json: SIMPLE_JSON
    obj: SIMPLE_JSON_OBJECT
do
    create json
    
    if attached json.parse ('{"name": "Diana", "age": 28}') as value
       and then value.is_object then
        obj := value.as_object
        
        -- Check if key exists
        if obj.has_key ("name") then
            -- Get string value (returns Void if wrong type)
            if attached obj.string_item ("name") as name then
                print ("Name: " + name)
            end
        end
        
        -- Get integer value (returns 0 if wrong type or missing)
        print ("Age: " + obj.integer_item ("age").out)
        
        -- Get count of keys
        print ("Keys: " + obj.count.out)
    end
end
```

### Type Checking

```eiffel
local
    json: SIMPLE_JSON
    value: SIMPLE_JSON_VALUE
do
    create json
    
    if attached json.parse ('{"count": 42}') as v then
        value := v.as_object.item ("count")
        
        if value.is_integer then
            print ("Integer: " + value.as_integer.out)
        elseif value.is_string then
            print ("String: " + value.as_string_32)
        elseif value.is_boolean then
            print ("Boolean: " + value.as_boolean.out)
        end
    end
end
```

## Core Components

### SIMPLE_JSON (Main Facade)

The main entry point providing parsing and building functionality.

**Parsing:**
- `parse (json_text: STRING_32): detachable SIMPLE_JSON_VALUE`
- `parse_file (file_path: STRING_32): detachable SIMPLE_JSON_VALUE`
- `is_valid_json (json_text: STRING_32): BOOLEAN`

**Building:**
- `new_object: SIMPLE_JSON_OBJECT`
- `new_array: SIMPLE_JSON_ARRAY`
- `string_value (STRING_32): SIMPLE_JSON_VALUE`
- `number_value (DOUBLE): SIMPLE_JSON_VALUE`
- `integer_value (INTEGER_64): SIMPLE_JSON_VALUE`
- `boolean_value (BOOLEAN): SIMPLE_JSON_VALUE`
- `null_value: SIMPLE_JSON_VALUE`

### SIMPLE_JSON_VALUE

Base wrapper around JSON values with type checking and conversion.

**Type Checking:**
- `is_string: BOOLEAN`
- `is_number: BOOLEAN`
- `is_integer: BOOLEAN`
- `is_boolean: BOOLEAN`
- `is_null: BOOLEAN`
- `is_object: BOOLEAN`
- `is_array: BOOLEAN`

**Type Conversion:**
- `as_string_32: STRING_32` (or `string_value`)
- `as_integer: INTEGER_64` (or `integer_value`)
- `as_real: DOUBLE` (or `real_value`)
- `as_natural: NATURAL_64`
- `as_boolean: BOOLEAN` (or `boolean_value`)
- `as_object: SIMPLE_JSON_OBJECT` (or `object_value`)
- `as_array: SIMPLE_JSON_ARRAY` (or `array_value`)
- `to_json_string: STRING_32` (or `representation`)

**Pretty Printing:**
- `to_pretty_json: STRING_32` - Pretty print with 2-space indentation (default)
- `to_pretty_json_with_spaces (count: INTEGER): STRING_32` - Custom number of spaces (1-8)
- `to_pretty_json_with_tabs: STRING_32` - Use tab characters for indentation
- `to_pretty_json_with_indent (indent: STRING_32): STRING_32` - Custom indentation string

### SIMPLE_JSON_OBJECT

JSON object with fluent builder API.

**Status:**
- `count: INTEGER`
- `is_empty: BOOLEAN`
- `has_key (key: STRING_32): BOOLEAN`

**Access:**
- `item (key: STRING_32): detachable SIMPLE_JSON_VALUE`
- `string_item (key: STRING_32): detachable STRING_32`
- `integer_item (key: STRING_32): INTEGER_64`
- `real_item (key: STRING_32): DOUBLE`
- `boolean_item (key: STRING_32): BOOLEAN`
- `object_item (key: STRING_32): detachable SIMPLE_JSON_OBJECT`
- `array_item (key: STRING_32): detachable SIMPLE_JSON_ARRAY`

**Building (Fluent):**
- `put_string (value, key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_integer (value: INTEGER_64; key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_real (value: DOUBLE; key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_boolean (value: BOOLEAN; key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_null (key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_object (value: SIMPLE_JSON_OBJECT; key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_array (value: SIMPLE_JSON_ARRAY; key: STRING_32): SIMPLE_JSON_OBJECT`
- `put_value (value: SIMPLE_JSON_VALUE; key: STRING_32): SIMPLE_JSON_OBJECT`

**Removal:**
- `remove (key: STRING_32)`
- `wipe_out`

**Iteration:**
- `keys: ARRAY [STRING_32]`

### SIMPLE_JSON_ARRAY

JSON array with fluent builder API.

**Status:**
- `count: INTEGER`
- `is_empty: BOOLEAN`
- `valid_index (i: INTEGER): BOOLEAN`

**Access:**
- `item alias "[]" (i: INTEGER): SIMPLE_JSON_VALUE`
- `string_item (i: INTEGER): detachable STRING_32`
- `integer_item (i: INTEGER): INTEGER_64`
- `real_item (i: INTEGER): DOUBLE`
- `boolean_item (i: INTEGER): BOOLEAN`
- `object_item (i: INTEGER): detachable SIMPLE_JSON_OBJECT`
- `array_item (i: INTEGER): detachable SIMPLE_JSON_ARRAY`

**Building (Fluent):**
- `add_string (value: STRING_32): SIMPLE_JSON_ARRAY`
- `add_integer (value: INTEGER_64): SIMPLE_JSON_ARRAY`
- `add_real (value: DOUBLE): SIMPLE_JSON_ARRAY`
- `add_boolean (value: BOOLEAN): SIMPLE_JSON_ARRAY`
- `add_null: SIMPLE_JSON_ARRAY`
- `add_object (value: SIMPLE_JSON_OBJECT): SIMPLE_JSON_ARRAY`
- `add_array (value: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY`
- `add_value (value: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY`

**Removal:**
- `wipe_out`

### SIMPLE_JSON_PRETTY_PRINTER

JSON pretty printer with configurable indentation (used internally by `to_pretty_json` methods).

**Configuration:**
- `make` - Initialize with default 2-space indentation
- `make_with_options (indent: STRING_32)` - Initialize with custom indentation
- `set_indent_string (indent: STRING_32)` - Change indentation string
- `use_tabs` - Configure to use tab characters
- `use_spaces (count: INTEGER)` - Configure number of spaces (1-8)

**Printing:**
- `print_json_value (value: JSON_VALUE): STRING_32` - Pretty print a value

**Features:**
- Visitor pattern implementation for clean traversal
- Proper nesting and indentation
- Empty structures display compactly: `{}` and `[]`
- Unicode characters displayed literally (not as escape codes)
- Special characters properly escaped
- Valid JSON output (can be re-parsed)

## Architecture

### Type Covariance

The library uses Eiffel's covariance feature properly:

```eiffel
class SIMPLE_JSON_VALUE
    json_value: JSON_VALUE

class SIMPLE_JSON_OBJECT inherit SIMPLE_JSON_VALUE
    redefine json_value, make_value
    json_value: JSON_OBJECT  -- Covariant redefinition
```

### Multiple Inheritance

Strategic use of multiple inheritance for shared functionality:

```eiffel
class TEST_SET_BASE
inherit
    EQA_TEST_SET
    
    EQA_COMMONLY_USED_ASSERTIONS
        undefine default_create
        end
end
```

### Design by Contract

Full DbC implementation throughout:

```eiffel
feature -- Access
    string_item (a_key: STRING_32): detachable STRING_32
        require
            key_not_empty: not a_key.is_empty
        do
            -- Implementation
        end
```

## Testing

The library includes a comprehensive test suite using EiffelStudio's AutoTest framework.

### Test Coverage

**Test Classes:** 
- `TEST_SIMPLE_JSON` - Core functionality tests
- `TEST_PRETTY_PRINTING` - Pretty printing tests (35 tests)

**Categories:**
- Parsing (objects, arrays, primitives)
- Building (objects, arrays, nested structures)
- Type checking (all JSON types)
- Unicode handling
- Pretty printing (basic, nested, custom indentation, Unicode)
- Edge cases (empty, null, zero, negative)
- Fluent API
- Array/object access

### Running Tests

1. Open `simple_json.ecf` in EiffelStudio
2. Set testing target as active
3. Compile and execute
4. All tests should pass ✅

### Test Base Class

The library provides `TEST_SET_BASE` for convenient test writing:

```eiffel
class MY_TEST
inherit
    TEST_SET_BASE
    
feature
    test_something
        do
            assert_strings_equal ("tag", "expected", "actual")
            assert_integers_equal ("tag", 42, result)
            assert_attached ("tag", some_object)
        end
end
```

## Use Cases

### API Integration
```eiffel
-- Parse JSON from REST API
response_json := http_client.get ("/api/users/123")
if attached json.parse (response_json) as user then
    name := user.as_object.string_item ("name")
end
```

### Configuration Files
```eiffel
-- Read application config
if attached json.parse_file ("config.json") as config then
    port := config.as_object.integer_item ("port")
    debug_mode := config.as_object.boolean_item ("debug")
end

-- Write pretty configuration file
config := json.new_object
    .put_integer (8080, "port")
    .put_boolean (False, "debug")
    .put_string ("localhost", "host")

-- Save with pretty formatting for human editing
file.put_string (config.to_pretty_json)
-- Produces readable config file:
-- {
--   "port": 8080,
--   "debug": false,
--   "host": "localhost"
-- }
```

### Data Serialization
```eiffel
-- Serialize data to JSON
user := json.new_object
    .put_string (person.name, "name")
    .put_integer (person.age, "age")
    .put_string (person.email, "email")

save_to_file (user.to_json_string)
```

### International Applications
```eiffel
-- Full Unicode support
translations := json.new_object
    .put_string ("Welcome", "en")
    .put_string ("Bienvenue", "fr")
    .put_string ("欢迎", "zh")
    .put_string ("Willkommen", "de")
```

## Requirements

- **EiffelStudio**: 19.05 or later (void-safe)
- **Platform**: Windows, macOS, Linux
- **Dependencies**: 
  - Eiffel base library
  - Eiffel encoding library
  - Eiffel JSON library (included with EiffelStudio)

## Design Principles

1. **Simple over complex** - Easy API for common use cases
2. **Unicode-first** - STRING_32 everywhere in public API
3. **Type-safe** - Proper contracts and preconditions
4. **Fluent** - Method chaining for builders
5. **Void-safe** - Full void-safety compliance
6. **Testable** - Comprehensive test coverage

## Comparison: Raw JSON vs SIMPLE_JSON

### Raw Eiffel JSON Library
```eiffel
local
    parser: JSON_PARSER
    obj: JSON_OBJECT
    key: JSON_STRING
    value: JSON_STRING
do
    create parser.make_with_string (utf8_string)
    parser.parse_content
    if parser.is_valid and then 
       attached {JSON_OBJECT} parser.parsed_json_value as jo then
        create key.make_from_string_32 (u32_key)
        if attached {JSON_STRING} jo.item (key) as js then
            result := js.unescaped_string_32
        end
    end
end
```

### SIMPLE_JSON
```eiffel
local
    json: SIMPLE_JSON
do
    create json
    if attached json.parse (text) as value and then value.is_object then
        result := value.as_object.string_item (key)
    end
end
```

## Contributing

Contributions are welcome! 

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit a pull request

### Coding Standards

- Follow Eiffel coding conventions
- Maintain 100% STRING_32 in public API
- Add comprehensive tests
- Include Design by Contract assertions
- Update documentation

## Roadmap

### Completed ✅
- Core parsing and building
- Unicode/UTF-8 support
- Fluent API
- Type checking
- Comprehensive tests
- Type covariance fixes
- Primitive value parsing
- Pretty printing with indentation (2-space, 4-space, tabs, custom)
- Unicode display in pretty output

### Future Enhancements 🚀
- [ ] JSON Schema validation
- [ ] Path-based queries (JSONPath-like)
- [ ] Streaming parser for large files
- [ ] JSON Patch (RFC 6902) support
- [ ] Performance optimizations
- [ ] Error position tracking

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Larry Rix** (ljr1981)
- GitHub: [@ljr1981](https://github.com/ljr1981)
- Email: rix.larry@gmail.com

## Acknowledgments

- Built with [EiffelStudio](https://www.eiffel.com/)
- AI-assisted development using Claude Sonnet 4.5
- Thanks to the Eiffel community for feedback and support
- Based on the standard Eiffel JSON library

## Support

- **Issues**: [GitHub Issues](https://github.com/ljr1981/simple_json/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ljr1981/simple_json/discussions)
- **Email**: rix.larry@gmail.com

---

**Made with ❤️ using Eiffel and AI**