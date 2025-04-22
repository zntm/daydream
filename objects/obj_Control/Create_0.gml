randomize();

show_debug_overlay(true);

audio_play_sound(global.music_data[$ "phantasia:phantasia"].get_audio(), 0, true);

global.world = {
    seed: random_get_seed(),
    dimension: "phantasia:playground",
    time: 0
}

obj_Player.y = global.world_data[$ global.world.dimension].get_surface_start() * TILE_SIZE;

global.structure_range_surface = {
    min:  infinity,
    max: -infinity
}

var _splash_data = global.splash_data;
var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];

window_set_caption($"{PROGRAM_NAME}: {array_choose(((chance(0.5)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data[$ "default"])}");