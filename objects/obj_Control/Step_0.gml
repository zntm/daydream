var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

if (keyboard_check_pressed(ord("R")))
{
    room_restart();
}

if (keyboard_check_pressed(vk_escape))
{
    game_end();
}

if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}

var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);