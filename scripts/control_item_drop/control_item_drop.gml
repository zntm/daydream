function control_item_drop()
{
    timer_life -= 1 / GAME_TICK;
    
    if (timer_life <= 0)
    {
        delete item;
        
        instance_destroy();
        
        global.spatial_grid.remove(physics_body);
        
        exit;
    }
    
    control_physics_item_drop(id);
    
    if (variable_instance_exists(id, "is_attracted") && (is_attracted))
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
    
    // Update spatial grid
    global.spatial_grid.update(physics_body);
    /*
    var _id = item.get_id();
    var _amount = item.get_amount();
    
    var _data = global.item_data[$ _id];
    
    var _inventory_max = _data.get_inventory_max();
    
    if (_amount < _inventory_max)
    {
        var _inst = instance_place(x, y, obj_Item_Drop);
        
        if (instance_exists(_inst))
        {
            var _item = _inst.item;
            
            if (_id == _item.get_id())
            {
                var _amount2 = _item.get_amount();
                
                if (_amount + _amount2 <= _inventory_max)
                {
                    item.add_amount(_amount);
                    
                    delete _item;
                    
                    instance_destroy(_inst);
                }
                else
                {
                    item.set_amount(_inventory_max);
                    
                    _item.add_amount(-(_inventory_max - _amount2));
                }
            }
        }
    }
    */
    if (timer_pickup <= 0) && (instance_exists(inst)) && (place_meeting(x, y, inst))
    {
        var _item_before = item;
        var _amount_before = (item != undefined) ? item.get_amount() : 0;
        
        // Multi-player Inventory Sync logic
        var _inv_target = global.inventory;
        var _client = undefined;
        
        if (global.network_role == NETWORK_ROLE.SERVER)
        {
            if (!inst.is_local)
            {
                _client = global.network_clients[? inst.socket_id];
                if (!is_undefined(_client))
                {
                    _inv_target = _client.inventory;
                }
            }
        }
        
        // Perform the give
        item = inventory_give(x, y, item, _inv_target, true);
        
        if (global.network_role != NETWORK_ROLE.SERVER)
        {
            sfx_diegetic_play(obj_Player.audio_emitter, x, y, "phantasia:sfx/item/collect", global.settings.audio_sfx);
        }
        
        // Emit item collected event
        var _collected_amount = _amount_before - ((item != undefined) ? item.get_amount() : 0);
        if (_collected_amount > 0)
        {
            event_emit(new EventDataEntityItemCollect(inst, _item_before, _collected_amount));
            
            // Server: Notify client of inventory change
            if (global.network_role == NETWORK_ROLE.SERVER && !is_undefined(_client))
            {
                // For simplicity, we currently just send updates for the slots that changed.
                // inventory_give doesn't tell us WHICH slots changed easily.
                // We'll need to either:
                // a) Modify inventory_give to return changed indices.
                // b) Send a full inventory update (expensive).
                // c) Guess and check? (bad).
                // For now, let's send a full "base" inventory update or a simplified version.
                // TODO: Optimization - only send changed slots.
                
                // Temporary: Send first 50 slots if anything changed? No, let's just send the whole thing for now to guarantee sync.
                for (var i = 0; i < global.inventory_length.base; ++i)
                {
                    var _slot = _inv_target.base[i];
                    var _iid = (_slot == INVENTORY_EMPTY) ? "" : _slot.get_id();
                    var _iam = (_slot == INVENTORY_EMPTY) ? 0 : _slot.get_amount();
                    network_send_inventory_update(inst.socket_id, "base", i, _iid, _iam);
                }
            }
        }
        
        if (global.network_role != NETWORK_ROLE.SERVER)
        {
            inventory_refresh_craftable();
        }
        
        if (item == undefined) || (item.get_amount() <= 0)
        {
            global.spatial_grid.remove(physics_body);
            instance_destroy();
        }
    }
}