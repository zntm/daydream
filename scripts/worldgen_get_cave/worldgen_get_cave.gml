function worldgen_get_cave(_x, _y, _surface_height, _cave_start, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    if (_y < _surface_height)
    {
        return true;
    }
    
    if (_y < _surface_height + _cave_start + _world_data.get_cave_start_min())
    {
        return false;
    }
    
    var _system = _world_data.get_cave_system();
    var _system_length = _world_data.get_cave_system_length();
    
    for (var i = 0; i < _system_length; ++i)
    {
        var _ = _system[i];
        
        var _octaves = _.threshold.octaves;
        
        var _noise = open_simplex_noise(_x / 64, (_y / 64) + ((0xffff * (i + 1)) + 8), 0xff, _octaves);
        
        if (_noise >= _.range_min) && (_noise < _.range_max)
        {
            return true;
        }
    }
    
    return false;
}