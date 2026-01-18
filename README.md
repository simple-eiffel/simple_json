<p align="center">
  <img src="docs/images/logo.png" alt="simple_json logo" width="200">
</p>

<h1 align="center">simple_json</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_json/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_json">GitHub</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

Modern JSON library for Eiffel with RFC compliance and JSON Schema validation.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 216 tests passing, 100% coverage
- JSON Schema Draft 7 validation
- Full RFC compliance (6901, 6902, 7386)
- Design by Contract throughout

## Overview

SIMPLE_JSON builds on the standard eJSON library to provide modern features: **JSON Schema validation** (Draft 7), **JSON Pointer** (RFC 6901), **JSON Patch** (RFC 6902), **JSON Merge Patch** (RFC 7386), **JSONPath queries**, and streaming for large files.

## Quick Start (Zero-Configuration)

Use `SIMPLE_JSON_QUICK` for the simplest possible JSON operations:

```eiffel
local
    json: SIMPLE_JSON_QUICK
    name: detachable STRING
do
    create json.make

    -- Parse and query in one call
    name := json.get_string (json_string, "$.users[0].name")

    -- Parse to object
    if attached json.parse_object (json_string) as obj then
        name := json.string_at (obj, "user.name")
    end

    -- Build JSON fluently
    print (json.object.put ("name", "Alice").put ("age", 30).to_json)
    -- {"name":"Alice","age":30}

    -- Quick object from pairs
    print (json.from_pairs (<<["city", "Paris"], ["country", "France"]>>))

    -- Validation
    if json.is_valid (some_string) then ...
    if json.is_object (some_string) then ...
end
```

## Standard API (Full Control)

```eiffel
local
    json: SIMPLE_JSON
do
    create json
    if attached json.parse ('{"users": [{"name": "Alice"}]}') as v then
        print (json.query_string (v, "$.users[0].name"))  -- "Alice"
    end
end
```

## Features

- **JSON Schema Validation** - Draft 7 support (only Eiffel library with this)
- **JSON Pointer** (RFC 6901) - Navigate with "/users/0/name"
- **JSON Patch** (RFC 6902) - add, remove, replace, move, copy, test
- **JSON Merge Patch** (RFC 7386) - Declarative document merging
- **JSONPath Queries** - SQL-like queries: "$.users[*].name"
- **Streaming Parser** - Process gigabyte files with constant memory
- **Full Unicode** - UTF-8/UTF-16 through STRING_32
- **Decimal Precision** - Exact decimal values via simple_decimal (no floating-point artifacts)

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

2. Add to ECF:
```xml
<library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
```

## Dependencies

- simple_decimal (for exact decimal support)

## Decimal Precision

For financial data or any values requiring exact representation, use `put_decimal` instead of `put_real`:

```eiffel
local
    obj: SIMPLE_JSON_OBJECT
    price: SIMPLE_DECIMAL
do
    create price.make ("19.99")
    obj := json.new_object
        .put_decimal (price, "price")

    print (obj.to_json)
    -- {"price": 19.99}  (exact, not 19.989999999999998)
end
```

**The problem with REAL:**
```eiffel
obj.put_real (19.99, "price")
-- Output: {"price": 19.989999999999998}
```

**The solution with SIMPLE_DECIMAL:**
```eiffel
create price.make ("19.99")
obj.put_decimal (price, "price")
-- Output: {"price": 19.99}
```

**Decimal API:**
- `put_decimal (value, key)` - Store exact decimal in object
- `decimal_item (key)` - Retrieve as SIMPLE_DECIMAL
- `add_decimal (value)` - Add to array
- `as_decimal` - Convert any JSON number to SIMPLE_DECIMAL

## License

MIT License - see [LICENSE](LICENSE) file.

---

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.
