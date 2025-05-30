var _window_focus = window_has_focus();

if (!_window_focus)
{
    window_focus = false;
    is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
    exit;
}
else if (!window_focus)
{
    window_focus = true;
    
    carbasa_repair_all();
}

if (keyboard_check_pressed(vk_escape))
{
    is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
    }
}

if (is_opened & IS_OPENED_BOOLEAN.PAUSE) exit;

var _delta_time = delta_time / 1_000_000;

global.delta_time = _delta_time;

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

if (keyboard_check_pressed(ord("R")))
{
    room_restart();
}
var _world_data = global.world_data[$ global.world.dimension];

if (keyboard_check(ord("C")))
{
    global.world.time += 1;
    
    if (global.world.time >= _world_data.get_time_length())
    {
        global.world.day += floor(global.world.time / _world_data.get_time_length());
        
        global.world.time %= _world_data.get_time_length();
    }
    
    obj_Control_Background.refresh += 1;
}

if (keyboard_check_pressed(ord("E")))
{
    is_opened ^= IS_OPENED_BOOLEAN.INVENTORY;
}

if (keyboard_check_pressed(ord("F")))
{
    spawn_item_drop(_player_x, _player_y, new Inventory("phantasia:dirt"));
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

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

if (global.world.time % 8 == 0)
{
    control_chunk_foliage(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);
}

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

var _mouse_wheel = mouse_wheel_down() - mouse_wheel_up();

if (_mouse_wheel != 0)
{
    global.inventory_selected_hotbar = (global.inventory_selected_hotbar + _mouse_wheel + INVENTORY_LENGTH.ROW) % INVENTORY_LENGTH.ROW;
    
    surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
}

if (cooldown_build <= 0) && (mouse_check_button(mb_right))
{
    player_place(_tile_x, _tile_y);
}
else
{
    cooldown_build -= _delta_time;
}

if (cooldown_harvest <= 0) && (mouse_check_button(mb_left))
{
    player_mine(_tile_x, _tile_y);
}
else
{
    harvest_amount = 0;
    
    cooldown_harvest -= _delta_time;
}

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);