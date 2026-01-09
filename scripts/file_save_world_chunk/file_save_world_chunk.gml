#macro CHUNK_REGION_SIZE 8

/// @function file_save_world_chunk(_world_save_data, _chunk)
/// @param {Struct.Chunk} _chunk The chunk struct to save
function file_save_world_chunk(_world_save_data, _chunk)
{
    // ==========================================================================================
    // 1. PREPARE DATA & CONTEXT
    // ==========================================================================================
    var _creature_data = global.creature_data;
    var _item_data = global.item_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _chunk_x = _chunk.chunk_xstart / CHUNK_SIZE;
    var _chunk_y = _chunk.chunk_ystart / CHUNK_SIZE;
    
    var _region_x = floor(_chunk_x / CHUNK_REGION_SIZE);
    var _region_y = floor(_chunk_y / CHUNK_REGION_SIZE);
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}/r{_region_x}_{_region_y}.dat";

    // Start by writing the *current* chunk to a temporary buffer so we know its exact size.
    var _current_chunk_buffer = buffer_create(1024, buffer_grow, 1);
    
    // ------------------------------------------------------------------------------------------
    // Write Chunk Header (internal versioning/metadata for the chunk itself)
    // ------------------------------------------------------------------------------------------
    buffer_write(_current_chunk_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    buffer_write(_current_chunk_buffer, buffer_f64, datetime_to_unix());
    
    var _is_generated = !!(_chunk.boolean & CHUNK_BOOLEAN.GENERATED);
    var _chunk_display = _chunk.chunk_display;
    
    buffer_write(_current_chunk_buffer, buffer_bool, _is_generated);
    buffer_write(_current_chunk_buffer, buffer_u16, _chunk_display);
    
    // ------------------------------------------------------------------------------------------
    // Write Tiles
    // ------------------------------------------------------------------------------------------
    if (_chunk_display)
    {
        var _chunk2 = _chunk.chunk;
        var _chunk_count = _chunk.chunk_count;
        var _chunk_covered = _chunk.chunk_covered;
        
        // Build Palette
        var _palette_map = {};
        var _palette_array = [];
        var _palette_index = 0;
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _tile = _chunk2[tile_index_xyz(l, j, i)];
                    
                    if (_tile != TILE_EMPTY)
                    {
                        var _id = _tile.get_id();
                        
                        if (!struct_exists(_palette_map, _id))
                        {
                            _palette_map[$ _id] = _palette_index++;
                            array_push(_palette_array, _id);
                        }
                    }
                }
            }
        }
        
        // Write Palette
        buffer_write(_current_chunk_buffer, buffer_u16, _palette_index);
        
        for (var i = 0; i < _palette_index; ++i)
        {
            buffer_write(_current_chunk_buffer, buffer_string, _palette_array[i]);
        }
        
        for (var i = 0; i < CHUNK_SIZE; ++i)
        {
            buffer_write(_current_chunk_buffer, buffer_u16, _chunk_covered[i]);
        }
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            buffer_write(_current_chunk_buffer, buffer_u16, _chunk_count[i]);
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _tile = _chunk2[tile_index_xyz(l, j, i)];
                    file_save_snippet_tile(_current_chunk_buffer, _tile, _item_data, _palette_map);
                    
                    if (_tile != TILE_EMPTY)
                    {
                        delete _tile;
                    }
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // Write Entities (Items & Creatures)
    // ------------------------------------------------------------------------------------------
    var _xcenter = _chunk.xcenter;
    var _ycenter = _chunk.ycenter;
    var _bbox_l = _xcenter - (CHUNK_SIZE_DIMENSION / 2);
    var _bbox_t = _ycenter - (CHUNK_SIZE_DIMENSION / 2);
    var _bbox_r = _xcenter + (CHUNK_SIZE_DIMENSION / 2);
    var _bbox_b = _ycenter + (CHUNK_SIZE_DIMENSION / 2);
    
    // -- Items --
    var _inst_item = [];
    var _length_item = 0;
    
    with (obj_Item_Drop)
    {
        if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _bbox_l, _bbox_t, _bbox_r, _bbox_b))
        {
            _inst_item[@ _length_item++] = id;
        }
    }
    
    buffer_write(_current_chunk_buffer, buffer_u32, _length_item);
    
    for (var i = 0; i < _length_item; ++i)
    {
        var _ = _inst_item[i];
        
        var _pos_start = buffer_tell(_current_chunk_buffer);
        buffer_write(_current_chunk_buffer, buffer_u32, 0); // Next ptr (relative placeholder)
        
        buffer_write(_current_chunk_buffer, buffer_f64, _.timer_pickup);
        buffer_write(_current_chunk_buffer, buffer_f64, _.timer_life);
        file_save_snippet_item(_current_chunk_buffer, _.item, _item_data);
        file_save_snippet_position(_current_chunk_buffer, _);
        
        var _pos_end = buffer_tell(_current_chunk_buffer);
        buffer_poke(_current_chunk_buffer, _pos_start, buffer_u32, _pos_end); 
        
        instance_destroy(_);
    }
    
    // -- Creatures --
    var _inst_creature = [];
    var _length_creature = 0;
    
    with (obj_Creature)
    {
        if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _bbox_l, _bbox_t, _bbox_r, _bbox_b))
        {
            _inst_creature[@ _length_creature++] = id;
        }
    }
    
    buffer_write(_current_chunk_buffer, buffer_u32, _length_creature);
    
    for (var i = 0; i < _length_creature; ++i)
    {
        var _ = _inst_creature[i];
        
        var _pos_start = buffer_tell(_current_chunk_buffer);
        buffer_write(_current_chunk_buffer, buffer_u32, 0); // Next ptr
        
        buffer_write(_current_chunk_buffer, buffer_string, _._id);
        buffer_write(_current_chunk_buffer, buffer_string, _[$ "variant"] ?? "");
        buffer_write(_current_chunk_buffer, buffer_u16, _.hp);
        buffer_write(_current_chunk_buffer, buffer_u16, _.hp_max);
        buffer_write(_current_chunk_buffer, buffer_f64, _.entity_xscale);
        buffer_write(_current_chunk_buffer, buffer_f64, _.entity_yscale);
        buffer_write(_current_chunk_buffer, buffer_string, _.uuid);
        
        file_save_snippet_position(_current_chunk_buffer, _);
        buffer_write(_current_chunk_buffer, buffer_f64, _.y_last);
        file_save_snippet_effects(_current_chunk_buffer, _[$ "effects"]);
        
        var _inventory = _[$ "inventory"];
        if (_inventory != undefined)
        {
            var _inventory_length = array_length(_inventory);
            buffer_write(_current_chunk_buffer, buffer_u8, _inventory_length);
            if (_inventory_length > 0)
                file_save_snippet_inventory(_current_chunk_buffer, _inventory, _inventory_length, _item_data);
        }
        else
        {
            buffer_write(_current_chunk_buffer, buffer_u8, 0);
        }
        
        var _pos_end = buffer_tell(_current_chunk_buffer);
        buffer_poke(_current_chunk_buffer, _pos_start, buffer_u32, _pos_end);
        
        instance_destroy(_);
    }

    // ==========================================================================================
    // 2. REBUILD REGION FILE
    // ==========================================================================================
    
    var _old_region_buffer = -1;
    if (file_exists(_directory))
    {
        _old_region_buffer = buffer_load_decompressed(_directory);
    }
    
    // Output buffer: Start with 512 bytes for header, then append data.
    var _new_region_buffer = buffer_create(512, buffer_grow, 1);
    buffer_fill(_new_region_buffer, 0, buffer_u32, 0, 512); // Zero out header initially
    
    var _current_chunk_rel_x = ((_chunk_x % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _current_chunk_rel_y = ((_chunk_y % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _current_chunk_index = _current_chunk_rel_y * CHUNK_REGION_SIZE + _current_chunk_rel_x;
    
    var _write_offset = 512; // Start writing data after header
    
    for (var i = 0; i < 64; ++i) // 8x8 = 64 chunks
    {
        // Position buffer to write this chunk's header entry
        buffer_seek(_new_region_buffer, buffer_seek_start, i * 8);
        
        if (i == _current_chunk_index)
        {
            // CASE A: This is the chunk we are saving RIGHT NOW.
            var _len = buffer_tell(_current_chunk_buffer);
            
            // Write Header
            buffer_write(_new_region_buffer, buffer_u32, _write_offset);
            buffer_write(_new_region_buffer, buffer_u32, _len);
            
            // Copy data to end of new buffer
            buffer_copy(_current_chunk_buffer, 0, _len, _new_region_buffer, _write_offset);
            
            _write_offset += _len;
        }
        else
        {
            // CASE B: Copy from old buffer if it exists.
            var _copied = false;
            
            if (_old_region_buffer != -1 && buffer_get_size(_old_region_buffer) >= 512)
            {
                var _off = buffer_peek(_old_region_buffer, i*8, buffer_u32);
                var _len = buffer_peek(_old_region_buffer, i*8+4, buffer_u32);
                
                // Validate offset/len
                // Note: Only strictly valid New Format entries are copied. 
                // Any garbage data or "Old Format" blobs are ignored/discarded as per user request.
                if (_len > 0 && _off >= 512 && (_off + _len <= buffer_get_size(_old_region_buffer)))
                {
                    buffer_write(_new_region_buffer, buffer_u32, _write_offset);
                    buffer_write(_new_region_buffer, buffer_u32, _len);
                    buffer_copy(_old_region_buffer, _off, _len, _new_region_buffer, _write_offset);
                    _write_offset += _len;
                    _copied = true;
                }
            }
            
            if (!_copied)
            {
                // Write Empty Header
                buffer_write(_new_region_buffer, buffer_u32, 0);
                buffer_write(_new_region_buffer, buffer_u32, 0);
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // 3. FLUSH TO DISK
    // ------------------------------------------------------------------------------------------
    buffer_save_compressed(_new_region_buffer, _directory);
    
    // Cleanup
    buffer_delete(_current_chunk_buffer);
    buffer_delete(_new_region_buffer);
    if (_old_region_buffer != -1) buffer_delete(_old_region_buffer);
}
