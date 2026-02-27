/// @function file_load_world_chunk(_current_world, _chunk)
/// @param {Struct.Chunk} _chunk The chunk struct to load into
function file_load_world_chunk(_current_world, _chunk)
{
    var _item_data  = global.item_data;
    var _world_data = global.world_data[$ _current_world.dimension];
    
    var _chunk_x = _chunk.chunk_xstart / CHUNK_SIZE;
    var _chunk_y = _chunk.chunk_ystart / CHUNK_SIZE;
    
    var _region_x = floor(_chunk_x / CHUNK_REGION_SIZE);
    var _region_y = floor(_chunk_y / CHUNK_REGION_SIZE);
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/r{_region_x}_{_region_y}.dat";
    
    if (!file_exists(_directory))
    {
        return false;
    }
    
    var _buffer = buffer_load_decompressed(_directory);
    
    /* validate file size (must accommodate at least the 512 byte header) */
    if (buffer_get_size(_buffer) < 512)
    {
        buffer_delete(_buffer);
        
        return false; 
    }
    
    var _chunk_relative_x = ((_chunk_x % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _chunk_relative_y = ((_chunk_y % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _chunk_index      = _chunk_relative_y * CHUNK_REGION_SIZE + _chunk_relative_x;
    
    /* read header */
    var _offset = buffer_peek(_buffer, _chunk_index * 8,     buffer_u32);
    var _length = buffer_peek(_buffer, _chunk_index * 8 + 4, buffer_u32);
    
    /* validate chunk entry */
    if (_length == 0) || (_offset < 512) || (_offset + _length > buffer_get_size(_buffer))
    {
        buffer_delete(_buffer);
        
        return false;
    }
    
    /* seek and read */
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    /* standard chunk read */
    var _version  = buffer_read(_buffer, buffer_u32);
    var _datetime = unix_to_datetime(buffer_read(_buffer, buffer_f64));
    
    if (buffer_read(_buffer, buffer_bool))
    {
        _chunk.boolean |= CHUNK_BOOL.GENERATED;
    }
    
    var _chunk_display = buffer_read(_buffer, buffer_u16);
    
    _chunk.chunk_display = _chunk_display;
    
    /* read master palette */
    var _palette_length = buffer_read(_buffer, buffer_u16);
    var _palette        = array_create(_palette_length);
    
    for (var i = 0; i < _palette_length; ++i)
    {
        _palette[@ i] = buffer_read(_buffer, buffer_string);
    }
    
    if (_chunk_display)
    {
        for (var i = 0; i < CHUNK_SIZE; ++i)
        {
            _chunk.chunk_covered[@ i] = buffer_read(_buffer, buffer_u16);
        }
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            _chunk.chunk_count[@ i] = buffer_read(_buffer, buffer_u16);
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    _chunk.chunk[@ tile_index_xyz(l, j, i)] = file_load_snippet_tile(_buffer, _item_data, _palette);
                }
            }
        }
    }
    
    var _length_item = buffer_read(_buffer, buffer_u32);
    
    for (var i = 0; i < _length_item; ++i)
    {
        var _next = buffer_read(_buffer, buffer_u32); /* skip next ptr */
        
        var _timer_pickup = buffer_read(_buffer, buffer_f64);
        var _timer_life   = buffer_read(_buffer, buffer_f64);
        
        var _item = file_load_snippet_item(_buffer, _item_data, _palette);
        
        var _inst_item = spawn_item_drop(0, 0, _item);
        
        file_load_snippet_position(_buffer, _inst_item);
        
        _inst_item.timer_pickup = _timer_pickup;
        _inst_item.timer_life   = _timer_life;
    }
    
    var _length_creature = buffer_read(_buffer, buffer_u32);
    
    for (var i = 0; i < _length_creature; ++i)
    {
        var _next = buffer_read(_buffer, buffer_u32); /* skip next ptr */
        
        /* read id from palette */
        var _id_index = buffer_read(_buffer, buffer_u16);
        var _id       = _palette[_id_index];
        
        var _variant = buffer_read(_buffer, buffer_string);
        
        var _inst_creature = spawn_creature(0, 0, _id, ((_variant != "") ? _variant : undefined));
        
        _inst_creature.hp     = buffer_read(_buffer, buffer_u16);
        _inst_creature.hp_max = buffer_read(_buffer, buffer_u16);
        
        var _xscale = buffer_read(_buffer, buffer_f64);
        var _yscale = buffer_read(_buffer, buffer_f64);
        
        with (_inst_creature)
        {
            entity_set_scale(_xscale, _yscale);
        }
        
        _inst_creature.uuid = buffer_read(_buffer, buffer_string);
        
        file_load_snippet_position(_buffer, _inst_creature);
        
        _inst_creature.y_last = buffer_read(_buffer, buffer_f64);
        
        file_load_snippet_effects(_buffer, _inst_creature);
        
        var _inventory_length = buffer_read(_buffer, buffer_u8);
        
        if (_inventory_length > 0)
        {
            _inst_creature.inventory = file_load_snippet_inventory(_buffer, _inventory_length, _item_data, _palette);
        }
    }
    
    buffer_delete(_buffer);
    
    return true;
}
