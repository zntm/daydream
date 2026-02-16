function audio_array_is_playing(_audio)
{
    if (_audio == undefined)
    {
        return false;
    }
    
    if (!is_array(_audio))
    {
        return audio_is_playing(_audio);
    }
    
    for (var i = array_length(_audio) - 1; i >= 0; --i)
    {
        var _ = _audio[i];
        
        if (audio_is_playing(_))
        {
            return _;
        }
    }
    
    return false;
}