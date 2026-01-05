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

Use `import` to use code from another module.

```javascript
// main.daydream
import area from "math_lib";

print(area(10));
```

## Module Paths

Module paths are usually relative to the project root or the current file (depending on implementation configuration). Standard library modules (if any) might be imported by name.
