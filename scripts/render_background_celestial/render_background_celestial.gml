function render_background_celestial(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _world_save_data = global.world_save_data;
    var _world_time = _world_save_data.time;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
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
}