# D05: Refactor Plan - simple_json + simple_encoding Integration

## Date: 2026-01-20

## Goal

Add SIMPLE_ENCODING dependency for BOM detection in file parsing.

## Changes Required

### 1. ECF Dependency (simple_json.ecf)

```xml
<library name="simple_encoding" location="$SIMPLE_EIFFEL/simple_encoding/simple_encoding.ecf"/>
```

### 2. New Feature (simple_json.e)

Add BOM stripping helper:

```eiffel
feature {NONE} -- Implementation

    strip_utf8_bom (a_bytes: STRING_8): STRING_8
            -- Remove UTF-8 BOM if present
        local
            l_detector: SIMPLE_ENCODING_DETECTOR
        do
            create l_detector.make
            if l_detector.has_utf8_bom (a_bytes) then
                Result := a_bytes.substring (4, a_bytes.count)
            else
                Result := a_bytes
            end
        ensure
            not_void: Result /= Void
            bom_removed: attached old a_bytes as oa implies
                (oa.count >= 3 and then oa[1] = '%/239/' and then oa[2] = '%/187/' and then oa[3] = '%/191/')
                implies Result.count = oa.count - 3
        end
```

### 3. Modify parse_file (simple_json.e:86-94)

Change:
```eiffel
l_file.read_stream (l_file.count)
l_content := utf_8_to_string_32 (l_file.last_string)
```

To:
```eiffel
l_file.read_stream (l_file.count)
l_content := utf_8_to_string_32 (strip_utf8_bom (l_file.last_string))
```

## Test Plan

1. Compile to verify no errors
2. Run existing tests (should all pass)
3. Add new test: `test_parse_file_with_bom`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing parsing | Low | High | All existing tests must pass |
| Performance impact | Negligible | Low | BOM check is O(1) |

## Verification Criteria

- [ ] ECF compiles with new dependency
- [ ] All existing tests pass
- [ ] New BOM test passes
- [ ] File with BOM parses correctly
- [ ] File without BOM still parses correctly
