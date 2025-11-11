# Simple JSON

A lightweight, easy-to-use JSON parsing and generation library for Eiffel.

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

Simple JSON provides a clean, intuitive interface for working with JSON data in Eiffel applications. Whether you need to parse JSON strings, query nested data structures, or build JSON programmatically, Simple JSON offers a straightforward API that follows Eiffel's design principles.

## Key Features

- **🔍 Easy Parsing**: Parse JSON strings with simple, expressive syntax
- **🔎 Path-Based Queries**: Navigate nested JSON structures using intuitive path notation
- **🏗️ Programmatic Building**: Construct JSON objects and arrays fluently
- **✅ Robust Validation**: Comprehensive error handling and validation
- **🧪 Well-Tested**: Extensive test suite covering edge cases and real-world scenarios
- **📚 Full Documentation**: Complete user guide and API documentation
- **🎯 Type Safety**: Leverages Eiffel's strong typing for safe JSON operations
- **🔢 Number Handling**: Proper support for integers, decimals, and scientific notation

## Installation

### Using EiffelStudio

1. Clone the repository:
```bash
git clone https://github.com/ljr1981/simple_json.git
```

2. Add the library to your project's `.ecf` file:
```xml
<library name="simple_json" location="$SIMPLE_JSON\simple_json.ecf"/>
```

3. Set the `SIMPLE_JSON` environment variable to point to your clone location, or use an absolute path.

## Quick Start

### Parsing JSON

```eiffel
local
    json: JSON
    name: STRING
    age: INTEGER
do
    create json.make_from_string ("{%"name%": %"Alice%", %"age%": 30}")
    
    if json.is_valid then
        name := json.string_value_at ("name")
        age := json.integer_value_at ("age")
        print ("Name: " + name + ", Age: " + age.out)
    end
end
```

### Building JSON

```eiffel
local
    builder: JSON_BUILDER
    json_string: STRING
do
    create builder.make
    builder.add_object
    builder.add_string_field ("name", "Bob")
    builder.add_integer_field ("age", 25)
    builder.add_array_field ("hobbies")
    builder.add_string_element ("reading")
    builder.add_string_element ("coding")
    builder.close_array
    builder.close_object
    
    json_string := builder.to_json
    print (json_string)
    -- Output: {"name":"Bob","age":25,"hobbies":["reading","coding"]}
end
```

### Querying Nested Data

```eiffel
local
    json: JSON
    city: STRING
do
    create json.make_from_string ("{%"user%": {%"address%": {%"city%": %"Boston%"}}}")
    
    if json.is_valid then
        city := json.string_value_at ("user.address.city")
        print ("City: " + city)
    end
end
```

## Core Components

### JSON
The main facade class providing the primary interface for parsing and querying JSON data.

**Key Features:**
- Parse JSON strings
- Query values by path
- Type-safe value extraction
- Validation and error reporting

### JSON_BUILDER
Fluent interface for constructing JSON structures programmatically.

**Key Features:**
- Build objects and arrays
- Add typed fields and elements
- Generate formatted JSON strings
- Nested structure support

### JSON_QUERY
Advanced querying capabilities for complex JSON navigation.

**Key Features:**
- Path-based navigation
- Type checking
- Existence verification
- Deep object traversal

### SIMPLE_JSON_OBJECT & SIMPLE_JSON_ARRAY
Low-level representation classes for JSON objects and arrays.

**Key Features:**
- Direct manipulation of JSON structures
- Iteration support
- Type conversion utilities

## Usage Examples

### Error Handling

```eiffel
local
    json: JSON
do
    create json.make_from_string ("{invalid json}")
    
    if not json.is_valid then
        print ("Parse error: " + json.error_message)
        print ("Error position: " + json.error_position.out)
    end
end
```

### Working with Arrays

```eiffel
local
    json: JSON
    query: JSON_QUERY
    count: INTEGER
    i: INTEGER
    item: STRING
do
    create json.make_from_string ("{%"items%": [%"apple%", %"banana%", %"cherry%"]}")
    
    if json.is_valid then
        create query.make (json.root_object)
        count := query.array_count_at ("items")
        
        from i := 0 until i >= count loop
            item := json.string_value_at ("items[" + i.out + "]")
            print (item + "%N")
            i := i + 1
        end
    end
end
```

### Building Complex Structures

```eiffel
local
    builder: JSON_BUILDER
do
    create builder.make
    builder.add_object
        builder.add_string_field ("name", "Product")
        builder.add_real_field ("price", 29.99)
        builder.add_boolean_field ("in_stock", True)
        
        builder.add_object_field ("manufacturer")
            builder.add_string_field ("name", "ACME Corp")
            builder.add_string_field ("country", "USA")
        builder.close_object
        
        builder.add_array_field ("tags")
            builder.add_string_element ("electronics")
            builder.add_string_element ("gadgets")
        builder.close_array
    builder.close_object
    
    print (builder.to_json)
end
```

### Handling Different Number Types

```eiffel
local
    json: JSON
do
    create json.make_from_string ("{%"int%": 42, %"real%": 3.14, %"sci%": 1.5e-10}")
    
    if json.is_valid then
        print (json.integer_value_at ("int"))      -- 42
        print (json.real_value_at ("real"))        -- 3.14
        print (json.real_value_at ("sci"))         -- 1.5e-10
    end
end
```

## Testing

