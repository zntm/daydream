timer_sfx_harvest = 0;

// Multiplayer & Identity Initialization
// These may be set via the struct parameter in instance_create_depth
if (!variable_instance_exists(id, "is_local")) is_local = true;
if (!variable_instance_exists(id, "uuid"))     uuid = global.player_save_data.uuid;

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

init_entity(100, 100, global.attribute_player, uuid);
show_debug_message($"[PLAYER] Initialized: UUID={uuid}, is_local={is_local}");

timer_attack = 0;
timer_respawn = 0;
selected_hotbar = 0; // Current hotbar slot (synced)
combo_count = 0;
timer_combo = 0;
stamina = 100;
stamina_max = 100;
stamina_regen_timer = 0;
charge_time = 0;

// Visuals
attire = undefined;
if (is_local)
{
    attire = global.player_save_data.attire;
}

harvest_progress = {}
harvest_last_key = undefined;
cooldown_build = 0;
cooldown_harvest = 0;

// Initialize Stat Bars (HP/Stamina)
if (is_local && variable_global_exists("gui_panel_hotbar_modular") && global.gui_panel_hotbar_modular != undefined) {
    proglang_call("phantasia:gui/stat_bars", [{ player: id, parent: global.gui_panel_hotbar_modular }]);
}