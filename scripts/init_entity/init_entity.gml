function init_entity(_hp, _hp_max, _attribute, _uuid = uuid_generate(irandom(0xffff_ffff)))
{
    attribute = _attribute;
    
    init_entity_physics(1);
    
    uuid = _uuid;
    
    hp = _hp;
    hp_max = _hp_max;
    
    saturation = 0;
    
    timer_regeneration = 0;
    
    jump_pressed = 0;
    jump_count = 0;
    
    timer_coyote = 0;
    
    input_left = false;
    input_right = false;
    
    input_jump = false;
    input_jump_pressed = false;
    
    audio_emitter = audio_emitter_create();
    
    timer_audio_effect = 0;
    
    audio_effect_lowpass = 0;
    audio_effect_reverb  = 0;

    audio_effect_lowpass_to = 0;
    audio_effect_reverb_to  = 0;
    
    timer_sfx_step = 0;
}