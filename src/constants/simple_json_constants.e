note
	description: "[
		Centralized constants for the SIMPLE_JSON library.
		
		This class provides named constants to replace magic values throughout
		the codebase, improving readability and maintainability.
		
		Constants are organized by category:
		- Size/Buffer Constants: Initial sizes for containers and buffers
		- String Processing: Offsets, lengths, and character codes
		- JSON Schema Keywords: Standard JSON Schema property names
		- JSON Formatting: Output formatting strings
		- Validation Limits: Already defined in SIMPLE_JSON_OBJECT
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "protocol=URI", "src=file://$(SYSTEM_PATH)/docs/docs/core/simple_json_constants.html"

class
	SIMPLE_JSON_CONSTANTS

feature -- Size and Buffer Constants

	Default_error_list_size: INTEGER = 5
			-- Default initial capacity for error lists in streaming and simple operations
			-- Used when creating error containers that typically have few errors

	Default_errors_capacity: INTEGER = 10
			-- Default initial capacity for error lists in schema validation
			-- Used for operations that may generate multiple validation errors

	Default_elements_capacity: INTEGER = 10
			-- Default initial capacity for element lists in streaming operations
			-- Provides reasonable starting size for most JSON arrays

	Default_path_segments_capacity: INTEGER = 5
			-- Default initial capacity for path segment arrays
			-- Most JSON paths have relatively few segments

	Error_message_buffer_size: INTEGER = 50
			-- Standard buffer size for constructing error messages
			-- Provides sufficient space for most error message strings
			-- Used in schema validation error construction

	Item_path_buffer_size: INTEGER = 20
			-- Buffer size for item path construction in schema validation
			-- Used when building paths for nested schema validation

feature -- String Processing Constants

	Substring_skip_first_char: INTEGER = 2
			-- Offset to skip first character in substring operations
			-- Used when removing leading slash from JSON Pointer paths
			-- substring(2, count) skips the first character

	Substring_skip_first_two_chars: INTEGER = 3
			-- Offset to skip first two characters in substring operations
			-- Used when removing array bracket markers like "[-"
			-- substring(3, count) skips the first two characters

	Hex_digit_count: INTEGER = 4
			-- Number of hex digits required for Unicode escape sequences (\uXXXX)
			-- JSON standard requires exactly 4 hex digits for Unicode escapes

	Hex_last_four_offset: INTEGER = 3
			-- Offset for extracting last 4 characters from hex string
			-- substring(count - 3, count) gives the last 4 characters
			-- Used when padding hex strings to ensure 4-digit format

	Position_prefix_length: INTEGER = 11
			-- Length of the string "(position: " used in error messages
			-- Used to calculate string offsets when extracting position information

	Ascii_control_char_boundary: INTEGER = 32
			-- ASCII code boundary for control characters (0x00-0x1F)
			-- Characters with code < 32 are control characters requiring escape
			-- Character code 32 is space (first printable ASCII character)

	Max_reasonable_indent_count: INTEGER = 8
			-- Maximum reasonable number of spaces for indentation
			-- Prevents excessive indentation that would harm readability
			-- Typical values: 2, 4, or 8 spaces

feature -- JSON Schema Keywords
	
	Schema_keyword_type: STRING_32 = "type"
			-- JSON Schema keyword for specifying value type
			-- Example: {"type": "string"}

	Schema_keyword_properties: STRING_32 = "properties"
			-- JSON Schema keyword for object property definitions
			-- Example: {"properties": {"name": {"type": "string"}}}

	Schema_keyword_required: STRING_32 = "required"
			-- JSON Schema keyword for required properties array
			-- Example: {"required": ["name", "email"]}

	Schema_keyword_items: STRING_32 = "items"
			-- JSON Schema keyword for array item schema
			-- Example: {"items": {"type": "number"}}

	Schema_keyword_minimum: STRING_32 = "minimum"
			-- JSON Schema keyword for minimum numeric value
			-- Example: {"minimum": 0}

	Schema_keyword_maximum: STRING_32 = "maximum"
			-- JSON Schema keyword for maximum numeric value
			-- Example: {"maximum": 100}

	Schema_keyword_min_length: STRING_32 = "minLength"
			-- JSON Schema keyword for minimum string length
			-- Example: {"minLength": 1}

	Schema_keyword_max_length: STRING_32 = "maxLength"
			-- JSON Schema keyword for maximum string length
			-- Example: {"maxLength": 255}

	Schema_keyword_min_items: STRING_32 = "minItems"
			-- JSON Schema keyword for minimum array length
			-- Example: {"minItems": 1}

	Schema_keyword_max_items: STRING_32 = "maxItems"
			-- JSON Schema keyword for maximum array length
			-- Example: {"maxItems": 100}

	Schema_keyword_pattern: STRING_32 = "pattern"
			-- JSON Schema keyword for regex pattern matching
			-- Example: {"pattern": "^[0-9]+$"}

