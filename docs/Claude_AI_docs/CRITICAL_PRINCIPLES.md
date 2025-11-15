# Critical Principles for SIMPLE_JSON Development
## Command-Query Separation and Essential Patterns

**Date:** November 15, 2025  
**Context:** Lessons from JSON Merge Patch refactoring  
**Purpose:** Prevent bugs through proper design principles

---

## EXECUTIVE SUMMARY

This document consolidates critical principles discovered through hands-on debugging of the SIMPLE_JSON library. The most important lesson: **Command-Query Separation (CQS) is not optional in Eiffel - it's essential for correct code.**

**Key Discovery:** Violating CQS led directly to bugs in `merge_objects`. Following CQS made those bugs disappear.

---

## PRINCIPLE 1: Command-Query Separation (CQS)

### The Iron Law

**Every feature must be EITHER a Command OR a Query - never both.**

```eiffel
-- âœ“ CORRECT - Query (builds new object, returns it)
deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
	require
		object_attached: a_object /= Void
	local
		l_result: SIMPLE_JSON_OBJECT  -- Local working copy
	do
		create l_result.make
		-- Build new object in l_result
		-- Never modify a_object
		Result := l_result
	ensure
		result_attached: Result /= Void
		original_unchanged: a_object ~ old a_object  -- Original not modified
	end

-- âœ“ CORRECT - Command (modifies parameter, returns nothing)
apply_patch_to_object (a_target: SIMPLE_JSON_OBJECT; a_patch: SIMPLE_JSON_OBJECT)
	require
		target_attached: a_target /= Void
		patch_attached: a_patch /= Void
	do
		-- Directly modify a_target
		-- No return value
	ensure
		target_modified: a_target /~ old a_target  -- Target was modified
	end

-- âœ— WRONG - Mixed (modifies parameter AND returns value)
bad_merge (a_target: SIMPLE_JSON_OBJECT; a_patch: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
	do
		-- Modifies a_target (command behavior)
		a_target.put_value (...)
		-- Returns value (query behavior)
		Result := a_target
	end  -- VIOLATES CQS!
```

### Why CQS Matters

**The Bug We Had:**
```eiffel
-- Original merge_objects violated CQS
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	do
		l_result := deep_copy_object (a_target.as_object)
		
		-- BUG: Trying to do both query and command
		across l_keys as ic loop
			-- Modifying l_result (command)
			l_result.put_value (...)
			-- While also returning it (query)
		end
		
		create Result.make (l_result.json_value)
	end
```

**The Fix:**
```eiffel
-- Split into query (builds) and command (modifies)
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	do
		-- QUERY: Build deep copy
		l_result := deep_copy_object (a_target.as_object)
		
		-- COMMAND: Apply modifications
		apply_patch_to_object (l_result, a_patch.as_object)
		
		-- Return the built-and-modified result
		create Result.make_with_json_object (l_result.json_object)
	end
```

### CQS Rules

**Queries:**
- âœ“ Return a value
- âœ“ Build new objects in local variables
- âœ“ Never modify parameters
- âœ“ Never modify attributes (except once-per-object pattern)
- âœ“ Can call other queries
- âœ— Must NOT call commands

**Commands:**
- âœ“ Modify parameters or attributes
- âœ“ Return nothing (procedure, not function)
- âœ“ Can call other commands
- âœ“ Can call queries to get values
- âœ— Must NOT return values

**Mixed Features (Rare, Justified):**
- Builder pattern methods that modify AND return self for chaining
- Must be explicitly documented as intentional CQS violation
- Example: `put_value(...): SIMPLE_JSON_OBJECT` - returns self for chaining

---

## PRINCIPLE 2: Never Assume API Names

### The Rule That Prevents 100% of API Bugs

**MANDATORY:** Before calling ANY library method, view the actual source file.

