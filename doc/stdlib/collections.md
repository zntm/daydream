# Collections

Functions for working with arrays and structs (objects).

---

## Arrays

### `array_length(arr)`: Number

Returns the number of elements in an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `arr` | Array | The array to measure |

**Returns:** Number of elements.

```javascript
var nums = [1, 2, 3];
print(array_length(nums)); // 3
```

### `array_push(arr, val, ...)`: Undefined

Adds one or more values to the end of an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `arr` | Array | The array to modify (mutated in place) |
| `val` | Any | Value(s) to add |

**Returns:** Nothing (undefined).

```javascript
var list = [];
array_push(list, "Apple");
array_push(list, "Banana", "Cherry");
// list is now ["Apple", "Banana", "Cherry"]
```

### `array_pop(arr)`: Any

Removes and returns the last element from an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `arr` | Array | The array to modify (mutated in place) |

**Returns:** The removed element.

```javascript
var stack = [1, 2, 3];
var last = array_pop(stack); // 3
// stack is now [1, 2]
```

### `array_resize(arr, size)`: Undefined

Resizes an array to a specific length.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `arr` | Array | The array to resize |
| `size` | Number | New length |

**Returns:** Nothing (undefined).

```javascript
var arr = [1, 2, 3, 4, 5];
array_resize(arr, 3);
// arr is now [1, 2, 3]
```

### `array_copy(dest, dest_index, src, src_index, length)`: Undefined

Copies elements from one array to another.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `dest` | Array | Destination array |
| `dest_index` | Number | Start index in destination |
| `src` | Array | Source array |
| `src_index` | Number | Start index in source |
| `length` | Number | Number of elements to copy |

**Returns:** Nothing (undefined).

```javascript
var src = [1, 2, 3, 4, 5];
var dest = [0, 0, 0];
array_copy(dest, 0, src, 1, 3);
// dest is now [2, 3, 4]
```

---

## Structs

### `struct_get_names(obj)`: Array

Returns an array of all property names in a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct | The struct to inspect |

**Returns:** Array of property name strings.

```javascript
var point = { x: 10, y: 20 };
var keys = struct_get_names(point);
// ["x", "y"] (order not guaranteed)
```

### `struct_exists(obj, key)`: Boolean

Checks if a struct has a specific property.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct | The struct to check |
| `key` | String | Property name |

**Returns:** `true` if property exists, `false` otherwise.

```javascript
var config = { volume: 80 };
struct_exists(config, "volume"); // true
struct_exists(config, "brightness"); // false
```

### `struct_get(obj, key)`: Any

Gets the value of a struct property by name.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct | The struct |
| `key` | String | Property name |

**Returns:** The property value, or `undefined` if not found.

```javascript
var player = { hp: 100, mp: 50 };
struct_get(player, "hp"); // 100
```

### `struct_set(obj, key, val)`: Undefined

Sets a struct property by name.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct | The struct to modify |
| `key` | String | Property name |
| `val` | Any | Value to set |

**Returns:** Nothing (undefined).

```javascript
var player = { hp: 100 };
struct_set(player, "mp", 50);
// player is now { hp: 100, mp: 50 }
```

### `struct_names_count(obj)`: Number

Returns the number of properties in a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct | The struct to count |

**Returns:** Number of properties.

```javascript
var obj = { a: 1, b: 2, c: 3 };
struct_names_count(obj); // 3
```

---

## JSON Serialization

### `struct_stringify(obj)`: String

Converts a struct to a JSON string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `obj` | Struct/Array | Data to serialize |

**Returns:** JSON string representation.

```javascript
var data = { name: "Player", score: 100 };
var json = struct_stringify(data);
// '{"name":"Player","score":100}'
```

### `struct_parse(json)`: Struct

Parses a JSON string into a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `json` | String | JSON string to parse |

**Returns:** Parsed struct/array.

```javascript
var json = '{"x": 10, "y": 20}';
var point = struct_parse(json);
print(point.x); // 10
```
