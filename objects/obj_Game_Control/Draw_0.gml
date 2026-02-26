if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) exit;

var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

BLENDMODE_TINT;

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

/* render lightning bolts on top of the scene */
global.lightning_pool.render();

/* register colorgrade pass once */
if (!__colorgrade_pass_registered)
{
    __colorgrade_pass_registered = true;
    
    global.post_process.add_pass(shd_Colorgrade, function()
    {
        var _world_data = global.world_data[$ global.current_world.dimension];
        var _weather    = global.current_world.weather;
        var _storm      = clamp(_weather.storm, 0, 1);
        
        /* base from world data, storm desaturates on top */
        var _saturation    = _world_data.get_colorgrade_saturation() * (1 - _storm * 0.6);
        var _tint_r        = _world_data.get_colorgrade_tint_r();
        var _tint_g        = _world_data.get_colorgrade_tint_g();
        var _tint_b        = _world_data.get_colorgrade_tint_b();
        var _tint_strength = _world_data.get_colorgrade_tint_strength();
        
        /* storm layers a blue-grey tint on top */
        if (_storm > 0)
        {
            var _storm_r = 0.75;
            var _storm_g = 0.82;
            var _storm_b = 0.90;
            var _storm_t = _storm * 0.4;
            
            _tint_r        = lerp(_tint_r, _storm_r, _storm_t);
            _tint_g        = lerp(_tint_g, _storm_g, _storm_t);
            _tint_b        = lerp(_tint_b, _storm_b, _storm_t);
            _tint_strength = clamp(_tint_strength + _storm_t, 0, 1);
        }
        
        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_saturation"),
            _saturation
        );
        
        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_tint_color"),
            _tint_r, _tint_g, _tint_b
        );
        
        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_tint_strength"),
            _tint_strength
        );
    }, true);
}

/* apply all post-processing passes */
global.post_process.apply(
    surface_get_width(application_surface),
    surface_get_height(application_surface)
);
/*
if (!is_opened)
{
    with (obj_Player)
    {
        if (is_local)
        {
            var _mx = mouse_x;
            var _my = mouse_y;
            
            var _tx = floor(_mx / TILE_SIZE);
            var _ty = floor(_my / TILE_SIZE);
            
            var _reach = attribute.get_harvest_reach();
            
            var _dist = point_distance(x, y - 20, _mx, _my);
            
            if (_dist <= _reach)
            {
                var _x = _tx * TILE_SIZE;
                var _y = _ty * TILE_SIZE;
                
                draw_set_colour(c_white);
                draw_set_alpha(0.4);
                draw_rectangle(_x, _y, _x + TILE_SIZE - 1, _y + TILE_SIZE - 1, true);
                draw_set_alpha(1.0);
            }
            
            break;
        }
    }
}
*/
if (keyboard_check_pressed(vk_f2))
{
    sfx_play("phantasia:sfx/menu/screenshot", global.settings.audio_sfx);
    
    var _surface = surface_create(_window_width, _window_height);
    
    surface_set_target(_surface);
    
    draw_surface_stretched(application_surface, 0, 0, _window_width, _window_height);
    draw_surface_stretched(application_surface, 0, 0, _window_width, _window_height);
    
    var _gui_scale = global.gui_scale;
    
    var _gui_scale_width  = _gui_scale * (global.gui_width  / 960);
    var _gui_scale_height = _gui_scale * (global.gui_height / 540);
    
    render_lighting(_camera_x, _camera_y, _window_width * _gui_scale_width, _window_height * _gui_scale_height);
    
    render_gui_vignette(obj_Player.y, _window_width, _window_height);
    
    render_hud(_window_width, _window_height);
    
    // Draw modular GUI for screenshot
    if (global.gui_root != undefined)
    {
        global.gui_root.draw();
    }
    
    // Draw new declarative UI for screenshot
    if (variable_global_exists("ui_hotbar") && global.ui_hotbar != undefined) {
        ui_draw(global.ui_hotbar);
    }
    if (variable_global_exists("ui_inventory") && global.ui_inventory != undefined && global.ui_inventory.visible) {
        ui_draw(global.ui_inventory);
    }
    
    // Draw deferred text for screenshot
    var _deferred_text_length = array_length(global.gui_deferred_text);
    
    if (_deferred_text_length > 0)
    {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        
        for (var i = 0; i < _deferred_text_length; ++i)
        {
            var _ = global.gui_deferred_text[i];
            
            render_text(_.x, _.y, _.text, _.xscale, _.yscale, 0, _.colour, _.alpha);
        }
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        array_resize(global.gui_deferred_text, 0);
    }
    
    surface_reset_target();
    
    surface_save(_surface, $"{PROGRAM_DIRECTORY_SCREENSHOTS}/{current_year}-{current_month}-{current_day}_{current_hour}.{current_minute}.{current_second}.png");
    
    surface_free(_surface);
}

BLENDMODE_NORMAL;