var _in_biome = bg_get_biome(round(obj_Player.x / TILE_SIZE), clamp(round(obj_Player.y / TILE_SIZE), 0, global.world_data[$ global.world_save_data.dimension].get_world_height() - 1));
var _in_biome_data = global.biome_data[$ _in_biome];

in_biome = _in_biome;
in_biome_transition = _in_biome;

in_biome_transition_value = 0;

music_current = undefined;
music_current_id = "";

var _music = _in_biome_data.get_music();

if (_music != undefined)
{
    bg_play_music(array_choose(_music));
}

music_pool = [];
music_pool_length = 0;

sky_colour_base = c_black;
sky_colour_gradient = c_black;

light_colour = c_black;

bg_sky_colour(_in_biome_data, _in_biome_data);

timer_refresh = 0;