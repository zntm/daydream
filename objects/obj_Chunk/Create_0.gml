chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);
chunk_covered = array_create(CHUNK_SIZE);

chunk_skew_back = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_back_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_skew_front = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_front_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

chunk_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

surface_light = -1;
surface_light_refresh = true;

is_generated = false;

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

xcenter = x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
ycenter = y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);

control_structure(chunk_xstart, chunk_ystart);

var _world_save_data = global.world_save_data;

var _is_loaded = file_load_world_chunk(_world_save_data, id);

if (!_is_loaded)
{
	chunk_generate();
}