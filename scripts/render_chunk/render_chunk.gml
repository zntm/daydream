

function render_chunk(_page, _position, _texel_width, _texel_height, _inst, _z)
{
    var _item_data = global.item_data;
    var _chunk = _inst.chunk;
    var _chunk_occluded = _inst.chunk_occluded;
    var _has_vertices = false;
    
    var _buffer = vertex_create_buffer();
    
    vertex_begin(_buffer, global.chunk_format_perspective);
    
    var _xstart = _inst.x;
    var _ystart = _inst.y;
    
    // Cache neighbors to avoid map lookups in the inner loop
    static __neighbors = array_create(8);
    var _tx = _xstart >> TILE_SIZE_BIT;
    var _ty = _ystart >> TILE_SIZE_BIT;
    
    __neighbors[@ 0] = chunk_map_get_by_tile(_tx - 1, _ty);     // Left
    __neighbors[@ 1] = chunk_map_get_by_tile(_tx + 1, _ty);     // Right
    __neighbors[@ 2] = chunk_map_get_by_tile(_tx,     _ty - 1); // Up
    __neighbors[@ 3] = chunk_map_get_by_tile(_tx,     _ty + 1); // Down
    
    for (var _x = 0; _x < CHUNK_SIZE; ++_x)
    {
        for (var _y = 0; _y < CHUNK_SIZE; ++_y)
        {
            var _tile = _chunk[tile_index_xyz(_x, _y, _z)];
            
            if (_tile == TILE_EMPTY) continue;
            
            var _id = _tile.get_id();
            var _data = _item_data[$ _id];
            
            if (!_data.get_is_visible()) continue;
            
            // Precalculated Occlusion Culling: Skip if this tile is marked as occluded
            // Precalculated Occlusion Culling: Skip if this tile AND all 4 neighbors are marked as occluded
            // We "erode" the occlusion mask by ANDing with neighbors.
            var _index_xy = tile_index_xy(_x, _y);
            var _flags = _chunk_occluded[_index_xy];
            
            if (_flags != 0)
            {
                // Left
                if (_x > 0)
                {
                    _flags &= _chunk_occluded[_index_xy - 1];
                }
                else
                {
                    var _neighbor = __neighbors[0];
                    
                    if (_neighbor != undefined)
                    {
                        _flags &= _neighbor.chunk_occluded[tile_index_xy(CHUNK_SIZE - 1, _y)];
                    }
                    else
                    {
                        _flags = 0;
                    }
                }
            }

            if (_flags != 0)
            {
                // Right
                if (_x < CHUNK_SIZE - 1)
                {
                    _flags &= _chunk_occluded[_index_xy + 1];
                }
                else
                {
                    var _neighbor = __neighbors[1];
                    
                    if (_neighbor != undefined)
                    {
                        _flags &= _neighbor.chunk_occluded[tile_index_xy(0, _y)];
                    }
                    else
                    {
                        _flags = 0;
                    }
                }
            }

            if (_flags != 0)
            {
                // Up
                if (_y > 0)
                {
                    _flags &= _chunk_occluded[_index_xy - CHUNK_SIZE];
                }
                else
                {
                    var _neighbor = __neighbors[2];
                    
                    if (_neighbor != undefined)
                    {
                        _flags &= _neighbor.chunk_occluded[tile_index_xy(_x, CHUNK_SIZE - 1)];
                    }
                    else
                    {
                        _flags = 0;
                    }
                }
            }

            if (_flags != 0)
            {
                // Down
                if (_y < CHUNK_SIZE - 1)
                {
                    _flags &= _chunk_occluded[_index_xy + CHUNK_SIZE];
                }
                else
                {
                    var _neighbor = __neighbors[3];
                    
                    if (_neighbor != undefined)
                    {
                        _flags &= _neighbor.chunk_occluded[tile_index_xy(_x, 0)];
                    }
                    else
                    {
                        _flags = 0;
                    }
                }
            }
            
            if (_flags & (1 << _z)) continue;
            
            var _index = _tile.get_index();
            var _index_offset = _tile.get_index_offset();
            
            var _sprite = _data.get_sprite();
            
            var _draw_x = _xstart + (_x << TILE_SIZE_BIT);
            var _draw_y = _ystart + (_y << TILE_SIZE_BIT);
            
            var _xscale = _tile.get_xscale();
            var _yscale = _tile.get_yscale();
            
            var _rotation = _tile.get_rotation();
            
            var _atla = _page[$ _sprite];
            
            if (_data.is_tile())
            {
                chunk_vertex_tile_connected(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _data.get_animation_type(),
                    _atla,
                    _position[_atla.___sprites_indeces[0]],
                    _index,
                    _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation
                );
                _has_vertices = true;
                
                continue;
            }
            
            if (_data.is_foliage())
            {
                chunk_vertex_foliage(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _data.get_animation_type(),
                    _atla,
                    _position[_atla.___sprites_indeces[0]],
                    _index_xy,
                    _index + _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation
                );
                _has_vertices = true;
                
                continue;
            }
            
            if (_data.is_liquid())
            {
                var _level = _tile.get_component("level") ?? 8;
                var _left_level = 0;
                var _right_level = 0;
                var _has_liquid_below = false;
                
                // Get world coordinates for this tile
                var _world_x = (_xstart >> TILE_SIZE_BIT) + _x;
                var _world_y = (_ystart >> TILE_SIZE_BIT) + _y;
                
                // Check for same liquid below (for bottom cropping)
                var _below_tile = tile_get(_world_x, _world_y + 1, _z);
                if (_below_tile != TILE_EMPTY)
                {
                    if (_below_tile.get_id() == _id)
                    {
                        _has_liquid_below = true;
                    }
                }
                
                // Check left neighbor using tile_get (handles cross-chunk)
                var _left_tile = tile_get(_world_x - 1, _world_y, _z);
                if (_left_tile != TILE_EMPTY)
                {
                    var _left_data = _item_data[$ _left_tile.get_id()];
                    if (_left_data.is_liquid())
                    {
                        _left_level = _left_tile.get_component("level") ?? 8;
                    }
                }
                
                // Check right neighbor using tile_get (handles cross-chunk)
                var _right_tile = tile_get(_world_x + 1, _world_y, _z);
                if (_right_tile != TILE_EMPTY)
                {
                    var _right_data = _item_data[$ _right_tile.get_id()];
                    if (_right_data.is_liquid())
                    {
                        _right_level = _right_tile.get_component("level") ?? 8;
                    }
                }
                
                chunk_vertex_liquid(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _data.get_animation_type(),
                    _atla,
                    _position[_atla.___sprites_indeces[0]],
                    _index + _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    _level,
                    _left_level,
                    _right_level,
                    _has_liquid_below
                );
                _has_vertices = true;
                
                continue;
            }
            
            chunk_vertex_tile(
                _buffer,
                _texel_width,
                _texel_height,
                _data.get_animation_type(),
                _atla,
                _position[_atla.___sprites_indeces[0]],
                _index + _index_offset,
                _draw_x,
                _draw_y,
                _xscale,
                _yscale,
                _rotation
            );
            _has_vertices = true;
        }
    }
    
    vertex_end(_buffer);

    if (!_has_vertices)
    {
        vertex_delete_buffer(_buffer);
        _inst.chunk_vertex_buffer[@ _z] = -1;
        return -1;
    }
    
    _inst.chunk_vertex_buffer[@ _z] = _buffer;
    
    vertex_freeze(_buffer);
    
    return _buffer;
}
