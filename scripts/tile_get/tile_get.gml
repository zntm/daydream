function tile_get(_x, _y, _z)
{
	if (_y < 0) || (_y >= global.world_data[$ global.world.dimension].get_world_height())
	{
		return TILE_EMPTY;
	}
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
	
	var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst))
    {
        // TODO: Replace with prediction system
        _inst = instance_create_layer(_chunk_x, _chunk_y, "Instances", obj_Chunk);
    }
    
	return _inst.chunk[tile_index(_x, _y, _z)];
}