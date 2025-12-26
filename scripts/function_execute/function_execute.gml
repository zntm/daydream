function function_execute(_function, _x, _y, _z, _xscale, _yscale, _dt)
{
    var _chance = _function[0];
    
    if (_chance != undefined) && (!chance(_chance * _dt)) exit;
    
    var _item_function = global.item_function;
    var _id = _function[1];
    
    if (_id != undefined)
    {
        // Proglang Script Execution
        if (string_pos("$proglang:", _id) == 1)
        {
            var _source = string_delete(_id, 1, 10); // Remove "$proglang:"
            var _context = {
                x: _x,
                y: _y,
                z: _z,
                xscale: _xscale,
                yscale: _yscale,
                dt: _dt,
                parameter: _function[2] 
            };
            
            // Pass common game objects to context if needed, or rely on global access
            // Maybe add 'player' to context explicitly?
            if (instance_exists(obj_Player)) _context.player = obj_Player;
            
            proglang_execute(_source, _context);
            exit;
        }

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