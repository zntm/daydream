function render_background_parallax(_sprite, _x, _y, _width, _height, _xsize, _ysize, _colour, _alpha)
{
	for (var i = -_xsize; i <= _xsize; ++i)
	{
        for (var j = -_ysize; j <= _ysize; ++j)
        {
            draw_sprite_ext(_sprite, 0, _x + (i * _width), _y + (j * _height), 1, 1, 0, _colour, _alpha);
        }
	}
}