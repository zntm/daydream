function render_text(_x, _y, _text, _xscale = 1, _yscale = 1, _rotation = 0, _colour = c_white, _alpha = 1)
{
    var _scale = global.loca_font_scale;
    
    draw_text_cuteify(
        _x,
        _y,
        _text,
        _xscale * _scale,
        _yscale * _scale,
        _rotation,
        _colour,
        _alpha
    );
}
