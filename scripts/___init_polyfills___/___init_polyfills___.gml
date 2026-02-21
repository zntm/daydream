/// @desc Polyfills for modern GML functions to ensure backwards compatibility.

/* 
 * array_fill polyfill 
 * fills a section of an array with a value
 */
function array_fill(_array, _index, _count, _value)
{
    for (var i = _index + _count - 1; i >= _index; --i)
    {
        _array[@ i] = _value;
    }
}

/* 
 * array_get_index polyfill
 * returns the first index of a value in an array, or -1 if not found
 */
function array_get_index(_array, _value)
{
    for (var i = array_length(_array) - 1; i >= 0; --i)
    {
        if (_array[i] == _value)
        {
            return i;
        }
    }
    
    return -1;
}

/* 
 * array_contains polyfill
 * returns true if an array contains a value
 */
function array_contains(_array, _value)
{
    return (array_get_index(_array, _value) != -1);
}
