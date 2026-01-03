function menu_popup_player_statistics(_data)
{
    // --- LAYOUT CONSTANTS ---
    // We need to be above the Player List which is on Surface 1.
    // So we'll use Surface 2 for static popup elements (Header, Background Dim).
    // And Surface 3 for the scrolling list (with Shader).
    
    // Get the current surface layer count - we add our layers on top
    var _current_surface_count = obj_Menu_Control_Render.surface_index_length;
    var _popup_static_layer = _current_surface_count;   // First new layer for dim + static elements
    var _popup_scroll_layer = _current_surface_count + 1; // Second new layer for scrolling content
    
    // Increment menu layer first (similar to keybind remap)
    obj_Menu_Control_Button.menu_layer++;
    
    // Logic layer (for input) must match the current controller layer
    var _logic_layer = obj_Menu_Control_Button.menu_layer;
    
    // Track where we started for cleanup
    var _base_menu_layer = _logic_layer - 1;
    
    var _menu_x_center = room_width / 2;
    var _menu_y_center = room_height / 2;
    var _popup_width = 800;
    var _popup_height = 450;
    
    var _popup_x = _menu_x_center - (_popup_width / 2);
    var _popup_y = _menu_y_center - (_popup_height / 2);
    
    var _popup_instances = [];
    
    // Set surface index length to accommodate our popup layers
    obj_Menu_Control_Render.surface_index_length = _popup_scroll_layer + 1;
    
    // Reset shader for static layer to enable dimming (overrides previous no_dim settings)
    obj_Menu_Control_Render.surface_index_shader[@ _popup_static_layer] = undefined;
    
    // Header
    with (instance_create_layer(_popup_x + 40, _popup_y + 40, "Instances", obj_Menu_Anchor))
    {
        menu_layer = _logic_layer;
        surface_index = _popup_static_layer;
        
        name = _data.get_name();
        
        on_draw = function(_x, _y, _xscale, _yscale)
        {
            render_text(x * _xscale, y * _yscale, $"Statistics: {name}", _xscale * 1.5, _yscale * 1.5);
        }
        
        array_push(_popup_instances, id);
    }
    
    // Close Button (Back)
    with (instance_create_layer(_popup_x + 40, _popup_y + 40, "Instances", obj_Menu_Button))
    {
        menu_layer = _logic_layer;
        surface_index = _popup_static_layer;
        
        image_xscale = 4;
        image_yscale = 2;
        
        x = 48;
        y = 48;
        
        text = "< Back";
        
        on_select_release = function()
        {
            menu_popup_destroy();
            
            if (variable_global_exists("statistics_popup_inst_slider"))
            {
                instance_destroy(global.statistics_popup_inst_slider);
            }
            
            // Cleanup Render Controller State
            if (instance_exists(obj_Menu_Control_Render))
            {
                // Reset surface length and restore player list layer shader
                obj_Menu_Control_Render.surface_index_length = 2;
                obj_Menu_Control_Render.surface_index_shader[@ 1] = {
                    id: shd_Menu_Settings_Fade,
                    u_FadeStart: 0.3, 
                    u_FadeEnd: 0.6,
                    no_dim: true
                }
            }
        }
        
        array_push(_popup_instances, id);
    }
    
    // --- SLIDER ---
    var _inst_slider = instance_create_layer(_popup_x + _popup_width - 32, _popup_y + 100, "Instances", obj_Menu_Button);
    with (_inst_slider)
    {
        is_setting = false; 
        
        menu_layer = _logic_layer;
        surface_index = _popup_static_layer;
        
        image_xscale = 2;
        image_yscale = 2;
        
        // Slider Logic
        on_select_hold = function()
        {
            y = clamp(mouse_y, ystart, ystart + global.statistics_popup_list_size); 
            
            var _range = global.statistics_popup_list_size;
            if (_range > 0)
            {
                var _max_scroll = global.statistics_popup_max_scroll;
                global.statistics_popup_list_offset = lerp(0, _max_scroll, (y - ystart) / 300); 
            }
            
            // Update items positions
            var _offset = global.statistics_popup_list_offset;
            with (all)
            {
                if (id[$ "is_popup_stat"])
                {
                    y = ystart - _offset;
                }
            }
        }
        
        // Scroll wheel logic
        on_step = function()
        {
            var _speed = (mouse_wheel_up() - mouse_wheel_down()) * 32 * global.delta_time * GAME_TICK;
            if (_speed != 0)
            {
                global.statistics_popup_list_offset = clamp(global.statistics_popup_list_offset - _speed, 0, global.statistics_popup_max_scroll);
                
                var _t = 0;
                if (global.statistics_popup_max_scroll > 0) _t = global.statistics_popup_list_offset / global.statistics_popup_max_scroll;
                y = ystart + (_t * 300); 
                
                // Update items
                var _offset = global.statistics_popup_list_offset;
                with (all)
                {
                    if (id[$ "is_popup_stat"])
                    {
                        y = ystart - _offset;
                    }
                }
            }
        }
        
        // Draw Track
        on_draw_behind = function(_x, _y, _render_xscale, _render_yscale)
        {
            draw_sprite_ext(spr_Menu_Indent, 0, x * _render_xscale, (ystart + 150) * _render_yscale, 1, 300/8, 0, c_white, 1);
        }
    }
    
    global.statistics_popup_inst_slider = _inst_slider;
    array_push(_popup_instances, _inst_slider);
    
    // --- CONTENT GENERATION ---
    var _stats = _data.get_statistics() ?? {};
    var _full_list = [];
    
    var _cats = ["general"];
    
    for (var c = 0; c < array_length(_cats); ++c)
    {
        var _cat_items = statistics_get_list(_stats, _cats[c]);
        
        if (array_length(_cat_items) > 0)
        {
            var _header_name = loca_translate($"phantasia:statistics.category.{_cats[c]}"); 
            if (_header_name == $"phantasia:statistics.category.{_cats[c]}") _header_name = string_upper(string_char_at(_cats[c], 1)) + string_copy(_cats[c], 2, string_length(_cats[c]));
            
            array_push(_full_list, { is_header: true, name: $"--- {_header_name} ---" });
            
            for (var k = 0; k < array_length(_cat_items); ++k)
            {
                array_push(_full_list, _cat_items[k]);
            }
        }
    }
    
    // --- SCROLL SETUP ---
    var _count = array_length(_full_list);
    var _item_height = 48; 
    var _view_height = 300; 
    
    global.statistics_popup_list_length = _count;
    global.statistics_popup_max_scroll = max(0, (_count * _item_height) - _view_height);
    global.statistics_popup_list_offset = 0;
    global.statistics_popup_list_size = 300; // Track height
    
    if (global.statistics_popup_max_scroll <= 0)
    {
        _inst_slider.x = -100; // Hide
    }
    
    // --- CREATE ITEMS ---
    // Configure Shader for Scroll Layer
    obj_Menu_Control_Render.surface_index_shader[@ _popup_scroll_layer] = {
        id: shd_Menu_Settings_Fade, 
        u_FadeStart: 0.1, 
        u_FadeEnd: 0.9,
        no_dim: true // No extra dim for the text layer, keeps it bright
    }
    
    var _gui_y_start = (_inst_slider.ystart / room_height) * global.gui_height; 
    var _gui_y_end = ((_inst_slider.ystart + 300) / room_height) * global.gui_height;
    
    obj_Menu_Control_Render.surface_index_boundary[@ _popup_scroll_layer] = {
        y_min: _gui_y_start,
        y_max: _gui_y_end
    }

    var _start_y = _inst_slider.ystart;
    
    for (var i = 0; i < _count; ++i)
    {
        var _item = _full_list[i];
        var _y_pos = _start_y + (i * _item_height);
        
        with (instance_create_layer(_popup_x + 100, _y_pos, "Instances", obj_Menu_Anchor))
        {
            is_popup_stat = true;
            name = _item.name;
            
            menu_layer = _logic_layer;
            surface_index = _popup_scroll_layer;
            
            if (variable_struct_exists(_item, "value"))
            {
                value = _item.value;
                on_draw = function(_x, _y, _xscale, _yscale)
                {
                    render_text(x * _xscale, y * _yscale, name, _xscale, _yscale);
                    render_text((x + 400) * _xscale, y * _yscale, value, _xscale, _yscale, 0, c_gray);
                }
            }
            else // Header
            {
                on_draw = function(_x, _y, _xscale, _yscale)
                {
                    draw_set_halign(fa_center);
                    render_text((x + 200) * _xscale, y * _yscale, name, _xscale * 1.2, _yscale * 1.2, 0, c_yellow);
                    draw_set_halign(fa_left);
                }
            }
            
            array_push(_popup_instances, id);
        }
    }
    
    // Register popup instances for cleanup tracking
    obj_Menu_Control_Button.menu_popup[_base_menu_layer] = _popup_instances;
}
