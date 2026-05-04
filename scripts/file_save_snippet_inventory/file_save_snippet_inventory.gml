function file_save_snippet_inventory(_buffer, _inventory, _length, _item_data, _palette_map)
{
    for (var i = _length - 1; i >= 0; --i)
    {
        file_save_snippet_item(_buffer, _inventory[i], _item_data, _palette_map);
    }
}
