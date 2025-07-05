function file_save_player_inventory(_player_save_data)
{
    var _item_data = global.item_data;
    
    var _uuid = _player_save_data.uuid;
    
    var _inventory = global.inventory;
    var _inventory_length = global.inventory_length;
    
    var _names = global.inventory_names;
    var _names_length = array_length(_names);
    
    for (var i = 0; i < _names_length; ++i)
    {
        var _name = _names[i];
        
        if (string_starts_with(_name, "_")) continue;
        
        var _v = _inventory[$ _name];
        
        var _length = _inventory_length[$ _name];
        
        var _buffer = buffer_create(0xff * _length, buffer_grow, 1);
        
        buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MAJOR);
        buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MINOR);
        buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_PATCH);
        buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_TYPE);
        
        file_save_snippet_inventory(_buffer, _v, _length, _item_data);
        
        buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}/inventory/{_name}.dat");
        
        buffer_delete(_buffer);
    }
}