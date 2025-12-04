/// @description Play a sound at a position with automatic occlusion calculation
/// @param {Real} _x Sound source X position
/// @param {Real} _y Sound source Y position
/// @param {Asset.GMSound} _id Sound asset ID
/// @param {Real} _gain Optional gain multiplier (default: global.settings.audio_sfx)
/// @return {Id.Sound} Sound instance ID
function sfx_diegetic_play_at(_x, _y, _id, _gain = global.settings.audio_sfx)
{
    var _data = global.sound_asset[$ _id];
    
    if (_data == undefined) exit;
    
    // Calculate occlusion from player to sound source
    var _occlusion = sfx_calculate_occlusion(obj_Player.x, obj_Player.y, _x, _y);
    
    // Get or create temporary emitter for this sound
    static _temp_emitter = audio_emitter_create();
    
    // Position the emitter at the sound source
    audio_emitter_position(_temp_emitter, _x, _y, 0);
    
    // Apply occlusion filter if needed
    if (_occlusion > 0)
    {
        var _lpf_index = min(AUDIO_EFFECT_SIZE - 1, round(_occlusion * (AUDIO_EFFECT_SIZE - 1)));
        audio_emitter_bus(_temp_emitter, global.audio_bus[$ $"{_lpf_index}_0"]);
    }
    else
    {
        audio_emitter_bus(_temp_emitter, global.audio_bus[$ "0_0"]);
    }
    
    // Play the sound
    return audio_play_sound_ext({
        emitter: _temp_emitter,
        sound: is_array_choose(_data).get_sound(),
        pitch: 1,
        gain: _gain
    });
}
