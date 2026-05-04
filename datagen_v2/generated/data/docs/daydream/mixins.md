# Data Mixins

Structured game data can extend an existing JSON definition with the `$MIXIN` field. This lets a mod patch base-game data instead of replacing an entire file.

## Syntax

Point `$MIXIN` at an existing namespaced id from the same registry type:

```json
{
    "$MIXIN": "phantasia:stone",
    "item": {
        "tile": {
            "light": 8
        }
    }
}
```

## Merge Rules

| Value Type | Behaviour                                              |
| ---------- | ------------------------------------------------------ |
| Objects    | Merged recursively. Patch fields override base fields. |
| Arrays     | Replaced by the patch value.                           |
| Scalars    | Replaced by the patch value.                           |

## Targeting Base Game Data

To modify base-game content from a mod, use an explicit namespaced target such as `phantasia:stone` or `phantasia:surface/forest`.

Bare ids are resolved against the current namespace. When a mixin targets another namespace, any new references you add should usually be fully namespaced as well.

## Datagen v2

`DatagenReturnData` supports mixins directly:

```ts
new DatagenReturnData("stone.json", {
    item: { tile: { light: 8 } }
}).setMixin("phantasia:stone")
```

## Repository Example

The bundled Torchmaster Lite example mod includes real registry mixins in `datafiles/mods/torchmaster_lite/data/items/torch.json` and `datafiles/mods/torchmaster_lite/data/items/campfire.json`. They target `phantasia:torch` and `phantasia:campfire`, adding an `on_stay` hook that applies the base-game `phantasia:burning` effect.

## Notes

- Registry data loaders resolve `$MIXIN` before parsing tags or registry references.
- Registry mixins only work after their target has already been loaded.
- Daydream `.json` imports also support `$MIXIN`, but there it resolves like a normal module import path instead of a registry id.
- `$NAMESPACE_EXISTS` can be combined with `$MIXIN` on the same JSON root.