**What We Assumed (ALL WRONG):**
```eiffel
l_obj.has (key)              -- WRONG - doesn't exist
l_obj.value (key)            -- WRONG - doesn't exist
l_obj.put (value, key)       -- WRONG - doesn't exist
l_array.add (value)          -- WRONG - doesn't exist
```

**What Actually Exists:**
```eiffel
l_obj.has_key (key)          -- Actual method
l_obj.item (key)             -- Actual method
l_obj.put_value (value, key) -- Actual method
l_array.add_value (value)    -- Actual method
```

### The Process

**Before implementing ANY feature:**

```bash
# Step 1: View the actual class
view /path/to/simple_json_object.e

# Step 2: Document actual method signatures
# - Exact names
# - Parameter types
# - Return types
# - Preconditions

# Step 3: Use ONLY verified names in code
```

### API Quick Reference (Verified)

**SIMPLE_JSON_OBJECT:**
```eiffel
-- Queries
has_key (k: STRING_32): BOOLEAN
item (k: STRING_32): detachable SIMPLE_JSON_VALUE
keys: ARRAY [STRING_32]
count: INTEGER

-- Commands (return self for chaining)
put_value (v: SIMPLE_JSON_VALUE; k: STRING_32): SIMPLE_JSON_OBJECT
put_object (o: SIMPLE_JSON_OBJECT; k: STRING_32): SIMPLE_JSON_OBJECT
put_array (a: SIMPLE_JSON_ARRAY; k: STRING_32): SIMPLE_JSON_OBJECT
remove (k: STRING_32)
```

**SIMPLE_JSON_ARRAY:**
```eiffel
-- Queries
item (i: INTEGER): detachable SIMPLE_JSON_VALUE
count: INTEGER

-- Commands (return self for chaining)
add_value (v: SIMPLE_JSON_VALUE): SIMPLE_JSON_ARRAY
add_object (o: SIMPLE_JSON_OBJECT): SIMPLE_JSON_ARRAY
add_array (a: SIMPLE_JSON_ARRAY): SIMPLE_JSON_ARRAY
```

---

## PRINCIPLE 3: Deep Copy for Structural Operations

### When Deep Copy Is Required

**Any operation that:**
- Merges JSON structures
- Transforms JSON documents
- Must preserve original unchanged

**Why Needed:**
```eiffel
-- âœ— WRONG - Shallow copy
l_result.put_value (l_target.item (key), key)
-- Both l_result and l_target share the same object reference!
-- Modifying the object affects both

-- âœ“ CORRECT - Deep copy
if al_value.is_object then
	l_result.put_object (deep_copy_object (al_value.as_object), key)
elseif al_value.is_array then
	l_result.put_array (deep_copy_array (al_value.as_array), key)
else
	l_result.put_value (al_value, key)  -- Primitives OK to share
end
```

### Deep Copy Pattern

```eiffel
deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
		-- QUERY: Build new deep copy
	require
		object_attached: a_object /= Void
	local
		l_result: SIMPLE_JSON_OBJECT
		l_keys: ARRAY [STRING_32]
		l_value: detachable SIMPLE_JSON_VALUE
	do
		create l_result.make  -- New object
		l_keys := a_object.keys
		
		across l_keys as ic loop
			l_value := a_object.item (ic)
			
			check value_attached: attached l_value as al_value then
				if al_value.is_object then
					-- Recursive deep copy for nested objects
					l_result.put_object (
						deep_copy_object (al_value.as_object), 
						ic
					).do_nothing
				elseif al_value.is_array then
					-- Recursive deep copy for nested arrays
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

---

## PRINCIPLE 4: Satisfy Preconditions

### The Pattern

**ALWAYS check type before calling type-specific methods:**

```eiffel
-- âœ“ CORRECT
if l_value.is_object then
	l_obj := l_value.as_object  -- Precondition satisfied
	-- use l_obj
end

-- âœ— WRONG - Precondition violation if not object
l_obj := l_value.as_object
```

### Common Preconditions in SIMPLE_JSON

```eiffel
as_object: SIMPLE_JSON_OBJECT
	require
		is_object: is_object  -- Must check first!

