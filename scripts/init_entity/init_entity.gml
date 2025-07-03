function init_entity(_hp, _hp_max, _attribute)
{
    attribute = _attribute;
    
    image_xscale = _attribute.get_collision_box_width()  / 8;
    image_yscale = _attribute.get_collision_box_height() / 8;
    
    hp = _hp;
    hp_max = _hp_max;
    
    xvelocity = 0;
    yvelocity = 0;
    
    jump_pressed = 0;
    jump_count = 0;
    
    timer_coyote = 0;
    
    input_left = false;
    input_right = false;
    
    input_jump = false;
    input_jump_pressed = false;
    
    audio_emitter = audio_emitter_create();
    audio_bus     = audio_bus_create();
    
    audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.REVERB] = audio_effect_create(AudioEffectType.Reverb1, {
        mix: 0
    });
    
    audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.LPF] = audio_effect_create(AudioEffectType.LPF2, {
        cutoff: 20_000
    });
    
    audio_emitter_bus(audio_emitter, audio_bus);
}