/// @desc Server Create Event - Initialize server state

// Server is authoritative for game logic
is_integrated = false; // Set to true if running with a local client

// Tick management
server_tick = 0;
timer_network_sync = 0;

// World state (server owns the world)
// Note: chunk_map and world generation are already global

// Client tracking (for integrated server, local client uses socket_id = -1)
// global.network_clients is already initialized by NetworkManager

show_debug_message("[SERVER] obj_Server created");
