function control_entity_effect()
{
    var _effects = effects;
    var _names = struct_get_names(_effects);
    var _names_length = array_length(_names);
    
    if (_names_length == 0) exit;
    
    var _effect_data = global.effect_data;
    var _refresh_buffs = false;
    
    for (var i = 0; i < _names_length; ++i)
    {
        var _name = _names[i];
        var _inst = _effects[$ _name];
        
        // Timer
        _inst.timer--;
        
        if (_inst.timer <= 0)
        {
            struct_remove(_effects, _name);
            _refresh_buffs = true;
            continue;
        }
        
        // Particles
        if (_inst.particle)
        {
            var _data = _effect_data[$ _name];
            var _particle = _data.get_particle();
            
            if (_particle != undefined) && (random(1) < _particle.chance)
            {
                var _x = x + ((random(1) - 0.5) * 8); // Simple offset, improve with bbox later
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
