timer_sfx_harvest = 0;

// Multiplayer & Identity Initialization
// These may be set via the struct parameter in instance_create_depth
if (!variable_instance_exists(id, "is_local")) is_local = true;
if (!variable_instance_exists(id, "uuid"))     uuid = global.current_player.uuid;


// Peer tracking (relay system)
peer_id = undefined;       // Relay peer ID (for host tracking remote players)


// Interpolation state (for remote players)
interp_start_x = 0;
interp_start_y = 0;
interp_target_x = 0;
interp_target_y = 0;
interp_timer = 0;
interp_duration = 0.05;  // ~50ms for 20Hz updates

init_entity(100, 100, global.attribute_player, uuid);
PRINT($"[PLAYER] Initialized: UUID={uuid}, is_local={is_local}");

timer_attack = 0;
timer_respawn = 0;
selected_hotbar = 0; // Current hotbar slot (synced)

// Visuals
attire = undefined;
if (is_local)
{
    attire = global.current_player.attire;
}