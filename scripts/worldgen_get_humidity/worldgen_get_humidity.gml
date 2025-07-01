#macro WORLDGEN_HUMIDITY_NOISE_SIZE 512

global.worldgen_noise_humidity = {}

function worldgen_get_humidity(_x, _y, _seed)
{
    var _x2 = floor(_x / WORLDGEN_HUMIDITY_NOISE_SIZE);
    var _y2 = floor(_y / WORLDGEN_HUMIDITY_NOISE_SIZE);
    
    var _index = $"{_x2}_{_y2}";
    var _buffer = global.worldgen_noise_humidity[$ _index];
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    
    if (_buffer == undefined)
    {
        var _octave = _world_data.get_surface_biome_humidity_octave();
        var _roughness = _world_data.get_surface_biome_humidity_roughness();
        
        _buffer = new Noise(_x2 * WORLDGEN_HUMIDITY_NOISE_SIZE, _y2 * WORLDGEN_HUMIDITY_NOISE_SIZE, WORLDGEN_HUMIDITY_NOISE_SIZE, WORLDGEN_HUMIDITY_NOISE_SIZE, WORLDGEN_SIZE_HUMIDITY, _octave, _roughness, _seed - 0x7fda);
        
        global.worldgen_noise_humidity[$ _index] = _buffer;
    }
    
    var _local_x = ((_x % WORLDGEN_HUMIDITY_NOISE_SIZE) + WORLDGEN_HUMIDITY_NOISE_SIZE) % WORLDGEN_HUMIDITY_NOISE_SIZE;
    var _local_y = ((_y % WORLDGEN_HUMIDITY_NOISE_SIZE) + WORLDGEN_HUMIDITY_NOISE_SIZE) % WORLDGEN_HUMIDITY_NOISE_SIZE;
    
    return round(_buffer.get(_local_x, _local_y));
}