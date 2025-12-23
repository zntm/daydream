function tile_place(_x, _y, _z, _tile)
{
    if (_y < 0) || (_y >= global.world_data[$ global.world_save_data.dimension].get_world_height()) exit;
    
    var _inst = chunk_map_get_by_tile(_x, _y);
    
    if (!instance_exists(_inst))
    {
        var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
        var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
        
        _inst = instance_create_layer(_chunk_x, _chunk_y, "Instances", obj_Chunk);
        
        control_update_chunk_in_view();
    }
    
    var _index = tile_index_xyz(_x, _y, _z);
    
    var _tile_before = _inst.chunk[_index];
    
    if (_tile != TILE_EMPTY)
    {
        _inst.chunk_display |= 1 << _z;
        
        ++_inst.chunk_count[@ _z];
        
        var _data = global.item_data[$ _tile.get_id()];    
        
        if (_data.get_render_state_length() > 0)
        {
            array_push(_inst.chunk_render_state, global.render_state_pool.acquire(_x, _y, _z, _data.get_render_state()));
        }
    }
    else if (_tile_before != TILE_EMPTY) && (--_inst.chunk_count[_z] <= 0)
    {
        _inst.chunk_display ^= 1 << _z;
        
        var _render_state = _inst.chunk_render_state;
        var _length = array_length(_render_state);
        
        for (var i = 0; i < _length; ++i)
        {
            var _ = _render_state[i];
            
            if (_.x == _x) && (_.y == _y) && (_.z == _z)
            {
                global.render_state_pool.release(_);
                
                array_delete(_render_state, i, 1);
                
                break;
            }
        }
    }
    
    if (_tile_before != TILE_EMPTY)
    {
        var _instance_crafting_station = _tile_before.get_instance_crafting_station();
        
        if (instance_exists(_instance_crafting_station))
        {
            instance_destroy(_instance_crafting_station);
        }
        
        var _instance_container = _tile_before.get_instance_container();
        
        if (instance_exists(_instance_container))
        {
            instance_destroy(_instance_container);
        }
        
        var _instance_light = _tile_before.get_instance_light();
        
        if (instance_exists(_instance_light))
        {
            instance_destroy(_instance_light);
        }
    }
    
    _inst.chunk[@ _index] = _tile;
    
    var _vertex_buffer = _inst.chunk_vertex_buffer[_z];
    
    if (vertex_buffer_exists(_vertex_buffer))
    {
        vertex_delete_buffer(_vertex_buffer);
    }
    
    // Emit tile changed event
    if (_tile != TILE_EMPTY)
    {
        event_emit(GAME_EVENT.TILE_CHANGED, {
            action: "placed",
            x: _x,
            y: _y,
            z: _z,
            tile_id: _tile.get_id(),
            tile: _tile
        });
    }
    else if (_tile_before != TILE_EMPTY)
    {
        event_emit(GAME_EVENT.TILE_CHANGED, {
            action: "destroyed",
            x: _x,
            y: _y,
            z: _z,
            tile_id: _tile_before.get_id()
        });
    }
    
    if (_tile_before != undefined)
    {
        delete _tile_before;
    }
}