function tile_update(_x, _y, _z)
{
    static _tile_connected_index = global.tile_connected_index;
    
    var _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height();
    
    if (_y < 0) || (_y >= _world_height) exit;
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst)) exit;
    
    var _index = tile_index(_x, _y, _z);
    
    var _tile = _inst.chunk[_index];
    
    if (_tile == TILE_EMPTY) exit;
    
    var _id = _tile.get_id();
    
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _id];
    
    var _animation_type = _data.get_animation_type();
    
    if (_animation_type == TILE_ANIMATION_TYPE.CONNECTED)
    {
        var _value = 0;
        
        for (var l = 0; l < 8; ++l)
        {
            var _ = l * 2;
            
            var _x2 = _x + _tile_connected_index[_ + 0];
            var _y2 = _y + _tile_connected_index[_ + 1];
            
            _value |= tile_condition_connected(_x2, _y2, _z, _id, _data, _item_data, _world_height) << l;
        }
        
        var _seed = global.world_save_data.seed + (global.world_save_data.time * 22);
        
        var _index_x = tile_connected_index_x(_value, _seed);
        var _index_y = tile_connected_index_y(_value, _seed);
        
        _tile
            .set_index(_value)
            .set_scale(_index_x, _index_y);
    }
    else if (_animation_type == TILE_ANIMATION_TYPE.CONNECTED_TO_SELF)
    {
        var _value = 0;
        
        for (var l = 0; l < 8; ++l)
        {
            var _ = l * 2;
            
            var _x2 = _x + _tile_connected_index[_ + 0];
            var _y2 = _y + _tile_connected_index[_ + 1];
            
            _value |= tile_condition_connected_to_self(_x2, _y2, _z, _id, _data, _item_data, _world_height) << l;
        }
        
        var _seed = global.world_save_data.seed + (global.world_save_data.time * 22);
        
        var _index_x = tile_connected_index_x(_value, _seed);
        var _index_y = tile_connected_index_y(_value, _seed);
        
        _tile
            .set_index(_value)
            .set_scale(_index_x, _index_y);
    }
}