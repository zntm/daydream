function inventory_container_open(_x, _y, _inst)
{
    obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.INVENTORY | WORLD_OPENED_BOOL.INVENTORY_CONTAINER;
    
    var _tile_x = _inst.tile_x;
    var _tile_y = _inst.tile_y;
    var _tile_z = _inst.tile_z;
    
    obj_Game_Control.tile_container_x = _tile_x;
    obj_Game_Control.tile_container_y = _tile_y;
    obj_Game_Control.tile_container_z = _tile_z;
    
    var _tile = tile_get(_tile_x, _tile_y, _tile_z);
    
    var _data = global.item_data[$ _tile.get_id()];
    var _container_length = _data.get_container_length();
    
    var _inventory = _tile.get_inventory();
    
    if (_inventory != undefined)
    {
        global.inventory._container = _inventory;
        
        var _inventory_instance = global.inventory_instance._container;
        
        for (var i = 0; i < _container_length; ++i)
        {
            var _slot_inst = instance_create_layer(0, 0, "Instances", obj_Inventory);
            
            _slot_inst.image_xscale = INVENTORY_SLOT_SCALE;
            _slot_inst.image_yscale = INVENTORY_SLOT_SCALE;
            
            _slot_inst.xoffset = (i mod INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED;
            _slot_inst.yoffset = (i div INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED;
            
            _slot_inst.slot_type = INVENTORY_SLOT_TYPE.CONTAINER;
            _slot_inst.inventory_type = "_container";
            _slot_inst.inventory_index = i;
            
            _inventory_instance[@ i] = _slot_inst;
            
            instance_deactivate_object(_slot_inst);
        }
        
        global.inventory_length._container = _container_length;
        
        if (variable_global_exists("ui_inventory"))
        {
            if (!variable_global_exists("ui_inventory_container")) global.ui_inventory_container = undefined;
            
            if (global.ui_inventory_container != undefined)
            {
                ui_instance_destroy(global.ui_inventory_container);
            }
            
            var _rows = ceil(_container_length / INVENTORY_LENGTH.ROW);
            var _cols = min(_container_length, INVENTORY_LENGTH.ROW);
            
            var _panel_w = _cols * 16;
            var _panel_h = _rows * 16;
            
            var _container_ui = new UIContainer(0, -(_panel_h + 8), _panel_w, _panel_h);
            _container_ui.set_anchor("center", "bottom");
            
            for (var i = 0; i < _container_length; ++i)
            {
                var _sx = (i mod INVENTORY_LENGTH.ROW) * 16;
                var _sy = (i div INVENTORY_LENGTH.ROW) * 16;
                
                var _slot = new UISlot(_sx, _sy)
                    .set_inventory("_container")
                    .set_index(i);
                
                // Get custom sprite from item JSON if it exists
                var _custom_sprite_name = _data.get_inventory_slot_sprite();
                
                if (_custom_sprite_name != undefined)
                {
                    _slot.set_sprite_background(_custom_sprite_name);
                }
                
                _container_ui.add_child(_slot);
            }
            
            global.ui_inventory.root_elements[0].add_child(_container_ui);
            global.ui_inventory_container = _container_ui;
        }
    }
    
    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        relay_send_container_open(_tile_x, _tile_y, _tile_z);
    }
    
    event_emit(new EventDataTileContainerOpen(_tile_x, _tile_y, _tile_z, obj_Player.id));
}