if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) exit;

var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

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
    
    surface_reset_target();
    
    surface_save(_surface, $"{PROGRAM_DIRECTORY_SCREENSHOTS}/{current_year}-{current_month}-{current_day}_{current_hour}.{current_minute}.{current_second}.png");
    
    surface_free(_surface);
}

gpu_set_blendmode(bm_normal);