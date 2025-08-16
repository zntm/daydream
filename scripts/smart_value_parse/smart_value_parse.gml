enum SMART_VALUE_TYPE {
    CHOOSE,
    CHOOSE_WEIGHTED,
    RANDOM,
    IRANDOM,
    CONCAT
}

function smart_value_parse(_value)
{
    static __type = {
        "choose":          SMART_VALUE_TYPE.CHOOSE,
        "choose_weighted": SMART_VALUE_TYPE.CHOOSE_WEIGHTED,
        "random":          SMART_VALUE_TYPE.RANDOM,
        "irandom":         SMART_VALUE_TYPE.IRANDOM,
        "concat":          SMART_VALUE_TYPE.CONCAT
    }
    
    if (!is_struct(_value))
    {
        return _value;
    }
    
    var _type = __type[$ _value.type];
    
    if (_type == SMART_VALUE_TYPE.CHOOSE)
    {
        var _values = _value.values;
        
        return [
            _type,
            array_length(_values),
            _values
        ];
    }
    
    if (_type == SMART_VALUE_TYPE.CHOOSE_WEIGHTED)
    {
        var _values = _value.values;
        
        return [
            _type,
            choose_weighted_parse(_values)
        ];
    }
    
    if (_type == SMART_VALUE_TYPE.RANDOM) || (_type == SMART_VALUE_TYPE.IRANDOM)
    {
        var _values = _value.values;
        
        return [
            _type,
            _values.min,
            _values.max,
        ];
    }
    
    if (_type == SMART_VALUE_TYPE.CONCAT)
    {
        var _data = [];
        
        var _values = _value.values;
        var _values_length = array_length(_values);
        
        for (var i = 0; i < _values_length; ++i)
        {
            var _ = _values[i];
            
            if (is_array(_))
            {
                _data = array_concat(_data, _);
            }
            else
            {
            	array_push(_data, _);
            }
        }
        
        return [
            _type,
            _data
        ];
    }
    
    return _value;
}