The library includes a comprehensive test suite covering:

- **Path and Integer Tests** (`TEST_JSON_FACADE`)
- **Basic Parsing** (`TEST_SIMPLE_JSON`)
- **Error Conditions** (`TEST_SIMPLE_JSON_ERRORS`)
- **JSON Generation** (`TEST_SIMPLE_JSON_GENERATION`)
- **Nested Structures** (`TEST_SIMPLE_JSON_NESTED`)
- **Number Formats** (`TEST_SIMPLE_JSON_NUMBERS`)
- **Query Interface** (`TEST_SIMPLE_JSON_QUERIES`)

### Running Tests

1. Open `simple_json.ecf` in EiffelStudio
2. Set the testing configuration as the active target
3. Compile and run tests
4. All tests should pass ✅

```
Executing 66 tests
test_json_path_integer (TEST_JSON_FACADE): pass
test_json_builder_build (TEST_JSON_FACADE): pass
test_json_validate (TEST_JSON_FACADE): pass
test_round_trip_numeric_precision (TEST_SIMPLE_JSON_NUMBERS): pass
...
[All tests passing]
```

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[User Guide](docs/user-guide.html)** - Complete usage documentation
- **[Quick Start](docs/quick-start.html)** - Get started quickly
- **[Use Cases](docs/use-cases/)** - Detailed examples for common scenarios
  - [Building JSON](docs/use-cases/building-json.html)
  - [Error Handling](docs/use-cases/error-handling.html)
  - [Path Navigation](docs/use-cases/path-navigation.html)
  - [Query Interface](docs/use-cases/query-interface.html)
  - [Quick Extraction](docs/use-cases/quick-extraction.html)
  - [Validation](docs/use-cases/validation.html)

## API Reference

### JSON Class

| Method | Description |
|--------|-------------|
| `make_from_string (json_string: STRING)` | Parse JSON from string |
| `is_valid: BOOLEAN` | Check if parsing succeeded |
| `string_value_at (path: STRING): STRING` | Extract string value |
| `integer_value_at (path: STRING): INTEGER` | Extract integer value |
| `real_value_at (path: STRING): REAL` | Extract real number value |
| `boolean_value_at (path: STRING): BOOLEAN` | Extract boolean value |
| `has_key (path: STRING): BOOLEAN` | Check if key exists |
| `error_message: STRING` | Get parse error description |

### JSON_BUILDER Class

| Method | Description |
|--------|-------------|
| `add_object` | Start a new object |
| `close_object` | Close current object |
| `add_array` | Start a new array |
| `close_array` | Close current array |
| `add_string_field (key, value: STRING)` | Add string field |
| `add_integer_field (key: STRING; value: INTEGER)` | Add integer field |
| `add_real_field (key: STRING; value: REAL)` | Add real field |
| `add_boolean_field (key: STRING; value: BOOLEAN)` | Add boolean field |
| `to_json: STRING` | Generate JSON string |

## Requirements

- **EiffelStudio**: Version 19.05 or later recommended
- **Platform**: Windows, macOS, Linux
- **Dependencies**: None (uses only EiffelBase)

## Project Structure

```
simple_json/
├── src/                    # Source code
│   ├── json.e             # Main facade class
│   ├── json_builder.e     # JSON construction
│   ├── json_query.e       # Query interface
│   ├── simple_json.e      # Base functionality
│   ├── simple_json_array.e
│   └── simple_json_object.e
├── testing/               # Test suite
│   ├── application.e
│   ├── test_json_facade.e
│   ├── test_simple_json.e
│   ├── test_simple_json_errors.e
│   ├── test_simple_json_generation.e
│   ├── test_simple_json_nested.e
│   ├── test_simple_json_numbers.e
│   └── test_simple_json_queries.e
├── docs/                  # Documentation
├── simple_json.ecf        # Project configuration
└── README.md             # This file
```

## Design Principles

Simple JSON follows these key principles:

1. **Simplicity First**: API designed for ease of use without sacrificing power
2. **Type Safety**: Leverage Eiffel's type system for compile-time safety
3. **Error Clarity**: Clear, actionable error messages
4. **Performance**: Efficient parsing and querying
5. **Testability**: Comprehensive test coverage for reliability

## Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Coding Standards

- Follow Eiffel coding conventions
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## Roadmap

Future enhancements under consideration:

- [ ] JSON Schema validation
- [ ] Pretty-printing with custom formatting
- [ ] Streaming parser for large files
- [ ] JSON Pointer (RFC 6901) support
- [ ] JSON Patch (RFC 6902) support
- [ ] Performance optimizations
- [ ] Extended Unicode support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Larry Rix** (ljr1981)
- GitHub: [@ljr1981](https://github.com/ljr1981)
- Email: rix.larry@gmail.com

## Acknowledgments

- Built with [EiffelStudio](https://www.eiffel.com/)
- Inspired by the need for simple, elegant JSON handling in Eiffel
- Thanks to the Eiffel community for feedback and support

## Support

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/ljr1981/simple_json/issues)
- **Discussions**: Join the conversation in [GitHub Discussions](https://github.com/ljr1981/simple_json/discussions)
- **Email**: rix.larry@gmail.com

## Related Projects

Looking for more Eiffel libraries? Check out:
- [Other ljr1981 projects](https://github.com/ljr1981)

---

**Made with ❤️ using Eiffel**