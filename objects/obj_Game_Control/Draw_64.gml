var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _lp = noone;
with (obj_Player) { if (is_local) { _lp = id; break; } }
if (_lp == noone)
{
    ui_editor_draw();

    exit;
}

var _player_x = _lp.x;
var _player_y = _lp.y;

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

var _gui_width  = global.gui_width;
var _gui_height = global.gui_height;

var _gui_scale = global.gui_scale;

var _gui_scale_width  = _gui_scale * (_gui_width  / 960);
var _gui_scale_height = _gui_scale * (_gui_height / 540);

if (is_opened & WORLD_OPENED_BOOL.GENERATING_WORLD)
{
    if !(surface_refresh & SURFACE_REFRESH_BOOL.GENERATING_WORLD)
    {
        surface_refresh |= SURFACE_REFRESH_BOOL.GENERATING_WORLD;
        
        render_pause();
    }
    
    if (surface_exists(surface_pause[1]))
    {
        var _display_blur = global.settings.display_blur;
        
        if (_display_blur > 0)
        {
            gpu_set_texfilter(true);
            
            draw_surface_stretched_ext(surface_pause[@ 1], 0, 0, _gui_width + GUI_PAUSE_BLUR_RESIZE, _gui_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);
            
            gpu_set_texfilter(false);
        }
    }
    else
    {
        draw_clear(c_black);
    }
    
    /* spawn loading ui if not yet created */
    if (!variable_instance_exists(id, "ui_loading")) || (ui_loading == undefined)
    {
        var _loading_def = ui_load("ui/menu/loading.ui");
        
        if (_loading_def != undefined)
        {
            ui_loading_link = {
                loading_text: loca_translate("phantasia:menu.loading_world.title")
            }
            
            ui_loading = ui_spawn(_loading_def, {
                link: ui_loading_link
            });
        }
    }
    
    /* draw loading ui */
    if (ui_loading != undefined)
    {
        /* update to process bindings (loading text) */
        ui_update(ui_loading);
        
        /* ui_draw handles scaling internally via ui_get_base_scale */
        ui_draw(ui_loading);
    }
    
    ui_editor_draw();
    
    exit;
}

if (is_opened & (WORLD_OPENED_BOOL.PAUSE | WORLD_OPENED_BOOL.EXIT))
{
    if !(surface_refresh & SURFACE_REFRESH_BOOL.PAUSE) || (!surface_exists(surface_pause[0])) || (!surface_exists(surface_pause[1]))
    {
        surface_refresh |= SURFACE_REFRESH_BOOL.PAUSE;
        
        render_pause();
    }
    
    var _display_blur = global.settings.display_blur;
    
    if (_display_blur > 0)
    {
        gpu_set_texfilter(true);
        
        draw_surface_stretched_ext(surface_pause[@ 1], 0, 0, _gui_width + GUI_PAUSE_BLUR_RESIZE, _gui_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);
        
        gpu_set_texfilter(false);
    }
    
    /* draw pause ui buttons */
    if (variable_instance_exists(id, "ui_pause")) && (ui_pause != undefined)
    {
        global.ui_hover_consumed = false;
        global.ui_input_consumed = false;
        
        ui_update(ui_pause);
        
        global.gui_root.draw();
    }
    
    ui_editor_draw();
    
    exit;
}

var _gui_mouse_x = (window_mouse_get_x() / _window_width)  * _gui_width;
var _gui_mouse_y = (window_mouse_get_y() / _window_height) * _gui_height;

render_gui_vignette(_player_y, _gui_width, _gui_height);

var _hp     = _lp.hp;
var _hp_max = _lp.hp_max;

/* only draw HUD elements when GUI is toggled on */
if (is_opened & WORLD_OPENED_BOOL.GUI)
{
    render_hud(_gui_width, _gui_height);
    
    // Draw modular GUI (including parented declarative UI instances)
    if (global.gui_root != undefined)
    {
        global.gui_root.draw();
    }
    
    /* draw dynamically spawned UI instances (blueprints, etc.) */
    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);
        
        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];
            
            if (_ui_inst != undefined) {
                // Only draw if the instance's root elements are not parented
                // (otherwise they are drawn via the parent's draw() call, usually gui_root)
                if (array_length(_ui_inst.root_elements) > 0 && _ui_inst.root_elements[0].parent == undefined) {
                    ui_draw(_ui_inst);
                }
            }
        }
    }
    
    // Draw deferred text
    var _deferred_text_length = array_length(global.gui_deferred_text);
    
    if (_deferred_text_length > 0)
    {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        
        for (var i = _deferred_text_length - 1; i >= 0; --i)
        {
            var _ = global.gui_deferred_text[i];
            
            if (struct_exists(_, "halign")) draw_set_halign(_.halign);
            else draw_set_halign(fa_right);
            
            if (struct_exists(_, "valign")) draw_set_valign(_.valign);
            else draw_set_valign(fa_bottom);
            
            render_text(_.x, _.y, _.text, _.xscale, _.yscale, 0, _.colour, _.alpha);
        }
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        array_resize(global.gui_deferred_text, 0);
    }
    
    // Display held item name
    if !(is_opened & WORLD_OPENED_BOOL.INVENTORY)
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
}

gpu_set_blendmode(bm_normal);

ui_editor_draw();