# Syntax and Variables

Daydream syntax is inspired by C-style languages like Javascript and C#.

## Comments

```javascript
// This is a single-line comment

/*
   This is a multi-line comment.
   It can span multiple lines.
*/
```

## Variables

Variables are dynamically typed, meaning a variable can hold a value of any type.

### Declaration

Use the `var` keyword to declare a local variable.

```javascript
var my_number = 42;
var my_string = "Hello";
```

### Global Variables

Use `global var` to declare a variable that is accessible throughout the file.

```javascript
global var PLAYER_MAX_HP = 100;
```

Global variables can be accessed directly by their name in any script.

```javascript
print(PLAYER_MAX_HP); // 100
```

> [!IMPORTANT] > `global var` variable declarations are visible to the shell of all other modules. However, you still need to `export` them if you want other modules to be able to `import` them. Use unique names to avoid collisions, like `MY_MOD_CONFIG`.

## Data Types

Daydream supports the following primary data types:

| Type          | Description                                                                                                   | Example                           |
| ------------- | ------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| **Number**    | Floating point numbers (double precision). Supports decimal, hexadecimal (`0x`), and hex color (`#`) formats. | `10`, `3.14`, `0xFFFF`, `#FF0000` |
| **String**    | Text sequences inclosed in double quotes. Supports interpolation.                                             | `"Hello"`, `$"Value: {x}"`        |
| **Boolean**   | Logical true or false.                                                                                        | `true`, `false`                   |
| **Array**     | Ordered list of values.                                                                                       | `[1, 2, 3]`                       |
| **Struct**    | Key-value pairs (Objects).                                                                                    | `{ x: 10, y: 20 }`                |
| **Regex**     | Regular expression patterns.                                                                                  | `/abc/i`                          |
| **Undefined** | Represents the absence of a value.                                                                            | `undefined`                       |
| **Function**  | Callable code blocks.                                                                                         | `fn() { ... }`                    |

### Number Literals

Daydream supports several ways to write numbers:

-   **Decimal**: `123`, `3.14`
-   **Hexadecimal**: `0xFFFF` (65535) or `$FFFFFF` (16777215)
-   **Hex Color**: `#FF0000` (Red).
    -   `#RGB` and `#RRGGBB` are automatically converted to GameMaker-compatible color values (BGR).
    -   `#RRGGBBAA` is returned as a packed 32-bit integer (`RRGGBBAA`).

```javascript
var red = #ff0000;
var white = #fff;
var transparent_red = #ff000000;
```

### Strings

Standard strings use double quotes.

```javascript
var name = "Daydream";
```

**Interpolated Strings** allow you to embed expressions inside a string using `{}` prefixed with `$`.

```javascript
var score = 100;
var message = $"Your score is {score}"; // "Your score is 100"
```

### Arrays

Arrays are created using brackets `[]`.

```javascript
var list = [10, 20, 30];
print(list[0]); // 10
```

### Structs (Objects)

Structs are created using braces `{}` with key-value pairs.

```javascript
var player = {
    name: "Hero",
    hp: 100,
};

print(player.name); // "Hero"
print(player["name"]); // "Hero"
player.hp = 90;
```
