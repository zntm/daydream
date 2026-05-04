/* tile & chunk sizing */
pub const TILE_SIZE:      f32 = 16.0;
pub const CHUNK_SIZE:     i32 = 16;
pub const CHUNK_SIZE_F32: f32 = 16.0;
pub const CHUNK_DEPTH:    usize = 8;

/* chunk layer indices */
pub const LAYER_WALL:          usize = 0;
pub const LAYER_FOLIAGE_BACK:  usize = 1;
pub const LAYER_TREE_BACK:     usize = 2;
pub const LAYER_DEFAULT:       usize = 3;
pub const LAYER_FOLIAGE_FRONT: usize = 4;
pub const LAYER_TREE_FRONT:    usize = 5;
pub const LAYER_LIQUID:        usize = 7;

/* world-gen */
pub const WORLD_SURFACE_Y:   i32 = 64;  /* tile-space surface row */
pub const WORLD_DIRT_DEPTH:  i32 = 5;   /* tiles of dirt below surface */

/* gametick */
pub const GAME_TICK: f64 = 20.0;  /* ticks per second */

/* view */
pub const CHUNK_VIEW_RADIUS: i32 = 4;  /* chunks in each direction from player */

/* connected-texture frame count */
pub const CONNECTED_FRAMES: u32 = 5;

/* 8-bit neighbor bitmask bit positions (matches GML 0bTL_T_TR_L_R_BL_B_BR) */
pub const NEIGHBOR_TL: u8 = 1 << 7;
pub const NEIGHBOR_T:  u8 = 1 << 6;
pub const NEIGHBOR_TR: u8 = 1 << 5;
pub const NEIGHBOR_L:  u8 = 1 << 4;
pub const NEIGHBOR_R:  u8 = 1 << 3;
pub const NEIGHBOR_BL: u8 = 1 << 2;
pub const NEIGHBOR_B:  u8 = 1 << 1;
pub const NEIGHBOR_BR: u8 = 1 << 0;
