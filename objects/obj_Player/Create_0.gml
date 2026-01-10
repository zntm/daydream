timer_sfx_harvest = 0;

// Multiplayer state
is_local = true;          // True if this is the local player
socket_id = undefined;    // Socket ID (for server tracking remote players)
network_input = undefined; // Input received from network (for remote players)

// Client-Side Prediction state
input_history = [];          // Ring buffer of { tick, input, predicted_x, predicted_y }
input_history_max = 128;     // Max inputs to keep for reconciliation
current_tick = 0;            // Local tick counter
last_server_tick = 0;        // Last tick acknowledged by server
server_verified_x = 0;       // Last server-verified position X
server_verified_y = 0;       // Last server-verified position Y

// Interpolation state (for remote players)
interp_start_x = 0;
interp_start_y = 0;
interp_target_x = 0;
interp_target_y = 0;
interp_timer = 0;
interp_duration = 0.05;  // ~50ms for 20Hz updates

init_entity(100, 100, global.attribute_player, global.player_save_data.uuid);

timer_attack = 0;
timer_respawn = 0;
selected_hotbar = 0; // Current hotbar slot (synced)