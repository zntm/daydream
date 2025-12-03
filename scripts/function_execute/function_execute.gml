function function_execute(_function, _x, _y, _z, _xscale, _yscale, _dt)
{
    var _chance = _function[0];
    
    if (_chance != undefined) && (!chance(_chance * _dt)) exit;
    
    var _item_function = global.item_function;
    var _id = _function[1];
    
    if (_id != undefined)
    {
        var _f = _item_function[$ _id];
        var _parameter = _function[2];
        var _repeat = _function[3];
        
        if (_repeat == undefined)
        {
            _f(_dt, _x, _y, _z, _xscale, _yscale, _parameter);
        }
        else
        {
            repeat (smart_value(_repeat))
            {
                _f(_dt, _x, _y, _z, _xscale, _yscale, _parameter);
            }
        }
    }
}