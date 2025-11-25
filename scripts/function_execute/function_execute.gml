function function_execute(_function, _x, _y, _z, _xscale, _yscale, _dt)
{
    var _chance = _function[0];
    
    if (_chance != undefined) && (!chance(_chance * _dt)) exit;
    
    var _item_function = global.item_function;
    
    var _functions = _function[1];
    var _functions_length = array_length(_functions);
    
    for (var i = 0; i < _functions_length; ++i)
    {
        var _ = _functions[i];
        
        var _id = _[0];
        
        if (_id != undefined)
        {
            var _f = _item_function[$ _id];
            var _parameter = _[1];
            
            repeat (smart_value(_[2]))
            {
                _f(_dt, _x, _y, _z, _xscale, _yscale, _parameter);
            }
        }
    }
}