function structure_create(_x, _y, _id, _seed)
{
    static __size = function(_v, _width, _height)
    {
        if (_v == "width")
        {
            return _width;
        }
        
        if (_v == "-width")
        {
            return -_width;
        }
        
        if (_v == "height")
        {
            return _height;
        }
        
        if (_v == "-height")
        {
            return -_height;
        }
        
        return _v;
    }
    
    var _structure_data = global.structure_data[$ _id];
    
    var _seed_current = random_get_seed();
    
    if (!structure_valid(_x, _y, _id, _seed)) exit;
    
    random_set_seed(_seed_current);
    
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
     
    var _xoffset = __size(_structure_data.get_placement_xoffset(), _width, _height);
    var _yoffset = __size(_structure_data.get_placement_yoffset(), _width, _height);
    
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