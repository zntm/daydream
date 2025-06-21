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