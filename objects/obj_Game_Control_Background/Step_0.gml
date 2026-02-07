var _delta_time = global.delta_time;

var _world_save_data = global.world_save_data;
var _world_seed = _world_save_data.seed;
var _world_data = global.world_data[$ _world_save_data.dimension];
var _world_height_cells = _world_data.get_world_height();

var _p_x_cell = round(obj_Player.x / TILE_SIZE);
var _p_y_cell = clamp(round(obj_Player.y / TILE_SIZE), 0, _world_height_cells - 1);

var _in_biome_id = bg_get_biome(_p_x_cell, _p_y_cell);
var _in_biome_data = global.biome_data[$ in_biome];
var _in_biome_transition_data = global.biome_data[$ in_biome_transition];

#macro BACKGROUND_MUSIC_FADE_TIME (1000 * 0.3)

if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.PAUSE)
{
    var _duration_biome = 0.8;
    var _duration_region = 1.5;
    
    // 1. Biome transitions (music/background sprites)
    if (in_biome_transition_value <= 0)
    {
        if (in_biome != _in_biome_id)
        {
            in_biome_transition = _in_biome_id;
            in_biome_transition_value = _delta_time / _duration_biome;
        }
    }
    else
    {
        in_biome_transition_value += _delta_time / _duration_biome;
        
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
            
            var _music_transition = global.biome_data[$ in_biome_transition].get_music();
            if (_music_transition != undefined)
            {
                bg_play_music(array_choose(_music_transition));
            }
            
            in_biome = in_biome_transition;
        }
    }
    
    // 2. Region transitions (sky/light colours)
    var _in_region = global.region_generator.get_region(obj_Player.x, obj_Player.y, 0, _world_seed);
    if (in_region_transition_value <= 0)
    {
        if (in_region.get_id() != _in_region.get_id())
        {
            in_region_transition = _in_region;
            in_region_transition_value = _delta_time / _duration_region;
        }
    }
    else
    {
        in_region_transition_value += _delta_time / _duration_region;
        if (in_region_transition_value >= 1)
        {
            in_region_transition_value = 0;
            in_region = in_region_transition;
        }
    }
}

timer_refresh += _delta_time;

if (timer_refresh >= 1) || (in_biome_transition_value > 0) || (in_region_transition_value > 0)
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
    
    if (!audio_is_playing(music_current))
    {
        music_current_id = "";
        
        if (music_current != undefined)
        {
            var _target_biome = (in_biome_transition_value <= 0) ? in_biome : in_biome_transition;
            var _music_list = global.biome_data[$ _target_biome].get_music();
            
            if (_music_list != undefined)
            {
                bg_play_music(array_choose(_music_list));
            }
        }
    }
    
    bg_sky_colour(in_region, in_region_transition);
}