function control_entity_sfx(_dt)
{
    timer_audio_effect -= _dt / GAME_TICK;
    
    if (timer_audio_effect > 0)
    {
        audio_effect_lowpass = lerp_delta(audio_effect_lowpass, audio_effect_lowpass_to, 0.1, _dt);
        audio_effect_reverb  = lerp_delta(audio_effect_reverb,  audio_effect_reverb_to,  0.1, _dt);
        
        audio_emitter_bus(audio_emitter, global.audio_bus[$ $"{round(audio_effect_lowpass * 7)}_{round(audio_effect_reverb * 7)}"]);
    }
    else
    {
        var _total_lowpass = 0;
        var _total_reverb  = 0;
        
        var _item_data = global.item_data;
        
        for (var i = 0; i < 32; ++i)
        {
            var _angle = (i / 32) * 360;
            
            var _xoffset =  dcos(_angle);
            var _yoffset = -dsin(_angle);
            
            var _tile_x = round(x / TILE_SIZE);
            var _tile_y = round(y / TILE_SIZE);
            
            var _tile_x_to = _tile_x + round(_xoffset * 16);
            var _tile_y_to = _tile_y + round(_yoffset * 16);
            
            for (var j = 0; j < 16; ++j)
            {
                var _t = (j + 1) / 16;
                
                var _tile = tile_get(_tile_x + round(_tile_x_to * _t), _tile_y + round(_tile_y_to * _t), CHUNK_DEPTH_DEFAULT);
                
                if (_tile != TILE_EMPTY)
                {
                    var _data = _item_data[$ _tile.get_id()];
                    
                    _total_lowpass += _data.get_audio_property_lowpass();
                    _total_reverb  += _data.get_audio_property_reverb();
                    
                    break;
                }
            }
        }
        
        var _l = min(1, _total_lowpass / 32);
        var _r = min(1, _total_reverb  / 32);
        
        audio_emitter_bus(audio_emitter, global.audio_bus[$ $"{round(_l * 7)}_{round(min(1, _r) * 7)}"]);
        
        audio_effect_lowpass = _total_lowpass;
        audio_effect_lowpass_to = _total_lowpass;
        
        audio_effect_reverb = _total_reverb;
        audio_effect_reverb_to = _total_reverb;
    }
    
    if ((input_left) || (input_right)) && (tile_meeting(x, y + 1))
    {
        timer_sfx_step += _dt / GAME_TICK;
        
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
                sfx_diegetic_play(audio_emitter, x, y, global.item_data[$ _tile.get_id()].get_sfx_step());
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