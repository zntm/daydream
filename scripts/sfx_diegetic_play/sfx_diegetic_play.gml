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
    var _data = is_array_choose(global.sound_asset[$ _id]);
    
    // Calculate sound occlusion
    var _occlusion = sfx_calculate_occlusion(obj_Player.x, obj_Player.y, _x, _y);
    
    var _distance = point_distance(obj_Player.x, obj_Player.y, _x, _y);
    
    var _falloff_reference = _data.get_falloff_reference();
    var _falloff_max = _data.get_falloff_max();
    
    _gain = _gain * (1 - normalize(_distance, _falloff_reference, _falloff_max));
    
    if (_gain <= 0) exit;
    
    // If occluded, set bus with LPF and play sound
    if (_occlusion > 0)
    {
        // Calculate LPF index based on occlusion
        var _lpf_index = min(AUDIO_EFFECT_SIZE - 1, round(_occlusion * (AUDIO_EFFECT_SIZE - 1)));
        
        // Set occluded bus (high LPF, no reverb)
        // Bus stays set so the sound plays with the filter applied
        // control_entity_sfx will restore the bus based on entity's environment
        audio_emitter_bus(_emitter, global.audio_bus[$ $"{_lpf_index}_0"]);
        
        // Play sound with occlusion effect
        return audio_play_sound_ext({
            emitter: _emitter,
            sound: _data.get_sound(),
            pitch: 1,
            gain: _gain
        });
    }
    
    // No occlusion - play normally
    return audio_play_sound_ext({
        emitter: _emitter,
        sound: _data.get_sound(),
        pitch: 1,
        gain: _gain
    });
}