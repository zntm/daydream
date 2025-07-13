function file_load_snippet_item(_buffer, _item_data)
{
    var _id = buffer_read(_buffer, buffer_string);
    
    if (_id == "")
    {
        return INVENTORY_EMPTY;
    }
    
    var _seek = buffer_read(_buffer, buffer_u32);
    
    var _amount = buffer_read(_buffer, buffer_u16);
    
    var _item = new Inventory(_id, _amount);
    
    var _durability = buffer_read(_buffer, buffer_u16);
    
    if (_durability > 0)
    {
        _item.set_durability(_durability);
    }
    
    var _inventory_length = buffer_read(_buffer, buffer_u8);
    
    if (_inventory_length > 0)
    {
        _item.set_inventory(file_save_snippet_inventory(_buffer, _item.get_inventory(), _inventory_length, _item_data));
    }
    
    return _item;
}