function structure_create(_x, _y, _id, _seed, _force_surface)
{
    var _structure_data = global.structure_data[$ _id];
    
    var _width  = _structure_data.get_width();
    var _height = _structure_data.get_height();
    
    if (_width % 2 == 0)
    {
        _x -= (TILE_SIZE / 2);
    }
    
    if (_height % 2 == 0)
    {
        _y -= (TILE_SIZE / 2);
    }
    
    if (_force_surface)
    {
        _x = _x - (ceil(_width  / 2) * TILE_SIZE);
        _y = _y - (ceil(_height / 2) * TILE_SIZE);
    }
    else
    {
        _x = _x + (ceil(_width  / 2) * TILE_SIZE);
        _y = _y + (ceil(_height / 2) * TILE_SIZE);
    }
    
    with (instance_create_layer(_x, _y, "Instances", obj_Structure))
    {
        image_xscale = _width;
        image_yscale = _height;
        
        if (_force_surface)
        {
            var _surface_height = worldgen_get_surface_height(round(_x / TILE_SIZE), _seed) * TILE_SIZE;
            
            if (bbox_bottom > _surface_height)
            {
                y -= floor(((bbox_bottom - _surface_height) - (TILE_SIZE / 2)) / TILE_SIZE) * TILE_SIZE;
            }
            else
            {
                y += ceil(((_surface_height - bbox_bottom) - (TILE_SIZE / 2)) / TILE_SIZE) * TILE_SIZE;
            }
        }
        
        x += (_structure_data.get_placement_xoffset() - 0) * TILE_SIZE;
        y += (_structure_data.get_placement_yoffset() - 1) * TILE_SIZE;
        
        structure_xrelative = ceil(bbox_left / TILE_SIZE);
        structure_yrelative = ceil(bbox_top  / TILE_SIZE);
        
        structure_id = _id;
        
        count = 0;
    }
}