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

control_structure_surface(floor(_camera_x / TILE_SIZE) - (CHUNK_SIZE * 16), ceil((_camera_x + _camera_width) / TILE_SIZE) + (CHUNK_SIZE * 16));

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

if (mouse_check_button(mb_right)) && (tile_get(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY)
{
    tile_place(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT, new Tile("phantasia:dirt"));
}

if (mouse_check_button(mb_left))
{
    for (var i = CHUNK_DEPTH - 1; i >= 0; --i)
    {
        if (tile_get(_tile_x, _tile_y, i) != TILE_EMPTY)
        {
            tile_place(_tile_x, _tile_y, i, TILE_EMPTY);
            
            break;
        }
    }
}

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);