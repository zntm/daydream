# Introduction to Daydream

**Daydream** is a custom scripting language integrated into the game. It is designed to be familiar to users of Javascript and GML (GameMaker Language), featuring dynamic typing, first-class functions, and object-oriented capabilities.

## Key Features

-   **Dynamic Typing**: Variables can hold any type of value (Number, String, Boolean, Array, Struct, etc.).
-   **C-Style Syntax**: Familiar syntax with braces `{}`, semicolons `;` (optional), and standard control flow.
-   **First-Class Functions**: Functions are values, supporting closures and high-order functions.
-   **Object-Oriented**: Support for Classes, methods, inheritance, and static members.
-   **Modular**: Built-in support for `import` and `export` to organize code.
-   **Game Integration**: Direct access to game logic through context variables and exposed API functions.

## Getting Started

Daydream scripts are typically stored in `.daydream` files or embedded within the game's data.

### Hello World

```javascript
// A simple Hello World script
print("Hello, World!");
```

### Basic Calculation

```javascript
var a = 10;
var b = 20;

fn add(x, y) {
    return x + y;
}

var result = add(a, b);
print($"The result is {result}");
```
