function sfx_environment_get_effect_index(_value = 0)
{
    return clamp(round(clamp(_value, 0, 1) * (AUDIO_EFFECT_SIZE - 1)), 0, AUDIO_EFFECT_SIZE - 1);
}

function sfx_environment_get_bus_from_indices(_lowpass_index = 0, _reverb_index = 0)
{
    _lowpass_index = clamp(_lowpass_index, 0, AUDIO_EFFECT_SIZE - 1);
    _reverb_index = clamp(_reverb_index, 0, AUDIO_EFFECT_SIZE - 1);
    
    return global.audio_bus_grid[_lowpass_index][@ _reverb_index] ?? audio_bus_main;
}

function sfx_environment_get_listener_effects(_listener = obj_Player)
{
    if (!instance_exists(_listener))
    {
        return {
            lowpass: 0,
            reverb: 0,
            lowpass_index: 0,
            reverb_index: 0,
            bus: audio_bus_main
        }
    }
    
    var _lowpass = clamp(_listener.audio_effect_lowpass_to ?? _listener.audio_effect_lowpass ?? 0, 0, 1);
    var _reverb = clamp(_listener.audio_effect_reverb_to ?? _listener.audio_effect_reverb ?? 0, 0, 1);
    var _lowpass_index = _listener.audio_effect_lowpass_index ?? sfx_environment_get_effect_index(_lowpass);
    var _reverb_index = _listener.audio_effect_reverb_index ?? sfx_environment_get_effect_index(_reverb);
    
    return {
        lowpass: _lowpass,
        reverb: _reverb,
        lowpass_index: _lowpass_index,
        reverb_index: _reverb_index,
        bus: _listener.audio_effect_bus ?? sfx_environment_get_bus_from_indices(_lowpass_index, _reverb_index)
    }
}

function sfx_environment_get_bus(_lowpass = 0, _reverb = 0)
{
    var _lpf_index = sfx_environment_get_effect_index(_lowpass);
    var _reverb_index = sfx_environment_get_effect_index(_reverb);
    
    return sfx_environment_get_bus_from_indices(_lpf_index, _reverb_index);
}

function sfx_environment_apply_bus(_emitter, _lowpass = 0, _reverb = 0)
{
    if ((_emitter != undefined) && audio_emitter_exists(_emitter))
    {
        audio_emitter_bus(_emitter, sfx_environment_get_bus(_lowpass, _reverb));
    }
}

function sfx_environmental_play(_id, _gain = global.settings.audio_sfx, _x = undefined, _y = undefined, _listener = obj_Player)
{
    var _data = is_array_choose(global.sound_asset[$ _id]);
    
    if (_data == undefined) exit;
    
    var _listener_x = 0;
    var _listener_y = 0;
    
    if (instance_exists(_listener))
    {
        _listener_x = _listener.x;
        _listener_y = _listener.y;
    }
    
    _x ??= _listener_x;
    _y ??= _listener_y;
    
    var _distance = point_distance(_listener_x, _listener_y, _x, _y);
    var _falloff_reference = _data.get_falloff_reference();
    var _falloff_max = _data.get_falloff_max();
    
    _gain *= (1 - normalize(_distance, _falloff_reference, _falloff_max));
    
    if (_gain <= 0) exit;
    
    var _effects = sfx_environment_get_listener_effects(_listener);
    var _occlusion = instance_exists(_listener) ? sfx_calculate_occlusion(_listener_x, _listener_y, _x, _y) : 0;
    var _occlusion_index = sfx_environment_get_effect_index(_occlusion);
    var _lowpass_index = clamp(_effects.lowpass_index + _occlusion_index, 0, AUDIO_EFFECT_SIZE - 1);
    var _bus = sfx_environment_get_bus_from_indices(_lowpass_index, _effects.reverb_index);
    
    var _emitter = global.sfx_pool.acquire();
    audio_emitter_position(_emitter, _x, _y, 0);
    
    if (audio_emitter_exists(_emitter))
    {
        audio_emitter_bus(_emitter, _bus);
    }
    
    var _sound = audio_play_sound_ext({
        emitter: _emitter,
        sound: _data.get_sound(),
        pitch: 1,
        gain: _gain
    });
    
    sfx_emitter_track(_emitter, _sound);
    
    return _sound;
}

function sfx_play(_id, _gain = 1)
{
    var _data = global.sound_asset[$ _id];
    
    if (_data == undefined) exit;
    
    return audio_play_sound_ext({
        sound: is_array_choose(_data).get_sound(),
        // pitch: smart_value(_data.get_pitch()),
        gain: _gain// * _data.get_gain()
    });
}
