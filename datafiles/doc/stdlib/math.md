# Math Functions

### `floor(n)`: number

Rounds down to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Value to round down |

**Returns:** number

```javascript
floor(3.9); // 3
```

---

### `ceil(n)`: number

Rounds up to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Value to round up |

**Returns:** number

```javascript
ceil(3.1); // 4
```

---

### `round(n)`: number

Rounds to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Value to round |

**Returns:** number

```javascript
round(3.6); // 4
```

---

### `abs(n)`: number

Returns the absolute value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

```javascript
abs(-5); // 5
```

---

### `sign(n)`: number

Returns the sign of a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

```javascript
sign(-50); // -1
```

---

### `min(a, b)`: number

Returns the smaller of two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | number | First value |
| `b` | number | Second value |

**Returns:** number

```javascript
min(10, 5); // 5
```

---

### `max(a, b)`: number

Returns the larger of two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | number | First value |
| `b` | number | Second value |

**Returns:** number

```javascript
max(10, 5); // 10
```

---

### `clamp(val, min, max)`: number

Constrains a value between min and max.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | number | Value to constrain |
| `min` | number | Minimum bound |
| `max` | number | Maximum bound |

**Returns:** number

```javascript
clamp(15, 0, 10); // 10
```

---

### `lerp(a, b, t)`: number

Linearly interpolates between two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | number | Start value |
| `b` | number | End value |
| `t` | number | Interpolation factor (0-1) |

**Returns:** number

```javascript
lerp(0, 100, 0.5); // 50
```

---

### `power(base, exp)`: number

Returns base raised to the power of exp.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `base` | number | The base |
| `exp` | number | The exponent |

**Returns:** number

```javascript
power(2, 3); // 8
```

---

### `sqrt(n)`: number

Returns the square root.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Value (must be >= 0) |

**Returns:** number

```javascript
sqrt(16); // 4
```

---

### `sqr(n)`: number

Returns the square of a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Value to square |

**Returns:** number

```javascript
sqr(5); // 25
```

---

### `frac(n)`: number

Returns the fractional part of a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

```javascript
frac(3.75); // 0.75
```

---

### `sin(x)`: number

Returns sine of x in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians |

**Returns:** number

---

### `cos(x)`: number

Returns cosine of x in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians |

**Returns:** number

---

### `tan(x)`: number

Returns tangent of x in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in radians |

**Returns:** number

---

### `dsin(x)`: number

Returns sine of x in degrees.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in degrees |

**Returns:** number

---

### `dcos(x)`: number

Returns cosine of x in degrees.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in degrees |

**Returns:** number

---

### `dtan(x)`: number

Returns tangent of x in degrees.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Angle in degrees |

**Returns:** number

---

### `degtorad(deg)`: number

Converts degrees to radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `deg` | number | Degrees |

**Returns:** number

---

### `radtodeg(rad)`: number

Converts radians to degrees.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `rad` | number | Radians |

**Returns:** number

---

### `lengthdir_x(len, dir)`: number

Returns the horizontal component of a vector.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `len` | number | Vector length |
| `dir` | number | Direction in degrees |

**Returns:** number

---

### `lengthdir_y(len, dir)`: number

Returns the vertical component of a vector.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `len` | number | Vector length |
| `dir` | number | Direction in degrees |

**Returns:** number

---

### `point_distance(x1, y1, x2, y2)`: number

Returns the distance between two points.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x1` | number | X of point 1 |
| `y1` | number | Y of point 1 |
| `x2` | number | X of point 2 |
| `y2` | number | Y of point 2 |

**Returns:** number

---

### `point_direction(x1, y1, x2, y2)`: number

Returns the direction from point 1 to point 2.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x1` | number | X of point 1 |
| `y1` | number | Y of point 1 |
| `x2` | number | X of point 2 |
| `y2` | number | Y of point 2 |

**Returns:** number

---

### `exp(n)`: number

Returns e^n.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Exponent |

**Returns:** number

---

### `ln(x)`: number

Returns the natural logarithm function of x.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value |

**Returns:** number

---

### `log2(n)`: number

Returns the base-2 logarithm.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

---

### `log10(n)`: number

Returns the base-10 logarithm.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | number | Input value |

**Returns:** number

---

### `arcsin(x)`: number

Returns the arcsine in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value |

**Returns:** number

---

### `arccos(x)`: number

Returns the arccosine in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value |

**Returns:** number

---

### `arctan(x)`: number

Returns the arctangent in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x` | number | Input value |

**Returns:** number

---

### `arctan2(y, x)`: number

Returns the angle from origin to (x, y) in radians.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `y` | number | Y coordinate |
| `x` | number | X coordinate |

**Returns:** number

---

