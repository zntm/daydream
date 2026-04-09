/// @desc Controls the behavior of a dropped item entity, handling client-side interpolation, lifetime expiration, physics, rotation, and item pickup logic.
function control_item_drop()
{
    /* client: interpolate position from server data */
    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        if (variable_instance_exists(self, "interp_start_x"))
        {
            interp_timer += 1 / GAME_TICK;
            
            var _t = clamp(interp_timer / interp_duration, 0, 1);
            
            x = lerp(interp_start_x, interp_target_x, _t);
            y = lerp(interp_start_y, interp_target_y, _t);
        }
        
        exit;
    }
    
    var _despawn_modifier = max(0, despawn_speed_modifier ?? 1);
    liquid_id = "";

    var _tile_x = floor(x / TILE_SIZE);
    var _tile_y = floor(y / TILE_SIZE);
    var _liquid_tile = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_LIQUID);

    if (_liquid_tile != TILE_EMPTY)
    {
        var _liquid_id = _liquid_tile.get_id();
        var _liquid_data = global.item_data[$ _liquid_id];

        if (_liquid_data != undefined) && (_liquid_data.is_liquid())
        {
            liquid_id = _liquid_id;
            _despawn_modifier = max(_despawn_modifier, liquid_get_item_drop_despawn_modifier(_liquid_id));
        }
    }

    timer_life -= (1 / GAME_TICK) * _despawn_modifier;
    
    if (timer_life <= 0)
    {
        delete item;
        
        global.spatial_grid.remove(physics_body);
        
        instance_destroy();
        
        exit;
    }
    
    control_physics_item_drop(id);
    
    if (id[$ "is_attracted"])
    {
        image_angle = point_direction(x, y, inst.x, inst.y);
    }
    else if (physics_body.collision.ground)
    {
        image_angle = 0;
    }
    else if (physics_body.vel_x != 0) && (physics_body.vel_y != 0)
    {
        image_angle = point_direction(x, y, x + physics_body.vel_x, y + physics_body.vel_y);
    }
    
    physics_body.sync_from_instance(id);
    
    global.spatial_grid.update(physics_body);
    
    if (timer_pickup > 0) || (!instance_exists(inst)) || (!place_meeting(x, y, inst)) exit;
    
    var _inv_target = global.inventory;
    
    var _is_relay_host = (global.network_role == RELAY_ROLE.HOST);
    
    /* resolve inventory target for remote players on host */
    if (_is_relay_host) && (!inst.is_local)
    {
        var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(inst);
        
        if (_peer != undefined)
        {
            _inv_target = _peer.inventory;
        }
    }
    
    var _changed_slots = [];
    
    var _amount_before = item.get_amount();
    
    item = inventory_give(x, y, item, _inv_target, true, _changed_slots);
    
    if (!_is_relay_host)
    {
        sfx_diegetic_play(obj_Player.audio_emitter, x, y, "phantasia:sfx/item/collect", global.settings.audio_sfx);
        
        inventory_refresh_craftable();
    }
    
    var _collected;
    
    if (item == undefined)
    {
        global.spatial_grid.remove(physics_body);
        
        instance_destroy();
        
        _collected = _amount_before;
    }
    else
    {
    	_collected = _amount_before - item.get_amount();
    }
    
    event_emit(new EventDataEntityItemCollect(inst, item, _collected));
    
    /* sync changed inventory slots to the collecting peer */
    if (_is_relay_host)
    {
        var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(inst);
        
        if (_peer != undefined)
        {
            for (var i = array_length(_changed_slots) - 1; i >= 0; --i)
            {
                var _idx = _changed_slots[i];
                
                relay_send_inventory_update(_peer.peer_id, "base", _idx, _inv_target.base[_idx]);
            }
        }
    }
}
