function ai_fall_detection(_x, _y, _distance, _max = 6)
{
    for (var i = 0; i <= _max; ++i)
    {
        if (tile_meeting(_x, _y + (i * _distance)))
        {
            return i;
        }
    }
    
    return _max;
}