# Eiffel Production Code Guide
## Complete Reference for Writing Professional Eiffel Code

**Date:** November 15, 2025  
**Purpose:** Primary guide consolidating all production patterns, conventions, and best practices  
**Scope:** General Eiffel development (not project-specific)

---

## TABLE OF CONTENTS

1. [Class Structure & Organization](#class-structure--organization)
2. [Feature Organization & Categories](#feature-organization--categories)
3. [Naming Conventions](#naming-conventions)
4. [Note Clauses & Documentation](#note-clauses--documentation)
5. [Inheritance Patterns](#inheritance-patterns)
6. [Creation Procedures](#creation-procedures)
7. [Type Safety & Void-Safety](#type-safety--void-safety)
8. [Design by Contract](#design-by-contract)
9. [The SHARED Pattern](#the-shared-pattern)
10. [The CELL Pattern](#the-cell-pattern)
11. [Once Features](#once-features)
12. [Generic Patterns](#generic-patterns)
13. [Testing Patterns](#testing-patterns)
14. [Advanced Patterns](#advanced-patterns)
15. [Quick Reference Tables](#quick-reference-tables)

---

## Class Structure & Organization

### Standard Class Template

```eiffel
note
    description: "[
        Multi-line descriptions use brackets.
        Each line describes an aspect of the class.
    ]"
    legal: "See notice at end of class."
    date: "$Date$"
    revision: "$Revision$"
    EIS: "name=...", "src=...", "tag=..."

class
    CLASS_NAME

inherit
    PARENT_1
        redefine
            feature1, feature2
        undefine
            feature3
        export
            {NONE} all
            {ANY} public_feature
        end

create
    make,
    make_with_value

feature {NONE} -- Initialization

feature -- Access

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Element change

feature -- Removal

feature -- Conversion

feature -- Output

feature {NONE} -- Implementation

feature {NONE} -- Constants

invariant
    named_invariant: condition

note
    copyright: "Copyright (c) YEAR, Organization"
    license: "License information"
    source: "[Organization details]"
end
```

### Key Structural Requirements

1. **Note clauses at beginning AND end**
2. **Features organized by standard categories** (see next section)
3. **Multiple named creation procedures**
4. **Export control in inheritance**
5. **Named invariants**

---

## Feature Organization & Categories

### Mandatory Category Order

Production Eiffel code uses these feature categories **in this exact order**:

| Order | Category | Visibility | Purpose |
|-------|----------|------------|---------|
| 1 | Initialization | {NONE} | Creation procedures |
| 2 | Access | Public | Query features returning values |
| 3 | Measurement | Public | Size, count, length queries |
| 4 | Status report | Public | Boolean queries about state |
| 5 | Status setting | Public | Enable/disable commands |
| 6 | Element change | Public | Modify content commands |
| 7 | Removal | Public | Delete/remove commands |
| 8 | Conversion | Public | Type conversion features |
| 9 | Output | Public | External output features |
| 10 | Implementation | {NONE} | Private helper features |
| 11 | Constants | {NONE} | Manifest constants |

### Category Examples

```eiffel
feature {NONE} -- Initialization
    make
            -- Initialize instance
        do
            create internal_list.make (10)
        end

feature -- Access
    count: INTEGER
            -- Number of items
    
    item (i: INTEGER): ITEM
            -- Item at position `i'

feature -- Measurement
    is_empty: BOOLEAN
            -- Is collection empty?
        do
            Result := count = 0
        end

feature -- Status report
    has_error: BOOLEAN
            -- Did an error occur?
    
    is_valid: BOOLEAN
            -- Is in valid state?

feature -- Status setting
    enable_logging
            -- Enable logging
    
    disable_feature
            -- Disable feature

feature -- Element change
    put (v: VALUE; k: KEY)
            -- Add `v' with key `k'
    
    extend (item: ITEM)
            -- Add `item' to end

feature -- Removal
    remove (key: KEY)
            -- Remove item with `key'
    
    wipe_out
            -- Remove all items

feature -- Conversion
    as_string: STRING
            -- String representation
    
    to_integer: INTEGER
            -- Integer value

feature {NONE} -- Implementation
    internal_buffer: STRING
            -- Private storage
    
    compute_value: INTEGER
            -- Calculate internal value

feature {NONE} -- Constants
    Default_size: INTEGER = 10
    Buffer_increment: INTEGER = 256
```

### Critical Rules

- âœ“ **Always use standard categories**
- âœ“ **Never mix categories**
- âœ“ **Maintain consistent order**
- âœ— **Don't organize by visibility first**
- âœ— **Don't create custom categories**

---

## Naming Conventions

### Local Variables

```eiffel
-- General locals - l_ prefix
l_result: STRING
l_count: INTEGER
l_item: like item
l_value: VALUE

-- Attachment locals - al_ prefix
if attached value as al_value then
    use (al_value)  -- al_value is attached
end

-- Loop cursors - ic suffix or ic_ prefix
across items as ic loop
    process (ic)
end

-- Cell pattern - cl_ prefix
create cl_index.put (0)
process (text, cl_index)
```

### Feature Names

```eiffel
-- Queries (return values)
count: INTEGER
name: STRING
value: VALUE

-- Boolean queries - is_ or has_ prefix
is_empty: BOOLEAN
is_valid: BOOLEAN
has_key (k: KEY): BOOLEAN
has_error: BOOLEAN

-- Commands (procedures)
put (item: ITEM)
extend (value: VALUE)
remove (key: KEY)
enable_logging
disable_feature
wipe_out
```

### Class Names

```eiffel
-- Concrete classes - UPPERCASE
HTML_ENCODER
JSON_NUMBER
DATE_VALUE

-- Deferred classes - UPPERCASE
ENCODER
JSON_VALUE
COMPARABLE

-- Shared classes - SHARED_ prefix
SHARED_HTML_ENCODER
SHARED_JSON_PARSER
```

### File Names

```eiffel
-- Files - lowercase_with_underscores
html_encoder.e
json_number.e
date_value.e

-- Tests - test_ prefix
test_html_encoder.e
test_json_number.e
```

### Constants

```eiffel
-- Manifest constants - Mixed or UPPERCASE
Default_size: INTEGER = 10
BUFFER_SIZE: INTEGER = 256
Maximum_retries: INTEGER = 3

-- External constants - descriptive names
Log_emergency: INTEGER external "C" end
Log_alert: INTEGER external "C" end
```

---

## Note Clauses & Documentation

### Beginning Note Clause

```eiffel
note
    description: "[
        Multi-line description in brackets.
        
        Additional details.
        See: http://reference.url
    ]"
    legal: "See notice at end of class."
    date: "$Date$"
    revision: "$Revision$"
    EIS: "name=Specification", 
         "src=http://spec.url",
         "tag=reference"
```

### Ending Note Clause

```eiffel
note
    copyright: "Copyright (c) 2024, Organization"
    license: "MIT License (see http://...)"
    source: "[
        Organization Name
        Address
        Contact
    ]"
end
```

### EIS (Eiffel Information System)

```eiffel
note
    EIS: "name=JSON Specification",
         "src=http://json.org",
         "tag=JSON, specification"
    EIS: "name=RFC 7386",
         "src=https://tools.ietf.org/html/rfc7386",
         "tag=merge-patch, RFC"
```

**Purpose:** Creates F1 context-sensitive help in EiffelStudio

### Feature Documentation

```eiffel
count: INTEGER
        -- Number of items in collection
    do
        Result := internal_list.count
    end
```

**Always provide one-line comment after feature signature**

---

## Inheritance Patterns

### Multiple Inheritance with Export Control

```eiffel
class MY_CLASS

inherit
    PARENT_1
        redefine
            feature1
        end
    
    UTILITY_CLASS
        export
            {NONE} all  -- Hide everything
            {ANY} needed_feature  -- Expose only this
        end
```

### Conflict Resolution

```eiffel
class MY_CLASS

inherit
    PARENT_1
        undefine
            conflicting_feature  -- Remove implementation
        redefine
            other_feature
        end
    
    PARENT_2
        -- Also has conflicting_feature
        -- This one's implementation wins
        end
```

### Frozen Features

```eiffel
frozen default_create
        -- Cannot be redefined in descendants
    do
        -- implementation
    ensure then
        initialized: is_initialized
    end
```

### Contract Inheritance

**When redefining features with contracts, use special keywords:**

```eiffel
-- Parent class with contracts
deferred class ITERATION_CURSOR [G]
feature
    item: G
        require
            not_after: not after
        deferred
        ensure
            result_attached: Result /= Void
        end
end

-- Descendant - WRONG (replaces parent's contract)
class MY_CURSOR
inherit
    ITERATION_CURSOR [MY_ELEMENT]
feature
    item: MY_ELEMENT
        require  -- WRONG! Replaces parent's precondition
            custom_check: my_validation
        do
            Result := elements.i_th (index)
        ensure  -- WRONG! Replaces parent's postcondition
            my_check: Result.is_valid
        end
end

-- Descendant - CORRECT (adds to parent's contract)
class MY_CURSOR
inherit
    ITERATION_CURSOR [MY_ELEMENT]
feature
    item: MY_ELEMENT
        require else  -- CORRECT! Adds alternatives to precondition
            custom_check: my_validation
        do
            Result := elements.i_th (index)
        ensure then  -- CORRECT! Adds guarantees to postcondition
            my_check: Result.is_valid
        end
end
```

**Keywords:**
- `require else` - Adds alternative preconditions (OR logic)
- `ensure then` - Adds additional postconditions (AND logic)

**When to use:**
- ALWAYS when implementing deferred features with contracts
- ALWAYS when redefining features that have contracts
- Common with: ITERATION_CURSOR, ITERABLE, COMPARABLE

---

## Creation Procedures

### Multiple Named Creators

```eiffel
create
    make,
    make_with_size,
    make_from_string,
    make_empty
```

### Implementation Patterns

```eiffel
feature {NONE} -- Initialization

    make
            -- Initialize with defaults
        do
            create items.make (Default_size)
        ensure
            items_created: items /= Void
        end
    
    make_with_size (n: INTEGER)
            -- Initialize with capacity `n'
        require
            positive_size: n > 0
        do
            create items.make (n)
        ensure
            items_created: items /= Void
            correct_capacity: items.capacity >= n
        end
    
    make_from_string (s: STRING)
            -- Initialize from string representation
        require
            string_attached: s /= Void
            valid_format: is_valid_format (s)
        do
            -- Parse and initialize
        ensure
            initialized: is_initialized
        end
```

---

## Type Safety & Void-Safety

### Attached vs Detachable

```eiffel
-- Attached (default) - cannot be Void
name: STRING

-- Detachable - can be Void
optional_value: detachable STRING
```

### If Attached Pattern

```eiffel
-- âœ“ CORRECT - creates attached local
if attached optional_value as al_value then
    -- al_value is proven attached
    use (al_value)
else
    -- handle void case
end

-- âœ— WRONG - check doesn't create attached local
check optional_value /= Void end
use (optional_value)  -- Still detachable!
```

### Type Anchoring with `like`

```eiffel
items: ARRAYED_LIST [ITEM]

process
    local
        l_items: like items  -- Type anchored to attribute
    do
        l_items := items
    end
```

### Once-Per-Object Pattern

```eiffel
feature -- Access
    buffer: like new_buffer
        do
            if attached internal_buffer as l_buf then
                Result := l_buf
            else
                Result := new_buffer
                internal_buffer := Result
            end
        ensure
            buffer_attached: Result /= Void
        end

feature {NONE} -- Implementation
    internal_buffer: detachable like buffer
            -- Lazy initialization storage
    
    new_buffer: STRING
            -- Create new buffer
        do
            create Result.make (1024)
        ensure
            result_attached: Result /= Void
        end
```

---

## Design by Contract

### Named Assertions

```eiffel
feature -- Element change
    put (v: VALUE; k: KEY)
            -- Add `v' with key `k'
        require
            value_attached: v /= Void
            key_attached: k /= Void
            key_not_empty: not k.is_empty
        do
            internal_table.force (v, k)
        ensure
            value_stored: item (k) = v
            count_increased: count = old count + 1 or else
                has_key (old k)  -- Or key already existed
        end
```

**Every assertion must have a descriptive name**

### Compound Conditions

```eiffel
require
    valid_input: input /= Void and then
                 input.count > 0 and then
                 input.is_valid
```

**Use `and then` for short-circuit evaluation**

### Old Values

```eiffel
ensure
    one_more: count = old count + 1
    unchanged: value ~ (old value)
    increased: result > old result
```

### Check Assertions

```eiffel
do
    check value_is_number: value.is_number end
    
    if value.is_integer then
        result := value.as_integer.to_double
    else
        result := value.as_real
    end
end
```

### Named Invariants

```eiffel
invariant
    items_attached: items /= Void
    count_non_negative: count >= 0
    consistent_count: count = items.count
```

---

## The SHARED Pattern

### Pattern Structure

```eiffel
class
    SHARED_ENCODER

feature -- Access

    encoder: ENCODER
            -- Shared encoder instance
        once
            create Result
        ensure
            encoder_attached: Result /= Void
        end

end
```

### Usage

```eiffel
class MY_CLASS

inherit
    SHARED_ENCODER

feature

    process (text: STRING)
        local
            l_encoded: STRING
        do
            l_encoded := encoder.encode (text)
        end

end
```

### When to Use

âœ“ **Use for:**
- Global configurations
- Expensive-to-create objects
- Stateless utilities
- System-wide services

âœ— **Avoid for:**
- Objects with mutable state
- Objects needing multiple instances
- Test fixtures

---

## The CELL Pattern

### Problem

Eiffel passes expanded types (INTEGER, BOOLEAN, etc.) by value. How to modify in called routine?

### Solution

```eiffel
process (text: STRING; cl_index: CELL [INTEGER]): STRING
        -- Extract next token, update index via `cl_index'
    local
        i: INTEGER
    do
        i := cl_index.item  -- Get current index
        
        -- ... processing ...
        
        cl_index.replace (i + 10)  -- Update caller's index
    end
```

### Usage

```eiffel
local
    cl_i: CELL [INTEGER]
    l_result: STRING
do
    create cl_i.put (1)
    l_result := process (text, cl_i)
    next_position := cl_i.item  -- Get updated index
end
```

### When to Use

Use CELL when:
- Need to return multiple values
- Need mutable reference for expanded types
- Iterating with changing index in helper

---

## Once Features

### Regular Once (Process-Wide)

```eiffel
shared_buffer: STRING
        -- Created once per process
    once
        create Result.make (1024)
    end
```

### Process Once (Explicit)

```eiffel
config: CONFIGURATION
        -- Created once per process
    once ("PROCESS")
        create Result.load_from_file
    end
```

### Thread Once

```eiffel
thread_buffer: STRING
        -- Created once per thread
    once ("THREAD")
        create Result.make (1024)
    end
```

---

## Generic Patterns

### Generic with Constraints

```eiffel
deferred class
    ENCODER [U -> READABLE_STRING_GENERAL, 
             E -> READABLE_STRING_GENERAL]

feature
    encode (unencoded: U): E
        deferred
        end
end
```

### Generic Instantiation

```eiffel
class
    HTML_ENCODER

inherit
    ENCODER [READABLE_STRING_32, READABLE_STRING_8]

end
```

---

## Testing Patterns

### Test Class Structure

```eiffel
class
    TEST_MY_CLASS

inherit
    EQA_TEST_SET

feature -- Test routines

    test_basic_functionality
        note
            testing: "basic-operations"
        local
            l_obj: MY_CLASS
        do
            create l_obj.make
            
            assert ("initialized", l_obj.is_initialized)
            assert ("count_zero", l_obj.count = 0)
        end

end
```

### Test Naming

- Prefix: `test_`
- Descriptive: `test_parse_json_object`
- Note tag: `testing: "category"`

### Round-Trip Testing

```eiffel
test_encoder_decoder_round_trip
    local
        l_original, l_decoded: STRING
        l_encoded: STRING
    do
        l_original := "Test String"
        l_encoded := encoder.encode (l_original)
        l_decoded := encoder.decode (l_encoded)
        
        assert ("round_trip_successful", l_decoded ~ l_original)
    end
```

---

## Advanced Patterns

### Visitor Pattern

```eiffel
-- Base class
deferred class VALUE
feature
    accept (v: VISITOR)
        deferred
        end
end

-- Concrete class
class NUMBER
inherit VALUE
feature
    accept (v: VISITOR)
        do
            v.visit_number (Current)
        end
end
```

### Creation Expression

```eiffel
result := (create {PARSER}.make (config)).parse (text)
```

### Alias Operators

```eiffel
item alias "@" alias "/" (key: STRING): VALUE
        -- Access via: obj @ "key" or obj / "key"
```

### Multiple Feature Names

```eiffel
double_value, real_value: REAL_64
        -- Same feature, two names
```

### Boolean Constants

```eiffel
is_number: BOOLEAN = True
        -- <Precursor>
```

### Across Loop Cursor Access

**Direct access to cursor features (no .item needed):**

```eiffel
-- Element type with features
class STREAM_ELEMENT
feature
    value: JSON_VALUE
    index: INTEGER
end

-- In across loop - CORRECT
across stream as ic loop
    process (ic.value)     -- Direct access to element's value
    print (ic.index)       -- Direct access to element's index
end

-- In across loop - WRONG
across stream as ic loop
    process (ic.item.value)  -- Extra .item not needed
    print (ic.item.index)    -- Extra .item not needed
end
```

**For simple types, use .item:**

```eiffel
-- Collection of INTEGER
across numbers as ic loop
    print (ic.item)  -- Correct - ic.item is the INTEGER value
end
```

**The Rule:**
- Complex types with features: `ic.feature_name`
- Simple types (INTEGER, STRING): `ic.item`

---

## Quick Reference Tables

### Feature Categories

| Category | Purpose | Typical Features |
|----------|---------|-----------------|
| Initialization | Create/initialize | make, make_with_X |
| Access | Return values | count, item, name |
| Measurement | Size queries | count, is_empty |
| Status report | Boolean state | is_valid, has_error |
| Status setting | Change state | enable_X, disable_Y |
| Element change | Modify content | put, extend, replace |
| Removal | Delete items | remove, wipe_out |
| Conversion | Type conversion | as_string, to_integer |

### Naming Quick Reference

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | UPPERCASE | JSON_PARSER |
| Files | lowercase | json_parser.e |
| Tests | TEST_ prefix | TEST_JSON_PARSER |
| Locals | l_ prefix | l_result |
| Attached locals | al_ prefix | al_value |
| Cursors | ic suffix | ic |
| Cells | cl_ prefix | cl_index |
| Queries | Noun | count, name |
| Boolean queries | is_/has_ | is_valid |
| Commands | Verb | put, remove |

### Type Patterns

| Pattern | Syntax | Usage |
|---------|--------|-------|
| Attached | name: TYPE | Cannot be Void |
| Detachable | name: detachable TYPE | Can be Void |
| Like anchor | name: like other | Type from other |
| Generic | CLASS [TYPE] | Parameterized |
| Constrained | [T -> PARENT] | Bounded generic |

---

## Production Code Checklist

Before committing code:

### Structure
- [ ] Note clauses at beginning and end
- [ ] Features in standard category order
- [ ] Multiple named creation procedures
- [ ] Export control on inheritance

### Naming
- [ ] l_ prefix for locals
- [ ] al_ prefix for attachment locals
- [ ] is_/has_ prefix for boolean queries
- [ ] Lowercase files, UPPERCASE classes
- [ ] TEST_ prefix for test classes

### Contracts
- [ ] All assertions named
- [ ] Preconditions state requirements
- [ ] Postconditions state guarantees
- [ ] Invariants named

### Patterns
- [ ] SHARED for singletons
- [ ] CELL for mutable references
- [ ] If attached for detachable
- [ ] Once for constants/singletons
- [ ] Across loops preferred

### Testing
- [ ] Inherit EQA_TEST_SET
- [ ] test_ prefix on methods
- [ ] testing note tags
- [ ] Round-trip tests for reversible ops

---

---

## Recursive Patterns

### When Recursion is Required

**Rule:** Recursive data structures require recursive operations.

```eiffel
-- Processing JSON (recursive structure)
process_json (value: JSON_VALUE)
	do
		if value.is_object then
			across value.as_object.keys as ic loop
				-- MUST recurse for nested objects
				process_json (value.as_object.item (ic))
			end
		elseif value.is_array then
			across value.as_array as ic loop
				-- MUST recurse for nested arrays
				process_json (ic.item)
			end
		else
			-- Base case: primitive value
			process_primitive (value)
		end
	end
```

### Recursion Indicators

**You need recursion when:**
- Data structure is tree/graph (JSON, XML, file systems)
- Type checks reveal nested types (`is_object`, `is_array`)
- Operation must traverse entire structure
- Spec describes "recursive" behavior

### Common Recursive Patterns

**Tree Traversal:**
```eiffel
traverse (node: TREE_NODE)
	do
		process (node)
		across node.children as ic loop
			traverse (ic.item)  -- Recursive call
		end
	end
```

**Deep Copy:**
```eiffel
deep_copy (source: COMPOSITE): COMPOSITE
	local
		l_result: COMPOSITE
	do
		create l_result.make
		across source.children as ic loop
			l_result.add (deep_copy (ic.item))  -- Recursive copy
		end
		Result := l_result
	end
```

**Structural Comparison:**
```eiffel
structures_equal (a, b: STRUCTURE): BOOLEAN
	do
		Result := a.type ~ b.type
		if Result and a.has_children then
			-- Recursive comparison needed
			Result := children_equal (a.children, b.children)
		end
	end
```

### Avoiding Infinite Recursion

**Always have base cases:**
```eiffel
-- ✅ CORRECT - Clear base case
process (value: JSON_VALUE)
	do
		if value.is_primitive then
			-- BASE CASE - stops recursion
			handle_primitive (value)
		else
			-- RECURSIVE CASE
			recurse_into_structure (value)
		end
	end

-- ❌ WRONG - No base case
process (value: JSON_VALUE)
	do
		-- Will recurse forever!
		process (value.first_child)
	end
```

### Contract Considerations

**Recursive features need careful contracts:**

```eiffel
count_nodes (tree: TREE): INTEGER
		-- Count all nodes in tree recursively
	require
		tree_attached: tree /= Void
	do
		Result := 1  -- Count this node
		
		across tree.children as ic loop
			Result := Result + count_nodes (ic.item)  -- Recursive
		end
	ensure
		positive: Result > 0
		-- Can't easily express recursive postconditions
	end
```

**Notes on recursive contracts:**
- Preconditions must be satisfied at each level
- Postconditions verify final result, not intermediate steps
- Invariants hold at each recursion level
- Be careful with `old` expressions (expensive in recursion)

---

## Summary

Production Eiffel code is characterized by:

1. **Rigorous organization** - Standard structure everywhere
2. **Clear contracts** - All obligations explicit
3. **Type safety** - Proper void-safety handling
4. **Consistent naming** - Conventions followed religiously
5. **Proven patterns** - SHARED, CELL, once-per-object, recursion
6. **Complete documentation** - Note clauses, EIS links
7. **Comprehensive testing** - EQA framework, round-trips

Follow these patterns and your code will be maintainable, reliable, and professional.

note
    copyright: "2024, Larry Rix"
    license: "MIT License"
    source: "[
        Consolidated from production Eiffel library analysis
        Updated with recursive patterns
    ]"
    last_updated: "November 15, 2025"
end
