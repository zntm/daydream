function menu_refresh_instance_statistics()
{
    static __text = function(_x, _y, _xscale, _yscale)
    {
        var _halign = draw_get_halign();
        var _valign = draw_get_valign();
        
        draw_set_align(fa_left, fa_middle);
        
        var _x2 = x * _xscale;
        var _y2 = y * _yscale;
        
        render_text(_x2, _y2, name, _xscale, _yscale);
        
        draw_set_align(fa_right, fa_middle);
        
        render_text((x + 600) * _xscale, _y2, value, _xscale, _yscale, 0, c_gray);
        
        draw_set_align(_halign, _valign);
    }
    
    with (all)
    {
        if (id[$ "is_setting"])
        {
            instance_destroy();
            continue;
        }
        
        if (id[$ "category"] != undefined)
        {
            sprite_index = spr_Menu_Button_Main;
        }
    }
    
    sprite_index = spr_Menu_Button_Secondary;
    
    var _menu_settings_xoffset = global.menu_settings_xoffset;
    var _menu_settings_yoffset = global.menu_settings_yoffset;
    
    var _list = [];
    
    // Use helper to get list
    // Note: We use global.player_statistics and global.world_statistics as implicit sources 
    // because that's what the original code did. 
    // However, the helper requires passing them.
    // The previous code mixed statistics_get keys with statistics_get_world keys.
    // Wait, the previous code had specific logic for "blocks" using global.world_statistics.
    // My helper implementation uses a single _stats source.
    // I NEED TO UPDATE statistics_get_list TO HANDLE WORLD STATS IF I WANT TO MATCH THIS LOGIC PRECISELY?
    // Actually, as discovered, global.player_statistics DOES contain the data.
    // So passing global.player_statistics is sufficient.
    var _list = statistics_get_list(global.player_statistics, category);
    
    // Handle display
    var _count = array_length(_list);
    var _inst_slider = global.settings_inst_slider; // We reuse settings slider? Or need a new one?
    // If we are in a new room, we should have a 'statistics_inst_slider'
    // But if we copy settings room, it might still refer to global.settings_inst_slider if we don't change creation code.
    // Let's assume global.statistics_inst_slider exists.
    
    // Actually, safetyl check
    if (variable_global_exists("statistics_inst_slider")) _inst_slider = global.statistics_inst_slider;
    
    if (_count <= 5)
    {
        _inst_slider.x = -64;
    }
    else
    {
        // Re-using settings list variables or new ones?
        // Let's use global.statistics_list_*
        global.statistics_list_offset = 0;
        global.statistics_list_length = _count;
        global.statistics_list_size = max(0, (_count - 5) * 64);
        
        _inst_slider.x = _menu_settings_xoffset + _inst_slider.xstart;
    }
    
    var _base_layer = obj_Menu_Control_Button.menu_layer;
    var _fade_layer = _base_layer + 1;
    
    obj_Menu_Control_Render.surface_index_length = _fade_layer + 1;
    obj_Menu_Control_Render.surface_index_shader[@ _fade_layer] = {
        id: shd_Menu_Settings_Fade, // Recycle shader
        u_FadeStart: 0.45, 
        u_FadeEnd: 0.85,
        no_dim: true
    }
    
    obj_Menu_Control_Render.surface_index_boundary[@ _fade_layer] = {
        y_min: global.gui_height * 0.45,
        y_max: global.gui_height * 0.85
    }
    
    for (var i = 0; i < _count; ++i)
    {
        var _item = _list[i];
        var _y = 192 + (64 * i);
        
        with (instance_create_layer(64, _y, "Settings", obj_Menu_Anchor))
        {
            is_setting = true;
            surface_index = _fade_layer;
            menu_layer = 0;
            
            name = _item.name;
            value = _item.value;
            
            on_draw = method(id, __text);
        }
    }
}
