# Regular Expressions

Daydream supports native regular expressions for pattern matching and text manipulation.

## Creating Regex

### `regex_parse(pattern, flags?)`: Regex

Creates a regex object from a pattern string and optional flags.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `pattern` | String | The regex pattern |
| `flags` | String | Optional. Flags like `"g"` (global), `"i"` (case-insensitive) |

**Returns:** A regex object that can be used with other regex functions.

```javascript
var email_pattern = regex_parse("[a-z]+@[a-z]+\\.[a-z]+", "i");
```

---

## Testing Patterns

### `regex_test(string, regex)`: Boolean

Tests if a string matches the regex pattern.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `string` | String | The string to test |
| `regex` | Regex | A regex object from `regex_parse` |

**Returns:** `true` if the pattern matches, `false` otherwise.

```javascript
var pattern = regex_parse("^hello", "i");
var result = regex_test("Hello World", pattern); // true
```

---

## Matching

### `regex_match(string, regex)`: Array | undefined

Returns an array of matches, or `undefined` if no match.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `string` | String | The string to search |
| `regex` | Regex | A regex object from `regex_parse` |

**Returns:** Array of matched strings, or `undefined`.

```javascript
var pattern = regex_parse("\\d+", "g");
var matches = regex_match("abc123def456", pattern); // ["123", "456"]
```

### `regex_match_index(string, regex)`: Number

Returns the index of the first match, or -1 if no match.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `string` | String | The string to search |
| `regex` | Regex | A regex object from `regex_parse` |

**Returns:** Index of first match (0-based), or `-1`.

```javascript
var pattern = regex_parse("world", "i");
var idx = regex_match_index("Hello World", pattern); // 6
```

---

## Replacing

### `regex_replace(string, regex, replacement)`: String

Replaces matched text with the replacement string.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `string` | String | The original string |
| `regex` | Regex | A regex object from `regex_parse` |
| `replacement` | String | The replacement text |

**Returns:** A new string with replacements made.

```javascript
var pattern = regex_parse("\\s+", "g");
var result = regex_replace("hello   world", pattern, " "); // "hello world"
```

> [!TIP]
> Use the `"g"` flag in your regex to replace all occurrences, not just the first.

---

## Splitting

### `regex_split(string, regex)`: Array

Splits a string by the regex pattern.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `string` | String | The string to split |
| `regex` | Regex | A regex object from `regex_parse` |

**Returns:** Array of substrings.

```javascript
var pattern = regex_parse("[,;]\\s*");
var parts = regex_split("apple, banana; cherry", pattern);
// ["apple", "banana", "cherry"]
```
