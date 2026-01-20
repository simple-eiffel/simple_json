# D02: Smell Detection - simple_json + simple_encoding Integration

## Date: 2026-01-20

## Context

This is a focused integration audit, not a full design review.
Goal: Add SIMPLE_ENCODING for BOM detection in file parsing.

## Relevant Smells Scan

### File Parsing Duplication

POTENTIAL SMELL: `utf_8_to_string_32` is duplicated in 3 files:
- `simple_json.e:471-477`
- `simple_json_value.e:321-326`
- `simple_json_stream.e:202-207`

SEVERITY: LOW
REASON: Each class needs it locally for void safety; extraction would add complexity without benefit.

### No God Class Issues

SIMPLE_JSON (main facade) has ~25 features but they are cohesive:
- Parsing (parse, parse_file, is_valid_json)
- Creation (new_object, new_array, new_value)
- Error handling (last_errors, has_errors)
- Utilities (utf_8_to_string_32, string_32_to_utf_8)

No extraction needed.

## Integration-Specific Analysis

For adding SIMPLE_ENCODING:

| Change Point | Smell Risk | Notes |
|--------------|------------|-------|
| Add ECF dependency | None | Standard addition |
| Add BOM stripping | None | Single helper feature |
| Modify parse_file | Low | One line change |

## Conclusion

No design smells block this integration. Proceed to D05-REFACTOR-PLAN.

## Next Step

→ D05-REFACTOR-PLAN.md (skipping D03, D04 as not relevant to this integration)
