var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

var _gui_width  = global.gui_width;
var _gui_height = global.gui_height;

if (is_opened & IS_OPENED_BOOLEAN.PAUSE)
{
    if !(surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE) || (!surface_exists(surface_pause[0])) || (!surface_exists(surface_pause[1]))
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.PAUSE;
        
        render_pause();
    }
    
    draw_surface(application_surface, 0, 0);
    
    gpu_set_texfilter(true);
    
    draw_surface_ext(surface_pause[@ 1], 0, 0, GUI_PAUSE_BLUR_RESIZE * (_camera_width / _gui_width), GUI_PAUSE_BLUR_RESIZE * (_camera_height / _gui_height), 0, c_white, global.settings.display_blur);
    
    gpu_set_texfilter(false);
    
    render_gui_vignette(_player_y, _gui_width, _gui_height);
    
    gpu_set_blendmode(bm_normal);
    
    exit;
}

var _gui_mouse_x = (window_mouse_get_x() / _window_width)  * _gui_width;
var _gui_mouse_y = (window_mouse_get_y() / _window_height) * _gui_height;

var _gui_multiplier_x = _gui_width  / _camera_width;
var _gui_multiplier_y = _gui_height / _camera_height;

render_gui_vignette(_player_y, _gui_width, _gui_height);

global.gui_mouse_x = _gui_mouse_x;
global.gui_mouse_y = _gui_mouse_y;

var _hp     = obj_Player.hp;
var _hp_max = obj_Player.hp_max;

if (_hp > 0) && (is_opened & IS_OPENED_BOOLEAN.GUI) && !(is_opened & IS_OPENED_BOOLEAN.MENU)
{
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
        
        gui_inventory_hotbar(_gui_multiplier_x, _gui_multiplier_y);
    }
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
        
        gui_inventory(_gui_multiplier_x, _gui_multiplier_y);
    }
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
        
        gui_inventory_craftable(_gui_multiplier_x, _gui_multiplier_y);
    }
    /*
    gui_effects();
    
    if (surface_exists(surface_hp))
    {
        draw_surface(surface_hp, 0, 0);
    }
    */
    var _gui_inventory = global.gui_inventory;
    
    if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        var _inventory = global.inventory;
        var _inventory_instance = global.inventory_instance;
        var _inventory_length = global.inventory_length;
        
        var _inventory_names = global.inventory_names;
        var _inventory_names_length = array_length(_inventory_names);
        
        for (var i = 0; i < _inventory_names_length; ++i)
        {
            var _name = _inventory_names[i];
            
            var _data = _gui_inventory[$ _name];
            var _surface_inventory = surface_inventory[$ _name];
            
            var _anchor_type = _data.anchor_type;
            
            var _x = _gui_multiplier_x * (gui_xanchor(_anchor_type, _camera_width)  + _data.surface_xoffset - GUI_INVENTORY_SURFACE_PADDING);
            var _y = _gui_multiplier_y * (gui_yanchor(_anchor_type, _camera_height) + _data.surface_yoffset - GUI_INVENTORY_SURFACE_PADDING);
            
            var _surface_slot = _surface_inventory.surface_slot;
            
            if (surface_exists(_surface_slot))
            {
                draw_surface_ext(_surface_slot, _x, _y, _gui_multiplier_x * INVENTORY_SLOT_SCALE, _gui_multiplier_y * INVENTORY_SLOT_SCALE, 0, c_white, 1);
            }
            
            var _surface_item = _surface_inventory.surface_item;
            
            if (surface_exists(_surface_item))
            {
                draw_surface(_surface_item, _x, _y);
            }
        }
        
        var _data = _gui_inventory.craftable;
        var _surface_inventory = surface_inventory.craftable;
        
        var _anchor_type = _data.anchor_type;
        
        var _x = _gui_multiplier_x * (gui_xanchor(_anchor_type, _camera_width)  + _data.surface_xoffset - GUI_INVENTORY_SURFACE_PADDING);
        var _y = _gui_multiplier_y * (gui_yanchor(_anchor_type, _camera_height) + _data.surface_yoffset - GUI_INVENTORY_SURFACE_PADDING);
        
        var _surface_slot = _surface_inventory.surface_slot;
        
        if (surface_exists(_surface_slot))
        {
            draw_surface_ext(_surface_slot, _x, _y, _gui_multiplier_x * INVENTORY_SLOT_SCALE, _gui_multiplier_y * INVENTORY_SLOT_SCALE, 0, c_white, 1);
        }
        
        var _surface_item = _surface_inventory.surface_item;
        
        if (surface_exists(_surface_item))
        {
            draw_surface(_surface_item, _x, _y);
        }
        
        var _inst = global.inventory_selected_hover;
        
        if (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            gui_inventory_tooltip(_gui_multiplier_x, _gui_multiplier_y);
        }
    }
    else
    {
        var _data = _gui_inventory.hotbar;
        var _surface_inventory = surface_inventory.hotbar;
        
        var _anchor_type = _data.anchor_type;
        
        var _x = _gui_multiplier_x * (gui_xanchor(_anchor_type, _camera_width)  + _data.surface_xoffset - GUI_INVENTORY_SURFACE_PADDING);
        var _y = _gui_multiplier_y * (gui_yanchor(_anchor_type, _camera_height) + _data.surface_yoffset - GUI_INVENTORY_SURFACE_PADDING);
        
        var _surface_slot = _surface_inventory.surface_slot;
        
        if (surface_exists(_surface_slot))
        {
            draw_surface_ext(_surface_slot, _x, _y, _gui_multiplier_x * INVENTORY_SLOT_SCALE, _gui_multiplier_y * INVENTORY_SLOT_SCALE, 0, c_white, 1);
        }
        
        var _surface_item = _surface_inventory.surface_item;
        
        if (surface_exists(_surface_item))
        {
            draw_surface(_surface_item, _x, _y);
        }
    }
    /*
    if (is_opened_inventory) && (surface_exists(surface_craftable))
    {
        draw_surface(surface_craftable, 0, 0);
    }
    */
}

gpu_set_blendmode(bm_normal);