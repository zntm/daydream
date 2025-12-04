#macro SFX_DIEGETIC_PADDING (TILE_SIZE / 2)

enum SFX_DIEGETIC_EFFECT_INDEX {
    REVERB,
    LPF
}

audio_falloff_set_model(audio_falloff_linear_distance_clamped);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

global.sfx_diegetic_floodfill_amount = 0;
global.sfx_diegetic_floodfill_position = {}

function sfx_diegetic_play(_emitter, _x, _y, _id, _gain = global.settings.audio_sfx, _world_height = global.world_data[$ global.world_save_data.dimension].get_world_height())
{
    var _data = global.sound_asset[$ _id];
    
    // Calculate sound occlusion
    var _occlusion = sfx_calculate_occlusion(obj_Player.x, obj_Player.y, _x, _y);
    
    // If occluded, temporarily change emitter bus
    if (_occlusion > 0)
    {
        // Calculate LPF index based on occlusion
        var _lpf_index = min(AUDIO_EFFECT_SIZE - 1, round(_occlusion * (AUDIO_EFFECT_SIZE - 1)));
        
        // Set occluded bus (high LPF, no reverb)
        audio_emitter_bus(_emitter, global.audio_bus[$ $"{_lpf_index}_0"]);
        
        // Play sound
        var _sound_id = audio_play_sound_ext({
            emitter: _emitter,
            sound: is_array_choose(_data).get_sound(),
            pitch: 1,
            gain: _gain
        });
        
        // Restore emitter to normal (will be set by control_entity_sfx)
        audio_emitter_bus(_emitter, global.audio_bus[$ "0_0"]);
        
        return _sound_id;
    }
    
    // No occlusion - play normally
    return audio_play_sound_ext({
        emitter: _emitter,
        sound: is_array_choose(_data).get_sound(),
        pitch: 1,
        gain: _gain
    });
    
    /*
    var _sfx_data = global.sfx_data;
    
    var _data = _sfx_data[$ _id];
    
    if (_data == undefined) exit;
    
    var _falloff_reference = _data.get_falloff_reference();
    var _falloff_max = _data.get_falloff_max();
    
    var _distance = point_distance(obj_Player.x, obj_Player.y, _x, _y);
    
    _gain = _gain * (1 - normalize(_distance, _falloff_reference, _falloff_max));
    
    if (_gain <= 0) exit;
    
    return audio_play_sound_ext({
        emitter: _emitter,
        sound: array_choose(_data.get_asset()),
        pitch: smart_value(_data.get_pitch()),
        gain: _gain
    });
    */
}