var _current_player = global.current_player;
var _current_world  = global.current_world;

var _chunks = chunk_map_get_all();

for (var i = array_length(_chunks) - 1; i >= 0; --i)
{
    chunk_clear(_chunks[i]);
}

if (instance_exists(obj_Player))
{
    with (obj_Player)
    {
        if (is_local)
        {
            _current_player.hp = hp;
            _current_player.hp_max = hp_max;
        }
    }
}

file_save_player_global(_current_player);
file_save_player_inventory(_current_player);

file_save_world_global(_current_world);

with (obj_Player)
{
    if (is_local) file_save_world_spawn(_current_world, id);
}