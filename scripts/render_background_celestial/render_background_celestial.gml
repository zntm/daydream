function render_background_celestial(_time, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _world_save_data = global.world_save_data;
    var _world_time = _world_save_data.time;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
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
            
            var _sprite = _data.get_sprite();
            var _sprite_width = sprite_get_width(_sprite);
            
            var _t = normalize(_world_time, _time_range_min, _time_range_max);
            
            var _x = lerp(_camera_x - _sprite_width, _camera_x + _camera_width + _sprite_width, _t);
            var _y = _camera_y;
            
            draw_sprite(_sprite, 0, _x, _y);
            
            break;
        }
    }
    
    /*
    var _celestial_name = _world_data.get_celestial_name(_world_time);
    
    if (_celestial_name != undefined)
    {
        var _celestial_data = _world_data.get_celestial_data(_celestial_name);
        var _celestial_sprite = _world_data.get_celestial_sprite(_celestial_name);
        
        var _sprite_width = sprite_get_width(_celestial_sprite) / 2;
        
        var _t = normalize(_world_time, _celestial_data.start, _celestial_data[$ "end"]);
        
        var _x = lerp(_camera_x - _sprite_width, _camera_x + _camera_width + _sprite_width, _t);
        var _y = _camera_y;
        
        draw_sprite(_celestial_sprite, 0, _x, _y);
    }
    */
}