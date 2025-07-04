chunk = array_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH, TILE_EMPTY);

chunk_skew_back = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_back_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_skew_front = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);
chunk_skew_front_to = array_create(CHUNK_SIZE * CHUNK_SIZE, 0);

chunk_vertex_buffer = array_create(CHUNK_DEPTH, -1);

chunk_count = array_create(CHUNK_DEPTH, 0);

chunk_display = 0;

is_generated = false;

chunk_xstart = floor(x / CHUNK_SIZE);
chunk_ystart = floor(y / CHUNK_SIZE);

xcenter = x - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);
ycenter = y - (TILE_SIZE / 2) + (CHUNK_SIZE_DIMENSION / 2);

control_structure(chunk_xstart, chunk_ystart);

chunk_generate();