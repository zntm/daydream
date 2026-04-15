import { Doc, Table } from "../../../lib";

export const mixins = new Doc("Data Mixins")
    .add("Structured game data can extend an existing JSON definition with the `$MIXIN` field. This lets a mod patch base-game data instead of replacing an entire file.")
    .section("Syntax")
    .add("Point `$MIXIN` at an existing namespaced id from the same registry type:\n\n```json\n{\n    \"$MIXIN\": \"phantasia:stone\",\n    \"item\": {\n        \"tile\": {\n            \"light\": 8\n        }\n    }\n}\n```")
    .section("Merge Rules")
    .table(["Value Type", "Behaviour"], (t: Table) => {
        t.addRow(["Objects", "Merged recursively. Patch fields override base fields."]);
        t.addRow(["Arrays", "Replaced by the patch value."]);
        t.addRow(["Scalars", "Replaced by the patch value."]);
    })
    .section("Targeting Base Game Data")
    .add("To modify base-game content from a mod, use an explicit namespaced target such as `phantasia:stone` or `phantasia:surface/forest`.")
    .add("Bare ids are resolved against the current namespace. When a mixin targets another namespace, any new references you add should usually be fully namespaced as well.")
    .section("Datagen v2")
    .add("`DatagenReturnData` supports mixins directly:\n\n```ts\nnew DatagenReturnData(\"stone.json\", {\n    item: { tile: { light: 8 } }\n}).setMixin(\"phantasia:stone\")\n```")
    .section("Repository Example")
    .add("The bundled Torchmaster Lite example mod includes real registry mixins in `datafiles/mods/torchmaster_lite/data/items/torch.json` and `datafiles/mods/torchmaster_lite/data/items/campfire.json`. They target `phantasia:torch` and `phantasia:campfire`, adding an `on_stay` hook that applies the base-game `phantasia:burning` effect.")
    .section("Notes")
    .add("- Registry data loaders resolve `$MIXIN` before parsing tags or registry references.\n- Registry mixins only work after their target has already been loaded.\n- Daydream `.json` imports also support `$MIXIN`, but there it resolves like a normal module import path instead of a registry id.\n- `$NAMESPACE_EXISTS` can be combined with `$MIXIN` on the same JSON root.")
    .toString();
