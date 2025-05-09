global.delta_time = (delta_time / 1_000_000) * 60;

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

with (obj_Player)
{
    key_left  = (keyboard_check(ord("A"))) || (keyboard_check(vk_left));
    key_right = (keyboard_check(ord("D"))) || (keyboard_check(vk_right));
    
    key_jump  = (keyboard_check(ord("W"))) || (keyboard_check(vk_space)) || (keyboard_check(vk_up));
    key_jump_pressed = (keyboard_check_pressed(ord("W"))) || (keyboard_check_pressed(vk_space)) || (keyboard_check_pressed(vk_up));
}

control_game_tick();

var _camera_x = global.camera_x_real;
var _camera_y = global.camera_y_real;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

// control_structure_surface(floor(_camera_x / TILE_SIZE) - (CHUNK_SIZE * 32), ceil((_camera_x + _camera_width) / TILE_SIZE) + (CHUNK_SIZE * 32));

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

if (global.world.time % 8 == 0)
{
    control_chunk_foliage(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);
}

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

++global.world.time;