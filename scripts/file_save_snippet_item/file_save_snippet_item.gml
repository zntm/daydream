function file_save_snippet_item(_buffer, _item, _item_data, _palette_map)
{
    if (_item == INVENTORY_EMPTY)
    {
        buffer_write(_buffer, buffer_u16, 65535);
        
        exit;
    }
    
    var _id = _item.get_id();
    
    buffer_write(_buffer, buffer_u16, _palette_map[$ _id]);
    
    var _seek = buffer_tell(_buffer);
    
    buffer_write(_buffer, buffer_u32, 0);
    buffer_write(_buffer, buffer_u16, _item.get_amount());
    
    var _data = _item_data[$ _id];
    
    buffer_write(_buffer, buffer_u16, _item.get_item_durability() ?? 0);
    
    file_save_snippet_item_component(_buffer, _item);
    
    var _inventory_length = _data.get_item_inventory_length();
    
    buffer_write(_buffer, buffer_u8, _inventory_length);
    
    if (_inventory_length > 0)
    {
        file_save_snippet_inventory(_buffer, _item.get_inventory(), _inventory_length, _item_data, _palette_map);
    }
    
    buffer_poke(_buffer, _seek, buffer_u32, buffer_tell(_buffer));
}
