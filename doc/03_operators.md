# Operators

Daydream supports a wide range of operators for arithmetic, comparison, logic, and more.

## Arithmetic

| Operator | Description        | Example  | Result |
| -------- | ------------------ | -------- | ------ |
| `+`      | Addition           | `10 + 5` | `15`   |
| `-`      | Subtraction        | `10 - 5` | `5`    |
| `*`      | Multiplication     | `10 * 5` | `50`   |
| `/`      | Division           | `10 / 2` | `5`    |
| `%`      | Modulo (Remainder) | `10 % 3` | `1`    |
| `**`     | Exponentiation     | `2 ** 3` | `8`    |

## Comparison

Comparison operators return a boolean (`true` or `false`).

| Operator | Description           | Example  |
| -------- | --------------------- | -------- |
| `==`     | Equal to              | `5 == 5` |
| `!=`     | Not equal to          | `5 != 3` |
| `<`      | Less than             | `3 < 5`  |
| `>`      | Greater than          | `5 > 3`  |
| `<=`     | Less than or equal    | `5 <= 5` |
| `>=`     | Greater than or equal | `6 >= 5` |

## Logical

| Operator | Description | Example                  |
| -------- | ----------- | ------------------------ |
| `&&`     | Logical AND | `true && false` (false)  |
| `\|\|`   | Logical OR  | `true \|\| false` (true) |
| `!`      | Logical NOT | `!true` (false)          |

## Bitwise

| Operator | Description | Example      |
| -------- | ----------- | ------------ |
| `&`      | Bitwise AND | `5 & 3` (1)  |
| `\|`     | Bitwise OR  | `5 \| 3` (7) |
| `^`      | Bitwise XOR | `5 ^ 3` (6)  |
| `~`      | Bitwise NOT | `~5` (-6)    |
| `<<`     | Left Shift  | `1 << 2` (4) |
| `>>`     | Right Shift | `8 >> 2` (2) |

## Assignment

| Operator | Description                |
| -------- | -------------------------- |
| `=`      | Assign value               |
| `+=`     | Add and assign             |
| `-=`     | Subtract and assign        |
| `*=`     | Multiply and assign        |
| `/=`     | Divide and assign          |
| `<<=`    | Left shift and assign      |
| `>>=`    | Right shift and assign     |
| `&=`     | Bitwise AND and assign     |
| `\|=`    | Bitwise OR and assign      |
| `^=`     | Bitwise XOR and assign     |
| `++`     | Increment (Prefix/Postfix) |
| `--`     | Decrement (Prefix/Postfix) |

```javascript
var a = 10;
a += 5; // a is now 15
a++; // a is now 16
```

## Special Operators

### Null Coalescing (`??`)

Returns the right-hand operand if the left-hand operand is `undefined`.

```javascript
var name = val ?? "Default";
```

### Ternary Operator (`? :`)

A conditional expression.

```javascript
var status = hp > 0 ? "Alive" : "Dead";
```

### Spread Operator (`...`)

Expands an array into elements.

```javascript
var parts = [1, 2];
var whole = [0, ...parts, 3]; // [0, 1, 2, 3]

var m = max(...whole); // Calls max(0, 1, 2, 3)
```

### In Operator (`in`)

Checks if a value exists in a collection.

```javascript
// Strings (substring check)
if "world" in "hello world" { ... }

// Arrays (element presence)
if 5 in [1, 2, 3, 5] { ... }

// Struct (explicit key check)
if "key" in key { key: "value" } { ... }

// Struct (value check)
if "value" in value { key: "value" } { ... }
```

### Optional Chaining (`?.`)

Safe access to properties or indices of potentially `undefined` or `null` values.

```javascript
var user = undefined;
var name = user?.name; // undefined (no error)
var item = user?.items?.[0]; // undefined
```

### String & Array Access

You can access characters in a string or elements in an array using square brackets `[]`.

```javascript
var str = "Hello";
var char = str[0]; // "H"
```

#### Slicing

You can slice strings and arrays using the range operator `..`.

```javascript
var str = "Hello World";
var sub = str[0..4]; // "Hello" (inclusive)
```
