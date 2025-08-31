function function_execute(_function, _x, _y, _z, _dt)
{
    if (!chance(_function[0] * _dt)) exit;
    
    var _random_tick_length = _function[1];
    
    var _ = _function[2];
    
    var _id = _[0];
    
    if (_id != undefined)
    {
        var _f = global.item_function[$ _id];
        var _parameter = _[1];
        
        repeat (smart_value(_[2]))
        {
            _f(_dt, _x, _y, _z, _parameter);
        }
    }
}