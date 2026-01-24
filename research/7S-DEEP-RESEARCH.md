# simple_json Deep Research


**Date**: 2026-01-18

## 7S: Seven-Step Research Process

---

## Step 1: RFC 8259 - JSON Data Interchange Format

**Source**: [RFC 8259 - IETF](https://datatracker.ietf.org/doc/html/rfc8259)

### Grammar Structure
```abnf
JSON-text = ws value ws
value     = object / array / number / string / false / null / true
ws        = *( %x20 / %x09 / %x0A / %x0D )
```

### Structural Characters
| Character | Symbol | Code Point |
|-----------|--------|------------|
| begin-array | `[` | %x5B |
| end-array | `]` | %x5D |
| begin-object | `{` | %x7B |
| end-object | `}` | %x7D |
| name-separator | `:` | %x3A |
| value-separator | `,` | %x2C |

### Number Format
```abnf
number = [ minus ] int [ frac ] [ exp ]
int    = zero / ( digit1-9 *DIGIT )
frac   = decimal-point 1*DIGIT
exp    = e [ minus / plus ] 1*DIGIT
```

**Critical Rules**:
- Leading zeros NOT allowed (except `0` itself)
- `Infinity` and `NaN` NOT permitted
- IEEE 754 double-precision recommended for interoperability

### String Escape Sequences
| Sequence | Meaning |
|----------|---------|
| `\"` | Quotation mark |
| `\\` | Reverse solidus |
| `\/` | Solidus |
| `\b` | Backspace |
| `\f` | Form feed |
| `\n` | Line feed |
| `\r` | Carriage return |
| `\t` | Tab |
| `\uXXXX` | Unicode code point |

**UTF-16 Surrogates**: Extended characters use 12-character surrogate pairs (e.g., `\uD834\uDD1E` for G clef).

### Edge Cases
1. **Duplicate Keys**: Behavior undefined - some parsers use last value, some error
2. **Unpaired Surrogates**: Valid per grammar but cause runtime exceptions
3. **BOM**: MUST NOT add byte order mark to networked JSON
4. **Encoding**: MUST use UTF-8 for interchange

---

## Step 2: RFC 6901 - JSON Pointer

**Source**: [RFC 6901 - IETF](https://datatracker.ietf.org/doc/html/rfc6901)

### Path Syntax
```abnf
json-pointer    = *( "/" reference-token )
reference-token = *( unescaped / escaped )
escaped         = "~" ( "0" / "1" )
```

### Escape Sequences
| Sequence | Character |
|----------|-----------|
| `~0` | `~` (tilde) |
| `~1` | `/` (slash) |

### Decoding Order (CRITICAL)
1. First: Transform `~1` → `/`
2. Second: Transform `~0` → `~`

**Why Order Matters**: `~01` should become `~1` (not `/`). Wrong order would incorrectly transform `~01` → `~1` → `/`.

### Array Access
- Arrays use 0-based indexing
- `-` token refers to nonexistent element after last (for append operations)

### Implementation Notes
- Empty string `""` is valid (refers to whole document)
- Single `/` refers to empty key in object

---

## Step 3: RFC 6902 - JSON Patch

**Source**: [RFC 6902 - IETF](https://datatracker.ietf.org/doc/html/rfc6902)

### Operations
| Operation | Required Members | Description |
|-----------|------------------|-------------|
| `add` | path, value | Add value at path |
| `remove` | path | Remove value at path |
| `replace` | path, value | Replace value at path |
| `move` | from, path | Move value from to path |
| `copy` | from, path | Copy value from to path |
| `test` | path, value | Test value equality |

### Atomic Semantics
- Operations applied sequentially
- If any operation fails, entire patch fails
- Original document unchanged on failure
- All-or-nothing guarantee

### Critical Rules
1. `add` to nonexistent parent: ERROR
2. `remove` from root `/`: ERROR (Errata 4787)
3. `move`: Conceptually remove then add
4. `test`: Deep equality comparison

### Error Conditions
- Path doesn't exist (for remove/replace/test)
- Index out of bounds (for arrays)
- Invalid JSON Pointer syntax
- Type mismatch (array index on object)

---

## Step 4: RFC 7386 - JSON Merge Patch

**Source**: [RFC 7386 - IETF](https://datatracker.ietf.org/doc/html/rfc7386)
**Note**: Obsoleted by RFC 7396

### Algorithm (Pseudocode)
```
define MergePatch(Target, Patch):
  if Patch is an Object:
    if Target is not an Object:
      Target = {}
    for each Name/Value in Patch:
      if Value is null:
        if Name exists in Target:
          remove Name from Target
      else:
        Target[Name] = MergePatch(Target[Name], Value)
    return Target
  else:
    return Patch
```

### Null Semantics (CRITICAL)
- `null` in patch = DELETE key
- Cannot set a value TO `null` via merge patch
- This is a fundamental limitation

### Preservation Rules
- Arrays replaced entirely (not merged)
- Nulls inside arrays preserved
- Missing keys in patch = unchanged

### Use Cases
- Simple updates to JSON objects
- HTTP PATCH with content-type `application/merge-patch+json`
- NOT suitable for documents using null values

---

## Step 5: JSON Schema Draft 2020-12

**Source**: [JSON Schema Specification](https://json-schema.org/draft/2020-12)

### Validation Keywords (Subset implemented in simple_json)

#### Type Keywords
| Keyword | Values |
|---------|--------|
| `type` | string, number, integer, object, array, boolean, null |

#### String Keywords
| Keyword | Description |
|---------|-------------|
| `minLength` | Minimum character count |
| `maxLength` | Maximum character count |
| `pattern` | ECMA-262 regex |

#### Number Keywords
| Keyword | Description |
|---------|-------------|
| `minimum` | Inclusive minimum |
| `maximum` | Inclusive maximum |
| `exclusiveMinimum` | Exclusive minimum |
| `exclusiveMaximum` | Exclusive maximum |

#### Object Keywords
| Keyword | Description |
|---------|-------------|
| `properties` | Schema for each property |
| `required` | Array of required property names |
| `additionalProperties` | Schema for unlisted properties |

#### Array Keywords
| Keyword | Description |
|---------|-------------|
| `items` | Schema for all items (2020-12) |
| `prefixItems` | Tuple validation (2020-12) |
| `minItems` | Minimum count |
| `maxItems` | Maximum count |
| `uniqueItems` | All items unique |

### NOT Implemented in simple_json
- `$ref`, `$defs` (references)
- `allOf`, `anyOf`, `oneOf`, `not` (composition)
- `if`, `then`, `else` (conditionals)
- `dependentRequired`, `dependentSchemas`
- `format` (semantic validation)
- `unevaluatedProperties`, `unevaluatedItems`

---

## Step 6: Implementation Gap Analysis

### RFC 8259 Compliance

| Requirement | simple_json | Notes |
|-------------|-------------|-------|
| UTF-8 encoding | ✅ COMPLIANT | Uses UTF_CONVERTER |
| All value types | ✅ COMPLIANT | string/number/boolean/null/object/array |
| Number format | ✅ COMPLIANT | Via ISE JSON library |
| Escape sequences | ✅ COMPLIANT | Via ISE JSON library |
| Duplicate keys | ⚠️ USES LAST | Standard behavior |
| Surrogate pairs | ✅ COMPLIANT | Via UTF_CONVERTER |

### RFC 6901 Compliance

| Requirement | simple_json | Notes |
|-------------|-------------|-------|
| Path parsing | ✅ COMPLIANT | `parse_path` feature |
| Escape decoding | ✅ COMPLIANT | Correct order ~1 → ~0 |
| Array indexing | ✅ COMPLIANT | 0-based to 1-based conversion |
| `-` token | ❌ NOT IMPLEMENTED | Append semantics missing |
| Empty path | ✅ COMPLIANT | Returns document root |

### RFC 6902 Compliance

| Requirement | simple_json | Notes |
|-------------|-------------|-------|
| add operation | ✅ COMPLIANT | Full implementation |
| remove operation | ✅ COMPLIANT | Full implementation |
| replace operation | ✅ COMPLIANT | Full implementation |
| move operation | ✅ COMPLIANT | Full implementation |
| copy operation | ✅ COMPLIANT | Full implementation |
| test operation | ✅ COMPLIANT | Deep equality |
| Atomic semantics | ✅ COMPLIANT | All-or-nothing |
| Sequential execution | ✅ COMPLIANT | In-order application |

### RFC 7386 Compliance

| Requirement | simple_json | Notes |
|-------------|-------------|-------|
| Null deletion | ✅ COMPLIANT | Key removed on null |
| Object merge | ✅ COMPLIANT | Recursive merge |
| Non-object replace | ✅ COMPLIANT | Primitives replace |
| Array in arrays | ✅ COMPLIANT | Nulls preserved |
| Deep copy | ✅ COMPLIANT | Original unchanged |

---

## Step 7: Recommendations

### Gaps to Address

1. **JSON Pointer `-` Token**
   - Location: `simple_json_pointer.e`
   - Issue: Cannot append to arrays using `-`
   - Severity: LOW (rarely used)

2. **JSON Schema Coverage**
   - Missing: `$ref`, composition keywords, conditionals
   - Impact: Complex schemas not supported
   - Severity: MEDIUM (documented limitation)

### Hardening Opportunities

1. **Parser Limits**
   - Add configurable limits for:
     - Maximum nesting depth
     - Maximum string length
     - Maximum array/object size
   - Current: Uses constants (10MB string limit)

2. **Unicode Validation**
   - Validate unpaired surrogates
   - Detect malformed UTF-8
   - Current: Relies on UTF_CONVERTER

3. **Numeric Edge Cases**
   - Test: Very large integers
   - Test: Precision loss on decimals
   - Current: Uses SIMPLE_DECIMAL for precision

### Test Coverage Gaps

| Area | Current Tests | Needed |
|------|---------------|--------|
| Escape sequences | Basic | All 8 sequences |
| Unicode surrogates | None | Paired/unpaired |
| Deep nesting | None | 100+ levels |
| Large documents | None | MB-scale |
| Malformed input | Basic | Comprehensive |

---

## Research Sources

- [RFC 8259 - JSON Format](https://datatracker.ietf.org/doc/html/rfc8259)
- [RFC 6901 - JSON Pointer](https://datatracker.ietf.org/doc/html/rfc6901)
- [RFC 6902 - JSON Patch](https://datatracker.ietf.org/doc/html/rfc6902)
- [RFC 7386 - JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7386)
- [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12)
- [RFC Editor Errata for RFC 8259](https://www.rfc-editor.org/errata/rfc8259)
- [RFC Editor Errata for RFC 6901](https://www.rfc-editor.org/errata/rfc6901)

---

*Research completed: 2026-01-18*
*Standards reviewed: RFC 8259, RFC 6901, RFC 6902, RFC 7386, JSON Schema 2020-12*
