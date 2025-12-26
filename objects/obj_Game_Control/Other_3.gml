var _player_save_data = global.player_save_data;
var _world_save_data = global.world_save_data;

// Clear all chunks using chunk_map
var _all_chunks = chunk_map_get_all();
var _chunks_length = array_length(_all_chunks);

for (var i = 0; i < _chunks_length; ++i)
{
    chunk_clear(_all_chunks[i]);
}

file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_player_save_data.uuid}", _player_save_data.name, _player_save_data.attire, obj_Player.hp, obj_Player.hp_max, obj_Player.saturation, {});
file_save_player_inventory(_player_save_data);

file_save_world_global(_world_save_data);

with (obj_Player)
{
    file_save_world_spawn(_world_save_data, id);
}