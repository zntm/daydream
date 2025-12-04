function smart_value(_data)
{
    if (!is_struct(_data)) || (instanceof(_data) != "SmartValue")
    {
        return _data;
    }
    
    var _type = _data.get_type();
    
    if (_type == SMART_VALUE_TYPE.CHOOSE)
    {
        return array_choose(_data.get_values());
    }
    
    if (_type == SMART_VALUE_TYPE.CHOOSE_WEIGHTED)
    {
        return choose_weighted(_data.get_values());
    }
    
    if (_type == SMART_VALUE_TYPE.RANDOM)
    {
        var _values = _data.get_values();
        
        return random_range(_values[0], _values[1]);
    }
    
    if (_type == SMART_VALUE_TYPE.IRANDOM)
    {
        var _values = _data.get_values();
        
        return irandom_range(_values[0], _values[1]);
    }
    
    return _data;
}