# Regular Expressions

### `regex_create(pattern, flags)`: Regex

Creates a regex object.

**Arguments:**
| Name      | Type   | Description                        |
| --------- | ------ | ---------------------------------- |
| `pattern` | string | Regex pattern                      |
| `flags`   | string | Regex flags (e.g. "gi") (Optional) |

**Returns:** Regex

---

### `regex_test(regex, str)`: boolean

Checks if a pattern matches a string.

**Arguments:**
| Name    | Type   | Description    |
| ------- | ------ | -------------- |
| `regex` | Regex  | Regex object   |
| `str`   | string | String to test |

**Returns:** boolean

---

### `regex_match(regex, str)`: array

Returns an array of matches.

**Arguments:**
| Name    | Type   | Description     |
| ------- | ------ | --------------- |
| `regex` | Regex  | Regex object    |
| `str`   | string | String to match |

**Returns:** array

---

### `regex_replace(regex, str, new)`: string

Replaces matches with new text.

**Arguments:**
| Name    | Type   | Description      |
| ------- | ------ | ---------------- |
| `regex` | Regex  | Regex object     |
| `str`   | string | Original string  |
| `new`   | string | Replacement text |

**Returns:** string

---
