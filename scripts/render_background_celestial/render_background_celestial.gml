/// @function celestial_get_active(_time)
/// @desc Returns the active world celestial struct for the given time, or undefined
function celestial_get_active(_time)
{
    var _world_save_data = global.world_save_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    if (_world_data == undefined) return undefined;
    
    var _celestials = _world_data.get_celestials();
    var _celestials_length = _world_data.get_celestials_length();
    
    for (var i = 0; i < _celestials_length; ++i)
    {
        var _ = _celestials[i];
        
        var _time_range_max = _.get_time_range_max();
        var _time_range_min = _.get_time_range_min();
        
        if (_time >= _time_range_min) && (_time < _time_range_max)
        {
            var _data = global.sprite_asset[$ _.get_id()];
            
            // Normalize time
            var _t = (_time - _time_range_min) / (_time_range_max - _time_range_min);
            
            return {
                id: _.get_id(),
                sprite_id: _.get_id(),
                t: _t,
                time_min: _time_range_min,
                time_max: _time_range_max
            };
        }
    }
    
    return undefined;
}