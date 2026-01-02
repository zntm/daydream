function function_execute(_function, _x, _y, _z, _xscale, _yscale, _inst = undefined, _item = undefined)
{
    // Handle simplified JSON object structure
    // { "id": "...", "chance": 0.1, "parameters": { ... } }
    
    // show_debug_message(_function);
    
    if (!is_struct(_function)) exit;
    
    var _chance = _function[$ "chance"];
    
    if (_chance != undefined) && (!chance(_chance)) exit;
    
    var _id = _function[$ "id"];
    
    if (_id != undefined)
    {
        // Proglang Script Execution (@ prefix indicates script file)
        if (string_char_at(_id, 1) == "@")
        {/*
            var _script_path = string_delete(_id, 1, 1); // Remove "@"
            
            // Convert namespace:path to file path
            var _colon_pos = string_pos(":", _script_path);
            if (_colon_pos > 0)
            {
                _script_path = string_delete(_script_path, 1, _colon_pos); // Remove namespace prefix
            }
            
            var _filepath = $"{PROGLANG_BASE_DIR}/{_script_path}.daydream";
            /*
            // show_debug_message(_filepath);
            
            // Load and execute the script
            if (file_exists(_filepath))
            {
                var _tx = round(_x / TILE_SIZE);
                var _ty = round(_y / TILE_SIZE);
                
                var _source = buffer_load_text(_filepath);
                
                var _context = {}
                
                if (_inst != undefined) && (instance_exists(_inst))
                {
                    _context.type = "unknown";
                    
                    if (_inst.object_index == obj_Player) _context.type = "player";
                    else if (object_is_ancestor(_inst.object_index, obj_Creature) || _inst.object_index == obj_Creature) _context.type = "creature";
                    else if (object_is_ancestor(_inst.object_index, obj_Projectile) || _inst.object_index == obj_Projectile) _context.type = "projectile";
                    
                    _context.entity_x = _inst.x / TILE_SIZE;
                    _context.entity_y = _inst.y / TILE_SIZE;
                    
                    if (variable_instance_exists(_inst, "physics_body"))
                    {
                        var _pb = _inst.physics_body;
                        _context.velocity = { x: _pb.vel_x, y: _pb.vel_y }
                    }
                    else
                    {
                        _context.velocity = { x: 0, y: 0 }
                    }
                    
                    if (variable_instance_exists(_inst, "effects"))
                    {
                        _context.effects = _inst.effects;
                    }
                    
                    // If the entity has its own inventory, we could expose it here
                    // For now, Player uses global.inventory
                }
                else if (instance_exists(obj_Player))
                {
                     // Fallback for backward compatibility or strict tile context? 
                     // The original code set _context.player = obj_Player
                     _context.player = obj_Player;
                }
                else
                {
                    _context = {
                        x: _tx,
                        y: _ty,
                        z: _z,
                        xscale: _xscale,
                        yscale: _yscale,
                        // dt: 1,
                        parameter: _function[$ "parameters"] ?? {},
                        tile: tile_get(_tx, _ty, _z),
                        item: _item,
                        inventory: global.inventory
                    }
                }
                
                proglang_execute(_source, _context, _filepath);
            }
            else if (IS_DEVELOPER_MODE)
            {
                show_debug_message($"[Daydream] Script not found: {_filepath}");
            }
            */
            exit;
        }
        
        /*
        // Native GML Function Execution
        var _item_function = global.item_function;
        var _f = _item_function[$ _id];
        var _parameter = _function[$ "parameters"];
        var _repeat = _function[$ "repeat"];
        
        if (_f != undefined)
        {
            if (_repeat == undefined)
            {
                _f(1, _x, _y, _z, _xscale, _yscale, _parameter);
            }
            else
            {
                repeat (smart_value(_repeat))
                {
                    _f(1, _x, _y, _z, _xscale, _yscale, _parameter);
                }
            }
        }*/
    }
}