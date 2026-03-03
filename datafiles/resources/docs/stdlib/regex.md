# Regular Expressions

## Functions

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

```javascript
regex_test("hello", /h/);
```

---

### `regex_match(str, regex)`: array

Returns matches of the regex in the string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | String to match |
| `regex` | regex | Regex object |

**Returns:** array

```javascript
regex_match("hello", /l+/g);
```

---

### `regex_match_index(str, regex)`: number

Returns the index of the match.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | String to match |
| `regex` | regex | Regex object |

**Returns:** number

```javascript
regex_match_index("hello", /e/);
```

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

```javascript
regex_replace("hello", /l/, "L");
```

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

```javascript
regex_replace_all("ho ho ho", /ho/, "he");
```

---

### `regex_split(str, regex)`: array

Splits a string by the regex.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `str` | string | Input string |
| `regex` | regex | Regex object |

**Returns:** array

```javascript
regex_split("a,b,c", /,/);
```

---
