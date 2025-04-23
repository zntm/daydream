var _in_biome_data = global.biome_data[$ in_biome.id];

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

draw_sprite_ext(
    spr_Square,
    0,
    camera_get_view_x(view_camera[0]),
    camera_get_view_y(view_camera[0]),
    camera_get_view_width(view_camera[0]),
    camera_get_view_height(view_camera[0]),
    0,
    _in_biome_data.get_sky_colour_base("day"),
    1
);

draw_sprite_general(
    spr_Glow_Corner,
    0,
    0,
    0,
    128,
    1,
    camera_get_view_x(view_camera[0]),
    camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]),
    camera_get_view_height(view_camera[0]) / 128,
    camera_get_view_width(view_camera[0]),
    90,
    _in_biome_data.get_sky_colour_gradient("day"),
    _in_biome_data.get_sky_colour_gradient("day"),
    _in_biome_data.get_sky_colour_gradient("day"),
    _in_biome_data.get_sky_colour_gradient("day"),
    1
);

var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

var _background_data = global.background_data;

var _in_biome_background = _background_data[$ _in_biome_data.get_background()];
var _in_biome_background_length = _in_biome_background.get_sprite_length();

for (var i = 0; i < _in_biome_background_length; ++i)
{
    var _sprite_width  = _in_biome_background.get_sprite_width(i);
    var _sprite_height = _in_biome_background.get_sprite_height(i);
    
    var _xoffset = (_player_x * (i + 1) * 0.05) % _sprite_width;
    
    var _xsize = ceil(_camera_width / _sprite_width) + 1;
    
    render_background_parallax(_in_biome_background.get_sprite(i), _player_x + _xoffset, _camera_y + _camera_height, _sprite_width, _sprite_height, _xsize, 0, c_white, 1);
}