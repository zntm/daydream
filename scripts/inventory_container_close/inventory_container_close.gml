function inventory_container_close()
{
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY_CONTAINER) exit;
    
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.INVENTORY_CONTAINER;
    
    var _x = obj_Game_Control.tile_container_x;
    var _y = obj_Game_Control.tile_container_y;
    var _z = obj_Game_Control.tile_container_z;
    
    var _tile = tile_get(_x, _y, _z);
    
    _tile.set_index(0);
	
	inventory_resize("container", 0);
}