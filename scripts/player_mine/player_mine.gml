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
    
    var _harvest_hardness = _data.get_harvest_hardness();
    
    if (_harvest_hardness == undefined) exit;
    
    var _harvest_type = _data.get_harvest_type();
    
    var _data2 = undefined;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    var _item_type = 0;
    
    var _item_hardness = 1;
    var _item_level = 0;
    
    if (_item != INVENTORY_EMPTY)
    {
        _data2 = _item_data[$ _item.get_item_id()];
        
        _item_type = _data2.get_type();
        
        _item_hardness = _data2.get_harvest_hardness();
        _item_level = _data2.get_harvest_level();
        
        if (_harvest_type) && (!_data.has_harvest_type(_item_type)) exit;
    }
    
    if (_data.get_harvest_level() > _item_level) exit;
    
    harvest_amount += _item_hardness * global.delta_time;
    
    if (harvest_amount >= _harvest_hardness)
    {
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        if (_item != INVENTORY_EMPTY)
        {
            _item.add_durability(-1);
            
            if (_item.get_durability() <= 0)
            {
                inventory_delete("base", _inventory_selected_hotbar);
            }
            
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
        }
        
        var _drop_tool = _data.get_drop_tool();
        
        if (!_drop_tool) || ((_item != INVENTORY_EMPTY) && (_drop_tool & _data2.get_type()))
        {
            var _drop_length = _data.get_drop_item_length();
            
            for (var i = 0; i < _drop_length; ++i)
            {
                var _drop_item = _data.get_drop_item(i);
                
                var _chance = _drop_item[$ "chance"];
                
                if (_chance != undefined) && (!chance(_chance)) continue;
                
                spawn_item_drop(_x * TILE_SIZE, _y * TILE_SIZE, new Inventory(_drop_item.id, _drop_item[$ "amount"] ?? 1));
            }
        }
        
        harvest_amount = 0;
        
        if (_item_hardness < _harvest_hardness)
        {
            cooldown_harvest = 0.1;
        }
    }
}