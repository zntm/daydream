# System & Environment

## Functions

### `print(values)`: void

Prints values to the debug console.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `values` | any | Values to print (Optional) |

**Returns:** void

```javascript
print("Hello", 123);
```

---

### `event_emit(event_type, data)`: void

Emits an event.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `event_type` | string | Type of event |
| `data` | struct | Event data (Optional) |

**Returns:** void

---

### `event_subscribe(event_type, callback)`: number

Subscribes to an event.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `event_type` | string | Type of event |
| `callback` | function | Callback function |

**Returns:** number

---

### `event_unsubscribe(listener_id)`: void

Unsubscribes from an event.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `listener_id` | number | ID returned by event_subscribe |

**Returns:** void

---

### `time_start(name)`: void

Starts a timer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | string | Timer name |

**Returns:** void

---

### `time_end(name)`: number

Ends a timer and returns elapsed milliseconds.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | string | Timer name |

**Returns:** number

---

### `runtime_error(type, message)`: void

Throws a runtime error.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `type` | string | Error type |
| `message` | string | Error message |

**Returns:** void

---

### `assert(condition, message)`: void

Throws an error if the condition is false.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `condition` | boolean | Condition to check |
| `message` | string | Error message (Optional) |

**Returns:** void

---
