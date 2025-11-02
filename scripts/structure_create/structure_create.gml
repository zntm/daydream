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
    
    if (_structure_data.has_clearance_condition())
    {
        var _clearance_condition = _structure_data.get_placement_clearance_condition();
        var _clearance_condition_length = _structure_data.get_placement_clearance_condition_length();
        
        var _tile_x = round(_x / TILE_SIZE);
        var _tile_y = round(_y / TILE_SIZE);
        
        for (var i = 0; i < _clearance_condition_length; ++i)
        {
            var _data = _clearance_condition[i];
            
            var _clearance_condition_width  = __size(_data.width,  _width, _height);
            var _clearance_condition_height = __size(_data.height, _width, _height);
            
            var _abs_clearance_condition_width  = abs(_clearance_condition_width);
            var _abs_clearance_condition_height = abs(_clearance_condition_height);
            
            var _xoffset = __size(_data.xoffset, _abs_clearance_condition_width, _abs_clearance_condition_height);
            var _yoffset = __size(_data.yoffset, _abs_clearance_condition_width, _abs_clearance_condition_height);
            
            for (var j = 0; j < _abs_clearance_condition_width; ++j)
            {
                var _x2 = _tile_x + j + _xoffset;
                
                var _surface_height = worldgen_get_surface_height(_x2, _seed);
                
                if (_tile_y + _abs_clearance_condition_height + _yoffset < _surface_height) continue;
                
                var l = 0;
                
                while (_tile_y + l + _yoffset < _surface_height) && (l < _abs_clearance_condition_height)
                {
                    ++l;
                }
                
                var _cave_start = worldgen_get_cave_start(_x2, _seed);
                
                for (; l < _abs_clearance_condition_height; ++l)
                {
                    var _y2 = _tile_y + l + _yoffset;
                    
                    if (!worldgen_get_cave(_x2, _y2, _surface_height, _cave_start, _seed)) exit;
                }
            }
        }
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