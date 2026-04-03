function bg_music_get_track_id(_music)
{
    if (_music == undefined) return "";
    if (is_string(_music)) return _music;
    if (struct_exists(_music, "get_id")) return _music.get_id();
    
    return "";
}

function bg_music_pool_contains_id(_music_pool, _music_id)
{
    if (_music_pool == undefined) || (_music_id == "") return false;
    
    var _length = array_length(_music_pool);
    
    for (var i = 0; i < _length; ++i)
    {
        if (bg_music_get_track_id(_music_pool[i]) == _music_id)
        {
            return true;
        }
    }
    
    return false;
}

function bg_stop_music()
{
    if (music_current == undefined) return;
    
    if (audio_is_playing(music_current))
    {
        audio_sound_gain(music_current, 0, BACKGROUND_MUSIC_FADE_TIME);
        
        if (!array_contains(music_pool, music_current))
        {
            music_pool[@ music_pool_length++] = music_current;
        }
    }
    
    music_current = undefined;
    music_current_id = "";
    music_current_gain = 0;
}

function bg_play_music(_music)
{
    if (_music == undefined) return false;
    
    var _music_id = bg_music_get_track_id(_music);
    var _asset = global.sound_asset[$ _music_id];
    
    if (_asset == undefined) return false;
    
    var _sound = _asset.get_sound();
    
    music_current    = audio_play_sound(_sound, 0, false, 0);
    music_current_id = _music_id;
    music_current_gain = _music.get_gain();
    
    audio_sound_gain(music_current, global.settings.audio_music * music_current_gain, BACKGROUND_MUSIC_FADE_TIME);
    
    return true;
}

function bg_sync_biome_music(_target)
{
    var _music_pool = worldgen_get_music(_target);
    var _previous_music_id = music_current_id;
    
    if (_music_pool == undefined) || (array_length(_music_pool) <= 0)
    {
        bg_stop_music();
        return false;
    }
    
    if (music_current != undefined) && audio_is_playing(music_current) && bg_music_pool_contains_id(_music_pool, music_current_id)
    {
        return false;
    }
    
    if (music_current != undefined)
    {
        bg_stop_music();
    }
    
    var _next_music_pool = [];
    var _music_pool_length = array_length(_music_pool);
    
    for (var i = 0; i < _music_pool_length; ++i)
    {
        var _entry = _music_pool[i];
        
        if (_music_pool_length <= 1) || (bg_music_get_track_id(_entry) != _previous_music_id)
        {
            array_push(_next_music_pool, _entry);
        }
    }
    
    if (array_length(_next_music_pool) <= 0)
    {
        _next_music_pool = _music_pool;
    }
    
    return bg_play_music(array_choose(_next_music_pool));
}
