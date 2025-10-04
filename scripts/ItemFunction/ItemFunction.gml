global.item_function = {}

global.item_function[$ "phantasia:explode"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
}

global.item_function[$ "phantasia:open_menu"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.MENU;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    obj_Menu_Control_Render.xscale = global.window_width  / global.camera_width;
    obj_Menu_Control_Render.yscale = global.window_height / global.camera_height;
    
    var _layer = layer_get_id("Menu_Item");
    
    var _data = _parameter.data;
    
    var _length = array_length(_data);
    
    for (var i = 0; i < _length; ++i)
    {
        var _ = _data[i];
        
        var _type = _.type;
        
        if (_type == "button")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Button);
            
            with (_inst)
            {
                image_xscale = _[$ "xscale"] ?? 1;
                image_yscale = _[$ "yscale"] ?? 1;
                
                text = _[$ "text"];
            }
        }
        else if (_type == "textbox-number")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);
            
            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;
                
                placeholder = _[$ "placeholder"];
            }	
        }
        else if (_type == "textbox-string")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);
            
            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;
                
                placeholder = _[$ "placeholder"];
            }
        }
        else if (_type == "anchor")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Anchor);
            
            with (_inst)
            {
                text = _.text;
                
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;
                
                on_draw = render_menu_title;
            }
        }
    }
    
    /*
    with (all)
    {
        if (layer == _layer)
        {
            x = _camera_x + xstart;
            y = _camera_y + ystart;
        }
    }*/
}

global.item_function[$ "phantasia:spawn_particle"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _offset = _parameter[$ "offset"];
    
    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];
        
        if (_xoffset != undefined)
        {
            _x += smart_value(_xoffset);
        }
        
        var _yoffset = _offset[$ "y"];
        
        if (_yoffset != undefined)
        {
            _y += smart_value(_yoffset);
        }
    }
    
    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:spawn_projectile"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _offset = _parameter[$ "offset"];
    
    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];
        
        if (_xoffset != undefined)
        {
            _x += smart_value(_xoffset);
        }
        
        var _yoffset = _offset[$ "y"];
        
        if (_yoffset != undefined)
        {
            _y += smart_value(_yoffset);
        }
    }
    
    var _id = smart_value(_parameter.id);
    var _damage = smart_value(_parameter.damage);
    
    spawn_projectile(_x * TILE_SIZE, _y * TILE_SIZE, _id, _damage, _xscale, _yscale);
}

global.item_function[$ "phantasia:sfx_play"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _audio_emitter = tile_audio_emitter(_x, _y);
    
    sfx_diegetic_play(_audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:tile_grow_crop"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
}

global.item_function[$ "phantasia:tile_place"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    static __chunk_depth = global.chunk_depth;
    
    var _condition = _parameter[$ "condition"];
    
    if (_condition != undefined)
    {
        var _condition_length = array_length(_condition);
        
        for (var i = 0; i < _condition_length; ++i)
        {
            var _ = _condition[i];
            
            var _xoffset = _[$ "x"];
            
            var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;
            
            var _yoffset = _[$ "y"];
            
            var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;
            
            var _tile = tile_get(_x2, _y2, __chunk_depth[$ _.z]);
            
            var _id = _.id;
            
            if (_id == TILE_EMPTY_ID)
            {
                if (_tile != TILE_EMPTY) exit;
            }
            else if (_tile == TILE_EMPTY) || ((is_array(_id)) ? !array_contains(_id, _tile.get_id()) : _tile.get_id() != _id) exit;
        }
    }
    
    var _xoffset = _parameter[$ "x"];
    
    var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;
    
    var _yoffset = _parameter[$ "y"];
    
    var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;
    
    var _z2 = __chunk_depth[$ _parameter.z];
    
    var _id = smart_value(_parameter.id);
    
    if (_id != TILE_EMPTY_ID)
    {
        tile_place(_x2, _y2, _z2, new Tile(_id));
    }
    else
    {
        tile_place(_x2, _y2, _z2, TILE_EMPTY_ID);
    }
    
    tile_update_surrounding(_x2, _y2, _z2);
}