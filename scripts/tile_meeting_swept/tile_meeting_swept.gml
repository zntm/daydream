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
    
    var _xscale = abs(image_xscale);
    var _yscale = abs(image_yscale);
    
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
    
    return tile_rectangle_meeting(_x1, _y1, _x2, _y2, _z, _type, _world_height);
}