feature -- JSON Type Keywords

	Json_type_string: STRING_32 = "string"
			-- JSON type name for string values
			-- Used in schema type validation

	Json_type_number: STRING_32 = "number"
			-- JSON type name for numeric values
			-- Used in schema type validation

	Json_type_integer: STRING_32 = "integer"
			-- JSON type name for integer values
			-- Used in schema type validation

	Json_type_object: STRING_32 = "object"
			-- JSON type name for object values
			-- Used in schema type validation

	Json_type_array: STRING_32 = "array"
			-- JSON type name for array values
			-- Used in schema type validation

	Json_type_null: STRING_32 = "null"
			-- JSON type name for null values
			-- Used in schema type validation

feature -- JSON Formatting Strings

	Default_two_space_indent: STRING_32 = "  "
			-- Standard two-space indentation for JSON pretty printing
			-- Most common indentation style for JSON

	Json_colon_space: STRING_32 = ": "
			-- Standard separator between key and value in JSON objects
			-- Format: "key": value

	Json_comma: STRING_32 = ","
			-- Comma separator for array elements and object properties

	Json_empty_object: STRING_32 = "{}"
			-- String representation of empty JSON object

	Json_empty_array: STRING_32 = "[]"
			-- String representation of empty JSON array

	Json_open_brace: STRING_32 = "{"
			-- Opening brace for JSON objects

	Json_close_brace: STRING_32 = "}"
			-- Closing brace for JSON objects

	Json_open_bracket: STRING_32 = "["
			-- Opening bracket for JSON arrays

	Json_close_bracket: STRING_32 = "]"
			-- Closing bracket for JSON arrays

	Json_quote: STRING_32 = "%""
			-- Double quote character for JSON strings

	Json_true: STRING_32 = "true"
			-- JSON boolean true literal

	Json_false: STRING_32 = "false"
			-- JSON boolean false literal

	Json_null_literal: STRING_32 = "null"
			-- JSON null literal

feature -- JSON Escape Sequences

	Json_escape_quote: STRING_32 = "\%""
			-- Escaped double quote: \"
			-- Used when outputting quotes within JSON strings

	Json_escape_backslash: STRING_32 = "\\"
			-- Escaped backslash: \\
			-- Used when outputting backslash within JSON strings

	Json_escape_newline: STRING_32 = "\n"
			-- Escaped newline: \n
			-- Used for newline characters in JSON strings

	Json_escape_return: STRING_32 = "\r"
			-- Escaped carriage return: \r
			-- Used for carriage return characters in JSON strings

	Json_escape_tab: STRING_32 = "\t"
			-- Escaped tab: \t
			-- Used for tab characters in JSON strings

	Json_escape_formfeed: STRING_32 = "\f"
			-- Escaped form feed: \f
			-- Used for form feed characters in JSON strings

	Json_escape_backspace: STRING_32 = "\b"
			-- Escaped backspace: \b
			-- Used for backspace characters in JSON strings

	Json_escape_unicode_prefix: STRING_32 = "\u"
			-- Unicode escape sequence prefix: \u
			-- Followed by 4 hex digits for Unicode code point

	Hex_padding_zero: STRING_32 = "0"
			-- Zero character used for padding hex strings
			-- Ensures 4-digit format for Unicode escapes

note
	copyright: "2025, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Library
		https://github.com/ljr1981/simple_json
	]"

end
