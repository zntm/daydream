entity_value = {
    collision_box: {
        width:  16,
        height: 32
    },
    hit_box: {
        width:  16 - 1 - 2,
        height: 32 - 1 - 2
    },
    eye_level: 8
}

hp = 100;
hp_max = 100;

image_xscale = entity_value.collision_box.width  / 8;
image_yscale = entity_value.collision_box.height / 8;