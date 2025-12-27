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
