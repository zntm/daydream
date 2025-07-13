var _player_save_data = global.player_save_data;
var _world_save_data = global.world_save_data;

with (obj_Chunk)
{
    chunk_clear(id);
}

file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_player_save_data.uuid}", _player_save_data.name, _player_save_data.attire, obj_Player.hp, obj_Player.hp_max, {});
file_save_player_inventory(_player_save_data);

file_save_world_global(_world_save_data);

with (obj_Player)
{
    file_save_world_spawn(_world_save_data, id);
}