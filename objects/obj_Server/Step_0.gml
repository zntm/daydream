/// @desc Server Step Event - Authoritative game tick

// Only run server logic if we are the server or integrated
if (global.network_role != NETWORK_ROLE.SERVER && global.network_role != NETWORK_ROLE.INTEGRATED) exit;

var _delta_time = global.delta_time;

// Authoritative game tick
server_tick++;

// Note: control_gametick is currently still called from obj_Game_Control
// This will be migrated here in a future refactor

// Network Time Sync (broadcast to clients)
timer_network_sync += _delta_time;

if (timer_network_sync >= 1.0)
{
    timer_network_sync = 0;
    
    var _buffer = packet_create(PACKET_TYPE.TIME_UPDATE);
    packet_write_time_update(_buffer, global.world_save_data.time);
    network_broadcast_packet(_buffer);
    buffer_delete(_buffer);
}

// Note: Entity updates are currently still handled in obj_Game_Control
// This will be migrated here in a future refactor

