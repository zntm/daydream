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
    _container:         []
}

global.inventory_names = [
    "base",
    "armor_helmet",
    "armor_breastplate",
    "armor_leggings",
    "accessory",
    "_container"
];

global.inventory_length = {
    base:              INVENTORY_LENGTH.BASE,
    armor_helmet:      1,
    armor_breastplate: 1,
    armor_leggings:    1,
    accessory:         INVENTORY_LENGTH.ACCESSORY,
    _container:         0
}

global.inventory_instance = {
    base:              array_create(INVENTORY_LENGTH.BASE, noone),
    armor_helmet:      array_create(1, noone),
    armor_breastplate: array_create(1, noone),
    armor_leggings:    array_create(1, noone),
    accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, noone),
    _container: [],
    _craftable: []
}

global.inventory_instance_names = [
    "base",
    "armor_helmet",
    "armor_breastplate",
    "armor_leggings",
    "accessory",
    "_container",
    "_craftable"
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

global.chunk_depth = {
    "default": 3,
    "wall": 0
}

/*
#macro CHUNK_DEPTH_DEFAULT       3
#macro CHUNK_DEPTH_WALL          0
#macro CHUNK_DEPTH_TREE_BACK     2
#macro CHUNK_DEPTH_TREE_FRONT    5
#macro CHUNK_DEPTH_TREE          choose(CHUNK_DEPTH_TREE_BACK, CHUNK_DEPTH_TREE_FRONT)
#macro CHUNK_DEPTH_FOLIAGE_BACK  1
#macro CHUNK_DEPTH_FOLIAGE_FRONT 4
#macro CHUNK_DEPTH_FOLIAGE       choose(CHUNK_DEPTH_FOLIAGE_BACK, CHUNK_DEPTH_FOLIAGE_FRONT)
#macro CHUNK_DEPTH_LIQUID        7

 */

global.window_width  = window_get_width();
global.window_height = window_get_height();

global.window_focus = true;

global.delta_time = delta_time / 1_000_000;

global.attribute_player = new Attribute()
    .set_collision_box({
        width:  16,
        height: 32
    })
    .set_hit_box({
        width:  14,
        height: 31
    })
    .set_eye_level(8)
    .set_gravity(0.72)
    .set_jump_count_max(1)
    .set_jump_falloff(2.2)
    .set_jump_height(8.2)
    .set_jump_time(12)
    .set_movement_speed(3.1)
    .set_regeneration_amount(1)
    .set_regeneration_time(2.4);