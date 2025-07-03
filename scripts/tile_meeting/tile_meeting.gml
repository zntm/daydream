function tile_meeting(_x, _y, _z = CHUNK_DEPTH_DEFAULT, _type = ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM, _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height())
{
    if (_y < 0) || (_y >= (_world_height * TILE_SIZE))
    {
        return false;
    }
    
    var _item_data = global.item_data;
    
    var _collision_box = attribute.collision_box;
    
    var _collision_width  = _collision_box.width;
    var _collision_height = _collision_box.height;
    
    var _xscale = abs(image_xscale * 8) / _collision_width;
    var _yscale = abs(image_yscale * 8) / _collision_height;
    
    var _x1 = _x - (_xscale / 2 * _collision_width);
    var _y1 = _y - (_yscale * _collision_height);
    
    var _x2 = _x - 1 + (_xscale / 2 * _collision_width);
    var _y2 = _y - 1;
    
    var _xstart = floor(_x1 / TILE_SIZE) - 1;
    var _ystart = floor(_y1 / TILE_SIZE) - 1;
    
    var _xend = ceil(_x2 / TILE_SIZE) + 1;
    var _yend = ceil(_y2 / TILE_SIZE) + 1;
    
    for (var j = max(0, _ystart); j <= _yend; ++j)
    {
        if (j >= _world_height)
        {
            return false;
        }
        
        var _tile_y = j * TILE_SIZE;
        
        for (var i = _xstart; i <= _xend; ++i)
        {
            var _tile = tile_get(i, j, _z);
            
            if (_tile == TILE_EMPTY) continue;
            
            var _data = _item_data[$ _tile.get_id()];
            
            if (!_data.has_type(_type)) continue;
            
            var _tile_x = i * TILE_SIZE;
            
            var _tile_xoffset = _tile.get_xoffset();
            var _tile_yoffset = _tile.get_yoffset();
            
            var _tile_xscale = _tile.get_xscale();
            var _tile_yscale = _tile.get_yscale();
            
            var _x3 = _tile_x + ((_tile_xoffset - _data.get_collision_box_left()) * _tile_xscale);
            var _y3 = _tile_y + ((_tile_yoffset - _data.get_collision_box_top())  * _tile_yscale);
            
            var _x4 = _x3 + (_data.get_collision_box_right()  * _tile_xscale);
            var _y4 = _y3 + (_data.get_collision_box_bottom() * _tile_yscale);
            
            var _collision_box_type = _data.get_collision_box_type();
            
            if (_collision_box_type == TILE_COLLISION_BOX_TYPE.RECTANGLE)
            {
                if (rectangle_in_rectangle(_x1, _y1, _x2, _y2, min(_x3, _x4), min(_y3, _y4), max(_x3, _x4), max(_y3, _y4)))
                {
                    return _tile;
                }
            }
            else if (_collision_box_type == TILE_COLLISION_BOX_TYPE.TRIANGLE)
            {
                if (rectangle_in_triangle(_x1, _y1, _x2, _y2, min(_x3, _x4), min(_y3, _y4), max(_x3, _x4), min(_y3, _y4), max(_x3, _x4), max(_y3, _y4)))
                {
                    return _tile;
                }
            }
        }
    }
    
    return false;
}