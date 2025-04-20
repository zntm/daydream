function control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _tile_connected_index = global.tile_connected_index;
    
    var _item_data = global.item_data;
    
    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    
    var _world_data = global.world_data[$ global.world.dimension];
    var _world_height = _world_data.get_world_height();
    
    for (var i = -_a; i <= _a; ++i)
    {
        for (var j = -_b; j <= _b; ++j)
        {
            var _x = (round(_player_x / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (i * CHUNK_SIZE_DIMENSION);
            var _y = (round(_player_y / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            var _inst = instance_position(_x, _y, obj_Chunk);
            
            if (!instance_exists(_inst))
            {
                instance_create_layer(_x, _y, "Instances", obj_Chunk);
            }
        }
    }
    
    for (var i = -_a; i <= _a; ++i)
    {
        for (var j = -_b; j <= _b; ++j)
        {
            var _x = (round(_player_x / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (i * CHUNK_SIZE_DIMENSION);
            var _y = (round(_player_y / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            var _inst = instance_position(_x, _y, obj_Chunk);
            
            if (!instance_exists(_inst)) || (_inst.is_generated) continue;
            
            _inst.is_generated = true;
            
            var _chunk = _inst.chunk;
            
            for (var _tile_z = 0; _tile_z < CHUNK_DEPTH; ++_tile_z)
            {
                if ((_inst.chunk_display & (1 << _tile_z)) == 0) continue;
                
                for (var _tile_y = 0; _tile_y < CHUNK_SIZE; ++_tile_y)
                {
                    for (var _tile_x = 0; _tile_x < CHUNK_SIZE; ++_tile_x)
                    {
                        var _tile = _chunk[(_tile_z << (CHUNK_SIZE_BIT * 2)) | (_tile_y << CHUNK_SIZE_BIT) | _tile_x];
                        
                        /*
                        if (_tile == TILE_EMPTY) || (_tile == TILE_STRUCTURE_VOID) || (!_item_data[$ _tile.get_item_id()].is_tile()) continue;
                        
                        // if (_tile_x > 0) && (_tile_x < CHUNK_SIZE - 1) && (_tile_y > 0) && (_tile_y < CHUNK_SIZE - 1)
                        {
                            var _bit = 0;
                            
                            for (var l = 0; l < 8; ++l)
                            {
                                var _index = l * 2;
                                
                                var _x2 = _tile_x + _tile_connected_index[_index + 0];
                                var _y2 = _tile_y + _tile_connected_index[_index + 1];
                                
                                // var _ = _chunk[(_tile_z << (CHUNK_SIZE_BIT * 2)) | (_y2 << CHUNK_SIZE_BIT) | _x2];
                                var _ = tile_get(_inst.chunk_xstart + _x2, _inst.chunk_ystart + _y2, _tile_z);
                                
                                if (_ != TILE_EMPTY)
                                {
                                    _bit |= 1 << l;
                                }
                            }
                            
                            _tile.set_index(_bit);
                            
                            if
                            (_bit == 0b000_00_000) ||
                            (_bit == 0b111_11_111)
                            {
                                if (chance_seeded(0.5, global.world.seed + ((_inst.chunk_xstart + _tile_x) * 1_039) - ((_inst.chunk_ystart + _tile_y) * 7_222)))
                                {
                                    _tile.set_xscale(-1);
                                }
                                
                                if (chance_seeded(0.5, global.world.seed + ((_inst.chunk_xstart + _tile_x) * 5_129) - ((_inst.chunk_ystart + _tile_y) * 8_202)))
                                {
                                    _tile.set_yscale(-1);
                                }
                            }
                            
                            if
                            (_bit == 0b111_00_000) ||
                            (_bit == 0b000_11_000) ||
                            (_bit == 0b000_00_111) ||
                            (_bit == 0b111_11_000) ||
                            (_bit == 0b000_11_111) ||
                            (_bit == 0b111_00_111) ||
                            (_bit == 0b111_11_111)
                            {
                                if (chance_seeded(0.5, global.world.seed + ((_inst.chunk_xstart + _tile_x) * 1_039) - ((_inst.chunk_ystart + _tile_y) * 7_222)))
                                {
                                    _tile.set_xscale(-1);
                                }
                            }
                        }
                        */
                    }
                }
            }
        }
    }
}