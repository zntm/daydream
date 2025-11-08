function render_background_parallax(_sprite, _index, _x, _y, _camera_x, _camera_y, _camera_width, _camera_height, _colour, _alpha)
{
    var _sprite_xoffset = sprite_get_xoffset(_sprite);
    var _width = sprite_get_width(_sprite);
    
    var _xoffset = (_x * (_index + 1) * 0.05) % _width;
    
    var _xsize = ceil(_camera_width / _width) + 1;
    
    for (var i = -_xsize; i <= _xsize; ++i)
    {
        var _x2 = _x + _xoffset + (i * _width);
        
        var _ = _x2 - _sprite_xoffset;
        
        if (_ + _width < _camera_x) || (_ >= _camera_x + _camera_width) continue;
        
        draw_sprite_ext(_sprite, 0, _x2, _y + _camera_height, 1, 1, 0, _colour, _alpha);
    }
}