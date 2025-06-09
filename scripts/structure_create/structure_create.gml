function structure_create(_x, _y, _id, _seed)
{
    var _structure_data = global.structure_data[$ _id];
    
    var _width  = _structure_data.get_width();
    var _height = _structure_data.get_height();
    
    if !(_width & 1)
    {
        _x -= TILE_SIZE / 2;
    }
    
    if !(_height & 1)
    {
        _y -= TILE_SIZE / 2;
    }
    
    _x += (round(_width  / 2) + _structure_data.get_placement_xoffset()) * TILE_SIZE;
    _y += (round(_height / 2) + _structure_data.get_placement_yoffset()) * TILE_SIZE;
    
    with (instance_create_layer(_x, _y, "Instances", obj_Structure))
    {
        image_xscale = _width;
        image_yscale = _height;
        
        structure_xrelative = ceil(bbox_left / TILE_SIZE);
        structure_yrelative = ceil(bbox_top  / TILE_SIZE);
        
        structure_id = _id;
        
        count = 0;
    }
}