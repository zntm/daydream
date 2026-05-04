function file_load_snippet_inventory(_buffer, _length, _item_data, _palette)
{
    var _inventory = array_create(_length, INVENTORY_EMPTY);
    
    for (var i = _length - 1; i >= 0; --i)
    {
        var _item = file_load_snippet_item(_buffer, _item_data, _palette);
        
        if (_item != INVENTORY_EMPTY)
        {
            _inventory[@ i] = _item;
        }
    }
    
    return _inventory;
}
