function tile_harvest_drop(_x, _y, _z, _tile, _harvest_id = INVENTORY_EMPTY)
{
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _tile.get_id()];
    
    var _drops = _data.get_tile_drops();
    var _drop_length = _data.get_tile_drops_length();
    
    for (var i = 0; i < _drop_length; ++i)
    {
        var _drop_item = _drops[i];
        
        var _item = _drop_item.item;
        
        var _chance = _item.get_chance();
        
        if (_chance != undefined) && (!chance(_chance)) continue;
        
        var _condition = _drop_item[$ "condition"];
        
        if (_condition != undefined)
        {
            var _tool = _condition.get_id();
            
            if (_tool != undefined) && (!array_contains(_tool, _harvest_id)) continue;
            
            var _index = _condition.get_index();
            
            if (_index != undefined) && (_tile.get_index() != _index) continue;
        }
        
        spawn_item_drop(_x * TILE_SIZE, _y * TILE_SIZE, new Inventory(_item.get_id(), _item.get_amount() ?? 1));
    }
}