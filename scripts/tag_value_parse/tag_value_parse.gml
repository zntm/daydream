global.tag_value = {}

function tag_value_parse(_data)
{
    if (!is_string(_data))
    {
        if (is_array(_data))
        {
            var _tag_data = [];
            
            var _length = array_length(_data);
            
            for (var i = 0; i < _length; ++i)
            {
                _tag_data[@ i] = tag_value_parse(_data[i]);
            }
            
            return _tag_data;
        }
        else if (is_struct(_data))
        {
            var _tag_data = {}
            
            var _names = struct_get_names(_data);
            var _length = array_length(_names);
            
            for (var i = 0; i < _length; ++i)
            {
                var _name = _names[i];
                
                _tag_data[$ _name] = tag_value_parse(_data[$ _name]);
            }
            
            return _tag_data;
        }
        
        return _data;
    }
    
    if (!string_starts_with(_data, "#"))
    {
        return _data;
    }
    
    var _tag_value = global.tag_value[$ _data];
    
    if (_tag_value != undefined)
    {
        return _tag_value;
    }
    
    var _tag_data = global.tag_data[$ _data];
    
    if (_tag_data == undefined)
    {
        return _data;
    }
    
    if (is_array(_tag_data))
    {
        var _length = array_length(_tag_data);
        
        for (var i = 0; i < _length; ++i)
        {
            _tag_data[@ i] = tag_value_parse(_tag_data[i]);
        }
    }
    else if (is_struct(_tag_data))
    {
        var _names = struct_get_names(_tag_data);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            
            _tag_data[$ _name] = tag_value_parse(_tag_data[$ _name]);
        }
    }
    
    global.tag_value[$ _data] = _tag_data;
    
    return _tag_data;
}