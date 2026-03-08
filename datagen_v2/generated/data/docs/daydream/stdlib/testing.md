# Testing

### `test_group(name, tests)`: void

Defines a new group of tests.

**Arguments:**
| Name    | Type   | Description         |
| ------- | ------ | ------------------- |
| `name`  | string | Name of the group   |
| `tests` | array  | Array of test cases |

**Returns:** void

---

### `test(name, callback)`: void

Defines a test case within a group.

**Arguments:**
| Name       | Type     | Description      |
| ---------- | -------- | ---------------- |
| `name`     | string   | Name of the test |
| `callback` | function | Test logic       |

**Returns:** void

---

### `test_expect(actual, expected)`: void

Asserts that two values are equal.

**Arguments:**
| Name       | Type | Description        |
| ---------- | ---- | ------------------ |
| `actual`   | any  | The value to test  |
| `expected` | any  | The expected value |

**Returns:** void

---

### `assert(condition, [message])`: void

Throws an error if the condition is false.

**Arguments:**
| Name        | Type    | Description              |
| ----------- | ------- | ------------------------ |
| `condition` | boolean | Condition to check       |
| `message`   | string  | Optional failure message |

**Returns:** void

---
