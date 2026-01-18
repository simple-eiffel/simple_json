# simple_json Design Audit (OOSC2 Compliance)

## D01: Single Choice Principle

**Principle**: Whenever a software system must support a set of alternatives, one and only one module in the system should know their exhaustive list.

### Assessment

| Decision | Location | Status |
|----------|----------|--------|
| JSON value types | SIMPLE_JSON_VALUE type checks | ✅ COMPLIANT |
| Patch operations | SIMPLE_JSON_PATCH_OPERATION subclasses | ✅ COMPLIANT |
| Schema keywords | SIMPLE_JSON_SCHEMA_VALIDATOR | ✅ COMPLIANT |
| Escape sequences | SIMPLE_JSON_CONSTANTS | ✅ COMPLIANT |
| Type strings | SIMPLE_JSON_CONSTANTS | ✅ COMPLIANT |

**Finding**: All alternatives centralized. JSON types defined once in SIMPLE_JSON_VALUE invariant.

---

## D02: Open/Closed Principle

**Principle**: Software entities should be open for extension but closed for modification.

### Assessment

| Class | Extensibility | Status |
|-------|---------------|--------|
| SIMPLE_JSON | Facade, complete API | ✅ COMPLIANT |
| SIMPLE_JSON_VALUE | Wrapper, can extend | ✅ COMPLIANT |
| SIMPLE_JSON_OBJECT | Inherits VALUE | ✅ COMPLIANT |
| SIMPLE_JSON_ARRAY | Inherits VALUE | ✅ COMPLIANT |
| SIMPLE_JSON_PATCH_OPERATION | Abstract base | ✅ COMPLIANT |
| SIMPLE_JSON_PATCH_ADD/REMOVE/etc | Concrete subclasses | ✅ COMPLIANT |

**Finding**: Patch operations use polymorphism. New operations can be added without modifying base class.

---

## D03: Command/Query Separation

**Principle**: A feature should either be a command (changes state) or a query (returns value), never both.

### Assessment

| Feature | Type | Returns | Modifies | Status |
|---------|------|---------|----------|--------|
| parse | Query | VALUE | - | ✅ COMPLIANT |
| is_valid_json | Query | BOOLEAN | - | ✅ COMPLIANT |
| new_object | Query | OBJECT | - | ✅ COMPLIANT |
| put_string | Fluent | Current | state | ⚠️ DOCUMENTED |
| put_integer | Fluent | Current | state | ⚠️ DOCUMENTED |
| remove | Command | - | state | ✅ COMPLIANT |
| wipe_out | Command | - | state | ✅ COMPLIANT |
| apply (Patch) | Query | RESULT | - | ✅ COMPLIANT |
| is_string | Query | BOOLEAN | - | ✅ COMPLIANT |
| as_string_32 | Query | STRING | - | ✅ COMPLIANT |
| clear_errors | Command | - | state | ✅ COMPLIANT |

**Finding**: Fluent API methods (`put_*`) are documented exception - return `Current` for chaining. All other features properly separated.

---

## D04: Uniform Access Principle

**Principle**: All services offered by a module should be available through a uniform notation.

### Assessment

| Class | Access Pattern | Status |
|-------|----------------|--------|
| SIMPLE_JSON_VALUE | is_string (function), json_value (attribute) | ✅ COMPLIANT |
| SIMPLE_JSON_OBJECT | count (function), json_value (attribute) | ✅ COMPLIANT |
| SIMPLE_JSON_ARRAY | count (function), json_value (attribute) | ✅ COMPLIANT |
| SIMPLE_JSON_PATCH | operations (attribute), count (function) | ✅ COMPLIANT |
| SIMPLE_JSON_ERROR | message (attribute), line (function) | ✅ COMPLIANT |

**Finding**: Attributes and functions interchangeable from client view. Line/column calculated from position on access.

---

## D05: Design by Contract

**Principle**: Use preconditions, postconditions, and invariants.

### Assessment

| Class | Require | Ensure | Invariant | Status |
|-------|---------|--------|-----------|--------|
| SIMPLE_JSON | 8 | 6 | 7 | ✅ STRONG |
| SIMPLE_JSON_VALUE | 15 | 8 | 12 | ✅ STRONG |
| SIMPLE_JSON_OBJECT | 45 | 20 | 9 | ✅ STRONG |
| SIMPLE_JSON_ARRAY | 30 | 15 | 6 | ✅ STRONG |
| SIMPLE_JSON_POINTER | 8 | 4 | 3 | ✅ STRONG |
| SIMPLE_JSON_PATCH | 20 | 12 | 5 | ✅ STRONG |
| SIMPLE_JSON_MERGE_PATCH | 15 | 10 | 5 | ✅ STRONG |
| SIMPLE_JSON_SCHEMA_VALIDATOR | 25 | 0 | 1 | ⚠️ NEEDS ENSURE |

**Finding**: Comprehensive contracts throughout. Schema validator could use more postconditions.

### Contract Examples

