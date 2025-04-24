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

control_camera_pos(obj_Player.x - (global.camera_width / 2), obj_Player.y - (global.camera_height / 2));