function function_execute(_function, _x, _y, _z, _xscale, _yscale, _inst = undefined, _item = undefined)
{
    // Handle simplified JSON object structure
    // { "id": "...", "chance": 0.1, "parameters": { ... } }
    
    // show_debug_message(_function);
    
    if (!is_struct(_function)) exit;
    
    var _chance = _function[$ "chance"];
    
    if (_chance != undefined) && (!chance(_chance)) exit;
    
    var _id = _function[$ "id"];
    if (_id != undefined && string_pos("@", _id) == 1) _id = string_delete(_id, 1, 1);
    var _parameter = _function[$ "parameters"] ?? {}
    
    // Build Context
    var _tx = round(_x / TILE_SIZE);
    var _ty = round(_y / TILE_SIZE);
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
    }
    else if (instance_exists(obj_Player))
    {
        _context.player = obj_Player;
    }
    
    show_debug_message(_function);
    
    // Always provide spatial context
    _context.caller = _inst;
    _context.x = _tx;
    _context.y = _ty;
    _context.z = _z;
    _context.xscale = _xscale;
    _context.yscale = _yscale;
    _context.tile = tile_get(_tx, _ty, _z);
    _context.item = _item;
    _context.inventory = global.inventory;
    
    if (_id != undefined)
    {
        _context.parameter = _parameter;
        
        show_debug_message(global.proglang_scripts[$ _id]);
        
        // Handle direct script call
        if (struct_exists(global.proglang_scripts, _id))
        {
            proglang_call(_id, [_parameter], _context);
        }
        else if (IS_DEVELOPER_MODE)
        {
            // Debugging aid
            // show_debug_message(struct_get_names(global.proglang_scripts));
            show_debug_message($"[Daydream] Script not found: '{_id}'");
            show_debug_message(global.proglang_scripts)
        }
    }
}