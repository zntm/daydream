entity_value = {
    collision_box: {
        width:  16,
        height: 32
    },
    hit_box: {
        width:  16 - 1 - 2,
        height: 32 - 1 - 2
    },
    eye_level: 8,
    physics: {
        gravity: 0.52,
        movement_speed: 1.9,
        jump_time: 12,
        jump_height: 3.7
    }
}

image_xscale = entity_value.collision_box.width  / 8;
image_yscale = entity_value.collision_box.height / 8;

hp = 100;
hp_max = 100;

xvelocity = 0;
yvelocity = 0;

jump_pressed = 0;
jump_count = 0;

coyote_time = 0;

ylast = 0;

input_left = false;
input_right = false;

input_jump = false;
input_jump_pressed = false;