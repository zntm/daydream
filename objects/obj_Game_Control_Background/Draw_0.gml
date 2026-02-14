if (global.window_width <= 0) || (global.window_height <= 0) exit;

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _camera_width, _camera_height, 0, sky_colour_base, 1);
draw_sprite_general(spr_Glow_Corner, 0, 0, 0, 128, 1, _camera_x, _camera_y + _camera_height, _camera_height / 128, _camera_width, 90, sky_colour_gradient, sky_colour_gradient, sky_colour_gradient, sky_colour_gradient, 1);

if (global.settings.display_background)
{
    if (!IS_DEVELOPER_MODE) || (global.dbg_settings[$ "display_background_celestial"])
    {
        event_emit("background_render", {
            time: global.world_save_data.time,
            camera_x: _camera_x,
            camera_y: _camera_y,
            camera_width: _camera_width,
            camera_height: _camera_height
        });
    }
    
    if (!IS_DEVELOPER_MODE) || (global.dbg_settings[$ "display_background_clouds"] ?? true)
    {
        render_background_clouds(_camera_x, _camera_y, _camera_width, _camera_height);
    }
    
    if (!IS_DEVELOPER_MODE) || (global.dbg_settings[$ "display_background_parallax"])
    {
        render_background(_camera_x, _camera_y, _camera_width, _camera_height);
    }
}