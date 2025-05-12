chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);
chunk_skew = array_create(CHUNK_SIZE * CHUNK_SIZE * 2, 0);
chunk_skew_to = array_create(CHUNK_SIZE * CHUNK_SIZE * 2, 0);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

chunk_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

is_generated = false;

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

chunk_generate();