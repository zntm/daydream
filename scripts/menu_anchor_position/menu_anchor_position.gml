function menu_anchor_position(_x, _y, _anchor_type, _width, _height)
{
    var _xscale = camera_get_view_width(view_camera[0])  / _width;
    var _yscale = camera_get_view_height(view_camera[0]) / _height;
    
    var _xanchor = gui_xanchor(_anchor_type, _width,  _xscale);
    var _yanchor = gui_yanchor(_anchor_type, _height, _yscale);
    
    x = _xanchor + ((x - _xanchor) * _xscale);
    y = _yanchor + ((y - _yanchor) * _yscale);
}