/// @description Initialize falling tile properties

// Tile data
tile_id = "";
tile_index = 0;
tile_z = CHUNK_DEPTH_DEFAULT;
tile_components = undefined;

// Physics Body & Input
physics_body = undefined;
input_state = new InputState();

// Interpolation
x_previous = x;
y_previous = y;

// Origin tracking
origin_x = 0;
origin_y = 0;

// Entity setup
entity_xscale = 1;
entity_yscale = 1;

// Collision attribute
attribute = undefined;