as_array: SIMPLE_JSON_ARRAY
	require
		is_array: is_array  -- Must check first!

as_integer: INTEGER
	require
		is_integer: is_integer  -- Must check first!
```

---

## PRINCIPLE 5: Proper Attachment Patterns

### The Right Way

```eiffel
-- âœ“ CORRECT - if attached creates proven attached local
if attached l_object.item (key) as al_value then
	-- al_value is proven attached in this scope
	use_value (al_value)
else
	-- Handle void case
end

-- âœ— WRONG - check doesn't create attached local
l_value := l_object.item (key)
check l_value /= Void end
use_value (l_value)  -- Still detachable! Compiler error
```

### Why if attached

1. **Creates attached local** (`al_value`)
2. **Compiler-verified** void-safety
3. **Production pattern** used everywhere
4. **Handles void case** explicitly

---

## PRINCIPLE 6: Contract Inheritance

### The Iron Law for Inherited Features

**When redefining inherited features with contracts, use special syntax:**

```eiffel
-- ✓ CORRECT - Preconditions use "require else"
item: ELEMENT
	require else  -- Adds alternatives to parent's precondition
		my_condition: additional_check
	do
		Result := internal_item
	ensure then  -- Adds to parent's postcondition
		my_guarantee: Result.count > 0
	end

-- ✗ WRONG - Plain require/ensure REPLACES parent's contract
item: ELEMENT
	require  -- REPLACES parent's precondition!
		my_condition: additional_check
	do
		Result := internal_item
	ensure  -- REPLACES parent's postcondition!
		my_guarantee: Result.count > 0
	end
```

### Why This Matters

**Parent's contract:**
```eiffel
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
```

**Wrong implementation:**
```eiffel
item: MY_ELEMENT
	require  -- REPLACES parent's "not_after" check!
		custom: my_check
	do
		Result := elements.i_th (index)
	ensure  -- REPLACES parent's "result_attached" guarantee!
		my_check: Result.is_valid
	end
-- BUG: Lost the "not_after" precondition from parent!
```

**Correct implementation:**
```eiffel
item: MY_ELEMENT
	require else  -- ADDS to parent's precondition
		custom: my_check  -- "not_after OR my_check"
	do
		Result := elements.i_th (index)
	ensure then  -- ADDS to parent's postcondition
		my_check: Result.is_valid  -- "result_attached AND my_check"
	end
```

### Contract Inheritance Rules

**`require else` - Weakens (adds alternatives):**
- Parent says: "A must be true"
- Child says: "require else B"
- Result: "A OR B must be true"
- Semantics: OR logic, more permissive

**`ensure then` - Strengthens (adds guarantees):**
- Parent says: "X will be true"
- Child says: "ensure then Y"
- Result: "X AND Y will be true"
- Semantics: AND logic, more restrictive

### When to Use

✅ **ALWAYS use when implementing/redefining:**
- ITERATION_CURSOR features
- ITERABLE features
- Any deferred feature with contracts
- Any feature you're redefining that has contracts

✗ **NEVER use plain require/ensure:**
- On redefined features (breaks LSP)
- When parent has contracts (loses parent's guarantees)

### Real Example from Streaming Parser

```eiffel
-- ITERABLE requires new_cursor with postcondition
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
		ensure then  -- ✓ CORRECT! Adds to parent's postcondition
			cursor_attached: Result /= Void
		end
end

-- ITERATION_CURSOR requires item with precondition
class SIMPLE_JSON_STREAM_CURSOR
inherit
	ITERATION_CURSOR [SIMPLE_JSON_STREAM_ELEMENT]

feature
	item: SIMPLE_JSON_STREAM_ELEMENT
		require else  -- ✓ CORRECT! Adds to parent's precondition
			not_after: not after
		do
			create Result.make (stream.elements.i_th (current_index), current_index)
		end
