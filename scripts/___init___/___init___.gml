#macro PROGRAM_VERSION_MAJOR current_year
#macro PROGRAM_VERSION_MINOR current_month
#macro PROGRAM_VERSION_PATCH 0

#macro PROGRAM_NAME "Phantasia"

#macro GAME_TICK 60

#macro SITE_BLUESKY "https://bsky.app/profile/phantasiagame.bsky.social"
#macro SITE_DISCORD "https://discord.gg/PjdKzPZUKK"
#macro SITE_TWITTER "https://x.com/PhantasiaGame"

cursor_sprite = spr_Mouse;

randomize();

window_set_cursor(cr_none);

gml_pragma("MarkTagAsUsed", "include_me");

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

#region Menu

#macro MENU_TRANSITION_FADE_SPEED 0.88

#endregion

#region Physics

#macro PHYSICS_GLOBAL_GRAVITY 3.7
#macro PHYSICS_GLOBAL_TERMINAL_YVELOCITY 24
#macro PHYSICS_GLOBAL_THRESHOLD_NUDGE 3

#macro PHYSICS_GLOBAL_timer_coyote 8

#endregion

#macro GUI_SAFE_ZONE_X 24
#macro GUI_SAFE_ZONE_Y 24

global.inventory = {
    mouse: {
        item: INVENTORY_EMPTY,
        type:  "",
        index: -1
    },
    base:              array_create(INVENTORY_LENGTH.BASE, INVENTORY_EMPTY),
    armor_helmet:      array_create(1, INVENTORY_EMPTY),
    armor_breastplate: array_create(1, INVENTORY_EMPTY),
    armor_leggings:    array_create(1, INVENTORY_EMPTY),
    accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, INVENTORY_EMPTY),
    container:         []
}

global.inventory_names = [
    "base",
    "armor_helmet",
    "armor_breastplate",
    "armor_leggings",
    "accessory",
    "container"
];

global.inventory_length = {
    base:              INVENTORY_LENGTH.BASE,
    armor_helmet:      1,
    armor_breastplate: 1,
    armor_leggings:    1,
    accessory:         INVENTORY_LENGTH.ACCESSORY,
    container:         0
}

global.inventory_instance = {
    base:              array_create(INVENTORY_LENGTH.BASE, noone),
    armor_helmet:      array_create(1, noone),
    armor_breastplate: array_create(1, noone),
    armor_leggings:    array_create(1, noone),
    accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, noone),
    container: [],
    craftable: []
}

global.inventory_instance_names = [
    "base",
    "armor_helmet",
    "armor_breastplate",
    "armor_leggings",
    "accessory",
    "container",
    "craftable"
];

global.attire_elements = [
    "body",
    "headwear",
    "hair",
    "eyes",
    "face",
    "shirt",
    "shirt_detail",
    "pants",
    "footwear"
];

global.attire_elements_ordered = [
    "body",
    "body_arm_right",
    [ "shirt", 0 ],
    [ "shirt_detail", 0 ],
    "body_legs",
    "eyes",
    "headwear",
    "face",
    "hair", 
    "pants",
    [ "shirt", 1 ],
    [ "shirt_detail", 1 ],
    "body_arm_left",
    [ "shirt", 2 ],
    [ "shirt_detail", 2 ],
    "footwear"
];