attribute = global.attribute_player;

image_xscale = attribute.get_collision_box_width()  / 8;
image_yscale = attribute.get_collision_box_height() / 8;

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