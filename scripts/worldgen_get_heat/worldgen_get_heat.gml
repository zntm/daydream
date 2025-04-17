#macro WORLDGEN_HEAT_NOISE_SIZE 512

global.worldgen_noise_heat = {}

function worldgen_get_heat(_x, _y, _seed)
{
    var _x2 = floor(_x / WORLDGEN_HEAT_NOISE_SIZE);
    var _y2 = floor(_y / WORLDGEN_HEAT_NOISE_SIZE);
    
    var _index = $"{_x2}_{_y2}";
    var _buffer = global.worldgen_noise_heat[$ _index];
    
    var _world_data = global.world_data[$ global.world.dimension];
    
    if (_buffer == undefined)
    {
        var _octave = _world_data.get_surface_biome_heat_octave();
        var _roughness = _world_data.get_surface_biome_heat_roughness();
    
        _buffer = new Noise(_x2 * WORLDGEN_HEAT_NOISE_SIZE, _y2 * WORLDGEN_HEAT_NOISE_SIZE, WORLDGEN_HEAT_NOISE_SIZE, WORLDGEN_HEAT_NOISE_SIZE, WORLDGEN_SIZE_HEAT, _octave, _roughness, _seed);
        
        global.worldgen_noise_heat[$ _index] = _buffer;
    }
    
    var _local_x = ((_x % WORLDGEN_HEAT_NOISE_SIZE) + WORLDGEN_HEAT_NOISE_SIZE) % WORLDGEN_HEAT_NOISE_SIZE;
    var _local_y = ((_y % WORLDGEN_HEAT_NOISE_SIZE) + WORLDGEN_HEAT_NOISE_SIZE) % WORLDGEN_HEAT_NOISE_SIZE;
    
    return round(_buffer.get(_local_x, _local_y));
}