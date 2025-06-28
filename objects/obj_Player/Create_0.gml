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
        gravity: 0.72,
        movement_speed: 13.1,
        jump_time: 12,
        jump_height: 28.5,
        jump_count_max: 1,
        jump_falloff: 2.2
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

timer_coyote = 0;

ylast = 0;

input_left = false;
input_right = false;

input_jump = false;
input_jump_pressed = false;

timer_sfx_harvest = 0;
timer_sfx_step = 0;

audio_emitter = audio_emitter_create();
audio_bus     = audio_bus_create();

audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.REVERB] = audio_effect_create(AudioEffectType.Reverb1, {
    mix: 0
});

audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.LPF] = audio_effect_create(AudioEffectType.LPF2, {
    cutoff: 20_000
});

audio_emitter_bus(audio_emitter, audio_bus);