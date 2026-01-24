# 7S-04: SIMPLE-STAR INTEGRATION - simple_json

**Library**: simple_json
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Ecosystem Position

simple_json is a **foundational library** - many simple_* libraries depend on it for JSON handling.

## Dependencies (Inbound)

| Library | Usage |
|---------|-------|
| EiffelStudio json | Underlying parser |
| simple_zstring | UTF-8/STRING_32 conversion |
| simple_encoding | BOM detection |
| simple_decimal | Precise number handling |

## Dependents (Outbound)

| Library | How It Uses simple_json |
|---------|-------------------------|
| simple_http | Parse API responses |
| simple_jwt | JWT payload handling |
| simple_k8s | Kubernetes API JSON |
| simple_config | JSON config files |
| simple_logger | JSON log formatting |
| simple_oracle | Ecosystem metadata |
| simple_docker | Docker API JSON |

## Integration Patterns

### Quick API Usage

```eiffel
local
    json: SIMPLE_JSON_QUICK
    obj: SIMPLE_JSON_OBJECT
do
    -- Parse
    if attached json.parse (json_string) as val then
        if val.is_object then
            obj := val.as_object
            name := obj.string_item ("name")
        end
    end

    -- Build
    obj := json.new_object
        .put_string ("name", "value")
        .put_integer (42, "count")
end
```

### Ecosystem Conventions

1. **Naming**: SIMPLE_JSON prefix
2. **Void safety**: Detachable returns where appropriate
3. **Contracts**: Full pre/post conditions
4. **Errors**: last_errors pattern with positions
