# Data Structures

### `array_length(array)`: number

Returns the length of an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `array` | array | Input array |

**Returns:** number

---

### `array_push(array, val)`: void

Adds elements to the end of an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `array` | array | Target array |
| `val` | any | Value(s) to push (Optional) |

**Returns:** void

---

### `array_pop(array)`: any

Removes and returns the last element of an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `array` | array | Target array |

**Returns:** any

---

### `array_resize(array, new_size)`: void

Resizes an array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `array` | array | Target array |
| `new_size` | number | New size |

**Returns:** void

---

### `array_copy(dest, dest_index, src, src_index, length)`: void

Copies part of an array into another.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `dest` | array | Destination array |
| `dest_index` | number | Start index in destination |
| `src` | array | Source array |
| `src_index` | number | Start index in source |
| `length` | number | Number of elements to copy |

**Returns:** void

---

### `struct_get_names(struct)`: array

Returns an array of property names in a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `struct` | struct | Input struct |

**Returns:** array

---

### `struct_get(struct, name)`: any

Gets a variable from a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `struct` | struct | Input struct |
| `name` | string | Variable name |

**Returns:** any

---

### `struct_set(struct, name, val)`: void

Sets a variable in a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `struct` | struct | Input struct |
| `name` | string | Variable name |
| `val` | any | Value to set |

**Returns:** void

---

### `struct_names_count(struct)`: number

Returns the number of variables in a struct.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `struct` | struct | Input struct |

**Returns:** number

---

### `struct_stringify(val)`: string

Converts a struct/array to a JSON string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | any | Value to stringify |

**Returns:** string

---

### `struct_parse(json)`: any

Parses a JSON string into a struct/array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON string |

**Returns:** any

---

