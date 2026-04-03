in_biome = bg_get_biome(round(obj_Player.x / TILE_SIZE), clamp(round(obj_Player.y / TILE_SIZE), 0, global.world_data[$ global.current_world.dimension].get_world_height() - 1));
in_biome_transition = in_biome;
in_biome_transition_value = 0;

music_current = undefined;
music_current_id = "";
music_current_gain = 0;
music_pool = [];
music_pool_length = 0;

sky_colour_base = c_black;
sky_colour_gradient = c_black;
light_colour = c_black;

timer_refresh = 0;
ambience_timer = 0;

var _in_biome_data = global.biome_data[$ in_biome];
if (_in_biome_data == undefined) exit;

bg_sync_biome_music(in_biome);

bg_sky_colour(_in_biome_data, _in_biome_data);

sky_scripts = {}

/* force-load aurora for testing */
if (struct_exists(global.proglang_scripts, "phantasia:sky/borea_aurora"))
{
    proglang_call("@phantasia:sky/borea_aurora", [], id);
    sky_scripts[$ "@phantasia:sky/borea_aurora"] = true;
}

init_background_clouds();
