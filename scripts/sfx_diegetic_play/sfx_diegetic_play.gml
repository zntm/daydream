#macro SFX_DIEGETIC_PADDING TILE_SIZE_HALF

enum SFX_DIEGETIC_EFFECT_INDEX {
    REVERB,
    LPF
}

audio_falloff_set_model(audio_falloff_linear_distance_clamped);
audio_listener_orientation(0, 0, 1, 0, -1, 0);

global.sfx_diegetic_floodfill_amount = 0;
global.sfx_diegetic_floodfill_position = {}

function sfx_diegetic_play(_x, _y, _id, _pitch_offset = 0.2, _gain = global.settings.audio_sfx, _world_height = global.world_data[$ global.world.dimension].get_world_height())
{
    var _sfx_data = global.sfx_data;
    
    var _data = _sfx_data[$ _id];
    
    if (_data == undefined) exit;
    
    var _item_data = global.item_data;
    
    var _audio_emitter = audio_emitter_create();
    var _audio_bus = audio_bus_create();
    
    // _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.REVERB] = audio_effect_create(AudioEffectType.Reverb1);
    // _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.LPF]    = audio_effect_create(AudioEffectType.LPF2);
    
    audio_emitter_bus(_audio_emitter, _audio_bus);
    audio_emitter_falloff(_audio_emitter, TILE_SIZE * 6, TILE_SIZE * 16, 1);
    audio_emitter_position(_audio_emitter, _x, _y, 0);
    /*
    var _x1tile = round(_x1 / TILE_SIZE);
    var _y1tile = round(_y1 / TILE_SIZE);
    
    var _x2tile = round(_x2 / TILE_SIZE);
    var _y2tile = round(_y2 / TILE_SIZE);
    */
    #region Reverb
    /*
    if (!collision_rectangle(_x2 - SFX_DIEGETIC_PADDING, _y2 - SFX_DIEGETIC_PADDING, _x2 + SFX_DIEGETIC_PADDING, _y2 + SFX_DIEGETIC_PADDING, obj_Light_Sun, false, true))
    {
        global.sfx_diegetic_floodfill_amount = 0;
        
        dbg_timer("sfx_reverb");
        
        sfx_diegetic_floodfill(_x2tile, _y2tile, 0, _item_data, _world_height);
        
        var _names = struct_get_names(global.sfx_diegetic_floodfill_position);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            struct_remove(global.sfx_diegetic_floodfill_position, _names[i]);
        }
        
        _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.REVERB].mix = global.sfx_diegetic_floodfill_amount / 64;
        
        dbg_timer("sfx_reverb", $"Calculated sound effect reverb for {_id} ({global.sfx_diegetic_floodfill_amount}).");
    }
    else
    {
        _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.REVERB].mix = 0;
    }
    */
    #endregion
    
    #region Low-Pass Filter
    /*
    var _tile  = tile_get(_x1tile, _y1tile, CHUNK_DEPTH_LIQUID);
    var _tile2 = tile_get(_x2tile, _y2tile, CHUNK_DEPTH_LIQUID);
    
    /*if ((_tile != TILE_EMPTY) && (_item_data[$ _tile].has_type(ITEM_TYPE_BIT.LIQUID))) || ((_tile2 != TILE_EMPTY) && (_item_data[$ _tile2].has_type(ITEM_TYPE_BIT.LIQUID)))
    {
        _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.LPF].bypass = 0;
    }
    else
    {
        _audio_bus.effects[@ SFX_DIEGETIC_EFFECT_INDEX.LPF].bypass = 1;
    }
    */
    #endregion
    
    return audio_play_sound_ext({
        emitter: _audio_emitter,
        sound: ((is_array(_data)) ? _sfx_data[$ array_choose(_data)] : _data),
        pitch: random_range(1 - _pitch_offset, 1 + _pitch_offset),
        gain: clamp(global.settings.audio_master * _gain, 0, 1)
    });
}