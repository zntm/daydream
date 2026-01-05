/// @function tile_place(_x, _y, _z, _tile)
/// @desc Place a tile at the specified position
function tile_place(_x, _y, _z, _tile)
{
    if (_y < 0) || (_y >= global.world_data[$ global.world_save_data.dimension].get_world_height()) exit;
    
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
        
        ++_chunk.chunk_count[@ _z];
        
        var _data = global.item_data[$ _tile.get_id()];    
        
        if (_data.get_render_state_length() > 0)
        {
            array_push(_chunk.chunk_render_state, global.render_state_pool.acquire(_x, _y, _z, _data.get_render_state()));
        }
    }
    else if (_tile_before != TILE_EMPTY) && (--_chunk.chunk_count[_z] <= 0)
    {
        _chunk.chunk_display ^= 1 << _z;
        
        var _render_state = _chunk.chunk_render_state;
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
        
        if (_instance_crafting_station != noone)
        {
            var _index_inst = array_get_index(_chunk.chunk_crafting_stations, _instance_crafting_station);
            if (_index_inst != -1) array_delete(_chunk.chunk_crafting_stations, _index_inst, 1);
        }
        
        var _instance_container = _tile_before.get_instance_container();
        
        if (_instance_container != noone)
        {
            var _index_inst = array_get_index(_chunk.chunk_containers, _instance_container);
            if (_index_inst != -1) array_delete(_chunk.chunk_containers, _index_inst, 1);
        }
        
        var _instance_light = _tile_before.get_instance_light();
        
        if (_instance_light != noone)
        {
            var _index_inst = array_get_index(_chunk.chunk_lights, _instance_light);
            if (_index_inst != -1) array_delete(_chunk.chunk_lights, _index_inst, 1);
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
    var _item_data = global.item_data;
    
    for (var _zz = CHUNK_DEPTH_DEFAULT; _zz >= CHUNK_DEPTH_WALL; --_zz)
    {
        if (_has_opaque_above)
        {
            _occluded |= (1 << _zz);
        }
        
        var _tile_check = _chunk.chunk[tile_index_xyz(_local_x, _local_y, _zz)];
        if (_tile_check != TILE_EMPTY)
        {
            var _data = _item_data[$ _tile_check.get_id()];
            if (_data != undefined && !_data.is_transparent() && _data.has_type(ITEM_TYPE_BIT.SOLID))
            {
                _has_opaque_above = true;
            }
        }
    }
    _chunk.chunk_occluded[@ tile_index_xy(_local_x, _local_y)] = _occluded;
    
    // Invalidate vertex buffers for all layers from WALL to _z
    for (var _zz = CHUNK_DEPTH_WALL; _zz <= _z; ++_zz)
    {
        var _vertex_buffer = _chunk.chunk_vertex_buffer[_zz];
        if (vertex_buffer_exists(_vertex_buffer))
        {
            vertex_delete_buffer(_vertex_buffer);
            _chunk.chunk_vertex_buffer[@ _zz] = -1;
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