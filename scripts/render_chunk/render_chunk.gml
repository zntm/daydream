
function render_chunk(_page, _position, _texel_width, _texel_height, _inst, _z)
{
    static __level_key = "level";
    static __neighbor_tiles = array_create(4);
    static __neighbor_occluded = array_create(4);

    var _item_data = global.item_data;
    var _chunk = _inst.chunk;
    var _chunk_occluded = _inst.chunk_occluded;
    var _has_vertices = false;

    var _buffer = vertex_create_buffer();

    vertex_begin(_buffer, global.chunk_format_perspective);

    var _xstart = _inst.x;
    var _ystart = _inst.y;

    var _chunk_tile_x = _xstart >> TILE_SIZE_BIT;
    var _chunk_tile_y = _ystart >> TILE_SIZE_BIT;
    var _world_height = global.world_data[$ global.current_world.dimension].get_world_height();
    var _z_bit = 1 << _z;
    var _z_offset = _z << (CHUNK_SIZE_BIT * 2);
    var _last_local = CHUNK_SIZE - 1;
    var _last_row_offset = _last_local << CHUNK_SIZE_BIT;

    var _neighbor = chunk_map_get_by_tile(_chunk_tile_x - CHUNK_SIZE, _chunk_tile_y);
    if (_neighbor != undefined) && !(_neighbor.boolean & CHUNK_BOOL.GENERATED) _neighbor = undefined;
    __neighbor_tiles[@ 0] = (_neighbor != undefined) ? _neighbor.chunk : undefined;
    __neighbor_occluded[@ 0] = (_neighbor != undefined) ? _neighbor.chunk_occluded : undefined;

    _neighbor = chunk_map_get_by_tile(_chunk_tile_x + CHUNK_SIZE, _chunk_tile_y);
    if (_neighbor != undefined) && !(_neighbor.boolean & CHUNK_BOOL.GENERATED) _neighbor = undefined;
    __neighbor_tiles[@ 1] = (_neighbor != undefined) ? _neighbor.chunk : undefined;
    __neighbor_occluded[@ 1] = (_neighbor != undefined) ? _neighbor.chunk_occluded : undefined;

    _neighbor = chunk_map_get_by_tile(_chunk_tile_x, _chunk_tile_y - CHUNK_SIZE);
    if (_neighbor != undefined) && !(_neighbor.boolean & CHUNK_BOOL.GENERATED) _neighbor = undefined;
    __neighbor_tiles[@ 2] = (_neighbor != undefined) ? _neighbor.chunk : undefined;
    __neighbor_occluded[@ 2] = (_neighbor != undefined) ? _neighbor.chunk_occluded : undefined;

    _neighbor = chunk_map_get_by_tile(_chunk_tile_x, _chunk_tile_y + CHUNK_SIZE);
    if (_neighbor != undefined) && !(_neighbor.boolean & CHUNK_BOOL.GENERATED) _neighbor = undefined;
    __neighbor_tiles[@ 3] = (_neighbor != undefined) ? _neighbor.chunk : undefined;
    __neighbor_occluded[@ 3] = (_neighbor != undefined) ? _neighbor.chunk_occluded : undefined;

    var _left_tiles = __neighbor_tiles[0];
    var _right_tiles = __neighbor_tiles[1];
    var _down_tiles = __neighbor_tiles[3];

    var _left_occluded = __neighbor_occluded[0];
    var _right_occluded = __neighbor_occluded[1];
    var _up_occluded = __neighbor_occluded[2];
    var _down_occluded = __neighbor_occluded[3];

    for (var _y = 0; _y < CHUNK_SIZE; ++_y)
    {
        var _row_offset = _y << CHUNK_SIZE_BIT;
        var _draw_y = _ystart + (_y << TILE_SIZE_BIT);
        var _world_y = _chunk_tile_y + _y;
        var _left_edge_index = _row_offset | _last_local;
        var _right_edge_index = _row_offset;

        for (var _x = 0; _x < CHUNK_SIZE; ++_x)
        {
            var _index_xy = _row_offset | _x;
            var _tile = _chunk[_z_offset | _index_xy];

            if (_tile == TILE_EMPTY) continue;

            var _id = _tile.get_id();
            var _data = _item_data[$ _id];
            
            if (_data == undefined) continue;
            if (!_data.get_is_visible()) continue;

            var _flags = _chunk_occluded[_index_xy];

            if (_flags != 0)
            {
                if (_x > 0)
                {
                    _flags &= _chunk_occluded[_index_xy - 1];
                }
                else
                {
                    _flags = (_left_occluded != undefined) ? (_flags & _left_occluded[_left_edge_index]) : 0;
                }
            }

            if (_flags != 0)
            {
                if (_x < _last_local)
                {
                    _flags &= _chunk_occluded[_index_xy + 1];
                }
                else
                {
                    _flags = (_right_occluded != undefined) ? (_flags & _right_occluded[_right_edge_index]) : 0;
                }
            }

            if (_flags != 0)
            {
                if (_y > 0)
                {
                    _flags &= _chunk_occluded[_index_xy - CHUNK_SIZE];
                }
                else
                {
                    _flags = (_up_occluded != undefined) ? (_flags & _up_occluded[_last_row_offset | _x]) : 0;
                }
            }

            if (_flags != 0)
            {
                if (_y < _last_local)
                {
                    _flags &= _chunk_occluded[_index_xy + CHUNK_SIZE];
                }
                else
                {
                    _flags = (_down_occluded != undefined) ? (_flags & _down_occluded[_x]) : 0;
                }
            }

            if (_flags & _z_bit) continue;

            var _index = _tile.get_index();
            var _index_offset = _tile.get_index_offset();
            var _frame_index = _index + _index_offset;
            var _animation_type = _data.get_animation_type();
            var _sprite = _data.get_sprite();
            var _atla = _page[$ _sprite];
            var _atla_sprite = _position[_atla.___sprites_indeces[0]];

            var _draw_x = _xstart + (_x << TILE_SIZE_BIT);
            var _world_x = _chunk_tile_x + _x;

            var _xscale = _tile.get_xscale();
            var _yscale = _tile.get_yscale();

            var _rotation = _tile.get_rotation();

            if (_data.is_tile())
            {
                _has_vertices = chunk_vertex_tile_connected(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _animation_type,
                    _atla,
                    _atla_sprite,
                    _index,
                    _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    _has_vertices
                );

                continue;
            }

            if (_data.is_foliage())
            {
                _has_vertices = chunk_vertex_foliage(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _animation_type,
                    _atla,
                    _atla_sprite,
                    _index_xy,
                    _frame_index,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    _has_vertices
                );

                continue;
            }

            if (_data.is_liquid())
            {
                _animation_type = TILE_ANIMATION_TYPE.WAVE;

                var _level = _tile.get_component(__level_key) ?? 8;
                var _left_level = 0;
                var _right_level = 0;
                /* left corner samples the left neighbor's wave so adjacent tiles
                   share the same edge displacement, forming a continuous surface */
                var _wave_index_left = (_x > 0) ? (_index_xy - 1) : _index_xy;
                var _wave_index_right = _index_xy;
                var _has_liquid_above = false;
                var _has_liquid_below = false;

                var _left_tile = TILE_EMPTY;
                if (_x > 0)
                {
                    _left_tile = _chunk[_z_offset | (_index_xy - 1)];
                }
                else if (_left_tiles != undefined)
                {
                    _left_tile = _left_tiles[_z_offset | _left_edge_index];
                }
                else
                {
                    _left_tile = tile_predict(_world_x - 1, _world_y, _z);
                }

                if (_left_tile != TILE_EMPTY)
                {
                    var _left_data = _item_data[$ _left_tile.get_id()];
                    if ((_left_data != undefined) && _left_data.is_liquid())
                    {
                        _left_level = _left_tile.get_component(__level_key) ?? 8;
                    }
                }

                var _right_tile = TILE_EMPTY;
                if (_x < _last_local)
                {
                    _right_tile = _chunk[_z_offset | (_index_xy + 1)];
                }
                else if (_right_tiles != undefined)
                {
                    _right_tile = _right_tiles[_z_offset | _right_edge_index];
                }
                else
                {
                    _right_tile = tile_predict(_world_x + 1, _world_y, _z);
                }

                if (_right_tile != TILE_EMPTY)
                {
                    var _right_data = _item_data[$ _right_tile.get_id()];
                    if ((_right_data != undefined) && _right_data.is_liquid())
                    {
                        _right_level = _right_tile.get_component(__level_key) ?? 8;
                    }
                }

                var _above_tile = TILE_EMPTY;
                if (_y > 0)
                {
                    _above_tile = _chunk[_z_offset | (_index_xy - CHUNK_SIZE)];
                }
                else if (__neighbor_tiles[2] != undefined)
                {
                    _above_tile = __neighbor_tiles[2][_z_offset | (_last_row_offset | _x)];
                }
                else if ((_world_y - 1) >= 0)
                {
                    _above_tile = tile_predict(_world_x, _world_y - 1, _z);
                }

                if (_above_tile != TILE_EMPTY) && (_above_tile.get_id() == _id)
                {
                    _has_liquid_above = true;
                }

                var _below_tile = TILE_EMPTY;
                if (_y < _last_local)
                {
                    _below_tile = _chunk[_z_offset | (_index_xy + CHUNK_SIZE)];
                }
                else if (_down_tiles != undefined)
                {
                    _below_tile = _down_tiles[_z_offset | _x];
                }
                else if ((_world_y + 1) < _world_height)
                {
                    _below_tile = tile_predict(_world_x, _world_y + 1, _z);
                }

                if (_below_tile != TILE_EMPTY) && (_below_tile.get_id() == _id)
                {
                    _has_liquid_below = true;
                }

                _has_vertices = chunk_vertex_liquid(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _animation_type,
                    _atla,
                    _atla_sprite,
                    _wave_index_left,
                    _wave_index_right,
                    _frame_index,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    _level,
                    _left_level,
                    _right_level,
                    _has_liquid_above,
                    _has_liquid_below,
                    _has_vertices
                );

                continue;
            }

            _has_vertices = chunk_vertex_tile(
                _buffer,
                _texel_width,
                _texel_height,
                _animation_type,
                _atla,
                _atla_sprite,
                _frame_index,
                _draw_x,
                _draw_y,
                _xscale,
                _yscale,
                _rotation,
                _has_vertices
            );
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
