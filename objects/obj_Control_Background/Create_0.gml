var _in_biome = bg_get_biome(obj_Player.x, obj_Player.y);
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

bg_sky_colour(_in_biome_data, _in_biome_data);

time_refresh = 0;