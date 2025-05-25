var _delta_time = global.delta_time;

var _biome_data = global.biome_data;

var _in_biome = bg_get_biome(obj_Player.x, obj_Player.y);

var _in_biome_data = _biome_data[$ in_biome];
var _in_biome_transition_data = _biome_data[$ _in_biome];

#macro BACKGROUND_TRANSITION_SPEED (GAME_TICK * 0.08)
#macro BACKGROUND_MUSIC_FADE_TIME 1000

if (in_biome_transition_value <= 0)
{
    var _type = _in_biome_transition_data.get_type();
    
    if (in_biome != _in_biome)
    {
        in_biome_transition = _in_biome;
        
        in_biome_transition_value = BACKGROUND_TRANSITION_SPEED * _delta_time;
    }
    else if (music_current != undefined) && (!audio_is_playing(music_current))
    {
        var _music = _in_biome_transition_data.get_music();
        
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
        
        var _music = _in_biome_transition_data.get_music();
        
        if (_music != undefined) && (!array_contains(_music, music_current_id))
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

refresh += _delta_time;

if (refresh >= 1) || (in_biome_transition_value > 0)
{
    refresh %= 1;
    
    var _world = global.world;
    var _world_time = _world.time;
    
    var _world_data = global.world_data[$ _world.dimension];
    
    var _time_diurnal_length = _world_data.get_time_diurnal_length();
    
    for (var i = 0; i < _time_diurnal_length; ++i)
    {
        var _name_from = _world_data.get_time_diurnal_name(i);
        
        var _start_from = _world_data.get_time_diurnal_start(_name_from);
        var _end_from   = _world_data.get_time_diurnal_end(_name_from);
        
        if (_world_time >= _start_from) && (_world_time < _end_from)
        {
            var _name_to = _world_data.get_time_diurnal_name((i + 1) % _time_diurnal_length);
            
            var _start_to = _world_data.get_time_diurnal_start(_name_to);
            var _end_to   = _world_data.get_time_diurnal_end(_name_to);
            
            var _colour_base_from = _in_biome_transition_data.get_sky_colour_base(_name_from);
            var _colour_base_to   = _in_biome_transition_data.get_sky_colour_base(_name_to);
            
            var _colour_gradient_from = _in_biome_transition_data.get_sky_colour_gradient(_name_from);
            var _colour_gradient_to   = _in_biome_transition_data.get_sky_colour_gradient(_name_to);
            
            var _t = normalize(_world_time, _start_from, _end_from);
            
            if (in_biome_transition_value <= 0)
            {
                sky_colour_base     = merge_colour(_colour_base_from,     _colour_base_to,     _t);
                sky_colour_gradient = merge_colour(_colour_gradient_from, _colour_gradient_to, _t);
            }
            else
            {
                var _transition_colour_base_from = _in_biome_transition_data.get_sky_colour_base(_name_from);
                var _transition_colour_base_to   = _in_biome_transition_data.get_sky_colour_base(_name_to);
                
                var _transition_colour_gradient_from = _in_biome_transition_data.get_sky_colour_gradient(_name_from);
                var _transition_colour_gradient_to   = _in_biome_transition_data.get_sky_colour_gradient(_name_to);
                
                var _colour_base     = merge_colour(_colour_base_from,     _colour_base_to,     _t);
                var _colour_gradient = merge_colour(_colour_gradient_from, _colour_gradient_to, _t);
                
                var _transition_colour_base     = merge_colour(_transition_colour_base_from, _transition_colour_base_to, _t);
                var _transition_colour_gradient = merge_colour(_transition_colour_gradient_from, _transition_colour_gradient_to, _t);
                
                sky_colour_base     = merge_colour(_colour_base,     _transition_colour_base,     in_biome_transition_value);
                sky_colour_gradient = merge_colour(_colour_gradient, _transition_colour_gradient, in_biome_transition_value);
            }
            
            break;
        }
    }
}