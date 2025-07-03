enum SMART_VALUE_TYPE {
    CHOOSE,
    CHOOSE_WEIGHTED,
    RANDOM,
    IRANDOM
}

function smart_value_parse(_value)
{
    static __type = {
        "choose":          SMART_VALUE_TYPE.CHOOSE,
        "choose_weighted": SMART_VALUE_TYPE.CHOOSE_WEIGHTED,
        "random":          SMART_VALUE_TYPE.RANDOM,
        "irandom":         SMART_VALUE_TYPE.IRANDOM,
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
    
    return _value;
}