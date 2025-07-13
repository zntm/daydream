function tile_update(_x, _y, _z)
{
    var _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height();
    
    if (_y < 0) || (_y >= _world_height) exit;
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst)) exit;
    
    var _index = tile_index(_x, _y, _z);
    
    var _tile = _inst.chunk[_index];
    
    if (_tile == TILE_EMPTY) exit;
    
    tile_connect(_x, _y, _z, _tile);
}