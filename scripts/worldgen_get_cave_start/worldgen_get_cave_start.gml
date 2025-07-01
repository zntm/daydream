global.worldgen_noise_cave_start = {}

function worldgen_get_cave_start(_x, _seed)
{
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    var _x2 = floor(_x / WORLDGEN_CAVE_NOISE_SIZE);
    
    var _local_x = ((_x % WORLDGEN_CAVE_NOISE_SIZE) + WORLDGEN_CAVE_NOISE_SIZE) % WORLDGEN_CAVE_NOISE_SIZE;
    
    var _index = string(_x2);
    
    var _buffer_start = global.worldgen_noise_cave_start[$ _index];
    
    if (_buffer_start == undefined)
    {
        var _amplitude = _world_data.get_cave_start_max() - _world_data.get_cave_start_min();
        var _octave = _world_data.get_cave_start_octave();
        var _roughness = _world_data.get_cave_start_roughness();
        
        _buffer_start = new Noise(_x2 * WORLDGEN_CAVE_NOISE_SIZE, 0x10f9, WORLDGEN_CAVE_NOISE_SIZE, 1, _amplitude, _octave, _roughness, _seed);
        
        global.worldgen_noise_cave_start[$ _index] = _buffer_start;
    }
    
    return _buffer_start.get(_local_x, 0);
}