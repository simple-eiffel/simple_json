# simple_json Reconciled Specifications

## R01: Research Integration

This document reconciles extracted specifications (S01-S08) with deep research (7S) findings.

---

## R02: Validated Specifications

### RFC 8259 Compliance (JSON Format)

| Specification | Extracted | Research | Status |
|---------------|-----------|----------|--------|
| UTF-8 encoding | UTF_CONVERTER | MUST use UTF-8 | ✅ VALIDATED |
| Value types | 6 types | 7 (with integer) | ✅ VALIDATED |
| Structural chars | Via ISE | 6 defined | ✅ VALIDATED |
| String escapes | Via ISE | 8 sequences | ✅ VALIDATED |
| Number format | SIMPLE_DECIMAL | IEEE 754 | ✅ VALIDATED |
| Duplicate keys | Last wins | Undefined | ✅ VALIDATED |

### RFC 6901 Compliance (JSON Pointer)

| Specification | Extracted | Research | Status |
|---------------|-----------|----------|--------|
| Path format | `/path/to/elem` | `/path/to/elem` | ✅ VALIDATED |
| Escape ~0 | `~0` → `~` | `~0` → `~` | ✅ VALIDATED |
| Escape ~1 | `~1` → `/` | `~1` → `/` | ✅ VALIDATED |
| Decode order | ~1 first | ~1 first | ✅ VALIDATED |
| Array index | 0-based | 0-based | ✅ VALIDATED |
| `-` token | Not found | Append to array | ⚠️ GAP |

### RFC 6902 Compliance (JSON Patch)

| Specification | Extracted | Research | Status |
|---------------|-----------|----------|--------|
| Operations | 6 types | 6 types | ✅ VALIDATED |
| add | Implemented | path + value | ✅ VALIDATED |
| remove | Implemented | path only | ✅ VALIDATED |
| replace | Implemented | path + value | ✅ VALIDATED |
| move | Implemented | from + path | ✅ VALIDATED |
| copy | Implemented | from + path | ✅ VALIDATED |
| test | Implemented | path + value | ✅ VALIDATED |
| Atomic | All-or-nothing | Required | ✅ VALIDATED |

### RFC 7386 Compliance (JSON Merge Patch)

| Specification | Extracted | Research | Status |
|---------------|-----------|----------|--------|
| Null = delete | Implemented | Required | ✅ VALIDATED |
| Object merge | Recursive | Required | ✅ VALIDATED |
| Non-object replace | Full replace | Required | ✅ VALIDATED |
| Array nulls | Preserved | Required | ✅ VALIDATED |
| Deep copy | Implemented | Immutable | ✅ VALIDATED |

---

## R03: Gap Specifications

### Gap 1: JSON Pointer `-` Token Not Implemented

**Location**: `simple_json_pointer.e:navigate`

**Current Spec**:
```eiffel
-- Array index access
if is_array_index (ic) then
    l_index := ic.to_integer
    -- Navigate to element at index
```

**Required Spec** (RFC 6901 Section 4):
```
The "-" character references the (nonexistent) member
after the last array element.
```

**Impact**: Cannot use JSON Patch `add` to append to arrays
**Severity**: LOW (workaround: use explicit index)

### Gap 2: JSON Schema Limited Coverage

**Location**: `simple_json_schema_validator.e`

**Current Spec**: Subset of Draft 2020-12
- type, properties, required
- minimum, maximum
- minLength, maxLength, pattern
- minItems, maxItems, items

**Missing Keywords**:
| Category | Keywords |
|----------|----------|
| References | $ref, $defs, $id |
| Composition | allOf, anyOf, oneOf, not |
| Conditionals | if, then, else |
| Dependencies | dependentRequired, dependentSchemas |
| Format | format (semantic validation) |

**Impact**: Complex schemas not validated
**Severity**: MEDIUM (documented limitation)

### Gap 3: No Nesting Depth Limit

**Location**: `simple_json.e:parse`

**Current Spec**: No explicit depth limit

**Required Spec** (RFC 8259 Section 9):
```
An implementation may set limits on the maximum depth of nesting.
```

**Impact**: Stack overflow on deeply nested malicious input
**Severity**: MEDIUM (depends on ISE parser limits)

