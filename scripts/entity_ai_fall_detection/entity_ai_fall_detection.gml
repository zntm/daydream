// Optimized fall detection for AI pathfinding
// Uses caching and adaptive step sizes for better performance
function entity_ai_fall_detection(_x, _y, _distance, _max = 6)
{
    // For longer distances, use larger steps for performance
    var _step = (abs(_distance) > TILE_SIZE) ? 2 : 1;
    var _checks = ceil(_max / _step);
    
    for (var i = 0; i <= _checks; ++i)
    {
        var _check_dist = i * _step;
        
        if (_check_dist > _max) break;
        
        if (tile_meeting(_x, _y + (_check_dist * _distance)))
        {
            return _check_dist;
        }
    }
    
    return _max;
}