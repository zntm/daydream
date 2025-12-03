function function_parse(_data)
{
    var _length = array_length(_data);
    var _functions = [];
    
    for (var i = 0; i < _length; ++i)
    {
        var _ = _data[i];
        
        _functions[@ i] = [
            _[$ "chance"],      // [0] = chance (can be undefined)
            _[$ "id"],          // [1] = function id
            _[$ "parameters"],  // [2] = parameters object
            _[$ "repeat"],      // [3] = repeat count (can be undefined)
        ];
    }
    
    return _functions;
}