---

## R04: Finalized Specifications

### Core Specifications (Validated)

1. **SIMPLE_JSON Facade**
   - Provides unified API for JSON operations
   - Full RFC 8259 compliance via ISE JSON library
   - Unicode/UTF-8 handling via UTF_CONVERTER
   - Error tracking with line/column position

2. **Value Types**
   - string: STRING_32 (Unicode)
   - number: DOUBLE or INTEGER_64
   - decimal: SIMPLE_DECIMAL (precise)
   - boolean: BOOLEAN
   - null: JSON_NULL
   - object: SIMPLE_JSON_OBJECT
   - array: SIMPLE_JSON_ARRAY

3. **JSON Pointer** (RFC 6901)
   - Path navigation with escape handling
   - Correct decode order (~1 → ~0)
   - Array indexing (0-based)

4. **JSON Patch** (RFC 6902)
   - All 6 operations implemented
   - Atomic execution guaranteed
   - Sequential application

5. **JSON Merge Patch** (RFC 7386)
   - Null deletion semantics
   - Recursive object merging
   - Immutable operations

### Operational Constraints

```
USAGE CONSTRAINTS:
- JSON Schema: Subset only (see Gap 2)
- Nesting depth: Depends on ISE parser
- String length: 10MB default limit
- Object size: 100K properties limit
```

---

## R05: Contract Refinements

### Proposed Contract Additions

**SIMPLE_JSON_POINTER.navigate** - Add support for `-`:
```eiffel
navigate_for_insert (a_document: SIMPLE_JSON_VALUE): TUPLE [parent: SIMPLE_JSON_VALUE; index: INTEGER]
    -- Navigate for insert operation, supporting "-" for append.
    require
        document_not_void: a_document /= Void
    ensure
        valid_result: Result.parent /= Void
```

**SIMPLE_JSON.parse** - Add depth protection:
```eiffel
parse_with_limits (a_json_text: STRING_32; a_max_depth: INTEGER): detachable SIMPLE_JSON_VALUE
    -- Parse with configurable nesting limit.
    require
        not_empty: not a_json_text.is_empty
        valid_depth: a_max_depth > 0
```

---

## R06: Recommended Improvements (Future)

### Priority 1: Implement `-` Token
- Add detection in `is_array_index`
- Return special value for append
- Update patch operations

### Priority 2: Configurable Limits
- Add `Max_nesting_depth` constant
- Add depth tracking in parser
- Fail fast on exceeded limits

### Priority 3: Expand JSON Schema
- Add `$ref` for reusable definitions
- Add `allOf` for composition
- Maintain subset documentation

---

## R07: Test Coverage Gaps

### Tests to Add

| Gap | Test Needed |
|-----|-------------|
| `-` token | Test append to array via patch |
| Deep nesting | Test 100+ level documents |
| Large documents | Test multi-MB parsing |
| Unicode surrogates | Test paired/unpaired |
| All escape sequences | Test all 8 sequences |
| Numeric edge cases | Test MAX_INTEGER, precision |

### Existing Coverage (Adequate)
- Core parsing: 43 tests ✅
- JSONPath queries: 12 tests ✅
- Type checking: 12 tests ✅
- Schema validation: 30+ tests ✅
- Pretty printing: 10 tests ✅
- Error tracking: 10 tests ✅
- Patch operations: 30+ tests ✅
- Merge patch: 20+ tests ✅
- Decimal support: 6 tests ✅

---

## R08: Final Specification Status

### Production-Ready
- RFC 8259 JSON parsing/generation
- RFC 6901 JSON Pointer (except `-`)
- RFC 6902 JSON Patch (all operations)
- RFC 7386 JSON Merge Patch
- JSON Schema (subset)

### Known Limitations
- JSON Pointer `-` token not implemented
- JSON Schema subset only
- No explicit nesting depth limit

### Interoperability
- Compatible with ISE JSON library
- UTF-8 interchange supported
- SIMPLE_DECIMAL for precise numbers

---

*Reconciliation completed: 2026-01-18*
*Based on: RFC 8259, RFC 6901, RFC 6902, RFC 7386, JSON Schema 2020-12*
