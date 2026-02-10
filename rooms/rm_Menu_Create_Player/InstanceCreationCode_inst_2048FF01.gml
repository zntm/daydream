on_draw = function(_x, _y, _sx, _sy)
{
    // Original was scale 4 in 540p. 
    // Now should be 4 * _sx in high-res GUI.
    render_attire(global.player_save_data.attire, 0, _x, _y, 4 * _sx, 4 * _sy);
}