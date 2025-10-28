function tile_update(_x, _y, _z)
{
    var _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height();
    
    if (_y < 0) || (_y >= _world_height) exit;
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst)) exit;
    
    var _index = tile_index_xyz(_x, _y, _z);
    
    var _tile = _inst.chunk[_index];
    
    if (_tile == TILE_EMPTY) exit;
    
    if (!tile_update_placement_condition(_x, _y, _z, _tile))
    {
        tile_harvest_drop(_x, _y, _z, _tile);
        
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        tile_update_surrounding(_x, _y, _z);
        
        var _data = global.item_data[$ _tile.get_id()];
        
        var _particle_colour = _data.get_tile_harvest_particle_colour();
        
        repeat (smart_value(_data.get_tile_harvest_particle_frequency()))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
        
        exit;
    }
    
    tile_connect(_x, _y, _z, _tile);
}