enum VERSION_VALUE {
    MAJOR = 2025,
    MINOR = 0,
    PATCH = 0
}

#macro PROGRAM_NAME "Phantasia"
#macro PROGRAM_DIRECTORY_RESOURCES (((GM_build_type == "run") ? $"{filename_dir(GM_project_filename)}/datafiles/" : "") + "resources")

#region Chunk

#macro TILE_EMPTY 0
#macro TILE_STRUCTURE_VOID -1

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

#endregion

#region Physics

#macro PHYSICS_GLOBAL_GRAVITY 0.12
#macro PHYSICS_GLOBAL_TERMINAL_YVELOCITY 24
#macro PHYSICS_GLOBAL_THRESHOLD_NUDGE 3

#macro PHYSICS_GLOBAL_COYOTE_TIME 8

#macro PHYSICS_GLOBAL_JUMP_TIME_LENGTH 68
#macro PHYSICS_GLOBAL_JUMP_HEIGHT 1.31

#endregion

#macro GUI_SAFE_ZONE_X 24
#macro GUI_SAFE_ZONE_Y 24

global.inventory = {
    base:              array_create(INVENTORY_LENGTH.BASE, INVENTORY_EMPTY),
    armor_helmet:      array_create(1, INVENTORY_EMPTY),
    armor_breastplate: array_create(1, INVENTORY_EMPTY),
    armor_leggings:    array_create(1, INVENTORY_EMPTY),
    accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, INVENTORY_EMPTY),
    craftable: [],
    container: []
}

global.inventory_length = {
    base:              INVENTORY_LENGTH.BASE,
    armor_helmet:      1,
    armor_breastplate: 1,
    armor_leggings:    1,
    accessory:         INVENTORY_LENGTH.ACCESSORY,
    craftable:         0,
    container:         0
}

global.inventory_instance = {
    base:              array_create(INVENTORY_LENGTH.BASE, noone),
    armor_helmet:      array_create(1, noone),
    armor_breastplate: array_create(1, noone),
    armor_leggings:    array_create(1, noone),
    accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, noone),
    craftable: [],
    container: []
}