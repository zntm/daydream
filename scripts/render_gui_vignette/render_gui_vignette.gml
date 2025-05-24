function render_gui_vignette(_y, _gui_width, _gui_height)
{
    var _data = global.world_data[$ global.world.dimension];
    
    var _start = _data.get_vignette_start();
    var _end   = _data.get_vignette_end();
    
    var _alpha = normalize(_y / TILE_SIZE, _start, _end);
    
    if (_alpha > 0)
    {
        draw_vignette(0, 0, _gui_width, _gui_height, _data.get_vignette_colour(), _alpha);
    }
}