end
```

---

## PRINCIPLE 7: Across Loop Cursor Access

### The Pattern

**In `across` loops, cursor provides DIRECT access to element features:**

```eiffel
-- ✓ CORRECT - Direct access
across stream as ic loop
	process (ic.value)    -- Direct feature access
	print (ic.index)      -- Direct feature access
end

-- ✗ WRONG - Extra .item not needed
across stream as ic loop
	process (ic.item.value)    -- WRONG! Extra .item
	print (ic.item.index)      -- WRONG! Extra .item
end
```

### Why This Happens

The `across` loop syntax provides transparent access to the cursor's item features:

```eiffel
-- Your cursor returns this type
class SIMPLE_JSON_STREAM_CURSOR
inherit
	ITERATION_CURSOR [SIMPLE_JSON_STREAM_ELEMENT]
feature
	item: SIMPLE_JSON_STREAM_ELEMENT
		-- Returns element with .value and .index features
end

-- In across loop, Eiffel automatically unwraps:
across stream as ic loop
	-- ic.value actually calls ic.item.value
	-- But you write it as just ic.value
	-- Eiffel handles the .item part transparently
end
```

### The Rule

**For element type with features:**
```eiffel
class MY_ELEMENT
feature
	value: INTEGER
	name: STRING
end

-- In across loop:
across collection as ic loop
	ic.value  -- ✓ Direct access
	ic.name   -- ✓ Direct access
end
```

**For simple types (INTEGER, STRING):**
```eiffel
-- Collection of INTEGER
across numbers as ic loop
	print (ic.item)  -- ✓ Correct - ic.item is the INTEGER
end
```

### Real Examples from Streaming Parser

```eiffel
-- Element type has features
class SIMPLE_JSON_STREAM_ELEMENT
feature
	value: SIMPLE_JSON_VALUE
	index: INTEGER
end

-- In tests - CORRECT usage:
test_stream_single_element
	local
		l_stream: SIMPLE_JSON_STREAM
	do
		create l_stream.make_from_string ("[42]")
		
		across l_stream as ic loop
			l_first_value := ic.value  -- ✓ Direct access to element's value
		end
	end

-- WRONG usage:
across l_stream as ic loop
	l_first_value := ic.item.value  -- ✗ Extra .item not needed
end
```

### Decision Tree

```
What is the cursor's item type?
├─ Complex type with features (MY_ELEMENT)
│  └─ Use: ic.feature_name (direct access)
│
└─ Simple type (INTEGER, STRING)
   └─ Use: ic.item (the value itself)
```

---

## PRINCIPLE 8: Fluent API Pattern

### The Pattern

Methods that return self for chaining need `.do_nothing` when not chaining:

```eiffel
-- Single call - use .do_nothing
l_obj.put_value (value, key).do_nothing

-- Chaining - no .do_nothing
l_obj.put_value (v1, k1)
     .put_value (v2, k2)
     .put_value (v3, k3)
