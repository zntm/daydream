# Regular Expressions

### `regex_parse(pattern, flags)`: regex

Creates a regex object.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `pattern` | string | Regex pattern |
| `flags` | string | Regex flags (e.g. 'g', 'i') (Optional) |

**Returns:** regex

---

### `regex_test(str, regex)`: boolean

Tests if a string matches the regex.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | String to test |
| `regex` | regex | Regex object |

**Returns:** boolean

---

### `regex_match(str, regex)`: array

Returns matches of the regex in the string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | String to match |
| `regex` | regex | Regex object |

**Returns:** array

---

### `regex_match_index(str, regex)`: number

Returns the index of the match.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | String to match |
| `regex` | regex | Regex object |

**Returns:** number

---

### `regex_replace(str, regex, replacement)`: string

Replaces a match.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |
| `regex` | regex | Regex object |
| `replacement` | string | Replacement string |

**Returns:** string

---

### `regex_replace_all(str, regex, replacement)`: string

Replaces all matches.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |
| `regex` | regex | Regex object |
| `replacement` | string | Replacement string |

**Returns:** string

---

### `regex_split(str, regex)`: array

Splits a string by the regex.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |
| `regex` | regex | Regex object |

**Returns:** array

---

