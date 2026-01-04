# Testing

### `test(name, fn, stop_on_fail)`: void

Registers a test case.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | string | Test name |
| `fn` | function | Test function |
| `stop_on_fail` | boolean | Stop remaining tests if this fails (Optional) |

**Returns:** void

---

### `test_group(name, tests)`: void

Registers a group of tests.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | string | Group name |
| `tests` | array | Array of tests |

**Returns:** void

---

### `test_expect(actual, expected)`: boolean

Asserts that a value equals the expected value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `actual` | any | Actual value |
| `expected` | any | Expected value |

**Returns:** boolean

---

