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
    
    if (_structure_data.has_if_clear())
    {
        var _if_clear = _structure_data.get_placement_if_clear();
        var _if_clear_length = _structure_data.get_placement_if_clear_length();
        
        for (var i = 0; i < _if_clear_length; ++i)
        {
            var _data = _if_clear[i];
            
            var _if_clear_width  = _data.width;
            var _if_clear_height = _data.height;
            
            if (_if_clear_width == "width")
            {
                _if_clear_width = _width;
            }
            else if (_if_clear_width == "-width")
            {
                _if_clear_width = -_width;
            }
            else if (_if_clear_width == "height")
            {
                _if_clear_width = _height;
            }
            else if (_if_clear_width == "-height")
            {
                _if_clear_width = -_height;
            }
            
            if (_if_clear_height == "width")
            {
                _if_clear_height = _width;
            }
            else if (_if_clear_height == "-width")
            {
                _if_clear_height = -_width;
            }
            else if (_if_clear_height == "height")
            {
                _if_clear_height = _height;
            }
            else if (_if_clear_height == "-height")
            {
                _if_clear_height = -_height;
            }
            
            var _xoffset = _data.xoffset;
            var _yoffset = _data.yoffset;
            
            if (_xoffset == "width")
            {
                _xoffset = _if_clear_width;
            }
            else if (_xoffset == "-width")
            {
                _xoffset = -_if_clear_width;
            }
            else if (_xoffset == "height")
            {
                _xoffset = _if_clear_height;
            }
            else if (_xoffset == "-height")
            {
                _xoffset = -_if_clear_height;
            }
            
            if (_yoffset == "width")
            {
                _yoffset = _if_clear_width;
            }
            else if (_yoffset == "-width")
            {
                _yoffset = -_if_clear_width;
            }
            else if (_yoffset == "height")
            {
                _yoffset = _if_clear_height;
            }
            else if (_yoffset == "-height")
            {
                _yoffset = -_if_clear_height;
            }
            
            for (var j = 0; j < _if_clear_width; ++j)
            {
                var _x2 = round(_x / TILE_SIZE) + j + _xoffset;
                
                var _surface_height = worldgen_get_surface_height(_x2, _seed);
                
                for (var l = 0; l < _if_clear_height; ++l)
                {
                    var _y2 = round(_y / TILE_SIZE) + l + _yoffset;
                    
                    if (!worldgen_get_cave(_x2, _y2, _surface_height, _seed)) exit;
                }
            }
        }
        /*
        var _if_clear_width  = _structure_data.get_placement_if_clear_width();
        var _if_clear_height = _structure_data.get_placement_if_clear_height();
        
        if (_if_clear_width == "width")
        {
            _if_clear_width = _width;
        }
        else if (_if_clear_width == "-width")
        {
            _if_clear_width = -_width;
        }
        else if (_if_clear_width == "height")
        {
            _if_clear_width = _height;
        }
        else if (_if_clear_width == "-height")
        {
            _if_clear_width = -_height;
        }
        
        if (_if_clear_height == "width")
        {
            _if_clear_height = _width;
        }
        else if (_if_clear_height == "-width")
        {
            _if_clear_height = -_width;
        }
        else if (_if_clear_height == "height")
        {
            _if_clear_height = _height;
        }
        else if (_if_clear_height == "-height")
        {
            _if_clear_height = -_height;
        }
        
        var _xoffset = _structure_data.get_placement_if_clear_xoffset();
        var _yoffset = _structure_data.get_placement_if_clear_yoffset();
        
        if (_xoffset == "width")
        {
            _xoffset = _if_clear_width;
        }
        else if (_xoffset == "-width")
        {
            _xoffset = -_if_clear_width;
        }
        else if (_xoffset == "height")
        {
            _xoffset = _if_clear_height;
        }
        else if (_xoffset == "-height")
        {
            _xoffset = -_if_clear_height;
        }
        
        if (_yoffset == "width")
        {
            _yoffset = _if_clear_width;
        }
        else if (_yoffset == "-width")
        {
            _yoffset = -_if_clear_width;
        }
        else if (_yoffset == "height")
        {
            _yoffset = _if_clear_height;
        }
        else if (_yoffset == "-height")
        {
            _yoffset = -_if_clear_height;
        }
        
        for (var i = 0; i < _if_clear_width; ++i)
        {
            var _x2 = round(_x / TILE_SIZE) + i + _xoffset;
            
            var _surface_height = worldgen_get_surface_height(_x2, _seed);
            
            for (var j = 0; j < _if_clear_height; ++j)
            {
                var _y2 = round(_y / TILE_SIZE) + j + _yoffset;
                
                if (!worldgen_get_cave(_x2, _y2, _surface_height, _seed)) exit;
            }
        }*/
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
    
    if (_yoffset == "width")
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