function control_entity_sfx()
{
    timer_audio_effect -= 1 / GAME_TICK;
    
    if (timer_audio_effect > 0)
    {
        audio_effect_lowpass = lerp_delta(audio_effect_lowpass, audio_effect_lowpass_to, 0.1, 1);
        audio_effect_reverb  = lerp_delta(audio_effect_reverb,  audio_effect_reverb_to,  0.1, 1);
    }
    else
    {
        var _total_lowpass = 0;
        var _total_reverb  = 0;
        
        var _item_data = global.item_data;
        
        for (var i = 0; i < 16; ++i)
        {
            var _angle = (i / 16) * 360;
            
            var _tile_x = round(x / TILE_SIZE);
            var _tile_y = round(y / TILE_SIZE);
            
            var _tile_x_to =  round(dcos(_angle) * 16);
            var _tile_y_to = -round(dsin(_angle) * 16);
            
            for (var j = 0; j < 16; ++j)
            {
                var _t = (j + 1) / 16;
                
                var _tile = tile_get(_tile_x + round(_tile_x_to * _t), _tile_y + round(_tile_y_to * _t), CHUNK_DEPTH_DEFAULT);
                
                if (_tile != TILE_EMPTY)
                {
                    var _data = _item_data[$ _tile.get_id()];
                    
                    _total_lowpass += _data.get_tile_audio_property_lowpass();
                    _total_reverb  += _data.get_tile_audio_property_reverb();
                    
                    break;
                }
            }
        }
        
        var _l = min(1, _total_lowpass / 16);
        var _r = min(1, _total_reverb  / 16);
        
        audio_effect_lowpass = _l;
        audio_effect_lowpass_to = _l;
        
        audio_effect_reverb = _r;
        audio_effect_reverb_to = _r;
        
        timer_audio_effect = 0.1; // Recalculate every ~0.1 seconds
    }
    
    audio_emitter_bus(audio_emitter, global.audio_bus[$ $"{round(audio_effect_lowpass * (AUDIO_EFFECT_SIZE - 1))}_{round(audio_effect_reverb * (AUDIO_EFFECT_SIZE - 1))}"]);
    
    if (input_state.move_x != 0) && (physics_body.collision.ground)
    {
        timer_sfx_step += 1 / GAME_TICK;
        
        if (timer_sfx_step >= 0.28)
        {
            timer_sfx_step = 0;
            
            var _tile_x = round(x / TILE_SIZE);
            var _tile_y = round(y / TILE_SIZE);
            
            var _tile = tile_get(_tile_x, _tile_y - 1, CHUNK_DEPTH_FOLIAGE_BACK);
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x, _tile_y - 1, CHUNK_DEPTH_FOLIAGE_FRONT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x - 1, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile == TILE_EMPTY)
            {
                _tile = tile_get(_tile_x + 1, _tile_y, CHUNK_DEPTH_DEFAULT);
            }
            
            if (_tile != TILE_EMPTY)
            {
                var _sound = global.item_data[$ _tile.get_id()].get_tile_sfx().get_step().get_id();
                
                sfx_diegetic_play(audio_emitter, x, y, _sound, global.settings.audio_creature_passive);
            }
            else
            {
                timer_sfx_step = 0.28;
            }
        }
    }
    else
    {
        timer_sfx_step = 0.28;
    }
}