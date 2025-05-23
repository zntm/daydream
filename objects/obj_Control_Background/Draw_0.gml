render_background(in_biome);

var _world_data = global.world_data[$ global.world.dimension];

var _celestial_name = _world_data.get_celestial_name(global.world.time);

if (_celestial_name != undefined)
{
    var _celestial_data = _world_data.get_celestial_data(_celestial_name);
    var _celestial_sprite = _world_data.get_celestial_sprite(_celestial_name);
    
    show_debug_message($"{_celestial_name} {_celestial_data} { _celestial_sprite}")
    
    var _sprite_width = sprite_get_width(_celestial_sprite) / 2;
    
    draw_sprite(_celestial_sprite, 0, lerp(global.camera_x - _sprite_width, global.camera_x + global.camera_width + _sprite_width, normalize(global.world.time, _celestial_data.start, _celestial_data[$ "end"])), global.camera_y);
}