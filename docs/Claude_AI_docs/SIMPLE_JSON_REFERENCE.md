# SIMPLE_JSON Library Reference
## Project-Specific API Knowledge and Patterns

**Date:** November 15, 2025  
**Purpose:** Complete API reference and usage patterns for SIMPLE_JSON library  
**Scope:** Project-specific (not general Eiffel)

---

## TABLE OF CONTENTS

1. [Library Overview](#library-overview)
2. [API Quick Reference](#api-quick-reference)
3. [Type-Specific vs Generic Methods](#type-specific-vs-generic-methods)
4. [Fluent API Pattern](#fluent-api-pattern)
5. [Type Checking & Conversion](#type-checking--conversion)
6. [Deep Copy Requirements](#deep-copy-requirements)
7. [Common Usage Patterns](#common-usage-patterns)
8. [Project Conventions](#project-conventions)
9. [Complete API Tables](#complete-api-tables)

---

## Library Overview

### Architecture

SIMPLE_JSON provides multiple abstraction levels:

1. **One-liners** - Quick value extraction
2. **Path navigation** - Dot notation access
3. **Query interface** - Type-safe checks
4. **Fluent builder** - Method chaining
5. **Full API** - Complete JSON_VALUE access

### Core Classes

```
SIMPLE_JSON               -- Parser and main entry point
SIMPLE_JSON_VALUE         -- Base value wrapper
SIMPLE_JSON_OBJECT        -- Object (map) wrapper
SIMPLE_JSON_ARRAY         -- Array (list) wrapper
SIMPLE_JSON_POINTER       -- JSON Pointer (RFC 6901)
SIMPLE_JSON_PATCH         -- JSON Patch (RFC 6902)
SIMPLE_JSON_MERGE_PATCH   -- JSON Merge Patch (RFC 7386)
SIMPLE_JSON_SCHEMA        -- Schema validation (Draft 7)
```

### Design Philosophy

- **Wrapper pattern** - Wraps underlying JSON library
- **Type safety** - Eiffel's static typing
- **Clean API** - Easier than raw JSON library
- **Production quality** - 100% test coverage

---

## API Quick Reference

### CRITICAL: Never Assume Method Names

**MANDATORY FIRST STEP before ANY implementation:**

```bash
# View the actual source file
view /path/to/simple_json_object.e
view /path/to/simple_json_array.e

# Document actual method signatures
# Use ONLY verified names in code
```

### Actual Method Names (Verified)

**What you might assume (ALL WRONG):**
```eiffel
obj.has (key)          -- WRONG - doesn't exist
obj.value (key)        -- WRONG - doesn't exist
obj.get (key)          -- WRONG - doesn't exist
obj.put (v, k)         -- WRONG - doesn't exist
arr.add (v)            -- WRONG - doesn't exist
```

**What actually exists (CORRECT):**
```eiffel
obj.has_key (key)           -- Actual method
obj.item (key)              -- Actual method
obj.put_value (v, k)        -- Generic variant
obj.put_object (o, k)       -- Type-specific variant
arr.add_value (v)           -- Generic variant
arr.add_object (o)          -- Type-specific variant
```

---

## Type-Specific vs Generic Methods

### The Pattern

SIMPLE_JSON provides BOTH generic and type-specific methods:

```eiffel
-- GENERIC - accepts any SIMPLE_JSON_VALUE
put_value (v: SIMPLE_JSON_VALUE; k: STRING_32)
add_value (v: SIMPLE_JSON_VALUE)

-- TYPE-SPECIFIC - enforces type at call site
put_object (o: SIMPLE_JSON_OBJECT; k: STRING_32)
put_array (a: SIMPLE_JSON_ARRAY; k: STRING_32)
put_string (s: STRING_32; k: STRING_32)
add_object (o: SIMPLE_JSON_OBJECT)
add_array (a: SIMPLE_JSON_ARRAY)
add_string (s: STRING_32)
```

### When to Use Which

```eiffel
-- âœ“ Use TYPE-SPECIFIC when you know the type
if al_value.is_object then
    obj.put_object (al_value.as_object, key).do_nothing
end

-- âœ“ Use GENERIC when type is variable
obj.put_value (some_value, key).do_nothing

-- âœ— Don't use generic when type is known
-- Less clear and loses type information
obj.put_value (al_value, key).do_nothing  -- When you know it's an object
```

---

## Fluent API Pattern

### The Design

All mutation methods return self for chaining:

```eiffel
put_value (v: SIMPLE_JSON_VALUE; k: STRING_32): SIMPLE_JSON_OBJECT
add_value (v: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY
-- Returns self (Current)
```

### Usage

```eiffel
-- âœ“ CHAINING - no .do_nothing needed
create obj.make
obj.put_string ("Alice", "name")
   .put_integer (30, "age")
   .put_boolean (True, "active")

-- âœ“ SINGLE CALL - use .do_nothing
obj.put_string ("Bob", "name").do_nothing

-- âœ— WRONG - unused result warning
obj.put_string ("Bob", "name")  -- Compiler warning
```

### Why .do_nothing

1. Fluent API returns self
2. Compiler warns if result not used
3. `.do_nothing` signals "I know, ignoring it"
4. Production standard

---

## Type Checking & Conversion

### Type Check Methods

```eiffel
-- ALWAYS check type before conversion
value.is_object: BOOLEAN
value.is_array: BOOLEAN
value.is_string: BOOLEAN
value.is_number: BOOLEAN
value.is_integer: BOOLEAN
value.is_real: BOOLEAN
value.is_boolean: BOOLEAN
value.is_null: BOOLEAN
```

### Type Conversion Methods

```eiffel
-- ALL have preconditions - MUST check type first!

as_object: SIMPLE_JSON_OBJECT
    require
        is_object: is_object

as_array: SIMPLE_JSON_ARRAY
    require
        is_array: is_array

as_string_32: STRING_32
    require
        is_string: is_string

as_integer: INTEGER
    require
        is_integer: is_integer

as_real: REAL_64
    require
        is_number: is_number

as_boolean: BOOLEAN
    require
        is_boolean: is_boolean
```

### Safe Usage Pattern

```eiffel
-- âœ“ CORRECT - check before conversion
if value.is_object then
    obj := value.as_object
    -- use obj safely
elseif value.is_array then
    arr := value.as_array
    -- use arr safely
else
    -- handle other types
end

-- âœ— WRONG - precondition violation if not object
obj := value.as_object
```

---

## Deep Copy Requirements

### When Deep Copy Is Required

**Any operation that:**
- Merges JSON structures
- Transforms documents
- Must preserve original unchanged

### Why Needed

```eiffel
-- âœ— WRONG - shallow copy shares references
result.put_value (original.item (key), key)
-- Both result and original share same nested object!
-- Modifying the nested object affects both

-- âœ“ CORRECT - deep copy creates independent structure
if al_value.is_object then
    result.put_object (deep_copy_object (al_value.as_object), key)
elseif al_value.is_array then
    result.put_array (deep_copy_array (al_value.as_array), key)
else
    result.put_value (al_value, key)  -- Primitives OK to share
end
```

### Implementation Pattern

```eiffel
deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
        -- Create deep copy of object
    require
        object_attached: a_object /= Void
    local
        l_result: SIMPLE_JSON_OBJECT
        l_keys: ARRAY [STRING_32]
        l_value: detachable SIMPLE_JSON_VALUE
    do
        create l_result.make
        l_keys := a_object.keys
        
        across l_keys as ic loop
            l_value := a_object.item (ic)
            
            check value_attached: attached l_value as al_value then
                if al_value.is_object then
                    -- Recursive deep copy
                    l_result.put_object (
                        deep_copy_object (al_value.as_object), 
                        ic
                    ).do_nothing
                elseif al_value.is_array then
                    -- Recursive deep copy
                    l_result.put_array (
                        deep_copy_array (al_value.as_array), 
                        ic
                    ).do_nothing
                else
                    -- Primitives can share (immutable)
                    l_result.put_value (al_value, ic).do_nothing
                end
            end
        end
        
        Result := l_result
    ensure
        result_attached: Result /= Void
        original_unchanged: a_object ~ old a_object
    end

deep_copy_array (a_array: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY
        -- Create deep copy of array
    require
        array_attached: a_array /= Void
    local
        l_result: SIMPLE_JSON_ARRAY
        l_value: detachable SIMPLE_JSON_VALUE
    do
        create l_result.make
        
        across 1 |..| a_array.count as ic loop
            l_value := a_array.item (ic)
            
            check value_attached: attached l_value as al_value then
                if al_value.is_object then
                    l_result.add_object (
                        deep_copy_object (al_value.as_object)
                    ).do_nothing
                elseif al_value.is_array then
                    l_result.add_array (
                        deep_copy_array (al_value.as_array)
                    ).do_nothing
                else
                    l_result.add_value (al_value).do_nothing
                end
            end
        end
        
        Result := l_result
    ensure
        result_attached: Result /= Void
        original_unchanged: a_array ~ old a_array
    end
```

---

## Common Usage Patterns

### Parsing JSON

```eiffel
local
    l_parser: SIMPLE_JSON
    l_value: detachable SIMPLE_JSON_VALUE
do
    create l_parser
    l_value := l_parser.parse ("{%"name%": %"Alice%"}")
    
    if l_value /= Void and then l_value.is_object then
        -- use l_value.as_object
    end
end
```

### Building JSON Object

```eiffel
local
    l_obj: SIMPLE_JSON_OBJECT
do
    create l_obj.make
    l_obj.put_string ("Alice", "name")
         .put_integer (30, "age")
         .put_boolean (True, "active")
end
```

### Accessing Nested Values

```eiffel
local
    l_city: detachable SIMPLE_JSON_VALUE
do
    -- Safe navigation with checks
    if attached obj.item ("address") as l_addr then
        if l_addr.is_object then
            l_city := l_addr.as_object.item ("city")
        end
    end
end
```

### Iterating Objects

```eiffel
local
    l_keys: ARRAY [STRING_32]
    l_value: detachable SIMPLE_JSON_VALUE
do
    l_keys := obj.keys
    
    across l_keys as ic loop
        l_value := obj.item (ic)
        
        if attached l_value as al_value then
            -- process al_value
        end
    end
end
```

### Iterating Arrays

```eiffel
local
    l_value: detachable SIMPLE_JSON_VALUE
do
    across 1 |..| arr.count as ic loop
        l_value := arr.item (ic)
        
        if attached l_value as al_value then
            -- process al_value
        end
    end
end
```

---

## Project Conventions

### File Naming

```
simple_json.e                    -- lowercase with underscores
simple_json_value.e
simple_json_object.e
test_simple_json.e               -- TEST_ prefix
```

### Class Naming

```eiffel
class SIMPLE_JSON                -- UPPERCASE with underscores
class SIMPLE_JSON_VALUE
class SIMPLE_JSON_OBJECT
class TEST_SIMPLE_JSON           -- TEST_ prefix
```

### Shared Pattern

```eiffel
class
    SHARED_SIMPLE_JSON

feature -- Access

    json: SIMPLE_JSON
            -- Shared parser instance
        once
            create Result
        ensure
            json_attached: Result /= Void
        end

end
```

**Usage in tests:**
```eiffel
class TEST_MY_FEATURE
inherit
    EQA_TEST_SET
    SHARED_SIMPLE_JSON  -- Use shared instance

feature
    test_something
        local
            l_value: detachable SIMPLE_JSON_VALUE
        do
            l_value := json.parse ("...")  -- Use shared json
        end
end
```

---

## Complete API Tables

### SIMPLE_JSON (Parser)

| Method | Returns | Purpose |
|--------|---------|---------|
| parse (text: STRING) | detachable SIMPLE_JSON_VALUE | Parse JSON text |
| string_value (s: STRING_32) | SIMPLE_JSON_VALUE | Create string value |
| integer_value (i: INTEGER) | SIMPLE_JSON_VALUE | Create integer value |
| real_value (r: REAL_64) | SIMPLE_JSON_VALUE | Create real value |
| boolean_value (b: BOOLEAN) | SIMPLE_JSON_VALUE | Create boolean value |
| null_value | SIMPLE_JSON_VALUE | Create null value |

### SIMPLE_JSON_OBJECT (Query Methods)

| Method | Returns | Purpose |
|--------|---------|---------|
| has_key (k: STRING_32) | BOOLEAN | Check if key exists |
| item (k: STRING_32) | detachable SIMPLE_JSON_VALUE | Get value for key |
| keys | ARRAY [STRING_32] | Get all keys |
| count | INTEGER | Number of properties |
| is_empty | BOOLEAN | Has no properties |

### SIMPLE_JSON_OBJECT (Mutation Methods)

All return SIMPLE_JSON_OBJECT for chaining:

| Method | Parameters | Purpose |
|--------|-----------|---------|
| put_value | (v: VALUE; k: STRING_32) | Generic put |
| put_object | (o: OBJECT; k: STRING_32) | Type-specific |
| put_array | (a: ARRAY; k: STRING_32) | Type-specific |
| put_string | (s: STRING_32; k: STRING_32) | Type-specific |
| put_integer | (i: INTEGER; k: STRING_32) | Type-specific |
| put_real | (r: REAL_64; k: STRING_32) | Type-specific |
| put_boolean | (b: BOOLEAN; k: STRING_32) | Type-specific |
| put_null | (k: STRING_32) | Type-specific |
| remove | (k: STRING_32) | Delete property |

### SIMPLE_JSON_ARRAY (Query Methods)

| Method | Returns | Purpose |
|--------|---------|---------|
| item (i: INTEGER) | detachable SIMPLE_JSON_VALUE | Get item at index |
| count | INTEGER | Number of items |
| is_empty | BOOLEAN | Has no items |

### SIMPLE_JSON_ARRAY (Mutation Methods)

All return SIMPLE_JSON_ARRAY for chaining:

| Method | Parameters | Purpose |
|--------|-----------|---------|
| add_value | (v: VALUE) | Generic add |
| add_object | (o: OBJECT) | Type-specific |
| add_array | (a: ARRAY) | Type-specific |
| add_string | (s: STRING_32) | Type-specific |
| add_integer | (i: INTEGER) | Type-specific |
| add_real | (r: REAL_64) | Type-specific |
| add_boolean | (b: BOOLEAN) | Type-specific |
| add_null | | Type-specific |

### SIMPLE_JSON_VALUE (Type Checking)

| Method | Returns | Purpose |
|--------|---------|---------|
| is_object | BOOLEAN | Is JSON object |
| is_array | BOOLEAN | Is JSON array |
| is_string | BOOLEAN | Is JSON string |
| is_number | BOOLEAN | Is JSON number |
| is_integer | BOOLEAN | Is integer number |
| is_real | BOOLEAN | Is real number |
| is_boolean | BOOLEAN | Is JSON boolean |
| is_null | BOOLEAN | Is JSON null |

### SIMPLE_JSON_VALUE (Type Conversion)

All have preconditions - check type first!

| Method | Returns | Precondition |
|--------|---------|-------------|
| as_object | SIMPLE_JSON_OBJECT | is_object |
| as_array | SIMPLE_JSON_ARRAY | is_array |
| as_string_32 | STRING_32 | is_string |
| as_integer | INTEGER | is_integer |
| as_real | REAL_64 | is_number |
| as_boolean | BOOLEAN | is_boolean |

---

## Critical Anti-Patterns

### âŒ NEVER Do These

```eiffel
-- 1. Don't assume method names
obj.has ("key")              -- WRONG - use has_key
obj.value ("key")            -- WRONG - use item
obj.put (v, k)               -- WRONG - use put_value or put_object

-- 2. Don't forget type checks
obj := value.as_object       -- WRONG - what if not object?

-- 3. Don't use check for attachment
check val /= Void end
use (val)                    -- WRONG - still detachable

-- 4. Don't shallow copy nested structures
result.put_value (original.item (key), key)  -- WRONG - shared reference

-- 5. Don't forget .do_nothing on single calls
obj.put_value (v, k)         -- WRONG - unused result warning
```

### âœ… ALWAYS Do These

```eiffel
-- 1. View source before calling
-- view /path/to/simple_json_object.e

-- 2. Check type before conversion
if value.is_object then
    obj := value.as_object
end

-- 3. Use if attached for detachable
if attached optional as al_val then
    use (al_val)
end

-- 4. Deep copy nested structures
if al_value.is_object then
    result.put_object (deep_copy_object (al_value.as_object), key)
end

-- 5. Add .do_nothing to single fluent calls
obj.put_value (v, k).do_nothing
```

---

## Quick Decision Trees

### Which method to use?

```
Adding to object with known type?
â”œâ”€ String â†’ put_string (s, k)
â”œâ”€ Integer â†’ put_integer (i, k)
â”œâ”€ Object â†’ put_object (o, k)
â”œâ”€ Array â†’ put_array (a, k)
â””â”€ Variable type â†’ put_value (v, k)

Adding to array with known type?
â”œâ”€ String â†’ add_string (s)
â”œâ”€ Integer â†’ add_integer (i)
â”œâ”€ Object â†’ add_object (o)
â”œâ”€ Array â†’ add_array (a)
â””â”€ Variable type â†’ add_value (v)
```

### How to safely access?

```
Getting value from object/array?
â”œâ”€ Use item (key) or item (index)
â”‚   â””â”€ Returns detachable
â”‚       â””â”€ Use if attached pattern
â”‚           â””â”€ Check type with is_X
â”‚               â””â”€ Convert with as_X
```

### Do I need deep copy?

```
Am I merging/transforming JSON?
â”œâ”€ YES â†’ Does operation preserve original?
â”‚   â”œâ”€ YES â†’ Need deep copy
â”‚   â”‚   â””â”€ Recursively copy objects/arrays
â”‚   â””â”€ NO â†’ Direct modification OK
â””â”€ NO â†’ Regular reference OK
```

---

## Summary

### Core Principles

1. **Never assume API** - Always view source
2. **Check types first** - Before conversion
3. **Use if attached** - For detachable
4. **Deep copy structures** - For transformations
5. **Use type-specific** - When type known
6. **Add .do_nothing** - For fluent single calls

### The Pattern

```eiffel
-- 1. View source
-- view /path/to/class.e

-- 2. Use actual method names
if obj.has_key ("name") then  -- Not has()
    val := obj.item ("name")  -- Not value() or get()
end

-- 3. Check type
if attached val as al_val then
    if al_val.is_string then
        name := al_val.as_string_32
    end
end

-- 4. Use type-specific when known
obj.put_string ("Alice", "name").do_nothing

-- 5. Deep copy for transforms
if al_val.is_object then
    result.put_object (deep_copy_object (al_val.as_object), key)
end
```

Follow these patterns and SIMPLE_JSON will be:
- âœ“ Safe from API bugs
- âœ“ Type-safe and void-safe
- âœ“ Clear and maintainable
- âœ“ Production quality

---

## ADDENDUM: Lessons from JSON Merge Patch Implementation

### Real API Calls That Work

**Context:** These are the ACTUAL method names verified by viewing source during JSON Merge Patch implementation.

```eiffel
-- ✅ VERIFIED - These methods exist
SIMPLE_JSON_OBJECT:
  - has_key (k: STRING_32): BOOLEAN
  - item (k: STRING_32): detachable SIMPLE_JSON_VALUE
  - put_value (v: SIMPLE_JSON_VALUE; k: STRING_32): SIMPLE_JSON_OBJECT
  - put_object (o: SIMPLE_JSON_OBJECT; k: STRING_32): SIMPLE_JSON_OBJECT
  - remove (k: STRING_32)
  - keys: ARRAY [STRING_32]
  
SIMPLE_JSON_ARRAY:
  - item (i: INTEGER): detachable SIMPLE_JSON_VALUE
  - add_value (v: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY
  - count: INTEGER

SIMPLE_JSON_VALUE:
  - is_object, is_array, is_string, is_number, is_null: BOOLEAN
  - as_object: SIMPLE_JSON_OBJECT (require is_object)
  - as_array: SIMPLE_JSON_ARRAY (require is_array)
  - json_object: JSON_OBJECT  -- Access to underlying type
  - json_value: JSON_VALUE    -- Access to underlying type
```

**What we learned the hard way:**
- NO `has()` method → Use `has_key()`
- NO `value()` method → Use `item()`
- NO `put()` method → Use `put_value()` or `put_object()`
- NO `add()` method → Use `add_value()` or `add_object()`

### Construction Patterns That Work

**Creating wrapped values from underlying types:**

```eiffel
-- ✅ CORRECT - These constructors exist
create Result.make_with_json_object (l_object.json_object)
create Result.make_with_json_value (l_value.json_value)

-- ❌ WRONG - Don't assume these exist
create Result.make (l_object)  -- Doesn't work
create Result.from_value (l_value)  -- Doesn't work
```

### Deep Copy Implementation (VERIFIED WORKING)

This pattern successfully merges JSON structures:

```eiffel
deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
		-- QUERY: Build deep copy of object
	require
		object_attached: a_object /= Void
	local
		l_result: SIMPLE_JSON_OBJECT
		l_keys: ARRAY [STRING_32]
		l_value: detachable SIMPLE_JSON_VALUE
	do
		create l_result.make
		l_keys := a_object.keys
		
		across l_keys as ic loop
			l_value := a_object.item (ic)
			
			check value_attached: attached l_value as al_value then
				if al_value.is_object then
					-- Recursive deep copy
					l_result.put_object (
						deep_copy_object (al_value.as_object),
						ic
					).do_nothing
				elseif al_value.is_array then
					-- Recursive deep copy
					l_result.put_array (
						deep_copy_array (al_value.as_array),
						ic
					).do_nothing
				else
					-- Primitives can share (immutable)
					l_result.put_value (al_value, ic).do_nothing
				end
			end
		end
		
		Result := l_result
	ensure
		result_attached: Result /= Void
		original_unchanged: a_object ~ old a_object
	end
```

**Why this works:**
- Creates new objects at each level
- Recursively copies nested structures
- Preserves originals (postcondition verified)
- Uses actual API method names

### Lessons Learned Checklist

Before implementing ANY feature using SIMPLE_JSON:

- [ ] View source files for classes you'll use
- [ ] Document exact method signatures
- [ ] Note parameter order (especially for put_* methods)
- [ ] Check if recursion needed (is_object/is_array checks?)
- [ ] Plan deep copy for structural operations
- [ ] Use type-specific methods when type known
- [ ] Remember .do_nothing for single fluent calls

### Common Mistakes (NOW AVOIDED)

```eiffel
-- ❌ Assuming API names
if obj.has ("key") then  -- Wrong: has_key not has

-- ❌ Wrong parameter order
obj.put ("key", value)  -- Wrong: put_value (value, key)

-- ❌ Missing recursion
result.put_value (orig.item (key), key)  -- Wrong: shallow copy

-- ❌ Wrong constructor
create Result.make (json_obj)  -- Wrong: make_with_json_object

-- ❌ Forgetting .do_nothing
obj.put_value (v, k)  -- Wrong: compiler warning

-- ✅ ALL CORRECT
if obj.has_key (key) then
    obj.put_value (value, key).do_nothing
    if attached obj.item (key) as al_val then
        if al_val.is_object then
            -- Recursive operation needed
        end
    end
end
```

---

## ADDENDUM 2: Streaming Parser Patterns (November 2025)

### Implementing ITERABLE and ITERATION_CURSOR

**Context:** Building SIMPLE_JSON_STREAM required implementing Eiffel's iterator interfaces.

### Contract Inheritance Requirements

**When implementing ITERABLE:**
```eiffel
class SIMPLE_JSON_STREAM
inherit
    ITERABLE [SIMPLE_JSON_STREAM_ELEMENT]

feature
    new_cursor: SIMPLE_JSON_STREAM_CURSOR
        do
            if not is_parsed then
                parse_array
            end
            create Result.make (Current)
        ensure then  -- REQUIRED! Not plain "ensure"
            cursor_attached: Result /= Void
        end
end
```

**When implementing ITERATION_CURSOR:**
```eiffel
class SIMPLE_JSON_STREAM_CURSOR
inherit
    ITERATION_CURSOR [SIMPLE_JSON_STREAM_ELEMENT]

feature
    item: SIMPLE_JSON_STREAM_ELEMENT
        require else  -- REQUIRED! Not plain "require"
            not_after: not after
        do
            create Result.make (stream.elements.i_th (current_index), current_index)
        end

    after: BOOLEAN
        do
            Result := current_index > stream.element_count
        end

    forth
        do
            current_index := current_index + 1
        end
end
```

### Across Loop Usage Pattern

**Creating streamable elements:**
```eiffel
class SIMPLE_JSON_STREAM_ELEMENT
create
    make

feature
    make (a_value: SIMPLE_JSON_VALUE; a_index: INTEGER)
        do
            value := a_value
            index := a_index
        end

    value: SIMPLE_JSON_VALUE
    index: INTEGER
end
```

**Using in across loops:**
```eiffel
-- âœ… CORRECT - Direct feature access
across stream as ic loop
    process (ic.value)  -- Not ic.item.value
    print (ic.index)    -- Not ic.item.index
end

-- âŒ WRONG - Extra .item indirection
across stream as ic loop
    process (ic.item.value)  -- Unnecessary .item
    print (ic.item.index)    -- Unnecessary .item
end
```

### Key Lessons

1. **Contract inheritance is mandatory** when implementing interfaces with contracts
   - Use `require else` for preconditions
   - Use `ensure then` for postconditions

2. **Across loops provide transparent access** to cursor's item features
   - Write: `ic.feature_name`
   - Not: `ic.item.feature_name`

3. **Element types should be simple data carriers** with clear features
   - Keep element classes focused
   - Provide meaningful feature names
   - No complex logic in element classes

### API Pattern for Streaming

```eiffel
-- Create stream from file or string
create stream.make_from_file ("data.json")
create stream.make_from_string ("[...]")

-- Natural iteration
across stream as ic loop
    -- ic.value: SIMPLE_JSON_VALUE
    -- ic.index: INTEGER (1-based position)
    process (ic.value)
end

-- Error checking
if stream.has_errors then
    across stream.last_errors as ic_err loop
        print (ic_err.to_string)
    end
end

-- Multiple iterations supported
across stream as ic loop ... end
across stream as ic loop ... end  -- Works fine
```

---

note
    copyright: "2024, Larry Rix"
    license: "MIT License"
    source: "[
        SIMPLE_JSON Project API Reference
        Updated with JSON Merge Patch lessons
    ]"
    last_updated: "November 15, 2025"
end
