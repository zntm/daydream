function structure_create(_x, _y, _id, _seed)
{
    var _structure_data = global.structure_data[$ _id];
    
    var _width  = smart_value(_structure_data.get_width());
    var _height = smart_value(_structure_data.get_height());
    
    if (_width & 1)
    {
        _x -= TILE_SIZE / 2;
    }
    
    if (_height & 1)
    {
        _y -= TILE_SIZE / 2;
    }
    
    var _xoffset = _structure_data.get_placement_xoffset();
    var _yoffset = _structure_data.get_placement_yoffset();
    
    if (_xoffset == "width")
    {
        _xoffset = _width;
    }
    else if (_xoffset == "-width")
    {
        _xoffset = -_width;
    }
    else if (_xoffset == "height")
    {
        _xoffset = _height;
    }
    else if (_xoffset == "-height")
    {
        _xoffset = -_height;
    }
    
    if (_yoffset == "height")
    {
        _yoffset = _width;
    }
    else if (_yoffset == "-width")
    {
        _yoffset = -_width;
    }
    else if (_yoffset == "height")
    {
        _yoffset = _height;
    }
    else if (_yoffset == "-height")
    {
        _yoffset = -_height;
    }
    
    _x += (ceil(_width  / 2) + _xoffset) * TILE_SIZE;
    _y += (ceil(_height / 2) + _yoffset) * TILE_SIZE;
    
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