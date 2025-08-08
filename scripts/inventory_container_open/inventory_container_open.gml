function inventory_container_open(_x, _y, _inst)
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.INVENTORY_CONTAINER;
    
    var _tile_x = _inst.tile_x;
    var _tile_y = _inst.tile_y;
    var _tile_z = _inst.tile_z;
    
    obj_Game_Control.tile_container_x = _tile_x;
    obj_Game_Control.tile_container_y = _tile_y;
    obj_Game_Control.tile_container_z = _tile_z;
    
    var _tile = tile_get(_tile_x, _tile_y, _tile_z);
    
    var _data = global.item_data[$ _tile.get_id()];
    var _container_length = _data.get_container_length();
}