enum SMART_VALUE_TYPE {
    CHOOSE,
    CHOOSE_WEIGHTED,
    RANDOM,
    IRANDOM
}

function smart_value_parse(_data)
{
    if (!is_struct(_data))
    {
        return _data;
    }
    
    var _type = _data[$ "type"];
    
    if (_type == "smart_value:choose")
    {
        return new SmartValue(SMART_VALUE_TYPE.CHOOSE, _data.values);
    }
    
    if (_type == "smart_value:choose_weighted")
    {
        return new SmartValue(SMART_VALUE_TYPE.CHOOSE_WEIGHTED, choose_weighted_parse(_data.values));
    }
    
    if (_type == "smart_value:concat")
    {
        var _array = [];
        
        var _values = _data.values;
        var _values_length = array_length(_values);
        
        for (var i = 0; i < _values_length; ++i)
        {
            var _value = _values[i];
            
            if (is_array(_value))
            {
                _array = array_concat(_array, _value);
            }
            else
            {
            	array_push(_array, _value);
            }
        }
        
        return _array;
    }
    
    if (_type == "smart_value:irandom") || (_type == "smart_value:random")
    {
        var _values = _data.values;
        
        return new SmartValue(SMART_VALUE_TYPE.CHOOSE_WEIGHTED, [ _values.min, _values.max ]);
    }
    
    return _data;
}