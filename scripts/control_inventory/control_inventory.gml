function control_inventory()
{
    static __keyboard_hotbar_ord = array_create_ext(INVENTORY_LENGTH.ROW, function(_index)
    {
        return ord(string((_index + 1) % INVENTORY_LENGTH.ROW));
    });
    
    if (keyboard_check_pressed(global.settings.input_keyboard_inventory))
    {
        is_opened ^= IS_OPENED_BOOLEAN.INVENTORY;
        
        if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
        {
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
            
            instance_activate_object(obj_Inventory);
            
            inventory_refresh_crafting_station(true);
        }
        else
        {
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
            
            with (obj_Inventory)
            {
                if (inventory_type == "_craftable")
                {
                    instance_destroy();
                }
            }
            
            var _item = global.inventory.mouse.item;
            
            if (_item != INVENTORY_EMPTY)
            {
                inventory_give(0, 0, _item, global.inventory, false);
                
                global.inventory.mouse.item = INVENTORY_EMPTY;
            }
            
            instance_deactivate_object(obj_Inventory);
            
            inventory_container_close();
        }
    }
    else if (mouse_check_button_pressed(mb_right))
    {
        var _player_x = obj_Player.x;
        var _player_y = obj_Player.y;
        
        var _nearest_dist = TILE_SIZE * 6;
        var _nearest_struct = undefined;
        
        var _chunk_x = floor(_player_x / CHUNK_SIZE_DIMENSION);
        var _chunk_y = floor(_player_y / CHUNK_SIZE_DIMENSION);
        
        for (var _cx = -CHUNK_SIZE; _cx <= CHUNK_SIZE; ++_cx)
        {
            for (var _cy = -CHUNK_SIZE; _cy <= CHUNK_SIZE; ++_cy)
            {
                var _chunk = chunk_map_get((_chunk_x + _cx) * TILE_SIZE, (_chunk_y + _cy) * TILE_SIZE);
                
                if (_chunk == undefined) continue;
                
                var _containers = _chunk.chunk_containers;
                
                for (var k = array_length(_containers) - 1; k >= 0; --k)
                {
                    var _container = _containers[k];
                    
                    var _d = point_distance(_player_x, _player_y, _container.x, _container.y);
                    
                    if (_d <= _nearest_dist)
                    {
                        _nearest_dist = _d;
                        _nearest_struct = _container;
                    }
                }
            }
        }
        
        if (_nearest_struct != undefined)
        {
            inventory_container_open(_player_x, _player_y, _nearest_struct);
        }
    }
    
    var _is_inventory_opened = is_opened & IS_OPENED_BOOLEAN.INVENTORY;
    
    if (_is_inventory_opened)
    {
        inventory_refresh_crafting_station();
    }
    
    for (var i = 0; i < INVENTORY_LENGTH.ROW; ++i)
    {
        if (!keyboard_check_pressed(__keyboard_hotbar_ord[i])) continue;
        
        global.inventory_selected_hotbar = i;
        
        with (obj_Player)
        {
            if (is_local) player_reset_charge();
        }
        
        if (!_is_inventory_opened)
        {
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
            
            break;
        }
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
        
        /* fast switch from inventory to hotbar */
        if (keyboard_check(vk_shift))
        {
            /* convert mouse to gui pos for collision detection */
            var _gui_mouse_x = (window_mouse_get_x() / global.window_width)  * global.gui_width;
            var _gui_mouse_y = (window_mouse_get_y() / global.window_height) * global.gui_height;
            
            var _inst = instance_position(_gui_mouse_x, _gui_mouse_y, obj_Inventory);
            
            if (instance_exists(_inst))
            {
                sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
                
                inventory_switch(_inst.inventory_type, _inst.inventory_index, "base", i);
            }
        }
        
        break;
    }
    
    var _mouse_wheel = mouse_wheel_down() - mouse_wheel_up();
    
    if (_mouse_wheel != 0)
    {
        global.inventory_selected_hotbar = (global.inventory_selected_hotbar + _mouse_wheel + INVENTORY_LENGTH.ROW) % INVENTORY_LENGTH.ROW;
        
        with (obj_Player)
        {
            if (is_local) player_reset_charge();
        }
        
        surface_refresh |= (_is_inventory_opened)
            ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK
            : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
    }

    /* update pos for inventory instances */
    if (_is_inventory_opened)
    {
        control_inventory_position();
        
        /* convert mouse to gui pos for collision detection */
        var _gui_mouse_x = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _gui_mouse_y = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _inst = instance_position(_gui_mouse_x, _gui_mouse_y, obj_Inventory);
        
        inventory_organize_mouse(_inst);
        
        global.inventory_selected_hover = _inst;
    }
}
