randomize();

show_debug_overlay(true);

audio_play_sound(global.music_data[$ "phantasia:phantasia"].get_audio(), 0, true);

global.world = {
    seed: random_get_seed(),
    dimension: "phantasia:playground",
    time: 0,
    wind: choose(-1, 1)
    // wind: random_range(-1, 1)
}

obj_Player.y = (worldgen_get_surface_height(0, global.world.seed) - 1) * TILE_SIZE;

global.camera_width  = camera_get_view_width(view_camera[0]);
global.camera_height = camera_get_view_height(view_camera[0]);

var _camera_x = obj_Player.x - (global.camera_width  / 2);
var _camera_y = obj_Player.y - (global.camera_height / 2);

global.camera_x = _camera_x;
global.camera_y = _camera_y;

global.camera_x_real = _camera_x;
global.camera_y_real = _camera_y;

control_camera_pos(_camera_x, _camera_y);

global.structure_range_surface = {
    min:  infinity,
    max: -infinity
}

var _splash_data = global.splash_data;
var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];

window_set_caption($"{PROGRAM_NAME}: {array_choose(((chance(0.5)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data[$ "default"])}");