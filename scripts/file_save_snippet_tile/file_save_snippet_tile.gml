function file_save_snippet_tile(_buffer, _tile, _item_data)
{
    if (_tile == TILE_EMPTY)
    {
        buffer_write(_buffer, buffer_string, "");
        
        exit;
    }
    
    var _id = _tile.get_id();
    
    buffer_write(_buffer, buffer_string, _id);
    
    var _seek = buffer_tell(_buffer);
    
    buffer_write(_buffer, buffer_u32, 0);
    
    buffer_write(_buffer, buffer_s8, _tile.get_xoffset());
    buffer_write(_buffer, buffer_s8, _tile.get_yoffset());
    
    buffer_write(_buffer, buffer_s8, _tile.get_xscale());
    buffer_write(_buffer, buffer_s8, _tile.get_yscale());
    
    buffer_write(_buffer, buffer_u8, _tile.get_index());
    buffer_write(_buffer, buffer_u8, _tile.get_index_offset());
    
    buffer_write(_buffer, buffer_u16, _tile.get_rotation());
    
    var _data = _item_data[$ _id];
    
    var _inventory_length = _data.get_tile_inventory_length();
    
    buffer_write(_buffer, buffer_u8, _inventory_length);
    
    if (_inventory_length > 0)
    {
        var _inventory = _tile.get_inventory();
        
        var _is_loot = is_string(_inventory);
        
        buffer_write(_buffer, buffer_bool, _is_loot);
        
        if (_is_loot)
        {
            buffer_write(_buffer, buffer_string, _inventory);
        }
        else
        {
            if (_inventory == undefined)
            {
                buffer_write(_buffer, buffer_bool, false);
            }
            else
            {
                buffer_write(_buffer, buffer_bool, true);
                
                buffer_write(_buffer, buffer_u8, _inventory_length);
                
                file_save_snippet_inventory(_buffer, _inventory, _inventory_length, _item_data);
            }
        }
    }
    
    buffer_poke(_buffer, _seek, buffer_u32, buffer_tell(_buffer));
}