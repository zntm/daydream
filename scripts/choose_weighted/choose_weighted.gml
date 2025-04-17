/// @func choose_weighted(args_or_array)
/// @desc Returns a random value with weight.
/// @arg {Any} _data Set any value with the weight in the next argument or use an array.
/// @return {Any}
function choose_weighted(_data)
{
	var _length = array_length(_data);
	
    var _random = 0;
    
    for (var i = 1; i < _length; i += 2)
    {
		_random += _data[i];
    }
    
	_random = random(_random);
	
    for (var i = 0; i < _length; i += 2)
    {
		_random -= _data[i + 1];
        
        if (_random < 0)
        {
            return _data[i];
        }
    }
	
	return _array[0];
}