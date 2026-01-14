/// @desc Server CleanUp Event

show_debug_message("[SERVER] obj_Server destroyed");

// Save world data if we were running as server
if (global.network_role == NETWORK_ROLE.SERVER)
{
    file_save_world_global(global.world_save_data);
}
