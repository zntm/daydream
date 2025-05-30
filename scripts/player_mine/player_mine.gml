function player_mine(_x, _y)
{
    var _tile = TILE_EMPTY;
    
    var _z = CHUNK_DEPTH - 1;
    
    for (; _z >= 0; --_z)
    {
        _tile = tile_get(_x, _y, _z);
        
        if (_tile == TILE_EMPTY) continue;
        
        if (_x != harvest_x) || (_y != harvest_y) || (_z != harvest_z)
        {
            harvest_amount = 0;
            
            cooldown_harvest = 0.1;
        }
        
        harvest_x = _x;
        harvest_y = _y;
        harvest_z = _z;
        
        break;
    }
    
    if (_z < 0) exit;
    
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _tile.get_item_id()];
    
    var _item = global.inventory.base[global.inventory_selected_hotbar];
    
    var _item_hardness = 1;
    var _item_level = 0;
    
    if (_item != INVENTORY_EMPTY)
    {
        var _data2 = _item_data[$ _item.get_item_id()];
        
        _item_hardness = _data2.get_harvest_hardness();
        _item_level = _data2.get_harvest_level();
    }
    
    if (_data.get_harvest_level() > _item_level) exit;
    
    harvest_amount += _item_hardness * global.delta_time;
    
    var _tile_hardness = _data.get_harvest_hardness();
    
    if (harvest_amount >= _tile_hardness)
    {
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        harvest_amount = 0;
        
        if (_item_hardness < _tile_hardness)
        {
            cooldown_harvest = 0.1;
        }
    }
}