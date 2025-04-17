#macro DATAFILES_RESOURCES (((GM_build_type == "run") ? $"{filename_dir(GM_project_filename)}/datafiles/" : "") + "resources")

#macro TILE_EMPTY 0

#macro TILE_SIZE_BIT 4
#macro TILE_SIZE (1 << TILE_SIZE_BIT)

#macro CHUNK_SIZE_BIT 4
#macro CHUNK_SIZE (1 << CHUNK_SIZE_BIT)

#macro CHUNK_DEPTH 8

#macro CHUNK_SIZE_DIMENSION (CHUNK_SIZE * TILE_SIZE)

#macro CHUNK_DEPTH_DEFAULT       3
#macro CHUNK_DEPTH_WALL          0
#macro CHUNK_DEPTH_TREE_BACK     2
#macro CHUNK_DEPTH_TREE_FRONT    5
#macro CHUNK_DEPTH_TREE          choose(CHUNK_DEPTH_TREE_BACK, CHUNK_DEPTH_TREE_FRONT)
#macro CHUNK_DEPTH_FOLIAGE_BACK  1
#macro CHUNK_DEPTH_FOLIAGE_FRONT 4
#macro CHUNK_DEPTH_FOLIAGE       choose(CHUNK_DEPTH_FOLIAGE_BACK, CHUNK_DEPTH_FOLIAGE_FRONT)
#macro CHUNK_DEPTH_LIQUID        7

global.tile_connected_index = [
     1,  1,
     0,  1,
    -1,  1,
     1,  0,
    -1,  0,
     1, -1,
     0, -1,
    -1, -1,
];

surface_depth_disable(true);

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);