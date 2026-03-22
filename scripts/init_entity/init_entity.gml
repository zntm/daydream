/// @desc Initialize entity with new physics system (no legacy)
/// @param {Real} _hp Starting HP
/// @param {Real} _hp_max Maximum HP
/// @param {Struct.Attribute} _attribute Attribute configuration
/// @param {String} [_uuid] Unique identifier

function init_entity(_hp, _hp_max, _attribute, _uuid = uuid_generate(irandom(0xffff_ffff)))
{
    // Attribute
    attribute = new Attribute().copy_from(_attribute);
    
    // Physics system
    physics_body = new PhysicsBody(attribute);
    physics_body.id = id;
    physics_body.pos_x = x;
    physics_body.pos_y = y;
    
    // Input state
    input_state = new InputState();
    
    // Identity
    uuid = _uuid;

    // Health
    hp = _hp;
    hp_max = _hp_max;
    saturation = 20;
    
    // Fall tracking
    y_last = y;
    
    // Timers
    timer_dash = 0;
    timer_regeneration = 0;
    timer_immunity = 0;
    timer_suffocation = 0;
    
    // Audio
    audio_emitter = audio_emitter_create();
    timer_audio_effect = 0.1;
    audio_effect_lowpass = 0;
    audio_effect_reverb = 0;
    audio_effect_lowpass_to = 0;
    audio_effect_reverb_to = 0;
    timer_sfx_step = 0;
    
    // Combat
    inst_item = noone;
    timer_attack = 0;
    
    // Effects
    effects = {}
    effect_immune = undefined;
    
    // Collision box scale (for physics)
    entity_xscale = 1;
    entity_yscale = 1;

    entity_set_scale(1, 1);
}
