#macro WORLDGEN_CAVE_NOISE_SIZE 512

global.worldgen_noise_cave = {}

function worldgen_get_cave(_x, _y, _surface_height, _seed)
{
    var _world_data = global.world_data[$ global.world.dimension];
    
    var _x2 = floor(_x / WORLDGEN_CAVE_NOISE_SIZE);
    
    var _local_x = ((_x % WORLDGEN_CAVE_NOISE_SIZE) + WORLDGEN_CAVE_NOISE_SIZE) % WORLDGEN_CAVE_NOISE_SIZE;
    
    if (_y < _surface_height)
    {
        return true;
    }
    
    if (_y < _surface_height + _world_data.get_cave_start_min() + worldgen_get_cave_start(_x, _seed))
    {
        return false;
    }
    
    var _y2 = floor(_y / WORLDGEN_CAVE_NOISE_SIZE);
    
    var _local_y = ((_y % WORLDGEN_CAVE_NOISE_SIZE) + WORLDGEN_CAVE_NOISE_SIZE) % WORLDGEN_CAVE_NOISE_SIZE;
    
    var _system_length = _world_data.get_cave_system_length();
    
    for (var i = 0; i < _system_length; ++i)
    {
        var _index = $"{_x2}_{_y2}_{i}";
        var _buffer = global.worldgen_noise_cave[$ _index];
        
        if (_buffer == undefined)
        {
            var _octave = _world_data.get_cave_system_threshold_octave(i);
            var _roughness = _world_data.get_cave_system_threshold_roughness(i);
            
            _buffer = new Noise(_x2 * WORLDGEN_CAVE_NOISE_SIZE, _y2 * WORLDGEN_CAVE_NOISE_SIZE, WORLDGEN_CAVE_NOISE_SIZE, WORLDGEN_CAVE_NOISE_SIZE, 255, _octave, _roughness, _seed - (i * 512));
            
            global.worldgen_noise_cave[$ _index] = _buffer;
        }
        
        var _noise = _buffer.get(_local_x, _local_y);
        
        if (_noise >= _world_data.get_cave_system_threshold_min(i)) && (_noise < _world_data.get_cave_system_threshold_max(i))
        {
            return true;
        }
    }
    
    return false;
}