# Daydream Modules

Daydream can import code, UI definitions, and structured data from other files. Import paths always require an explicit extension.

## Syntax

Named imports support both compact and braced forms:

```javascript
import add, sub as subtract from "./math.daydream"
import { add as plus, sub } from "./math.daydream"
```

Paths may be namespace-qualified or relative:

```javascript
import flow from "phantasia:tile/liquid/flow.daydream"
import helper from "./util.daydream"
```

## Supported Extensions

| Extension      | Available Exports                                  |
| -------------- | -------------------------------------------------- |
| `.daydream`    | Exported Daydream names                            |
| `.ui`          | Named UI definitions loaded through `ui_load(...)` |
| `.json`        | `data`, `json`, `text`, plus top-level object keys |
| `.csv`         | `data`, `records`, `rows`, `header`, `text`        |
| `.ini`         | `data`, `sections`, `text`, plus section names     |
| `.txt` / `.md` | `data`, `text`                                     |

## Examples

Importing another Daydream module:

```javascript
import area, perimeter as circ from "./math_lib.daydream"
```

Importing named definitions from a `.ui` file:

```javascript
import hp_container, stamina_container from "ui/stat_bars.ui"
```

Importing data files:

```javascript
import data, player_name from "./player.json"
import records, header from "./loot_table.csv"
import settings, player from "./settings.ini"
```

## Notes

- Daydream does not auto-append `.daydream`; the extension must be written explicitly.
- JSON, CSV, and INI imports coerce numeric and boolean scalar values where possible.
- Unsupported extensions fail during import resolution.
