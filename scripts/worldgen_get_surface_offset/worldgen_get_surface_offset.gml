#macro WORLDGEN_SURFACE_OFFSET_NOISE_SIZE 512

global.worldgen_noise_surface_offset = {}

function worldgen_get_surface_offset(_x, _seed)
{
    var _x2 = floor(_x / WORLDGEN_SURFACE_OFFSET_NOISE_SIZE);
    
    var _index = string(_x2);
    var _buffer = global.worldgen_noise_surface_offset[$ _index];
    
    var _world_data = global.world_data[$ global.world.dimension];
    
    if (_buffer == undefined)
    {
        _buffer = new Noise(_x2 * WORLDGEN_SURFACE_OFFSET_NOISE_SIZE, 0x23ee, WORLDGEN_SURFACE_OFFSET_NOISE_SIZE, 1, _world_data.get_surface_biome_offset_max() - _world_data.get_surface_biome_offset_min(), _world_data.get_surface_biome_offset_octave(), _world_data.get_surface_biome_offset_roughness(), _seed);
        
        global.worldgen_noise_surface_offset[$ _index] = _buffer;
    }
    
    var _local_x = ((_x % WORLDGEN_SURFACE_OFFSET_NOISE_SIZE) + WORLDGEN_SURFACE_OFFSET_NOISE_SIZE) % WORLDGEN_SURFACE_OFFSET_NOISE_SIZE;
    
    return _world_data.get_surface_biome_offset_min() + round(_buffer.get(_local_x, 0));
}