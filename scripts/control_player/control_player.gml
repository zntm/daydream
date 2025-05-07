function control_player(_tick)
{
    if (keyboard_check(ord("W")))
    {
        // y -= TILE_SIZE * 2 * _tick;
    }
    
    if (keyboard_check(ord("A")))
    {
        // x -= TILE_SIZE * 2 * _tick;
    }
    
    if (keyboard_check(ord("S")))
    {
        // y += TILE_SIZE * 2 * _tick;
    }
    
    if (keyboard_check(ord("D")))
    {
        // x += TILE_SIZE * 2 * _tick;
    }
    
    xvelocity = lerp(xvelocity, (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * 8 * _tick, 0.1);
    yvelocity = lerp(yvelocity, (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * 8 * _tick, 0.1);
    
    x += xvelocity;
    y += yvelocity;
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _tick);
}