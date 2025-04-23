chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

tile_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

is_generated = false;
is_in_view = false;

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

chunk_generate();