**SIMPLE_JSON_VALUE** - Type exclusivity invariants:
```eiffel
invariant
    valid_json_type:
        is_string or is_number or is_boolean or is_null or is_object or is_array
    string_excludes_others: is_string implies
        (not is_number and not is_boolean and not is_null and not is_object and not is_array)
    string_type_accurate: is_string = (attached {JSON_STRING} json_value)
```

**SIMPLE_JSON_OBJECT** - Key integrity:
```eiffel
invariant
    every_key_exists: across keys as ic_key all has_key (ic_key) end
    every_key_has_value: across keys as ic_key all item (ic_key) /= Void end
```

---

## D06: Information Hiding

**Principle**: Module should reveal only necessary information.

### Assessment

| Class | Public | Private | Status |
|-------|--------|---------|--------|
| SIMPLE_JSON | 35 | 10 | ✅ COMPLIANT |
| SIMPLE_JSON_VALUE | 25 | 2 | ✅ COMPLIANT |
| SIMPLE_JSON_OBJECT | 40 | 0 | ⚠️ All public |
| SIMPLE_JSON_ARRAY | 35 | 0 | ⚠️ All public |
| SIMPLE_JSON_POINTER | 8 | 3 | ✅ COMPLIANT |
| SIMPLE_JSON_PATCH | 15 | 0 | ⚠️ All public |
| SIMPLE_JSON_MERGE_PATCH | 12 | 8 | ✅ COMPLIANT |

**Finding**: Builder classes (OBJECT, ARRAY, PATCH) have all features public for fluent API. This is acceptable for builder pattern.

---

## D07: Genericity

**Principle**: Use type parameterization where appropriate.

### Assessment

| Usage | Class | Status |
|-------|-------|--------|
| ARRAYED_LIST[SIMPLE_JSON_ERROR] | SIMPLE_JSON | ✅ USES STDLIB |
| ARRAYED_LIST[STRING_32] | SIMPLE_JSON_POINTER | ✅ USES STDLIB |
| ARRAYED_LIST[SIMPLE_JSON_PATCH_OPERATION] | SIMPLE_JSON_PATCH | ✅ USES STDLIB |
| ARRAY[STRING_32] | SIMPLE_JSON_OBJECT.keys | ✅ USES STDLIB |
| ARRAYED_LIST[SIMPLE_JSON_VALUE] | Query results | ✅ USES STDLIB |

**Finding**: Uses standard library generics appropriately. No custom generic classes needed - JSON values are naturally polymorphic.

---

## D08: Audit Summary

### OOSC2 Compliance Score

| Principle | Score | Notes |
|-----------|-------|-------|
| Single Choice | 5/5 | All alternatives centralized |
| Open/Closed | 5/5 | Polymorphic patch operations |
| Command/Query | 4/5 | Fluent API documented exception |
| Uniform Access | 5/5 | Transparent |
| Design by Contract | 5/5 | Comprehensive |
| Information Hiding | 4/5 | Builder classes all public (expected) |
| Genericity | 5/5 | Uses stdlib generics |

**Overall**: 33/35 (94%) - Excellent OOSC2 compliance

### Design Strengths

1. **Comprehensive Contracts**: Type exclusivity invariants in SIMPLE_JSON_VALUE
2. **Facade Pattern**: SIMPLE_JSON provides clean API
3. **Fluent Builder**: Chainable methods for object/array construction
4. **Error Tracking**: Position-aware error messages
5. **RFC Compliance**: Matches JSON standards

### Design Recommendations

1. **Add postconditions to SIMPLE_JSON_SCHEMA_VALIDATOR**
   - Ensure validation result is consistent with input
   - Document validation semantics in contracts

2. **Consider feature export clauses for builder classes**
   - Mark implementation details as `{NONE}`
   - Keep fluent API public

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SIMPLE_JSON (Facade)                      │
│  - parse/build JSON                                          │
│  - JSONPath queries                                          │
│  - Error tracking                                            │
└─────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐
│   VALUE    │  │   OBJECT   │  │   ARRAY    │  │   ERROR    │
│ - Type     │  │ - put_*    │  │ - add_*    │  │ - Position │
│ - Convert  │  │ - item     │  │ - item     │  │ - Line/Col │
└────────────┘  └────────────┘  └────────────┘  └────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│  JSON_POINTER  │  │   JSON_PATCH   │  │ MERGE_PATCH    │
│  RFC 6901      │  │   RFC 6902     │  │ RFC 7386       │
└────────────────┘  └────────────────┘  └────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  PATCH_ADD   │  │ PATCH_REMOVE │  │  PATCH_TEST  │
│  PATCH_MOVE  │  │PATCH_REPLACE │  │  PATCH_COPY  │
└──────────────┘  └──────────────┘  └──────────────┘
                              │
                              ▼
              ┌────────────────────────────┐
              │    SCHEMA_VALIDATOR        │
              │    Draft 2020-12 subset    │
              └────────────────────────────┘
```

---

*Audit completed: 2026-01-18*
*Standard: OOSC2 (Object-Oriented Software Construction 2nd Ed)*
