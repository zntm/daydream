chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

chunk_covered = array_create(CHUNK_SIZE);
chunk_covered_surface = -1;
chunk_covered_surface_refresh = true;

chunk_render_state = [];

chunk_skew_back = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_back_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_skew_front = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_front_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

chunk_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

enum CHUNK_BOOLEAN {
    GENERATED                = 1 << 0,
    SURFACE_LIGHTING_REFRESH = 1 << 1,
    QUEUED                   = 1 << 2,  // Chunk is queued for generation
    DIRTY                    = 1 << 3   // Chunk vertex buffer needs rebuild
}

boolean =
    CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;

surface_lighting = -1;

xcenter = x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
ycenter = y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);

control_structure(chunk_xstart, chunk_ystart);

var _world_save_data = global.world_save_data;

var _is_loaded = file_load_world_chunk(_world_save_data, id);

if (!_is_loaded)
{
	chunk_generate();
}
else
{
    var _item_data = global.item_data;
    
    for (var _tile_z = 0; _tile_z < CHUNK_DEPTH; ++_tile_z)
    {
        if !(chunk_display & (1 << _tile_z)) continue;
        
        for (var _tile_y = 0; _tile_y < CHUNK_SIZE; ++_tile_y)
        {
            for (var _tile_x = 0; _tile_x < CHUNK_SIZE; ++_tile_x)
            {
                var _world_x = chunk_xstart + _tile_x;
                var _world_y = chunk_ystart + _tile_y;
                
                var _tile = chunk[tile_index_xyz(_world_x, _world_y, _tile_z)];
                
                if (_tile == TILE_EMPTY) continue;
                
                var _data = _item_data[$ _tile.get_id()];
                
                tile_instance_create(_world_x, _world_y, _tile_z, _tile);
                
                tile_connect(_world_x, _world_y, _tile_z, _tile);
            }
        }
    }
}
