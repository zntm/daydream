function tile_point_meeting(_x, _y, _z = CHUNK_DEPTH_DEFAULT, _type = ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM, _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height())
{
    if (_y < 0) || (_y >= (_world_height * TILE_SIZE))
    {
        return false;
    }
    
    var _item_data = global.item_data;
    
    var _tile_x = round(_x / TILE_SIZE);
    var _tile_y = round(_y / TILE_SIZE);
    
    var _tile = tile_get(_tile_x, _tile_y, _z);
    
    if (_tile == TILE_EMPTY)
    {
        return false;
    }
    
    var _data = _item_data[$ _tile.get_id()];
    
    if (!_data.has_type(_type))
    {
        return false;
    }
    
    var _inst_x = _tile_x * TILE_SIZE;
    var _inst_y = _tile_y * TILE_SIZE;
    
    var _tile_xoffset = _tile.get_xoffset();
    var _tile_yoffset = _tile.get_yoffset();
    
    var _tile_xscale = _tile.get_xscale();
    var _tile_yscale = _tile.get_yscale();
    
    var _x3 = _inst_x + ((_tile_xoffset - _data.get_collision_box_left()) * _tile_xscale);
    var _y3 = _inst_y + ((_tile_yoffset - _data.get_collision_box_top())  * _tile_yscale);
    
    var _x4 = _x3 + (_data.get_collision_box_right()  * _tile_xscale);
    var _y4 = _y3 + (_data.get_collision_box_bottom() * _tile_yscale);
    
    var _collision_box_type = _data.get_collision_box_type();
    
    if (_collision_box_type == TILE_COLLISION_BOX_TYPE.RECTANGLE)
    {
        if (point_in_rectangle(_x, _y, _x3, _y3, _x4, _y4))
        {
            return _tile;
        }
    }
    else if (_collision_box_type == TILE_COLLISION_BOX_TYPE.TRIANGLE)
    {
        if (point_in_triangle(_x, _y, _x3, _y3, _x4, _y3, _x3, _y4))
        {
            return _tile;
        }
    }
    
    return false;
}