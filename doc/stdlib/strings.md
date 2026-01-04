# Strings and Types

Functions for type checking, type conversion, and string manipulation.

---

## Type Conversion

### `string(val)`: String

Converts any value to its string representation.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | Any | Value to convert |

**Returns:** String representation of the value.

```javascript
string(123); // "123"
string(true); // "true"
string([1, 2, 3]); // "[1, 2, 3]"
```

### `real(val)`: Number

Converts a string to a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | String | String containing a number |

**Returns:** The numeric value.

```javascript
real("42"); // 42
real("3.14"); // 3.14
```

---

## Type Checking

### `typeof(val)`: String

Returns a string describing the type of the value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | Any | Value to check |

**Returns:** One of: `"number"`, `"string"`, `"boolean"`, `"array"`, `"struct"`, `"object"`, `"function"`, `"regex"`, `"undefined"`.

```javascript
typeof 123; // "number"
typeof "hi"; // "string"
typeof true; // "boolean"
typeof [1, 2]; // "array"
typeof { x: 1 }; // "struct"
typeof new Player(); // "object" (class instance)
typeof regex_parse(".*"); // "regex"
```

### `is_string(val)`: Boolean

Returns true if the value is a string.

```javascript
is_string("hello"); // true
is_string(123); // false
```

### `is_regex(val)`: Boolean

Returns true if the value is a regex object.

```javascript
var re = regex_parse(".*");
is_regex(re); // true
is_regex(".*"); // false
```

### `is_real(val)`: Boolean

Returns true if the value is a number.

```javascript
is_real(42); // true
is_real("42"); // false
```

### `is_numeric(val)`: Boolean

Returns true if the value is numeric (real or int64).

```javascript
is_numeric(42); // true
is_numeric(3.14); // true
```

### `is_bool(val)`: Boolean

Returns true if the value is a boolean.

```javascript
is_bool(true); // true
is_bool(1); // false
```

### `is_array(val)`: Boolean

Returns true if the value is an array.

```javascript
is_array([1, 2, 3]); // true
is_array("array"); // false
```

### `is_struct(val)`: Boolean

Returns true if the value is a struct.

```javascript
is_struct({ x: 10 }); // true
is_struct([1, 2]); // false
```

### `is_undefined(val)`: Boolean

Returns true if the value is undefined.

```javascript
is_undefined(undefined); // true
is_undefined(0); // false
```

---

## String Functions

### `string_length(str)`: Number

Returns the length of a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Input string |

**Returns:** Number of characters.

```javascript
string_length("Hello"); // 5
```

### `string_pos(substr, str)`: Number

Finds the position of a substring within a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `substr` | String | Substring to find |
| `str` | String | String to search in |

**Returns:** Position (1-indexed), or `0` if not found.

```javascript
string_pos("lo", "Hello"); // 4
string_pos("x", "Hello"); // 0
```

### `string_delete(str, index, count)`: String

Removes a part of a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Input string |
| `index` | Number | Start position (1-indexed) |
| `count` | Number | Number of characters to delete |

**Returns:** New string.

```javascript
string_delete("Hello World", 6, 6); // "Hello"
```

### `string_insert(str, substr, index)`: String

Inserts a substring into a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Base string |
| `substr` | String | String to insert |
| `index` | Number | Insertion position (1-indexed) |

**Returns:** New string.

```javascript
string_insert("World", "Hello ", 1); // "Hello World"
```

### `string_upper(str)`: String

Converts a string to uppercase.

```javascript
string_upper("hello"); // "HELLO"
```

### `string_lower(str)`: String

Converts a string to lowercase.

```javascript
string_lower("HELLO"); // "hello"
```

### `string_replace(str, old, new)`: String

Replaces the first occurrence of a substring.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Original string |
| `old` | String | Substring to replace |
| `new` | String | Replacement text |

**Returns:** Modified string.

```javascript
string_replace("Hello World", "World", "Daydream");
// "Hello Daydream"
```

### `string_replace_all(str, old, new)`: String

Replaces all occurrences of a substring.

```javascript
// "ho ho ho"
```

### `string_width(str)`: Number

Returns the width of the string in pixels based on current font.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Input string |

**Returns:** Width in pixels.

### `string_height(str)`: Number

Returns the height of the string in pixels based on current font.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | String | Input string |

**Returns:** Height in pixels.

---

## Character Functions

### `chr(code)`: String

Converts an ASCII/Unicode value to a character.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `code` | Number | Character code |

**Returns:** Single character string.

```javascript
chr(65); // "A"
chr(10); // newline character
```

### `ord(char)`: Number

Converts a character to its ASCII/Unicode value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `char` | String | Single character |

**Returns:** Character code.

```javascript
ord("A"); // 65
ord("a"); // 97
```
