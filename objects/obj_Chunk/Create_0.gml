chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

chunk_covered = array_create(CHUNK_SIZE);
chunk_covered_surface = -1;
chunk_covered_surface_refresh = true;

chunk_skew_back = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_back_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_skew_front = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_front_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

chunk_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

enum CHUNK_BOOLEAN {
    GENERATED                = 1 << 0,
    SURFACE_LIGHTING_REFRESH = 1 << 1
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

/*
function init_chunk_audio_emitter(_value, _index)
{
    var _audio_emitter = audio_emitter_create();
    
    var _x = (chunk_xstart + (_index                     & (CHUNK_SIZE - 1))) * TILE_SIZE;
    var _y = (chunk_ystart + ((_index >> CHUNK_SIZE_BIT) & (CHUNK_SIZE - 1))) * TILE_SIZE;
    
    audio_emitter_position(_audio_emitter, _x, _y, 0);
    
    return _audio_emitter;
}
*/

chunk_audio_emitter = array_create(CHUNK_SIZE * CHUNK_SIZE);

for (var i = 0; i < CHUNK_SIZE; ++i)
{
    for (var j = 0; j < CHUNK_SIZE; ++j)
    {
        var _audio_emitter = audio_emitter_create();
        
        var _x = (chunk_xstart + i) * TILE_SIZE;
        var _y = (chunk_ystart + j) * TILE_SIZE;
        
        audio_emitter_position(_audio_emitter, _x, _y, 0);
        
        chunk_audio_emitter[@ tile_index_xy(i, j)] = _audio_emitter;
    }
}

// chunk_audio_emitter = array_create_ext(CHUNK_SIZE * CHUNK_SIZE, method(id, init_chunk_audio_emitter));