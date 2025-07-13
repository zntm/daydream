#macro CHUNK_REGION_SIZE 8

function file_save_world_chunk(_world_save_data, _inst)
{
    var _creature_data = global.creature_data;
    var _item_data = global.item_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _chunk_x = _inst.chunk_xstart / CHUNK_SIZE;
    var _chunk_y = _inst.chunk_ystart / CHUNK_SIZE;
    
    var _region_x = floor(_chunk_x / CHUNK_REGION_SIZE);
    var _region_y = floor(_chunk_y / CHUNK_REGION_SIZE);
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dimension/{_world_data.get_namespace()}/{_world_data.get_id()}/chunk/{_region_x} {_region_y}.dat";
    
    var _buffer;
    
    if (file_exists(_directory))
    {
        _buffer = buffer_load_decompressed(_directory);
    }
    else
    {
        _buffer = buffer_create(0xff, buffer_grow, 1);
        
        for (var i = 0; i < CHUNK_REGION_SIZE; ++i)
        {
            buffer_write(_buffer, buffer_u32, 0);
        }
    }
    
    var _chunk_relative_x = ((_chunk_x % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _chunk_relative_y = ((_chunk_y % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    
    buffer_poke(_buffer, _chunk_relative_x * 4, buffer_u32, buffer_peek(_buffer, _chunk_relative_x * 4, buffer_u32) | (1 << _chunk_relative_y));
    
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MAJOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MINOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_PATCH);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_TYPE);
    
    buffer_write(_buffer, buffer_f64, datetime_to_unix());
    
    var _seek = (CHUNK_REGION_SIZE * 4) + (((_chunk_relative_y * CHUNK_REGION_SIZE) + _chunk_relative_x) * (1 << 16));
    
    buffer_seek(_buffer, buffer_seek_start, _seek);
    
    var _chunk_display = _inst.chunk_display;
    
    buffer_write(_buffer, buffer_bool, _inst.is_generated);
    buffer_write(_buffer, buffer_u16, (_inst.is_generated << CHUNK_DEPTH) | _chunk_display);
    
    if (_chunk_display)
    {
        var _chunk = _inst.chunk;
        var _chunk_count = _inst.chunk_count;
        
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            buffer_write(_buffer, buffer_u16, _chunk_count[i]);
            
            var _index_z = i << (CHUNK_SIZE_BIT + CHUNK_SIZE_BIT);
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _tile = _chunk[_index_z | (j << CHUNK_SIZE_BIT) | l];
                    
                    file_save_snippet_tile(_buffer, _tile, _item_data);
                    
                    if (_tile != TILE_EMPTY)
                    {
                        delete _tile;
                    }
                }
            }
        }
    }
    
    var _xcenter = _inst.xcenter;
    var _ycenter = _inst.ycenter;
    
    var _bbox_l = _xcenter - (CHUNK_SIZE_DIMENSION / 2);
    var _bbox_t = _ycenter - (CHUNK_SIZE_DIMENSION / 2);
    
    var _bbox_r = _xcenter + (CHUNK_SIZE_DIMENSION / 2);
    var _bbox_b = _ycenter + (CHUNK_SIZE_DIMENSION / 2);
    
    var _inst_item = [];
    var _length_item = 0;
    
    with (obj_Item_Drop)
    {
        if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _bbox_l, _bbox_t, _bbox_r, _bbox_b))
        {
            _inst_item[@ _length_item++] = id;
        }
    }
    
    buffer_write(_buffer, buffer_u32, _length_item);
    
    for (var i = 0; i < _length_item; ++i)
    {
        var _ = _inst_item[i];
        
        var _next = buffer_tell(_buffer);
        
        buffer_write(_buffer, buffer_u32, 0);
        
        buffer_write(_buffer, buffer_f64, _.timer_pickup);
        buffer_write(_buffer, buffer_f64, _.timer_life);
        
        file_save_snippet_position(_buffer, _);
        
        file_save_snippet_item(_buffer, _.item, _item_data);
        
        buffer_poke(_buffer, _next, buffer_u32, buffer_tell(_buffer));
        
        instance_destroy(_);
    }
    
    var _inst_creature = [];
    var _length_creature = 0;
    
    with (obj_Creature)
    {
        if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _bbox_l, _bbox_t, _bbox_r, _bbox_b))
        {
            _inst_creature[@ _length_creature++] = id;
        }
    }
    
    buffer_write(_buffer, buffer_u32, _length_creature);
    
    for (var i = 0; i < _length_creature; ++i)
    {
        var _ = _inst_creature[i];
        
        var _next = buffer_tell(_buffer);
        
        buffer_write(_buffer, buffer_u32, 0);
        
        buffer_write(_buffer, buffer_u16, _.hp);
        buffer_write(_buffer, buffer_u16, _.hp_max);
        
        buffer_write(_buffer, buffer_f64, _.entity_scale);
        
        buffer_write(_buffer, buffer_string, _.uuid);
        buffer_write(_buffer, buffer_string, _._id);
        buffer_write(_buffer, buffer_string, _[$ "variant"] ?? "");
        
        file_save_snippet_position(_buffer, _);
        
        file_save_snippet_effects(_buffer, _[$ "effects"]);
        
        var _inventory = _[$ "inventory"];
        
        if (_inventory != undefined)
        {
            var _inventory_length = array_length(_inventory);
            
            buffer_write(_buffer, buffer_u8, _inventory_length);
            
            if (_inventory_length > 0)
            {
                file_save_snippet_inventory(_buffer, _inventory, _inventory_length, _item_data);
            }
            
            buffer_poke(_buffer, _next, buffer_u32, buffer_tell(_buffer));
        }
        else
        {
            buffer_write(_buffer, buffer_u8, 0);
        }
        
        buffer_poke(_buffer, _next, buffer_u32, buffer_tell(_buffer));
        
        instance_destroy(_);
    }
    
    buffer_save_compressed(_buffer, _directory);
    
    buffer_delete(_buffer);
}