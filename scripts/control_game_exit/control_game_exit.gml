/// @desc Saves the world and player, frees all surfaces, disconnects from relay, and returns to main menu.
///       Processes one chunk save per frame until all queued chunks are saved.
function control_game_exit()
{
    if (chunk_saved_count >= chunk_saved_count_max)
    {
        audio_stop_all();

        var _current_player = global.current_player;
        var _current_world  = global.current_world;

        var _lp = noone;
        with (obj_Player) { if (is_local) { _lp = id; break; } }

        if (_lp != noone)
        {
            _current_player.hp     = _lp.hp;
            _current_player.hp_max = _lp.hp_max;
        }

        file_save_player_global(_current_player);
        file_save_player_inventory(_current_player);

        file_save_world_global(_current_world);

        with (obj_Player)
        {
            if (is_local) file_save_world_spawn(_current_world, id);
        }

        window_progress(window_progress_none);

        var _names  = struct_get_names(obj_Game_Control.surface_inventory);
        var _length = array_length(_names);

        for (var i = _length - 1; i >= 0; --i)
        {
            var _data = obj_Game_Control.surface_inventory[$ _names[i]];

            if (surface_exists(_data[$ "surface"]      ?? -1)) surface_free(_data.surface);
            if (surface_exists(_data[$ "surface_slot"] ?? -1)) surface_free(_data.surface_slot);
            if (surface_exists(_data[$ "surface_item"] ?? -1)) surface_free(_data.surface_item);
        }

        if (global.relay != undefined) && (global.relay.role != RELAY_ROLE.NONE)
        {
            global.relay_manager.leave_session();
        }

        world_cleanup();

        room_goto(rm_Menu_Title);

        exit;
    }

    ++chunk_saved_count;

    if (os_type == os_windows)
    {
        window_progress(window_progress_normal, chunk_saved_count, chunk_saved_count_max);
    }

    var _chunks = chunk_map_get_all();

    for (var i = array_length(_chunks) - 1; i >= 0; --i)
    {
        chunk_clear(_chunks[i]);
    }
}
