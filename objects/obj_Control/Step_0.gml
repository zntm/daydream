var _window_focus = window_has_focus();

if (!_window_focus)
{
    window_focus = false;
    
    exit;
}
else if (!window_focus)
{
    window_focus = true;
    
    carbasa_repair_all();
}

global.delta_time = delta_time / 1_000_000;

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

if (keyboard_check_pressed(ord("R")))
{
    room_restart();
}

if (keyboard_check(ord("C")))
{
    global.world.time += 1000
}


if (keyboard_check_pressed(vk_escape))
{
    game_end();
}

if (keyboard_check_pressed(ord("E")))
{
    is_opened_inventory = !is_opened_inventory;
}

if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}

var _window_width  = window_get_width();
var _window_height = window_get_height();

if ((_window_width > 0) && (_window_height > 0)) && ((window_width != _window_width) || (window_height != _window_height))
{
    window_width  = _window_width;
    window_height = _window_height;
    
    room_set_viewport(room, 0, true, 0, 0, window_width, window_height);
    
    if (window_width != surface_get_width(application_surface)) || (window_height != surface_get_height(application_surface))
    {
        surface_resize(application_surface, window_width, window_height);
    }
    
    carbasa_repair_all();
    
    var _gui_scale = global.gui_scale;
    
    global.gui_width  = round(_gui_scale * _window_width);
    global.gui_height = round(_gui_scale * _window_height);
    
    surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
}

var _settings = global.settings;

with (obj_Player)
{
    input_left  = keyboard_check(_settings.key_left);
    input_right = keyboard_check(_settings.key_right);
    
    input_climb_up   = keyboard_check(_settings.key_climb_up);
    input_climb_down = keyboard_check(_settings.key_climb_down);
    
    input_jump = keyboard_check(_settings.key_jump);
    input_jump_pressed = keyboard_check_pressed(_settings.key_jump);
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