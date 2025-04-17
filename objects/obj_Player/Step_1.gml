if (keyboard_check(ord("W")))
{
    y -= TILE_SIZE * 2;
}

if (keyboard_check(ord("A")))
{
    x -= TILE_SIZE * 2;
}

if (keyboard_check(ord("S")))
{
    y += TILE_SIZE * 2;
}

if (keyboard_check(ord("D")))
{
    x += TILE_SIZE * 2;
}

camera_set_view_pos(view_camera[0], obj_Player.x - (camera_get_view_width(view_camera[0]) / 2), obj_Player.y - (camera_get_view_height(view_camera[0]) / 2));