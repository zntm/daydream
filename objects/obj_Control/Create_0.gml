randomize();

global.worldgen_noise_surface_biome = {}

show_debug_overlay(true);

audio_play_sound(global.music_data[$ "phantasia:phantasia"].get_audio(), 0, true);

global.world = {
    seed: random_get_seed(),
    dimension: "phantasia:playground"
}

obj_Player.y = global.world_data[$ global.world.dimension].get_surface_start() * TILE_SIZE;