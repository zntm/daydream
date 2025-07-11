function control_light_clusterize()
{
    with (obj_Light_Sun)
    {
        y = -0xffff;
        
        image_xscale = 0;
    }
    
    var _sunlight_y = global.sunlight_y;
    
    var _sunlight_inst = global.sunlight_inst;
    var _sunlight_inst_length = array_length(_sunlight_inst);
    
    var _cluster_y = -1;
    var _cluster_inst = noone;
    
    var _xstart = round(global.camera_x / TILE_SIZE) - SUNLIGHT_PADDING;
    
    for (var i = 0; i < _sunlight_inst_length; ++i)
    {
        var _x = _xstart + i;
        var _y = ((ds_map_exists(_sunlight_y, _x)) ? _sunlight_y[? _x] * TILE_SIZE : 0) - (TILE_SIZE / 2);
        
        if (_y == _cluster_y) && (instance_exists(_cluster_inst))
        {
            _cluster_inst.x += TILE_SIZE / 2;
            
            ++_cluster_inst.image_xscale;
            
            continue;
        }
        
        _cluster_y = _y;
        
        _cluster_inst = _sunlight_inst[i];
        
        _cluster_inst.x = _x * TILE_SIZE;
        _cluster_inst.y = _y;
        
        _cluster_inst.image_xscale = 1;
    }
}