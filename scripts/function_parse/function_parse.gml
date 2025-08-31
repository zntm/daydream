function function_parse(_data)
{
    var _length = array_length(_data);
    
    var _function = array_create(_length);
    
    for (var i = 0; i < _length; ++i)
    {
        var _ = _data[i];
        
        var _f = _[$ "function"];
        var _f_length = array_length(_f);
        
        _function[@ i] = [
            _[$ "chance"] ?? 1,
            _f_length
        ];
        
        for (var j = 0; j < _f_length; ++j)
        {
            var _a = _f[j];
            
            var _parameter = _a[$ "parameter"];
            var _parameters = {}
            
            var _parameter_names = struct_get_names(_parameter);
            var _parameter_length = array_length(_parameter_names);
            
            for (var l = 0; l < _parameter_length; ++l)
            {
                var _name = _parameter_names[l];
                
                _parameters[$ _name] = smart_value_parse(_parameter[$ _name]);
            }
            
            var _repeat = _[$ "repeat"];
            
            _function[@ i][@ 2] = [
                _a.id,
                _parameters,
                ((_repeat != undefined) ? smart_value_parse(_repeat) : 1)
            ];
        }
    }
    
    return _function;
}