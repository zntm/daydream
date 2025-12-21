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

var _gui_scale = global.gui_scale;

var _gui_scale_width  = _gui_scale * (_gui_width  / 960);
var _gui_scale_height = _gui_scale * (_gui_height / 540);

if (is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD)
{
    if !(surface_refresh & SURFACE_REFRESH_BOOLEAN.GENERATING_WORLD) || (!surface_exists(surface_pause[0])) || (!surface_exists(surface_pause[1]))
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.GENERATING_WORLD;
        
        render_pause();
    }
    
    var _display_blur = global.settings.display_blur;
    
    if (_display_blur > 0)
    {
        gpu_set_texfilter(true);
        
        draw_surface_stretched_ext(surface_pause[@ 1], 0, 0, _gui_width + GUI_PAUSE_BLUR_RESIZE, _gui_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);
        
        gpu_set_texfilter(false);
    }
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    render_text(_gui_width / 2, _gui_height / 2, loca_translate("phantasia:menu.loading_world.title"), 2 * _gui_scale, 2 * _gui_scale);
    
    draw_set_align(_halign, _valign);
    
    exit;
}

if (is_opened & (IS_OPENED_BOOLEAN.PAUSE | IS_OPENED_BOOLEAN.EXIT))
{
    if !(surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE) || (!surface_exists(surface_pause[0])) || (!surface_exists(surface_pause[1]))
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.PAUSE;
        
        render_pause();
    }
    
    var _display_blur = global.settings.display_blur;
    
    if (_display_blur > 0)
    {
        gpu_set_texfilter(true);
        
        draw_surface_stretched_ext(surface_pause[@ 1], 0, 0, _gui_width + GUI_PAUSE_BLUR_RESIZE, _gui_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);
        
        gpu_set_texfilter(false);
    }
    
    exit;
}

var _gui_mouse_x = (window_mouse_get_x() / _window_width)  * _gui_width;
var _gui_mouse_y = (window_mouse_get_y() / _window_height) * _gui_height;

render_gui_vignette(_player_y, _gui_width, _gui_height);

var _hp     = obj_Player.hp;
var _hp_max = obj_Player.hp_max;

render_hud(_gui_width, _gui_height);

// Draw modular GUI
if (global.gui_root != undefined)
{
    global.gui_root.draw();
}

// Draw deferred text
var _deferred_text_length = array_length(global.gui_deferred_text);

if (_deferred_text_length > 0)
{
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    
    for (var i = 0; i < _deferred_text_length; ++i)
    {
        var _ = global.gui_deferred_text[i];
        
        if (variable_struct_exists(_, "halign")) draw_set_halign(_.halign);
        else draw_set_halign(fa_right);
        
        if (variable_struct_exists(_, "valign")) draw_set_valign(_.valign);
        else draw_set_valign(fa_bottom);
        
        render_text(_.x, _.y, _.text, _.xscale, _.yscale, 0, _.colour, _.alpha);
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    array_resize(global.gui_deferred_text, 0);
}

// Display held item name
if !(is_opened & IS_OPENED_BOOLEAN.INVENTORY)
{
    var _item = global.inventory.base[global.inventory_selected_hotbar];
    
    if (_item != INVENTORY_EMPTY)
    {
        var _data = global.item_data[$ _item.get_id()];
        
        var _text_x = _gui_width / 2;
        var _text_y = _gui_height - (INVENTORY_SLOT_DIMENSION_SCALED + (96 * _gui_scale));
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        
        render_text(_text_x, _text_y, loca_translate($"{_data.get_namespace()}:item.{_data.get_id()}.name"), 1.5 * _gui_scale, 1.5 * _gui_scale);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

gpu_set_blendmode(bm_normal);