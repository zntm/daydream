enum WORLDGEN_CAVE_TRANSITION_TYPE {
    LINEAR,
    RANDOM,
    SPIKE
}

function worldgen_get_biome_cave(_x, _y, _surface_height, _seed)
{
    var _surface_offset = worldgen_get_surface_offset(_x, _seed);
    
    if (_y <= _surface_height + _surface_offset)
    {
        return undefined;
    }
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _default_length = _world_data.get_default_cave_length();
    
    for (var i = 0; i < _default_length; ++i)
    {
        var _start = _world_data.get_default_cave_start(i);
        
        if (_y < _start) continue;
        
        var _type = _world_data.get_default_cave_transition_type(i);
        
        if (_type == WORLDGEN_CAVE_TRANSITION_TYPE.RANDOM)
        {
            if (_y < _start + random_seeded(_world_data.get_default_cave_transition_amplitude(i), _seed + ((((_x * _y) + (i << 9)) * 244) * ((_y & 0xf) * 188)))) continue;
            
            return _world_data.get_default_cave_id(i);
        }
        
        var _end = _world_data.get_default_cave_end(i);
        
        if (_y < _end)
        {
            return _world_data.get_default_cave_id(i);
        }
        
        /*
        if (_type == "phantasia:linear")
        {
            if (_y >= _range_max + (noise(_x, _y, _world_data.get_default_cave_transition_octave(i), _seed - (1024 * i)) * _world_data.get_default_cave_transition_amplitude(i))) continue;
            
            return _world_data.get_default_cave_id(i);
        }
        */
    }
    
    return undefined;
}