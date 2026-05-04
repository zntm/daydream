function file_save_player_inventory(_current_player)
{
    var _item_data        = global.item_data;
    var _uuid             = _current_player.uuid;
    var _inventory        = global.inventory;
    var _inventory_length = global.inventory_length;
    var _names            = global.inventory_names;
    var _names_length     = array_length(_names);
    
    static collect_palette = function(_inventory, _length, _item_data, _map, _list)
    {
        for (var i = _length - 1; i >= 0; --i)
        {
            var _item = _inventory[i];
            
            if (_item == INVENTORY_EMPTY) continue;
            
            var _id = _item.get_id();
            
            if (!struct_exists(_map, _id))
            {
                _map[$ _id] = true;
                
                array_push(_list, _id);
            }
            
            var _data = _item_data[$ _id];
            
            if (_data == undefined) continue;
            
            var _inventory_length = _data.get_item_inventory_length();
            
            if (_inventory_length > 0)
            {
                var _item_inventory = _item.get_inventory();
                
                if (is_array(_item_inventory))
                {
                    collect_palette(_item_inventory, _inventory_length, _item_data, _map, _list);
                }
            }
        }
    }
    
    for (var i = _names_length - 1; i >= 0; --i)
    {
        var _name = _names[i];
        
        if (string_starts_with(_name, "_")) continue;
        
        var _v      = _inventory[$ _name];
        var _length = _inventory_length[$ _name];
        
        var _buffer = buffer_create(0xff * _length, buffer_grow, 1);
        
        buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
        
        var _palette_list   = [];
        var _palette_lookup = {}
        
        collect_palette(_v, _length, _item_data, _palette_lookup, _palette_list);
        
        array_sort(_palette_list, true);
        
        var _palette_length = array_length(_palette_list);
        var _palette_map    = {}
        
        buffer_write(_buffer, buffer_u16, _palette_length);
        
        for (var j = 0; j < _palette_length; ++j)
        {
            var _id = _palette_list[j];
            
            buffer_write(_buffer, buffer_string, _id);
            
            _palette_map[$ _id] = j;
        }
        
        file_save_snippet_inventory(_buffer, _v, _length, _item_data, _palette_map);
        
        buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}/inventory/{_name}.dat");
        
        buffer_delete(_buffer);
    }
}
