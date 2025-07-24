function gui_xanchor(_anchor, _camera_width = global.camera_width, _scale = 1)
{
    if (_anchor == GUI_ANCHOR.TOP_LEFT) || (_anchor == GUI_ANCHOR.MIDDLE_LEFT) || (_anchor == GUI_ANCHOR.BOTTOM_LEFT)
    {
        return GUI_SAFE_ZONE_X * _scale;
    }
    
    if (_anchor == GUI_ANCHOR.TOP) || (_anchor == GUI_ANCHOR.MIDDLE) || (_anchor == GUI_ANCHOR.BOTTOM)
    {
        return _camera_width / 2;
    }
    
    return _camera_width - (GUI_SAFE_ZONE_X * _scale);
}