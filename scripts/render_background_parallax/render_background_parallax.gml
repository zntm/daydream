function render_background_parallax(_data, _index, _x, _y, _camera_x, _camera_y, _camera_width, _camera_height, _colour, _alpha)
{
    var _width = _data.get_sprite_width(_index);
    
    var _xoffset = (_x * (_index + 1) * 0.05) % _width;
    
    var _xsize = ceil(_camera_width / _width) + 1;
    
    for (var i = -_xsize; i <= _xsize; ++i)
    {
        var _x2 = _x + _xoffset + (i * _width);
        
        var _ = _x2 - _data.get_sprite_xoffset(_index);
        
        show_debug_message($"{_} {_ + _width} :: {_camera_x} {_camera_x + _camera_width}");
        
        if (_ + _width < _camera_x) || (_ >= _camera_x + _camera_width) continue;
        
        draw_sprite_ext(_data.get_sprite(_index), 0, _x2, _y + _camera_height, 1, 1, 0, _colour, _alpha);
    }
}