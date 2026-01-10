timer_sfx_harvest = 0;

// Multiplayer state
is_local = true;          // True if this is the local player
socket_id = undefined;    // Socket ID (for server tracking remote players)
network_input = undefined; // Input received from network (for remote players)

init_entity(100, 100, global.attribute_player, global.player_save_data.uuid);

timer_attack = 0;