#macro WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE 512

global.worldgen_noise_surface_height = {}

function worldgen_get_surface_height(_x, _seed)
{
    var _x2 = floor(_x / WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE);
    
    var _index = string(_x2);
    var _buffer = global.worldgen_noise_surface_height[$ _index];
    
    var _world_data = global.world_data[$ global.world.dimension];
    
    if (_buffer == undefined)
    {
        _buffer = new Noise(_x2 * WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE, 0x17bd, WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE, 1, _world_data.get_surface_offset_min() + _world_data.get_surface_offset_max(), _world_data.get_surface_offset_octave(), _world_data.get_surface_offset_roughness(), _seed);
        
        global.worldgen_noise_surface_height[$ _index] = _buffer;
    }
    
    var _local_x = ((_x % WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE) + WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE) % WORLDGEN_SURFACE_HEIGHT_NOISE_SIZE;
    
    return round(_world_data.get_surface_start() + _world_data.get_surface_offset_min() - _buffer.get(_local_x, 0));
}