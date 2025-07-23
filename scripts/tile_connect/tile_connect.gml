function tile_connect(_x, _y, _z, _tile)
{
    static _tile_connected_index = global.tile_connected_index;
    
    var _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height();
    
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
        
        var _seed = (round(global.world_save_data.seed / 0x800) + (_x * 97) + (_y * 116) + (_z * 278)) ^ 0x7f91_d88c;
        
        var _index_x = tile_connected_index_x(_value, _seed);
        var _index_y = tile_connected_index_y(_value, (_seed * 193) + _value + (_x * 97) + round(_y * 116.34) + 1);
        
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
        
        var _seed = (round(global.world_save_data.seed / 0x800) + (_x * 97) + (_y * 116) + (_z * 278)) ^ 0x7f91_d88c;
        
        var _index_x = tile_connected_index_x(_value, _seed);
        var _index_y = tile_connected_index_y(_value, (_seed * 193) + _value + (_x * 97) + round(_y * 116.34) + 1);
        
        _tile
            .set_index(_value)
            .set_scale(_index_x, _index_y);
    }
}