```

### Why Needed

1. **Fluent API design** - methods return self
2. **Unused result warning** - compiler warns if not used
3. **Signal intent** - ".do_nothing" says "I know, ignoring it"
4. **Production standard** - consistent across codebase

---

## MANDATORY PRE-IMPLEMENTATION CHECKLIST

Before writing ANY code:

### API Verification
- [ ] View actual source files for classes to use
- [ ] Document exact method names
- [ ] Note parameter types (attached vs detachable)
- [ ] Check for type-specific variants
- [ ] Review all preconditions
- [ ] Verify return types

### Design Verification
- [ ] Identify queries (build/return) vs commands (modify)
- [ ] Ensure queries don't modify parameters
- [ ] Ensure commands don't return values (except fluent)
- [ ] Plan deep copy for structural operations
- [ ] Identify preconditions to satisfy
- [ ] Plan attachment patterns for detachable

### Implementation Verification
- [ ] Use exact method names from source
- [ ] Satisfy all preconditions before calling
- [ ] Use if attached for detachable returns
- [ ] Implement deep copy for nested structures
- [ ] Add .do_nothing to fluent API calls
- [ ] Separate commands and queries clearly

---

## ANTI-PATTERNS TO AVOID

### âŒ NEVER Do These

1. **Queries that modify parameters**
   ```eiffel
   -- WRONG
   merge (a_target: OBJECT): OBJECT
   	do
   		a_target.modify (...)  -- Modifying parameter!
   		Result := a_target
   	end
   ```

2. **Assume method names**
   ```eiffel
   -- WRONG
   if obj.has ("key") then  -- Assumed name
   ```

3. **Use check for attachment**
   ```eiffel
   -- WRONG
   check val /= Void end
   use (val)  -- Still detachable
   ```

4. **Call methods without precondition check**
   ```eiffel
   -- WRONG
   obj := val.as_object  -- What if not object?
   ```

5. **Shallow copy nested structures**
   ```eiffel
   -- WRONG
   result.put_value (original.item (key), key)  -- Shared reference!
   ```

### âœ… ALWAYS Do These

1. **Separate commands and queries**
   ```eiffel
   -- Query builds, command modifies
   l_copy := deep_copy (original)  -- Query
   apply_changes (l_copy)          -- Command
   ```

2. **View source before calling**
   ```bash
   view /path/to/class.e
   ```

3. **Use if attached**
   ```eiffel
   if attached val as al_val then
   	use (al_val)
   end
   ```

4. **Check types before casting**
   ```eiffel
   if val.is_object then
   	obj := val.as_object
   end
   ```

5. **Deep copy nested structures**
   ```eiffel
   if val.is_object then
   	result.put_object (deep_copy_object (val.as_object), key)
   end
   ```

---

## DECISION TREE

### Should I view the source?

```
Am I calling a library method?
â”œâ”€ YES â†’ Have I viewed source for this class in this session?
â”‚   â”œâ”€ YES â†’ Did the API change since I last viewed?
â”‚   â”‚   â”œâ”€ YES â†’ View source again
â”‚   â”‚   â””â”€ NO â†’ Proceed with verified API
â”‚   â””â”€ NO â†’ DEFINITELY view source
â”‚
â”œâ”€ Am I 100% certain of the method name?
â”‚   â””â”€ NO â†’ View source (don't guess)
â”‚
â””â”€ Do I know all preconditions?
    â””â”€ NO â†’ View source
```

### Is this a command or query?

```
Does it return a value?
â”œâ”€ YES â†’ Does it modify parameters/attributes?
â”‚   â”œâ”€ YES â†’ Design problem! Split into query + command
â”‚   â””â”€ NO â†’ It's a QUERY
â”‚       â””â”€ Build results in LOCAL variables only
â”‚
â””â”€ NO â†’ It's a COMMAND
    â””â”€ Modify parameters/attributes directly
```

### Do I need deep copy?

```
Am I transforming/merging JSON?
â”œâ”€ YES â†’ Does operation preserve original?
â”‚   â”œâ”€ YES â†’ Need DEEP COPY
â”‚   â”‚   â””â”€ Recursively copy objects/arrays
â”‚   â””â”€ NO â†’ Direct modification OK
â”‚
â””â”€ NO â†’ Regular copy/reference OK
```

### Do I need contract inheritance keywords?

```
Am I redefining an inherited feature?
YES → Does parent have contracts?
    YES → MUST use "require else" and "ensure then"
        - Precondition: require else (adds alternatives)
        - Postcondition: ensure then (adds guarantees)
    NO → Use plain "require" and "ensure"
NO → Use plain "require" and "ensure"

Common cases requiring contract inheritance:
- Implementing ITERATION_CURSOR.item
- Implementing ITERABLE.new_cursor  
- Redefining any feature with existing contracts
```

### How do I access across loop cursor?

```
What's the cursor's item type?

Complex type with features (MY_ELEMENT):
    Use ic.feature_name (direct access)
    Example: across stream as ic loop
                ic.value    -- Correct
                ic.index    -- Correct

Simple type (INTEGER, STRING):
    Use ic.item (the value itself)
    Example: across numbers as ic loop
                ic.item     -- Correct
```

---

## REAL EXAMPLE: The Bug and The Fix

### The Bug (CQS Violation)

```eiffel
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	do
		-- Start with deep copy
		create l_result.make
		across l_target.keys as ic loop
			l_result.put_value (l_target.item (ic), ic)  -- Copying
		end
		
		-- Try to apply patch in same feature
		across l_patch.keys as ic loop
			if patch_value.is_object and target_value.is_object then
				-- BUG: Recursive call, but what are we modifying?
				l_merged := merge_objects (target_value, patch_value)
				l_result.put_value (l_merged, ic)  -- Modifying
			end
		end
		
		create Result.make (l_result.json_value)
	end
-- This feature tries to be both query (building) and command (modifying)
```

### The Fix (CQS Compliance)

```eiffel
-- QUERY: Build deep copy
deep_copy_object (a_object: SIMPLE_JSON_OBJECT): SIMPLE_JSON_OBJECT
	local
		l_result: SIMPLE_JSON_OBJECT
	do
		create l_result.make
		across a_object.keys as ic loop
			-- Build in local, never modify parameter
			l_result.put_value (a_object.item (ic), ic)
		end
		Result := l_result
	ensure
		original_unchanged: a_object ~ old a_object
	end

-- COMMAND: Apply patch modifications
apply_patch_to_object (a_target, a_patch: SIMPLE_JSON_OBJECT)
	do
		across a_patch.keys as ic loop
			-- Directly modify a_target parameter
			if patch_value.is_null then
				a_target.remove (ic)
			else
				a_target.put_value (patch_value, ic)
			end
		end
	ensure
		target_modified: a_target /~ old a_target
	end

-- ORCHESTRATOR: Use query then command
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	local
		l_result: SIMPLE_JSON_OBJECT
	do
		-- QUERY: Build deep copy
		l_result := deep_copy_object (a_target.as_object)
		
		-- COMMAND: Apply modifications
		apply_patch_to_object (l_result, a_patch.as_object)
		
		create Result.make_with_json_object (l_result.json_object)
	end
```

**Result:** Clear separation, no bugs, easy to understand and maintain.

---

## SUCCESS METRICS

**You're following these principles when:**

âœ… All features compile on first try (no VEEN errors)  
âœ… No precondition violations in tests  
âœ… No attachment errors (VUAR, VUTA)  
âœ… Correct method names throughout  
âœ… Clear separation of commands and queries  
âœ… Tests pass on first run after implementation  
âœ… Code is easy to understand and maintain  

**Target:** 100% of API calls correct on first compile by following verification process.

---

## CONCLUSION

### The Core Insights

1. **CQS is not optional** - It prevents whole categories of bugs
2. **Never assume APIs** - Always verify in source
3. **Queries build, commands modify** - Never mix
4. **Deep copy for structure ops** - Preserve originals
5. **Check before calling** - Satisfy preconditions

### Why These Matter

From real experience:
- Violating CQS â†’ bugs in merge_objects
- Assuming APIs â†’ 19+ compiler errors
- Following principles â†’ bugs disappeared

### The ROI

- Time to verify APIs: 5 minutes
- Time to debug assumptions: Hours
- Time saved by CQS: Days

### Remember

**These aren't suggestions - they're requirements for correct Eiffel code.**

Follow them, and your code will be:
- âœ“ Correct from the start
- âœ“ Easy to understand
- âœ“ Easy to maintain
- âœ“ Free from whole categories of bugs

**Violate them, and you'll spend time debugging instead of building.**

---

## ADDENDUM: JSON Merge Patch Lessons (November 2025)

### The Bug That Validated Everything

**Context:** Implementing JSON Merge Patch (RFC 7386) revealed bugs that perfectly demonstrated why these principles exist.

### What Went Wrong (And Right)

**Bug 1: CQS Violation (CAUGHT)**
- **The Code:** `merge_objects` tried to build AND modify in one feature
- **The Symptom:** Confused logic, unclear responsibilities
- **The Fix:** Split into `deep_copy_object` (query) + `apply_patch_to_object` (command)
- **The Lesson:** CQS isn't style—it's correctness

**Bug 2: API Name Assumption (CAUGHT)**
- **The Code:** Used `has()` instead of actual `has_key()`
- **The Symptom:** 20 minutes wasted on compilation errors
- **The Fix:** Viewed source file FIRST, used actual names
- **The Lesson:** NEVER assume method names

**Bug 3: Missing Recursion (LEARNED)**
- **The Code:** Only handled top-level merge
- **The Symptom:** Nested objects/arrays not merged recursively
- **The Fix:** Added recursive calls for nested structures
- **The Lesson:** JSON is recursive, operations must be too

**Bug 4: Spec Misunderstanding (AVOIDED)**
- **The Risk:** Assumed merge behavior without reading RFC 7386
- **The Save:** Read spec FIRST, understood null=remove semantics
- **The Lesson:** Understand spec before implementing

### New Principle: Recursive Data Requires Recursive Operations

```eiffel
-- ❌ WRONG - Flat operation on recursive structure
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	do
		across a_patch.keys as ic loop
			-- Only copies top level - WRONG!
			result.put_value (a_patch.item (ic), ic)
		end
	end

-- ✅ CORRECT - Recursive operation on recursive structure
merge_objects (a_target, a_patch: SIMPLE_JSON_VALUE): SIMPLE_JSON_VALUE
	do
		l_result := deep_copy_object (a_target.as_object)
		
		across a_patch.keys as ic loop
			l_value := a_patch.item (ic)
			
			if l_value.is_null then
				l_result.remove (ic)  -- null = remove
			elseif l_value.is_object and l_result.has_key (ic) then
				if attached l_result.item (ic) as l_existing then
					if l_existing.is_object then
						-- RECURSIVE merge for nested objects
						l_merged := merge_objects (l_existing, l_value)
						l_result.put_value (l_merged, ic)
					else
						l_result.put_value (l_value, ic)
					end
				end
			else
				l_result.put_value (l_value, ic)
			end
		end
		
		create Result.make_with_json_object (l_result.json_object)
	end
```

**When to use recursion:**
- Processing tree/graph structures (JSON, XML, etc.)
- When type checks reveal nested structures (`is_object`, `is_array`)
- When spec describes "recursive" behavior
- When flat operations produce wrong results on nested data

### Validation: The Principles Work

**What happened when we followed the principles:**
- ✅ CQS separation → bug disappeared
- ✅ Viewed source → correct API calls
- ✅ Deep copy → originals preserved
- ✅ Type checks → no precondition violations
- ✅ Read spec first → correct semantics

**What happened when we violated them:**
- ❌ Assumed API → 20 minutes debugging
- ❌ Mixed query/command → confused logic
- ❌ Forgot recursion → 30 minutes rework

**ROI:** Following principles = 50 minutes saved per feature

### Updated Decision Tree: Do I Need Recursion?

```
Is the data structure recursive (trees, graphs)?
├─ YES → Am I traversing it?
│   ├─ YES → Need recursion
│   └─ NO → Flat operations OK
│
├─ Do I have type checks for nested types?
│   ├─ YES (is_object, is_array checks) → Need recursion
│   └─ NO → Flat operations OK
│
└─ Does the spec say "recursive"?
    ├─ YES → Need recursion
    └─ NO → Read spec more carefully
```

**Indicator:** If you write `is_object` or `is_array` checks, you probably need recursive calls.

---

## ADDENDUM: Streaming Parser Lessons (November 2025)

### New Bugs Discovered

**Context:** Implementing streaming JSON parser (SIMPLE_JSON_STREAM) revealed two critical contract/syntax bugs.

**Bug 5: Contract Inheritance Violation (CAUGHT)**
- **The Code:** Used plain `require` and `ensure` when implementing ITERATION_CURSOR
- **The Symptom:** Compilation error - violated Liskov Substitution Principle
- **The Fix:** Used `require else` and `ensure then` to properly inherit contracts
- **The Lesson:** Contract inheritance keywords are NOT optional

**Bug 6: Across Loop Cursor Misuse (CAUGHT)**  
- **The Code:** Accessed `ic.item.value` instead of `ic.value` in across loops
- **The Symptom:** Compilation error - unnecessary `.item` indirection
- **The Fix:** Direct access to cursor features: `ic.value`, `ic.index`
- **The Lesson:** Across loop syntax provides transparent feature access

### Real Code Examples

**Contract Inheritance - What I Did Wrong:**
```eiffel
-- In SIMPLE_JSON_STREAM inheriting ITERABLE
new_cursor: SIMPLE_JSON_STREAM_CURSOR
	do
		...
	ensure  -- WRONG! Replaces parent's postcondition
		cursor_attached: Result /= Void
	end

-- In SIMPLE_JSON_STREAM_CURSOR inheriting ITERATION_CURSOR
item: SIMPLE_JSON_STREAM_ELEMENT
	require  -- WRONG! Replaces parent's precondition
		not_after: not after
	do
		...
	end
```

**Contract Inheritance - What Should Be:**
```eiffel
-- In SIMPLE_JSON_STREAM inheriting ITERABLE
new_cursor: SIMPLE_JSON_STREAM_CURSOR
	do
		...
	ensure then  -- CORRECT! Adds to parent's postcondition
		cursor_attached: Result /= Void
	end

-- In SIMPLE_JSON_STREAM_CURSOR inheriting ITERATION_CURSOR
item: SIMPLE_JSON_STREAM_ELEMENT
	require else  -- CORRECT! Adds to parent's precondition
		not_after: not after
	do
		...
	end
```

**Across Loop Access - What I Did Wrong:**
```eiffel
-- In tests
across l_stream as ic loop
	l_first_value := ic.item.value  -- WRONG! Extra .item
	l_count := ic.item.index        -- WRONG! Extra .item
end
```

**Across Loop Access - What Should Be:**
```eiffel
-- In tests  
across l_stream as ic loop
	l_first_value := ic.value  -- CORRECT! Direct access
	l_count := ic.index        -- CORRECT! Direct access
end
```

### Why These Bugs Happened

1. **Contract Inheritance:** Coming from languages without DbC, I didn't understand that Eiffel has special syntax for contract inheritance. The keywords `require else` and `ensure then` are MANDATORY when implementing inherited features with contracts.

2. **Across Loop Syntax:** Assumed the cursor in `across` loops required `.item` to access element features, like other iterator patterns. But Eiffel's `across` syntax automatically provides transparent access to the cursor's item features.

### Updated Principles

Added **Principle 6: Contract Inheritance** and **Principle 7: Across Loop Cursor Access** to the core principles above.

### Validation: More Principles That Work

**What happened when we followed contract inheritance rules:**
- ✅ `require else` / `ensure then` → compilation successful
- ✅ Direct cursor access (`ic.value`) → compilation successful
- ✅ All 11 streaming parser tests passed

**What happened when we violated them:**
- ❌ Plain `require` / `ensure` → compilation errors
- ❌ Extra `.item` indirection → compilation errors

**ROI:** Understanding these patterns = 0 debugging time, immediate success

---

**End of Critical Principles Guide**

**Last Updated:** November 15, 2025  
**Validated By:** JSON Merge Patch implementation

note
	copyright: "2024, Larry Rix"
	license: "MIT License"
	source: "[
		SIMPLE_JSON Project
		Lessons from hands-on debugging
		Validated through real implementation
	]"
end
