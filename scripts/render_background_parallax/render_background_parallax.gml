function render_background_parallax(_sprite, _index, _x, _y, _camera_x, _camera_y, _camera_width, _camera_height, _colour, _alpha, _parallax_base = 0.005, _parallax_scale = 1)
{
    var _sprite_xoffset = sprite_get_xoffset(_sprite);
    var _width = sprite_get_width(_sprite) * _parallax_scale;
    
    var _parallax_factor = (_index + 1) * _parallax_base;
    var _xoffset = (_x - _camera_x * _parallax_factor) % _width;
    
    var _xsize = ceil(_camera_width / _width) + 1;
    
    for (var i = -1; i <= _xsize; ++i)
    {
        var _x2 = _camera_x + _xoffset + (i * _width);
        
        draw_sprite_ext(_sprite, 0, _x2, _y + _camera_height, _parallax_scale, _parallax_scale, 0, _colour, _alpha);
    }
}