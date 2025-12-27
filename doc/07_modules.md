# Modules

Daydream supports a module system to organize code into separate files.

## Exporting

Use the `export` keyword to make variables or functions available to other modules.

```javascript
// math_lib.daydream

export var PI = 3.14159;

export fn area(r) {
    return PI * r * r;
}
```

## Importing

Use `import` to use code from another module.

```javascript
// main.daydream
import PI, area from "math_lib";

print(PI);
print(area(10));
```

## Module Paths

Module paths are usually relative to the project root or the current file (depending on implementation configuration). Standard library modules (if any) might be imported by name.
