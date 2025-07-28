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

#macro AUDIO_EFFECT_SIZE 16

global.audio_effect_reverb = array_create(8);

for (var i = 0; i < AUDIO_EFFECT_SIZE; ++i)
{
    var _reverb = audio_effect_create(AudioEffectType.Reverb1);
    
    var _t = i / (AUDIO_EFFECT_SIZE - 1);
    
    _reverb.mix  = _t;
    _reverb.size = _t;
    
    global.audio_effect_reverb[@ i] = _reverb;
}

global.audio_effect_lpf2 = array_create(8);

for (var i = 0; i < AUDIO_EFFECT_SIZE; ++i)
{
    var _lpf2 = audio_effect_create(AudioEffectType.LPF2);
    
    _lpf2.cutoff = lerp(28_000, 600, i / (AUDIO_EFFECT_SIZE - 1));
    
    global.audio_effect_lpf2[@ i] = _lpf2;
}

global.audio_bus = {}

for (var i = 0; i < AUDIO_EFFECT_SIZE; ++i)
{
    for (var j = 0; j < AUDIO_EFFECT_SIZE; ++j)
    {
        var _audio_bus = audio_bus_create();
        
        _audio_bus.effects[@ 0] = global.audio_effect_lpf2[i];
        _audio_bus.effects[@ 1] = global.audio_effect_reverb[j];
        
        global.audio_bus[$ $"{i}_{j}"] = _audio_bus;
    }
}

global.menu_music = -1;
global.menu_music_gain = 0;

global.menu_settings_xoffset = 0;
global.menu_settings_yoffset = 0;

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