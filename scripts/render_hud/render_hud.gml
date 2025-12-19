function render_hud(_gui_width, _gui_height)
{
    var _gui_scale = global.gui_scale;
    
    var _gui_scale_width  = _gui_scale * (_gui_width  / 960);
    var _gui_scale_height = _gui_scale * (_gui_height / 540);
    
    var _hp     = obj_Player.hp;
    var _hp_max = obj_Player.hp_max;
    
    if (_hp > 0) && (is_opened & IS_OPENED_BOOLEAN.GUI) && !(is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        // Note: Hotbar and inventory rendering now handled by modular GUI system
        // (GUISlot components in global.gui_root)
        
        // Craftable panel now handled by modular GUI system
        
        // HP bar rendering
        if (surface_refresh & SURFACE_REFRESH_BOOLEAN.HP)
        {
            surface_refresh ^= SURFACE_REFRESH_BOOLEAN.HP;
            
            gui_hp(_hp, _hp_max);
        }
        
        if (surface_exists(surface_hp))
        {
            var _x = gui_xanchor(GUI_ANCHOR.TOP_RIGHT, _gui_width,  _gui_scale_width) - (_gui_scale_width * 13 * min(GUI_HP_ROW_LENGTH, ceil(_hp_max / GUI_HP_PER_SPRITE)));
            var _y = gui_yanchor(GUI_ANCHOR.TOP_RIGHT, _gui_height, _gui_scale_height);
            
            var _header = string(loca_translate("phantasia:gui.hp.header"), _hp, _hp_max);
            
            draw_set_halign(fa_right);
            
            render_text(_x + (surface_get_width(surface_hp) * _gui_scale_width), _y, _header, _gui_scale_width * 0.75, _gui_scale_height * 0.75);
            
            draw_set_halign(fa_left);
            
            draw_surface_ext(surface_hp, _x, _y + (_gui_scale_height * string_height(_header) * global.loca_font_scale * 0.75), _gui_scale_width, _gui_scale_height, 0, c_white, 1);
        }
        
        var _gui_inventory = global.gui_inventory;
        
        if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
        {
            // Craftable panel rendering handled by modular GUI
            
            // Tooltip rendering
            var _inst = global.inventory_selected_hover;
            
            if (instance_exists(_inst))
            {
                if (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
                {
                    gui_inventory_tooltip(_gui_scale_width, _gui_scale_height);
                    
                    var _tooltip = surface_inventory.tooltip;
                    
                    var _surface_tooltip = _tooltip.surface;
                    
                    if (surface_exists(_surface_tooltip))
                    {
                        var _window_width  = global.window_width;
                        var _window_height = global.window_height;
                        
                        var _gui_mouse_x = (window_mouse_get_x() / _window_width)  * _gui_width;
                        var _gui_mouse_y = (window_mouse_get_y() / _window_height) * _gui_height;
                        
                        var _tooltip_x = _gui_mouse_x + (GUI_TOOLTIP_XOFFSET * _gui_scale_width);
                        var _tooltip_y = _gui_mouse_y + (GUI_TOOLTIP_YOFFSET * _gui_scale_height);
                        
                        draw_sprite_ext(
                            spr_Inventory_Tooltip,
                            0,
                            _tooltip_x - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _gui_scale_width),
                            _tooltip_y - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _gui_scale_height),
                            (((_tooltip.surface_width  + (GUI_INVENTORY_TOOLTIP_BG_PADDING)) / 14)) * _gui_scale_width,
                            (((_tooltip.surface_height + (GUI_INVENTORY_TOOLTIP_BG_PADDING)) / 14)) * _gui_scale_height,
                            0,
                            c_white,
                            1
                        );
                        
                        draw_surface(_surface_tooltip, _tooltip_x, _tooltip_y);
                    }
                }
            }
        }
        // Note: Hotbar rendering when inventory is closed is now handled by modular GUI
    }
}
