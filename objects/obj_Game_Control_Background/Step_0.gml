var _delta_time = global.delta_time;

var _biome_data = global.biome_data;

var _in_biome = bg_get_biome(round(obj_Player.x / TILE_SIZE), clamp(round(obj_Player.y / TILE_SIZE), 0, global.world_data[$ global.current_world.dimension].get_world_height() - 1));

var _in_biome_data = _biome_data[$ in_biome];
var _in_biome_transition_data = _biome_data[$ _in_biome];

#macro BACKGROUND_MUSIC_FADE_TIME (1000 * 0.3)

if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.PAUSE)
{
    // var _duration = max(0.001, global.settings.graphics_background_transition_speed);
    var _duration = 0.8;
    
    if (in_biome_transition_value <= 0)
    {
        if (in_biome != _in_biome)
        {
            in_biome_transition = _in_biome;
            
            in_biome_transition_value = _delta_time / _duration;
        }
    }
    else
    {
        in_biome_transition_value += _delta_time / _duration;
        
        if (in_biome_transition_value >= 1)
        {
            in_biome_transition_value = 0;
            
            if (music_current != undefined)
            {
                audio_sound_gain(music_current, 0, BACKGROUND_MUSIC_FADE_TIME);
                
                if (!array_contains(music_pool, music_current))
                {
                    music_pool[@ music_pool_length++] = music_current;
                }
            }
            
            var _music = worldgen_get_music(in_biome_transition);
            
            if (_music != undefined) && (!array_contains(_music, music_current_id))
            {
                bg_play_music(array_choose(_music));
            }
            
            in_biome = in_biome_transition;
        }
    }
    
    // Manage sky scripts
    var _biomes = [in_biome, (in_biome_transition_value > 0) ? in_biome_transition : undefined];
    for (var i = 0; i < 2; i++)
    {
        var _b_id = _biomes[i];
        if (_b_id == undefined) continue;
        
        var _b_data = global.biome_data[$ _b_id];
        if (_b_data == undefined) continue;
        
        var _script_id = _b_data.get_sky_script();
        if (_script_id != undefined) && (!struct_exists(sky_scripts, _script_id))
        {
            if (struct_exists(global.proglang_scripts, _script_id))
            {
                proglang_call(_script_id, [], id);
                sky_scripts[$ _script_id] = true;
            }
        }
    }
}

timer_refresh += _delta_time;

if (timer_refresh >= 1) || (in_biome_transition_value > 0)
{
    timer_refresh %= 1;
    
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
    
    if (music_current == undefined || !audio_is_playing(music_current))
    {
        music_current_id = "";
        
        if (music_current != undefined)
        {
            var _music = (in_biome_transition_value <= 0) ? worldgen_get_music(in_biome) : worldgen_get_music(in_biome_transition);
            
            if (_music != undefined)
            {
                bg_play_music(array_choose(_music));
            }
        }
    }
    
    bg_sky_colour(in_biome, in_biome_transition);
}

update_background_clouds(_delta_time, global.camera_width);
