global.item_function = {}

global.item_function[$ "phantasia:explode"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
}

global.item_function[$ "phantasia:export_structure"] = function()
{
    var _item_data = global.item_data;
    
    var _tile = tile_get(tile_x, tile_y, tile_z);
    
    var _id = _tile.get_component("id");
    
    if (file_exists($"{PROGRAM_DIRECTORY_STRUCTURES}/{_id}.dat"))
    {
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        
        var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
        
        with (_inst_header)
        {
            text = loca_translate("phantasia:menu.create_player.error.empty_name");
            
            menu_layer = 1;
            
            on_draw = function(_x, _y, _xscale, _yscale)
            {
                var _x2 = x * _xscale;
                var _y2 = y * _yscale;
                
                var _halign = draw_get_halign();
                var _valign = draw_get_valign();
                
                draw_set_align(fa_center, fa_middle);
                
                render_text(_x2, _y2, text, _xscale, _yscale);
                
                draw_set_align(_halign, _valign);
            }
        }
        
        var _inst_close = instance_create_layer(_camera_x + 480, _camera_y + 300, "Instances", obj_Menu_Button);
        
        with (_inst_close)
        {
            text = loca_translate("phantasia:menu.generic.close");
            
            image_xscale = 17;
            image_yscale = 3;
            
            menu_layer = 1;
            
            on_select_release = menu_popup_destroy;
        }
        
        menu_popup_create([
            _inst_header,
            _inst_close
        ]);
        
        exit;
    }
    
    var _xoffset = _tile.get_component("xoffset");
    var _yoffset = _tile.get_component("yoffset");
    
    var _xscale = _tile.get_component("xscale");
    var _yscale = _tile.get_component("yscale");
    
    var _x1 = tile_x + _xoffset;
    var _y1 = tile_y + _yoffset;
    
    var _x2 = tile_x + _xscale - 1;
    var _y2 = tile_y + _yscale - 1;
    
    var _buffer = buffer_create(0xffff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    
    buffer_write(_buffer, buffer_u8, _xscale);
    buffer_write(_buffer, buffer_u8, _yscale);
    
    for (var _x = _x1; _x <= _x2; ++_x)
    {
        for (var _y = _y1; _y <= _y2; ++_y)
        {
            var _tile_default = tile_get(_x, _y, CHUNK_DEPTH_DEFAULT);
            
            if (_tile_default != TILE_EMPTY) && (_tile_default.get_id() == "phantasia:void_blueprint")
            {
                buffer_write(_buffer, buffer_bool, true);
                
                continue;
            }
            
            buffer_write(_buffer, buffer_bool, false);
            
            for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
            {
                var _ = ((_z == CHUNK_DEPTH_DEFAULT) ? _tile_default : tile_get(_x, _y, _z));
                
                file_save_snippet_tile(_buffer, _, _item_data);
            }
        }
    }
    
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_STRUCTURES}/{_id}.dat");
    
    buffer_delete(_buffer);
}

global.item_function[$ "phantasia:open_menu"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    static __update_float = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];
        
        var _component = _data.get_component(tile_component);
        
        var _min = _component[$ "min"];
        var _max = _component[$ "max"];
        
        try
        {
            var _ = real(text);
            
            if (_min != undefined) && (_ < _min)
            {
                _ = _min;
            }
            
            if (_max != undefined) && (_ > _max)
            {
                _ = _max;
            }
            
            _tile.set_component(tile_component, _);
        }
        catch (_error)
        {
            var _default = _component[$ "default"];
            
            _tile.set_component(tile_component, _default);
        }
    }
    
    static __update_integer = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];
        
        var _component = _data.get_component(tile_component);
        
        var _min = _component[$ "min"];
        var _max = _component[$ "max"];
        var _default = _component[$ "default"];
        
        try
        {
            var _ = real(text);
            
            if (_ % 1 == 0)
            {
                if (_min != undefined) && (_ < _min)
                {
                    _ = _min;
                }
                
                if (_max != undefined) && (_ > _max)
                {
                    _ = _max;
                }
                
                _tile.set_component(tile_component, _);
            }
            else
            {
                _tile.set_component(tile_component, _default);
            }
        }
        catch (_error)
        {
            _tile.set_component(tile_component, _default);
        }
    }
    
    static __update_string = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];
        
        if (text == "")
        {
            var _default = _data.get_component(tile_component)[$ "default"];
            
            _tile.set_component(tile_component, _default);
        }
        else
        {
        	_tile.set_component(tile_component, text);
        }
    }
    
    static __exit = function()
    {
        obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.MENU;
        
        var _item_data = global.item_data;
        
        var _layer = layer_get_id("Menu_Item");
        
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }
    
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.MENU;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    obj_Menu_Control_Render.xscale = global.window_width  / global.camera_width;
    obj_Menu_Control_Render.yscale = global.window_height / global.camera_height;
    
    var _tile = tile_get(_x, _y, _z);
    
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
                
                tile_x = _x;
                tile_y = _y;
                tile_z = _z;
                
                var _on_select_release = _[$ "on_select_release"];
                
                if (_on_select_release != undefined)
                {
                    on_select_release = ((_on_select_release == "exit") ? __exit : method(id, global.item_function[$ _on_select_release]));
                }
            }
        }
        else if (_type == "textbox-float")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);
            
            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;
                
                placeholder = _[$ "placeholder"];
                
                var _component = _[$ "component"];
                
                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }
                
                tile_x = _x;
                tile_y = _y;
                tile_z = _z;
                
                tile_component = _component;
                
                on_update = method(id, __update_float);
            }	
        }
        else if (_type == "textbox-integer")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);
            
            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;
                
                placeholder = _[$ "placeholder"];
                
                var _component = _[$ "component"];
                
                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }
                
                tile_x = _x;
                tile_y = _y;
                tile_z = _z;
                
                tile_component = _component;
                
                on_update = method(id, __update_integer);
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
                
                var _component = _[$ "component"];
                
                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }
                
                tile_x = _x;
                tile_y = _y;
                tile_z = _z;
                
                tile_component = _component;
                
                text_length = _[$ "max"] ?? 24;
                
                on_update = method(id, __update_string);
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