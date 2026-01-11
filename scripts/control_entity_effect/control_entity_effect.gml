function control_entity_effect()
{
    var _effects = effects;
    var _names = struct_get_names(_effects);
    var _names_length = array_length(_names);
    
    if (_names_length == 0) exit;
    
    var _effect_data = global.effect_data;
    var _effect_data = global.effect_data;
    var _refresh_buffs = false;
    
    for (var i = 0; i < _names_length; ++i)
    {
        var _name = _names[i];
        var _inst = _effects[$ _name];
        var _data = _effect_data[$ _name];
        
        // Timer
        _inst.timer--;
        
        // Check for effect end
        if (_inst.timer <= 0)
        {
            // Trigger on_end before removal
            if (_data != undefined)
            {
                var _on_end = _data.get_on_end();
                
                if (_on_end != undefined)
                {
                    var _params = variable_clone(_on_end[$ "parameters"] ?? {});
                    _params[$ "target"] = id;
                    _params[$ "effect_name"] = _name;
                    _params[$ "level"] = _inst.level;
                    
                    function_execute({ id: _on_end.id, parameters: _params }, x, y, CHUNK_DEPTH_DEFAULT, 1, 1, id);
                }
            }
            
            struct_remove(_effects, _name);
            _refresh_buffs = true;
            continue;
        }
        
        if (_data == undefined) continue;
        
        // on_interval: Fires every N ticks
        var _on_interval = _data.get_on_interval();
        
        if (_on_interval != undefined)
        {
            var _tick = _on_interval.tick ?? 20;
            
            if (_inst.timer % _tick == 0)
                {
                    var _params = variable_clone(_on_interval[$ "parameters"] ?? {});
                    _params[$ "target"] = id;
                    _params[$ "effect_name"] = _name;
                    _params[$ "level"] = _inst.level;
                    
                    function_execute({ id: _on_interval.id, parameters: _params }, x, y, CHUNK_DEPTH_DEFAULT, 1, 1, id);
                }
        }
        
        // on_chance: Fires with a random chance each tick
        var _on_chance = _data.get_on_chance();
        
        if (_on_chance != undefined)
        {
            var _chance = _on_chance.chance ?? 0.1;
            
            if (random(1) < _chance)
            {
                var _params = variable_clone(_on_chance[$ "parameters"] ?? {});
                _params[$ "target"] = id;
                _params[$ "effect_name"] = _name;
                _params[$ "level"] = _inst.level;
                
                function_execute({ id: _on_chance.id, parameters: _params }, x, y, CHUNK_DEPTH_DEFAULT, 1, 1, id);
            }
        }
        
        // Particles
        if (_inst.particle)
        {
            var _particle = _data.get_particle();
            
            if (_particle != undefined) && (random(1) < _particle.chance)
            {
                var _x = x + ((random(1) - 0.5) * 8);
                var _y = y + ((random(1) - 0.5) * 8);
                var _z = variable_instance_exists(id, "z") ? z : CHUNK_DEPTH_DEFAULT;
                
                var _id = _particle.id;
                var _colour = _particle.colour;
                
                spawn_particle(_x, _y, _id, _colour);
            }
        }
    }
    
    if (_refresh_buffs)
    {
        if (object_index == obj_Creature)
        {
            get_buffs(global.creature_data[$ creature_id].attributes);
        }
        else if (object_index == obj_Player)
        {
            get_buffs(global.attribute_player);
        }
    }
}
