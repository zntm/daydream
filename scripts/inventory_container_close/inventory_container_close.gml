function inventory_container_close()
{
    if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY_CONTAINER) exit;
    
    obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.INVENTORY_CONTAINER;
    
    var _x = obj_Game_Control.tile_container_x;
    var _y = obj_Game_Control.tile_container_y;
    var _z = obj_Game_Control.tile_container_z;
    
    var _tile = tile_get(_x, _y, _z);
    
    _tile.set_index(0);
	
	inventory_resize("_container", 0);
    
    if (variable_global_exists("ui_inventory_container") && global.ui_inventory_container != undefined)
    {
        ui_instance_destroy(global.ui_inventory_container);
        global.ui_inventory_container = undefined;
    }

    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        relay_send_container_close();
    }
    
    event_emit(new EventDataTileContainerClose(_x, _y, _z));
}