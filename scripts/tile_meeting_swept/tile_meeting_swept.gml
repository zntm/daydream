function tile_meeting_swept(_x_start, _y_start, _x_end, _y_end, _z = CHUNK_DEPTH_DEFAULT, _type = ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM, _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height())
{
    // Check bounds roughly
    var _min_y = min(_y_start, _y_end);
    if (_min_y < 0) || (_min_y >= (_world_height * TILE_SIZE))
    {
        return false;
    }
    
    var _item_data = global.item_data;
    
    var _collision_width  = attribute.get_collision_box_width();
    var _collision_height = attribute.get_collision_box_height();
    
    var _xscale = abs(image_xscale * 8) / _collision_width;
    var _yscale = abs(image_yscale * 8) / _collision_height;
    
    // Calculate start BBOX
    var _x1_start = _x_start - ((_xscale * _collision_width) / 2);
    var _y1_start = _y_start -  (_yscale * _collision_height);
    var _x2_start = _x_start - 1 + (_xscale / 2 * _collision_width);
    var _y2_start = _y_start - 1;
    
    // Calculate end BBOX
    var _x1_end = _x_end - ((_xscale * _collision_width) / 2);
    var _y1_end = _y_end -  (_yscale * _collision_height);
    var _x2_end = _x_end - 1 + (_xscale / 2 * _collision_width);
    var _y2_end = _y_end - 1;
    
    // Union BBOX
    var _x1 = min(_x1_start, _x1_end);
    var _y1 = min(_y1_start, _y1_end);
    var _x2 = max(_x2_start, _x2_end);
    var _y2 = max(_y2_start, _y2_end);
    
    var _xstart = floor(_x1 / TILE_SIZE) - 1;
    var _ystart = floor(_y1 / TILE_SIZE) - 1;
    
    var _xend_tile = ceil(_x2 / TILE_SIZE) + 1;
    var _yend_tile = ceil(_y2 / TILE_SIZE) + 1;
    
    for (var j = max(0, _ystart); j <= _yend_tile; ++j)
    {
        if (j >= _world_height)
        {
            return false;
        }
        
        var _tile_y = j * TILE_SIZE;
        
        for (var i = _xstart; i <= _xend_tile; ++i)
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
            
            var _x3 = _tile_x + ((_tile_xoffset + _data.get_collision_box_left()) * _tile_xscale);
            var _y3 = _tile_y + ((_tile_yoffset + _data.get_collision_box_top())  * _tile_yscale);
            
            var _x4 = _x3 + (_data.get_collision_box_right()  * _tile_xscale);
            var _y4 = _y3 + (_data.get_collision_box_bottom() * _tile_yscale);
            
            var _x5 = min(_x3, _x4);
            var _y5 = min(_y3, _y4);
            
            var _x6 = max(_x3, _x4);
            var _y6 = max(_y3, _y4);
            
            var _collision_box_type = _data.get_collision_box_type();
            
            // Check against the Union BBOX
            if (_collision_box_type == TILE_COLLISION_BOX_TYPE.RECTANGLE)
            {
                if (rectangle_in_rectangle(_x1, _y1, _x2, _y2, _x5, _y5, _x6, _y6))
                {
                    return _tile;
                }
            }
            else if (_collision_box_type == TILE_COLLISION_BOX_TYPE.TRIANGLE)
            {
                if (rectangle_in_triangle(_x1, _y1, _x2, _y2, _x5, _y5, _x6, _y5, _x6, _y6))
                {
                    return _tile;
                }
            }
        }
    }
    
    return false;
}
