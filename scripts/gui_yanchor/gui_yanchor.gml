function gui_yanchor(_anchor, _camera_height = global.camera_height)
{
    if (_anchor == GUI_ANCHOR.TOP_LEFT) || (_anchor == GUI_ANCHOR.TOP) || (_anchor == GUI_ANCHOR.TOP_RIGHT)
    {
        return GUI_SAFE_ZONE_Y;
    }
    
    if (_anchor == GUI_ANCHOR.MIDDLE_LEFT) || (_anchor == GUI_ANCHOR.MIDDLE) || (_anchor == GUI_ANCHOR.MIDDLE_RIGHT)
    {
        return _camera_height / 2;
    }
    
    return _camera_height - GUI_SAFE_ZONE_Y;
}