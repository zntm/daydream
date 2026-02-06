function file_load_snippet_item(_buffer, _item_data, _palette)
{
    var _index = buffer_read(_buffer, buffer_u16);
    
    if (_index == 65535)
    {
        return INVENTORY_EMPTY;
    }
    
    var _id = _palette[_index];
    
    var _seek = buffer_read(_buffer, buffer_u32);
    
    var _amount = buffer_read(_buffer, buffer_u16);
    
    var _item = new Inventory(_id, _amount);
    
    var _durability = buffer_read(_buffer, buffer_u16);
    
    if (_durability > 0)
    {
        _item.set_durability(_durability);
    }
    
    file_load_snippet_item_component(_buffer, _item);
    
    var _inventory_length = buffer_read(_buffer, buffer_u8);
    
    if (_inventory_length > 0)
    {
        _item.set_inventory(file_load_snippet_inventory(_buffer, _inventory_length, _item_data, _palette));
    }
    
    return _item;
}