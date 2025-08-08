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
                inventory_give(0, 0, _item, false);
                
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
        
        var _inst = instance_nearest(_player_x, _player_y, obj_Tile_Container);
        
        if (instance_exists(_inst)) && (point_distance(_player_x, _player_y, _inst.x, _inst.y) <= TILE_SIZE * 6)
        {
            inventory_container_open(_player_x, _player_y, _inst);
        }
    }
    
    if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        inventory_refresh_crafting_station();
    }
    
    for (var i = 0; i < INVENTORY_LENGTH.ROW; ++i)
    {
        if (keyboard_check_pressed(__keyboard_hotbar_ord[i]))
        {
            if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
            {
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
                
                if (keyboard_check(vk_shift))
                {
                    var _inst = instance_position(mouse_x, mouse_y, obj_Inventory);
                    
                    if (instance_exists(_inst))
                    {
                        sfx_play("phantasia:item.collect");
                        
                        inventory_switch(_inst.inventory_type, _inst.inventory_index, "base", i); 
                        
                        break;
                    }
                }
            }
            else
            {
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
            }
            
            global.inventory_selected_hotbar = i;
            
            break;
        }
    }
    
    var _mouse_wheel = mouse_wheel_down() - mouse_wheel_up();
    
    if (_mouse_wheel != 0)
    {
        global.inventory_selected_hotbar = (global.inventory_selected_hotbar + _mouse_wheel + INVENTORY_LENGTH.ROW) % INVENTORY_LENGTH.ROW;
        
        surface_refresh |= ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
    }
    
    if !(is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        exit;
    }
    
    control_inventory_position();
    
    var _inst = instance_position(mouse_x, mouse_y, obj_Inventory);
    
    inventory_organize_mouse(_inst);
    
    global.inventory_selected_hover = _inst;
}