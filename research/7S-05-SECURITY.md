# 7S-05: SECURITY - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Security Considerations

### Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| JSON bomb (deeply nested) | Medium | Depth limits in parser |
| Large string DoS | Medium | Max_reasonable_string_length |
| Large object DoS | Medium | Max_reasonable_object_size |
| Large array DoS | Medium | Max_reasonable_array_size |
| Malformed UTF-8 | Low | Conversion validation |
| Integer overflow | Low | INTEGER_64 range |

### Defensive Limits

| Constant | Value | Purpose |
|----------|-------|---------|
| Max_reasonable_key_length | 1,024 | Prevent key abuse |
| Max_reasonable_string_length | 10,000,000 | 10MB string limit |
| Max_reasonable_object_size | 100,000 | Property count limit |
| Max_reasonable_array_size | 1,000,000 | Array element limit |

### Input Validation

1. **UTF-8 BOM handling**: Automatically stripped
2. **Key validation**: Non-empty keys required
3. **Type checking**: Safe type conversion methods
4. **Error tracking**: Position information for debugging

## Security Best Practices

1. **Validate structure**: Check expected keys exist
2. **Limit depth**: Don't recurse unbounded
3. **Size limits**: Reject oversized documents
4. **Type assertions**: Use is_* checks before as_*

## Known Limitations

- No configurable depth limit (uses parser default)
- No streaming with size limits
- Trust in underlying JSON parser security
