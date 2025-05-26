var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

var _gui_width  = global.gui_width;
var _gui_height = global.gui_height;

if (game_boolean & GAME_BOOLEAN.IS_PAUSED)
{
    if ((surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE) == 0)
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.PAUSE;
        
        render_pause();
    }
    
    draw_surface(application_surface, 0, 0);
    
    gpu_set_texfilter(true);
    
    draw_surface_ext(surface_pause[@ 1], 0, 0, 4, 4, 0, c_white, global.settings.display_blur);
    
    gpu_set_texfilter(false);
    
    render_gui_vignette(_player_y, _gui_width, _gui_height);
    
    exit;
}

render_gui_vignette(_player_y, _gui_width, _gui_height);

var _gui_multiplier_x = _gui_width  / _camera_width;
var _gui_multiplier_y = _gui_height / _camera_height;

var _gui_mouse_x = (window_mouse_get_x() / window_width)  * _gui_width;
var _gui_mouse_y = (window_mouse_get_y() / window_height) * _gui_height;

global.gui_mouse_x = _gui_mouse_x;
global.gui_mouse_y = _gui_mouse_y;

var _hp     = obj_Player.hp;
var _hp_max = obj_Player.hp_max;

if (_hp > 0)// && (is_opened_gui) && (!is_opened_menu)
{
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.INVENTORY)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.INVENTORY;
        
        gui_inventory(_gui_multiplier_x, _gui_multiplier_y);
        gui_inventory_hotbar(_gui_multiplier_x, _gui_multiplier_y);
    }
    /*
    gui_effects();
    
    if (surface_exists(surface_hp))
    {
        draw_surface(surface_hp, 0, 0);
    }
    */
    var _gui_inventory = global.gui_inventory;
    
    if (is_opened_inventory)
    {
        var _inventory = global.inventory;
        var _inventory_instance = global.inventory_instance;
        var _inventory_length = global.inventory_length;
        
        var _inventory_names = struct_get_names(_inventory);
        var _inventory_names_length = array_length(_inventory_names);
        
        for (var i = 0; i < _inventory_names_length; ++i)
        {
            var _name = _inventory_names[i];
            
            var _data = _gui_inventory[$ _name];
            var _surface_inventory = surface_inventory[$ _name];
            
            var _anchor_type = _data.anchor_type;
            
            var _x = _gui_multiplier_x * (gui_xanchor(_anchor_type, _camera_width)  + _data.surface_xoffset - INVENTORY_GUI_SURFACE_PADDING);
            var _y = _gui_multiplier_y * (gui_yanchor(_anchor_type, _camera_height) + _data.surface_yoffset - INVENTORY_GUI_SURFACE_PADDING);
            
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
        gui_inventory_tooltip(_gui_multiplier_x, _gui_multiplier_y);
        
        if (instance_exists(global.inventory_selected_hover))
        {
            var _ = surface_inventory.tooltip;
            
            draw_sprite_ext(
                spr_Inventory_Tooltip,
                0,
                global.gui_mouse_x - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _gui_multiplier_x),
                global.gui_mouse_y - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _gui_multiplier_y),
                (((_.surface_width  + (GUI_INVENTORY_TOOLTIP_BG_PADDING * 2)) / 7)) * _gui_multiplier_x,
                (((_.surface_height + (GUI_INVENTORY_TOOLTIP_BG_PADDING * 2)) / 7)) * _gui_multiplier_y,
                0,
                c_white,
                1
            );
            
            var _surface = _.surface;
            
            if (surface_exists(_surface))
            {
                draw_surface(_.surface, _gui_mouse_x, _gui_mouse_y);
            }
        }
        */
    }
    else
    {
        var _data = _gui_inventory.hotbar;
        var _surface_inventory = surface_inventory.hotbar;
        
        var _anchor_type = _data.anchor_type;
        
        var _x = _gui_multiplier_x * (gui_xanchor(_anchor_type, _camera_width)  + _data.surface_xoffset - INVENTORY_GUI_SURFACE_PADDING);
        var _y = _gui_multiplier_y * (gui_yanchor(_anchor_type, _camera_height) + _data.surface_yoffset - INVENTORY_GUI_SURFACE_PADDING);
        
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

draw_text(16, 16,
    $"FPS: {fps}\n" +
    $"X/Y: {_player_x}/{_player_y}\n" +
    $"Num: {instance_number(obj_Chunk)}\n" +
    $"Time: {global.world.time}"
);