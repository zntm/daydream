function smart_value(_value)
{
    if (!is_array(_value))
    {
        return _value;
    }
    
    var _type = _value[0];
    
    if (_type == SMART_VALUE_TYPE.CHOOSE)
    {
        return array_choose(_value[2], _value[1]);
    }
    
    if (_type == SMART_VALUE_TYPE.CHOOSE_WEIGHTED)
    {
        return choose_weighted(_value[1]);
    }
    
    if (_type == SMART_VALUE_TYPE.RANDOM)
    {
        return random_range(_value[1], _value[2]);
    }
    
    if (_type == SMART_VALUE_TYPE.IRANDOM)
    {
        return irandom_range(_value[1], _value[2]);
    }
}