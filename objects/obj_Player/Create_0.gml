timer_sfx_harvest = 0;

init_entity(100, 100, global.attribute_player, global.player_save_data.uuid);

call_later(60, time_source_units_frames, function() { effect_set("phantasia:bad_luck", 60 * 60, 1, obj_Player); });

timer_attack = 0;