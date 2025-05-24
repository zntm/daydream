var _delta_time = global.delta_time;

var _biome_data = global.biome_data;

var _in_biome = bg_get_biome(obj_Player.x, obj_Player.y);
var _in_biome_data = _biome_data[$ _in_biome];

#macro BACKGROUND_TRANSITION_SPEED (GAME_TICK * 0.08)
#macro BACKGROUND_MUSIC_FADE_TIME 1000

if (in_biome_transition_value <= 0)
{
    var _type = _in_biome_data.get_type();
    
    if (in_biome != _in_biome)
    {
        in_biome_transition = _in_biome;
        
        in_biome_transition_value = BACKGROUND_TRANSITION_SPEED * _delta_time;
    }
    else if (music_current != undefined) && (!audio_is_playing(music_current))
    {
        var _music = _in_biome_data.get_music();
        
        if (_music != undefined)
        {
            bg_play_music(array_choose(_music));
        }
    }
}
else
{
    in_biome_transition_value += BACKGROUND_TRANSITION_SPEED * _delta_time;
    
    if (in_biome_transition_value >= 1)
    {
        in_biome_transition_value = 0;
        
        /*
        if (!instance_exists(obj_Toast))
        {
            spawn_toast(GAME_FPS * 8, toast_biome);
        }
        */
        
        if (!array_contains(_in_biome_data.get_music(), music_current_id))
        {
            if (music_current != undefined)
            {
                audio_sound_gain(music_current, 0, BACKGROUND_MUSIC_FADE_TIME);
                
                if (!array_contains(music_pool, music_current))
                {
                    music_pool[@ music_pool_length++] = music_current;
                }
            }
            
            var _music_transition = _biome_data[$ in_biome_transition].get_music();
            
            if (_music_transition != undefined)
            {
                bg_play_music(array_choose(_music_transition));
            }
        }
        
        in_biome = in_biome_transition;
    }
}

for (var i = 0; i < music_pool_length; ++i)
{
    var _audio = music_pool[i];
    
    if (audio_sound_get_gain(_audio) <= 0)
    {
        audio_stop_sound(_audio);
        array_delete(music_pool, i, 1);
        
        --i;
        --music_pool_length;
    }
}