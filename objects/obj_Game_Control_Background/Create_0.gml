var _world_save_data = global.world_save_data;
var _world_seed = _world_save_data.seed;
var _world_height_cells = global.world_data[$ _world_save_data.dimension].get_world_height();

var _p_x_cell = round(obj_Player.x / TILE_SIZE);
var _p_y_cell = clamp(round(obj_Player.y / TILE_SIZE), 0, _world_height_cells - 1);

var _in_biome_id = bg_get_biome(_p_x_cell, _p_y_cell);
var _in_biome_data = global.biome_data[$ _in_biome_id];

in_biome = _in_biome_id;
in_biome_transition = _in_biome_id;
in_biome_transition_value = 0;

var _in_region = global.region_generator.get_region(obj_Player.x, obj_Player.y, 0, _world_seed);
in_region = _in_region;
in_region_transition = _in_region;
in_region_transition_value = 0;

music_current = undefined;
music_current_id = "";

if (_in_biome_data != undefined)
{
    var _music = _in_biome_data.get_music();
    if (_music != undefined)
    {
        bg_play_music(array_choose(_music));
    }
}

music_pool = [];
music_pool_length = 0;

sky_colour_base = c_black;
sky_colour_gradient = c_black;

light_colour = c_black;

bg_sky_colour(in_region, in_region);

timer_refresh = 0;