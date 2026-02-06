# Modules

Daydream supports a module system to organize code into separate files.

## Exporting

Use the `export` keyword to make variables or functions available to other modules.

```javascript
// math_lib.daydream

export fn area(r) {
    return PI * r * r;
}
```

## Importing

Use `import` to use code from another module. You can import multiple names separated by commas and use `as` to provide an alias.

```javascript
// main.daydream
import area, perimeter as circ from "math_lib";

print(area(10));
print(circ(10));
```

> [!NOTE]
> Proglang uses a simplified import syntax. Braces `{}` around imported names are NOT required and NOT supported.

## Module Paths

Modules are identified by their namespace and file path, separated by a colon `:`.

```javascript
import flow from "phantasia:tile/liquid/flow";
```

-   **Namespace**: Usually represents the mod or project name (e.g., `phantasia`).
-   **Path**: The relative path to the `.daydream` file from the script root, excluding the extension.

For relative imports between files in the same namespace, use `./` or `../`:

```javascript
import internal_helper from "./util";
```
