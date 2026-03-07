if (global.window_width <= 0) || (global.window_height <= 0) exit;

var _camera_x = variable_global_exists("camera_x") ? global.camera_x : 0;
var _camera_y = variable_global_exists("camera_y") ? global.camera_y : 0;

var _camera_width  = variable_global_exists("camera_width") ? global.camera_width : 960;
var _camera_height = variable_global_exists("camera_height") ? global.camera_height : 540;

draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _camera_width, _camera_height, 0, sky_colour_base, 1);
draw_sprite_general(spr_Glow_Corner, 0, 0, 0, 128, 1, _camera_x, _camera_y + _camera_height, _camera_height / 128, _camera_width, 90, sky_colour_gradient, sky_colour_gradient, sky_colour_gradient, sky_colour_gradient, 1);

if (global.settings.display_background)
{
    if (!IS_DEVELOPER_MODE) || (global.dbg_settings[$ "display_background_celestial"])
    {
        var _biome_1 = global.biome_data[$ in_biome];
        var _biome_1_script = (_biome_1 != undefined) ? _biome_1.get_sky_script() : undefined;
        
        var _biome_2 = (in_biome_transition_value > 0) ? global.biome_data[$ in_biome_transition] : undefined;
        var _biome_2_script = (_biome_2 != undefined) ? _biome_2.get_sky_script() : undefined;

        event_emit("background_render", {
            time: global.current_world.time,
            camera_x: _camera_x,
            camera_y: _camera_y,
            camera_width: _camera_width,
            camera_height: _camera_height,
            blend: 1.0 - in_biome_transition_value,
            biome_script: _biome_1_script
        });
        
        if (_biome_2_script != undefined)
        {
            event_emit("background_render", {
                time: global.current_world.time,
                camera_x: _camera_x,
                camera_y: _camera_y,
                camera_width: _camera_width,
                camera_height: _camera_height,
                blend: in_biome_transition_value,
                biome_script: _biome_2_script
            });
        }
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