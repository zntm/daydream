# Collections

### `array_length(arr)`: Number

Returns the number of elements in an array.

```javascript
var nums = [1, 2, 3];
print(array_length(nums)); // 3
```

### `array_push(arr, val)`: Undefined

Adds a value to the end of an array. Modifies the array in place.

```javascript
var list = [];
array_push(list, "Apple");
```

### `array_pop(arr)`: Any

Removes the last element from an array and returns it.

```javascript
var item = array_pop(list);
```

### `array_contains(arr, val)`: Boolean

Returns true if the array contains the specified value.

### `struct_get_names(obj)`: Array

Returns an array of strings containing the names of the struct's properties.

```javascript
var p = { x: 10, y: 20 };
var keys = struct_get_names(p); // ["x", "y"]
```
