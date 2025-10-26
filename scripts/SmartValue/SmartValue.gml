function SmartValue(_type, _values) constructor
{
    type = _type;
    values = _values;
    
    static get_type = function()
    {
        return type;
    }
    
    static get_values = function()
    {
        return values;
    }
}