enum WORLDGEN_CAVE_TRANSITION_TYPE {
    LINEAR,
    RANDOM,
    SPIKE
}

function worldgen_get_biome_cave(_x, _y, _surface_height, _seed)
{
    var _surface_offset = worldgen_get_surface_noise_offset(_x, _seed);
    
    if (_y <= _surface_height + _surface_offset)
    {
        return undefined;
    }
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _default = _world_data.get_cave_biome_default();
    var _default_length = _world_data.get_cave_biome_default_length();
    
    for (var i = 0; i < _default_length; ++i)
    {
        var _data = _default[i];
        var _start = _data.start;
        
        if (_y < _start) continue;
        
        var _transition = _data.transition;
        
        var _type = _transition.type;
        
        // if (_type == WORLDGEN_CAVE_TRANSITION_TYPE.RANDOM)
        if (_type == "random")
        {
            var _ = _seed + ((((_x * _y) + (i << 9)) * 244) * ((_y & 0xf) * 188));
            
            if (_y < round(_start + _transition.min + random_seeded(_transition.max - _transition.min, _))) continue;
            
            return _data.id;
        }
        
        var _end = _data[$ "end"];
        
        if (_y < _end)
        {
            return _data.id;
        }
        
        /*
        if (_type == "phantasia:linear")
        {
            if (_y >= _range_max + (noise(_x, _y, _world_data.get_default_cave_transition_octaves(i), _seed - (1024 * i)) * _world_data.get_default_cave_transition_amplitude(i))) continue;
            
            return _world_data.get_default_cave_id(i);
        }
        */
    }
    
    return undefined;
}