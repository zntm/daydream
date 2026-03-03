# Strings and Types

## Functions

### `string(val)`: string

Converts any value to its string representation.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to convert |

**Returns:** string

```javascript
string(123); // "123"
```

---

### `real(val)`: number

Converts a string to a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | string | String containing a number |

**Returns:** number

```javascript
real("42"); // 42
```

---

### `string_length(str)`: number

Returns the length of a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |

**Returns:** number

```javascript
string_length("Hello"); // 5
```

---

### `string_pos(substr, str)`: number

Finds the position of a substring within a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `substr` | string | Substring to find |
| `str` | string | String to search in |

**Returns:** number

```javascript
string_pos("lo", "Hello"); // 4
```

---

### `string_delete(str, index, count)`: string

Removes a part of a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |
| `index` | number | Start position (1-indexed) |
| `count` | number | Number of characters to delete |

**Returns:** string

```javascript
string_delete("Hello World", 6, 6); // "Hello"
```

---

### `string_insert(str, substr, index)`: string

Inserts a substring into a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Base string |
| `substr` | string | String to insert |
| `index` | number | Insertion position (1-indexed) |

**Returns:** string

```javascript
string_insert("World", "Hello ", 1); // "Hello World"
```

---

### `string_replace(str, old, new)`: string

Replaces the first occurrence of a substring.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Original string |
| `old` | string | Substring to replace |
| `new` | string | Replacement text |

**Returns:** string

```javascript
string_replace("Hello World", "World", "Daydream"); // "Hello Daydream"
```

---

### `string_replace_all(str, old, new)`: string

Replaces all occurrences of a substring.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Original string |
| `old` | string | Substring to replace |
| `new` | string | Replacement text |

**Returns:** string

```javascript
string_replace_all("ho ho ho", "ho", "he"); // "he he he"
```

---

### `string_upper(str)`: string

Converts a string to uppercase.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |

**Returns:** string

```javascript
string_upper("hello"); // "HELLO"
```

---

### `string_lower(str)`: string

Converts a string to lowercase.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |

**Returns:** string

```javascript
string_lower("HELLO"); // "hello"
```

---

### `string_width(str)`: number

Returns the width of the string in pixels based on current font.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |

**Returns:** number

---

### `string_height(str)`: number

Returns the height of the string in pixels based on current font.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |

**Returns:** number

---

### `chr(code)`: string

Converts an ASCII/Unicode value to a character.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `code` | number | Character code |

**Returns:** string

```javascript
chr(65); // "A"
```

---

### `ord(char)`: number

Converts a character to its ASCII/Unicode value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `char` | string | Single character |

**Returns:** number

```javascript
ord("A"); // 65
```

---

### `is_string(val)`: boolean

Returns true if the value is a string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_real(val)`: boolean

Returns true if the value is a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_numeric(val)`: boolean

Returns true if the value is numeric (real or int64).

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_bool(val)`: boolean

Returns true if the value is a boolean.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_array(val)`: boolean

Returns true if the value is an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_struct(val)`: boolean

Returns true if the value is a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_undefined(val)`: boolean

Returns true if the value is undefined.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `is_regex(val)`: boolean

Returns true if the value is a regex object.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** boolean

---

### `typeof(val)`: string

Returns a string describing the type of the value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to check |

**Returns:** string

```javascript
typeof(123); // "number"
```

---
