function file_load_snippet_tile(_buffer, _item_data)
{
    var _id = buffer_read(_buffer, buffer_string);
    
    if (_id == "")
    {
        return TILE_EMPTY;
    }
    
    var _seek = buffer_read(_buffer, buffer_u32);
    
    var _xoffset = buffer_read(_buffer, buffer_s8);
    var _yoffset = buffer_read(_buffer, buffer_s8);
    
    var _xscale = buffer_read(_buffer, buffer_s8);
    var _yscale = buffer_read(_buffer, buffer_s8);
    
    var _index = buffer_read(_buffer, buffer_u8);
    var _index_offset = buffer_read(_buffer, buffer_u8);
    
    var _rotation = buffer_read(_buffer, buffer_u16);
    
    var _tile = new Tile(_id, _item_data)
        .set_offset(_xoffset, _yoffset)
        .set_scale(_xscale, _yscale)
        .set_index(_index)
        .set_index_offset(_index_offset)
        .set_rotation(_rotation);
    
    var _inventory_length = buffer_read(_buffer, buffer_u8);
    
    if (_inventory_length > 0)
    {
        var _is_loot = buffer_read(_buffer, buffer_bool);
        
        if (_is_loot)
        {
            _tile.set_inventory(buffer_read(_buffer, buffer_string));
        }
        else
        {
            _tile.set_inventory(file_load_snippet_inventory(_buffer, _inventory_length, _item_data));
        }
    }
    
    return _tile;
}