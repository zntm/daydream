ylast = 0;

timer_sfx_harvest = 0;

init_entity(100, 100, global.attribute_player, global.player_save_data.uuid);

file_load_world_spawn(global.world_save_data, id);

control_camera_pos(x, y, true);