function structure_valid(_tx, _ty, _id, _seed)
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
    var _world_data = global.world_data[$ global.current_world.dimension];
    
    var _width  = smart_value(_structure_data.get_width());
    var _height = smart_value(_structure_data.get_height());
    
    if (!_structure_data.has_clearance_condition())
    {
        return true;
    }
    
    var _clearance_condition = _structure_data.get_placement_clearance_condition();
    var _clearance_condition_length = _structure_data.get_placement_clearance_condition_length();
    var _if_clear = _structure_data.get_if_clear();
    
    for (var i = 0; i < _clearance_condition_length; ++i)
    {
        var _data = _clearance_condition[i];
        
        var _abs_clearance_condition_width  = abs(__size(_data.width,  _width, _height));
        var _abs_clearance_condition_height = abs(__size(_data.height, _width, _height));
        
        var _xoffset = __size(_data.xoffset, _abs_clearance_condition_width, _abs_clearance_condition_height);
        var _yoffset = __size(_data.yoffset, _abs_clearance_condition_width, _abs_clearance_condition_height);
        
        for (var j = 0; j < _abs_clearance_condition_width; ++j)
        {
            var _x2 = _tx + j + _xoffset;
            var _surface_height = worldgen_get_surface_height(_x2, _seed, _world_data);
            
            // If if_clear is true, ensure the structure's footprint is not below the local surface
            // We check if the bottom of where the structure would be (top + height) is deeper than the surface
            if (_if_clear) && (_ty < _surface_height) && (_ty + _height > _surface_height)
            {
                return false;
            }
            
            if (_ty + _abs_clearance_condition_height + _yoffset < _surface_height) continue;
            
            var l = 0;
            
            while (_ty + l + _yoffset < _surface_height) && (l < _abs_clearance_condition_height)
            {
                ++l;
            }
            
            var _cave_start = worldgen_get_cave_start(_x2, _seed, _world_data);
            
            for (; l < _abs_clearance_condition_height; ++l)
            {
                var _y2 = _ty + l + _yoffset;
                
                if (!worldgen_get_cave(_x2, _y2, _surface_height, _cave_start, _seed, _world_data))
                {
                    return false;
                }
            }
        }
    }
    
    return true;
}
