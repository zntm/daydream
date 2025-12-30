function function_execute(_function, _x, _y, _z, _xscale, _yscale, _dt)
{
    // Handle simplified JSON object structure
    // { "id": "...", "chance": 0.1, "parameters": { ... } }
    
    // show_debug_message(_function);
    
    if (!is_struct(_function)) exit;
    
    var _chance = _function[$ "chance"];
    
    if (_chance != undefined) && (!chance(_chance * _dt)) exit;
    
    var _id = _function[$ "id"];
    
    if (_id != undefined)
    {
        // Proglang Script Execution (@ prefix indicates script file)
        if (string_char_at(_id, 1) == "@")
        {
            var _script_path = string_delete(_id, 1, 1); // Remove "@"
            
            // Convert namespace:path to file path
            var _colon_pos = string_pos(":", _script_path);
            if (_colon_pos > 0)
            {
                _script_path = string_delete(_script_path, 1, _colon_pos); // Remove namespace prefix
            }
            
            var _filepath = $"{PROGLANG_BASE_DIR}/{_script_path}.daydream";
            
            // show_debug_message(_filepath);
            
            // Load and execute the script
            if (file_exists(_filepath))
            {
                var _source = buffer_load_text(_filepath);
                var _context = {
                    x: _x,
                    y: _y,
                    z: _z,
                    xscale: _xscale,
                    yscale: _yscale,
                    dt: _dt,
                    parameter: _function[$ "parameters"] ?? {},
                    tile: tile_get(_x, _y, _z),
                    inventory: global.inventory
                }
                
                if (instance_exists(obj_Player)) _context.player = obj_Player;
                
                proglang_execute(_source, _context, _filepath);
            }
            else if (IS_DEVELOPER_MODE)
            {
                show_debug_message($"[Daydream] Script not found: {_filepath}");
            }
            
            exit;
        }
        
        // Native GML Function Execution
        var _item_function = global.item_function;
        var _f = _item_function[$ _id];
        var _parameter = _function[$ "parameters"];
        var _repeat = _function[$ "repeat"];
        
        if (_f != undefined)
        {
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
}