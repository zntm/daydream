function file_load_world_chunk(_world_save_data, _inst)
{
    var _item_data = global.item_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _chunk_x = _inst.chunk_xstart / CHUNK_SIZE;
    var _chunk_y = _inst.chunk_ystart / CHUNK_SIZE;
    
    var _region_x = floor(_chunk_x / CHUNK_REGION_SIZE);
    var _region_y = floor(_chunk_y / CHUNK_REGION_SIZE);
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/r{_region_x}_{_region_y}.dat";
    
    if (!file_exists(_directory))
    {
        return false;
    }
    
    var _buffer = buffer_load_decompressed(_directory);
    
    var _chunk_relative_x = ((_chunk_x % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _chunk_relative_y = ((_chunk_y % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    
    var _bit = buffer_peek(_buffer, _chunk_relative_x * 4, buffer_u64);
    
    if !(_bit & (1 << _chunk_relative_y))
    {
        return false;
    }
    
    var _version = buffer_read(_buffer, buffer_u32);
    
    var _datetime = unix_to_datetime(buffer_read(_buffer, buffer_f64));
    
    var _seek = (CHUNK_REGION_SIZE * 4) + (((_chunk_relative_y * CHUNK_REGION_SIZE) + _chunk_relative_x) * (1 << 16));
    
    buffer_seek(_buffer, buffer_seek_start, _seek);
    
    if (buffer_read(_buffer, buffer_bool))
    {
        _inst.boolean |= CHUNK_BOOLEAN.GENERATED;
    }
    
    var _chunk_display = buffer_read(_buffer, buffer_u16);
    
    _inst.chunk_display = _chunk_display;
    
    if (_chunk_display)
    {
        for (var i = 0; i < CHUNK_SIZE; ++i)
        {
            _inst.chunk_covered[@ i] = buffer_read(_buffer, buffer_u16);
        }
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            _inst.chunk_count[@ i] = buffer_read(_buffer, buffer_u16);
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    _inst.chunk[@ tile_index_xyz(l, j, i)] = file_load_snippet_tile(_buffer, _item_data);
                }
            }
        }
    }
    
    var _length_item = buffer_read(_buffer, buffer_u32);
    
    for (var i = 0; i < _length_item; ++i)
    {
        var _next = buffer_read(_buffer, buffer_u32);
        
        var _timer_pickup = buffer_read(_buffer, buffer_f64);
        var _timer_life = buffer_read(_buffer, buffer_f64);
        
        var _item = file_load_snippet_item(_buffer, _item_data);
        
        var _inst_item = spawn_item_drop(0, 0, _item);
        
        file_load_snippet_position(_buffer, _inst_item);
    }
    
    var _length_creature = buffer_read(_buffer, buffer_u32);
    
    for (var i = 0; i < _length_creature; ++i)
    {
        var _next = buffer_read(_buffer, buffer_u32);
        
        var _id = buffer_read(_buffer, buffer_string);
        var _variant = buffer_read(_buffer, buffer_string);
        
        var _inst_creature = spawn_creature(0, 0, _id, ((_variant != "") ? _variant : undefined));
        
        _inst_creature.hp = buffer_read(_buffer, buffer_u16);
        _inst_creature.hp_max = buffer_read(_buffer, buffer_u16);
        
        var _xscale = buffer_read(_buffer, buffer_f64);
        var _yscale = buffer_read(_buffer, buffer_f64);
        
        with (_inst_creature)
        {
            entity_set_scale(_xscale, _yscale);
        }
        
        _inst_creature.uuid = buffer_read(_buffer, buffer_string);
        
        file_load_snippet_position(_buffer, _inst_creature);
        file_load_snippet_effects(_buffer, _inst_creature);
        
        var _inventory_length = buffer_read(_buffer, buffer_u8);
        
        if (_inventory_length > 0)
        {
            _inst_creature.inventory = file_load_snippet_inventory(_buffer, _inventory_length, _item_data);
        }
    }
    
    buffer_delete(_buffer);
    
    return true;
}