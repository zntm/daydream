/// @function tile_place(_x, _y, _z, _tile)
/// @desc Place a tile at the specified position
function tile_place(_x, _y, _z, _tile)
{
    if (_y < 0) || (_y >= global.world_data[$ global.current_world.dimension].get_world_height()) exit;
    
    // NETWORKING INTERCEPTION
    // Handle Client Requests and Host Broadcasts
    var _applying_packet = global.network_applying_packet ?? false;
    
    if (!_applying_packet)
    {
        var _id = (_tile == TILE_EMPTY) ? "base:empty" : _tile.get_id();
        relay_send_tile_update(_x, _y, _z, _id);
    }
    
    var _chunk = chunk_map_get_by_tile(_x, _y);
    
    if (_chunk == undefined)
    {
        var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
        var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
        
        _chunk = global.chunk_pool.acquire(_chunk_x, _chunk_y);
        
        control_update_chunk_in_view();
    }
    
    var _index = tile_index_xyz(_x, _y, _z);
    
    var _tile_before = _chunk.chunk[_index];
    
    if (_tile != TILE_EMPTY)
    {
        _chunk.chunk_display |= 1 << _z;
        
        // Only increment if we are replacing empty space
        if (_tile_before == TILE_EMPTY)
        {
            ++_chunk.chunk_count[@ _z];
        }
        
        var _data = global.item_data[$ _tile.get_id()];    
        
        if (_data.get_render_state_length() > 0)
        {
            array_push(_chunk.chunk_render_state, global.render_state_pool.acquire(_x, _y, _z, _data.get_render_state()));
        }
    }
    else if (_tile_before != TILE_EMPTY)
    {
        // Decrement only if we are removing a tile
        if (--_chunk.chunk_count[@ _z] <= 0)
        {
            _chunk.chunk_count[@ _z] = 0;
            _chunk.chunk_display &= ~(1 << _z);
        }
        
        var _render_state = _chunk.chunk_render_state;
        
        for (var i = array_length(_render_state) - 1; i >= 0; --i)
        {
            var _ = _render_state[i];
            
            if (_.x != _x) || (_.y != _y) || (_.z != _z) continue;
            
            global.render_state_pool.release(_);
            
            array_delete(_render_state, i, 1);
            
            break;
        }
    }
    
    if (_tile_before != TILE_EMPTY)
    {
        var _instance_crafting_station = _tile_before.get_instance_crafting_station();
        
        if (is_struct(_instance_crafting_station))
        {
            var _index_inst = array_get_index(_chunk.chunk_crafting_stations, _instance_crafting_station);
            
            if (_index_inst != -1)
            {
                array_delete(_chunk.chunk_crafting_stations, _index_inst, 1);
            }
        }
        
        var _instance_container = _tile_before.get_instance_container();
        
        if (is_struct(_instance_container))
        {
            var _index_inst = array_get_index(_chunk.chunk_containers, _instance_container);
            
            if (_index_inst != -1)
            {
                array_delete(_chunk.chunk_containers, _index_inst, 1);
            }
        }
        
        var _instance_light = _tile_before.get_instance_light();
        
        if (is_struct(_instance_light))
        {
            var _index_inst = array_get_index(_chunk.chunk_lights, _instance_light);
            
            if (_index_inst != -1)
            {
                array_delete(_chunk.chunk_lights, _index_inst, 1);
            }
        }
    }
    
    _chunk.chunk[@ _index] = _tile;
    
    // Recalculate occlusion for this column
    var _local_x = _x mod CHUNK_SIZE;
    var _local_y = _y mod CHUNK_SIZE;
    if (_local_x < 0) _local_x += CHUNK_SIZE;
    if (_local_y < 0) _local_y += CHUNK_SIZE;
    
    var _occluded = 0;
    var _has_opaque_above = false;
    var _is_covered = false;
    var _item_data = global.item_data;
    
    for (var _zz = CHUNK_DEPTH - 1; _zz >= 0; --_zz)
    {
        if (_has_opaque_above)
        {
            _occluded |= (1 << _zz);
        }

        var _tile_check = _chunk.chunk[tile_index_xyz(_local_x, _local_y, _zz)];
        
        if (_tile_check != TILE_EMPTY)
        {
            var _data = _item_data[$ _tile_check.get_id()];
            
            if (_data != undefined) && (!_data.is_transparent()) && (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE))
            {
                _has_opaque_above = true;
                
                /* sunlight only blocked by layers 3 and up (interactive plane) */
                if (_zz >= 3)
                {
                    _is_covered = true;
                }
            }
        }
    }

    _chunk.chunk_occluded[@ tile_index_xy(_local_x, _local_y)] = _occluded;
    
    // Update coverage for lighting
    if (_is_covered)
    {
        _chunk.chunk_covered[@ _local_x] |= (1 << _local_y);
    }
    else
    {
        _chunk.chunk_covered[@ _local_x] &= ~(1 << _local_y);
    }
    
    _chunk.boolean |= CHUNK_BOOL.SURFACE_LIGHTING_REFRESH;
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.LIGHTING;
    
    // Invalidate vertex buffers for all layers from WALL to _z
    for (var _zz = CHUNK_DEPTH_WALL; _zz <= _z; ++_zz)
    {
        var _vertex_buffer = _chunk.chunk_vertex_buffer[_zz];
        
        if (vertex_buffer_exists(_vertex_buffer))
        {
            vertex_delete_buffer(_vertex_buffer);
        }
        
        _chunk.chunk_vertex_buffer[@ _zz] = -1;
    }
    
    // Invalidate neighbors if on boundary
    if (_local_x == 0) || (_local_x == CHUNK_SIZE - 1)
        || (_local_y == 0) || (_local_y == CHUNK_SIZE - 1)
    {
        var _tx = _chunk.chunk_xstart;
        var _ty = _chunk.chunk_ystart;
        
        var _n_left  = (_local_x == 0) ? chunk_map_get_by_tile(_tx - CHUNK_SIZE, _ty) : undefined;
        var _n_right = (_local_x == CHUNK_SIZE - 1) ? chunk_map_get_by_tile(_tx + CHUNK_SIZE, _ty) : undefined;
        var _n_up    = (_local_y == 0) ? chunk_map_get_by_tile(_tx,     _ty - CHUNK_SIZE) : undefined;
        var _n_down  = (_local_y == CHUNK_SIZE - 1) ? chunk_map_get_by_tile(_tx,     _ty + CHUNK_SIZE) : undefined;
        
        var _neighbor_list = [_n_left, _n_right, _n_up, _n_down];
        
        for (var i = array_length(_neighbor_list) - 1; i >= 0; --i)
        {
            var _n = _neighbor_list[i];
            
            if (_n != undefined)
            {
                for (var _zz = CHUNK_DEPTH - 1; _zz >= 0; --_zz)
                {
                    var _vertex_buffer = _n.chunk_vertex_buffer[_zz];
                    
                    if (vertex_buffer_exists(_vertex_buffer))
                    {
                        vertex_delete_buffer(_vertex_buffer);
                    }
                    
                    _n.chunk_vertex_buffer[@ _zz] = -1;
                }
            }
        }
    }

    if (_z == CHUNK_DEPTH_LIQUID)
    {
        chunk_rebuild_liquid_surface_cache(_chunk);

        if (_local_y == 0)
        {
            var _n_liquid_up = chunk_map_get_by_tile(_chunk.chunk_xstart, _chunk.chunk_ystart - CHUNK_SIZE);

            if (_n_liquid_up != undefined)
            {
                chunk_rebuild_liquid_surface_cache(_n_liquid_up);
            }
        }

        if (_local_y == CHUNK_SIZE - 1)
        {
            var _n_liquid_down = chunk_map_get_by_tile(_chunk.chunk_xstart, _chunk.chunk_ystart + CHUNK_SIZE);

            if (_n_liquid_down != undefined)
            {
                chunk_rebuild_liquid_surface_cache(_n_liquid_down);
            }
        }
    }
    
    // Emit tile changed event
    if (_tile != TILE_EMPTY)
    {
        event_emit(new EventDataTilePlace(_x, _y, _z, _tile));
    }
    else if (_tile_before != TILE_EMPTY)
    {
        event_emit(new EventDataTileUpdate(_x, _y, _z, _tile_before));
    }
    
    if (_tile_before != undefined)
    {
        delete _tile_before;
    }
}
