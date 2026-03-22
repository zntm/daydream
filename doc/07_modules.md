# Modules

Daydream modules can export code, UI definitions, and structured data from other files.

## Exporting

Use `export` to expose functions, variables, or values from a `.daydream` module.

```javascript
// math_lib.daydream

export fn area(r) {
    return PI * r * r;
}
```

## Importing

Use `import` to bind one or more exported names into the current file. Named imports support both the compact form and the braced form, and `as` can be used to rename an import locally.

```javascript
// main.daydream
import area, perimeter as circ from "./math_lib.daydream";
import { area as circle_area } from "./math_lib.daydream";

print(area(10));
print(circ(10));
print(circle_area(4));
```

## Module Paths

Every import path must include an explicit extension.

Namespace imports use `namespace:path.ext`:

```javascript
import flow from "phantasia:tile/liquid/flow.daydream";
```

Relative imports use `./` or `../`:

```javascript
import internal_helper from "./util.daydream";
```

- **Namespace**: Usually represents the mod or project name (for example `phantasia`).
- **Path**: The file path from the script root or current file.
- **Extension**: Required for all imports. Daydream does not auto-append `.daydream`.

## Supported Import Types

### `.daydream`

Loads another Daydream module and imports its exported names.

```javascript
import add, sub as subtract from "./math.daydream";
```

### `.ui`

Loads a UI definition through the UI runtime and imports named definitions from the `.ui` file.

```javascript
import hp_container, stamina_container from "ui/stat_bars.ui";
```

### `.json`

JSON modules expose:

- `data`: Parsed JSON value
- `json`: Alias of `data`
- `text`: Original file contents
- top-level object keys as named imports when the JSON root is an object

```javascript
import data, player_name, stats from "./player_profile.json";
```

### `.csv`

CSV modules expose:

- `data`: Array of record structs
- `records`: Same value as `data`
- `rows`: Raw rows, including the header row
- `header`: The first row
- `text`: Original file contents

```javascript
import records, rows, header from "./loot_table.csv";
```

### `.ini`

INI modules expose:

- `data`: Parsed section map
- `sections`: Alias of `data`
- each section name as a named import
- `text`: Original file contents

```javascript
import data, player, flags from "./settings.ini";
```

### `.txt` and `.md`

Text modules expose the raw file contents as both `data` and `text`.

```javascript
import data, text from "./notes.md";
```

## Notes

- JSON, CSV, and INI imports automatically coerce numbers, `true`, `false`, `null`, and `undefined` where possible.
- Unsupported extensions raise an import error at load time.
