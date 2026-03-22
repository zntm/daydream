import { Doc, Table } from "../../../lib";

export const modules = new Doc("Daydream Modules")
    .add("Daydream can import code, UI definitions, and structured data from other files. Import paths always require an explicit extension.")
    .section("Syntax")
    .add("Named imports support both compact and braced forms:\n\n```javascript\nimport add, sub as subtract from \"./math.daydream\"\nimport { add as plus, sub } from \"./math.daydream\"\n```")
    .add("Paths may be namespace-qualified or relative:\n\n```javascript\nimport flow from \"phantasia:tile/liquid/flow.daydream\"\nimport helper from \"./util.daydream\"\n```")
    .section("Supported Extensions")
    .table(["Extension", "Available Exports"], (t: Table) => {
        t.addRow(["`.daydream`", "Exported Daydream names"]);
        t.addRow(["`.ui`", "Named UI definitions loaded through `ui_load(...)`"]);
        t.addRow(["`.json`", "`data`, `json`, `text`, plus top-level object keys"]);
        t.addRow(["`.csv`", "`data`, `records`, `rows`, `header`, `text`"]);
        t.addRow(["`.ini`", "`data`, `sections`, `text`, plus section names"]);
        t.addRow(["`.txt` / `.md`", "`data`, `text`"]);
    })
    .section("Examples")
    .add("Importing another Daydream module:\n\n```javascript\nimport area, perimeter as circ from \"./math_lib.daydream\"\n```")
    .add("Importing named definitions from a `.ui` file:\n\n```javascript\nimport hp_container, stamina_container from \"ui/stat_bars.ui\"\n```")
    .add("Importing data files:\n\n```javascript\nimport data, player_name from \"./player.json\"\nimport records, header from \"./loot_table.csv\"\nimport settings, player from \"./settings.ini\"\n```")
    .section("Notes")
    .add("- Daydream does not auto-append `.daydream`; the extension must be written explicitly.\n- JSON, CSV, and INI imports coerce numeric and boolean scalar values where possible.\n- Unsupported extensions fail during import resolution.")
    .toString();
