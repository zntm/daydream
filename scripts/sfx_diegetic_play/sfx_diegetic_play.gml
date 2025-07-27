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
    var _sfx_data = global.sfx_data;
    
    var _data = _sfx_data[$ _id];
    
    if (_data == undefined) exit;
    
    var _item_data = global.item_data;
    
    var _falloff_reference = _data.get_falloff_reference();
    var _falloff_max = _data.get_falloff_max();
    
    var _distance = point_distance(obj_Player.x, obj_Player.y, _x, _y);
    
    var _falloff_gain = 1 - normalize(_distance, _falloff_reference, _falloff_max);
    
    if (_falloff_gain <= 0) exit;
    
    return audio_play_sound_ext({
        emitter: _emitter,
        sound: array_choose(_data.get_asset()),
        pitch: smart_value(_data.get_pitch()),
        gain: _gain * _falloff_gain
    });
}