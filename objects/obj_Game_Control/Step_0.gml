if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.EXIT)
{
    chunk_saved_count_max = instance_number(obj_Chunk);
    
    if (chunk_saved_count >= chunk_saved_count_max)
    {
        room_goto(rm_Menu_Title);
        
        exit;
    }
    
    with (obj_Chunk)
    {
        instance_destroy();
        
        break;
    }
    
    ++chunk_saved_count;
    
    exit;
}

if (is_opened & IS_OPENED_BOOLEAN.PAUSE) exit;

var _delta_time = global.delta_time;

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

var _world_data = global.world_data[$ global.world_save_data.dimension];

var _settings = global.settings;

with (obj_Player)
{
    input_left  = keyboard_check(_settings.input_keyboard_left);
    input_right = keyboard_check(_settings.input_keyboard_right);
    
    input_climb_up   = keyboard_check(_settings.input_keyboard_climb_up);
    input_climb_down = keyboard_check(_settings.input_keyboard_climb_down);
    
    input_jump = keyboard_check(_settings.input_keyboard_jump);
    input_jump_pressed = keyboard_check_pressed(_settings.input_keyboard_jump);
}

control_game_tick();

var _camera_x = global.camera_x_real;
var _camera_y = global.camera_y_real;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

timer_foliage_sway += _delta_time;

if (timer_foliage_sway >= 0.04)
{
    timer_foliage_sway %= 0.04;
    
    control_chunk_foliage(_delta_time, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);
}

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

control_inventory();

if (cooldown_build <= 0) && (mouse_check_button(mb_right))
{
    player_build(_tile_x, _tile_y);
}
else
{
    cooldown_build -= _delta_time;
}

if (cooldown_harvest <= 0) && (mouse_check_button(mb_left))
{
    player_harvest(_tile_x, _tile_y);
}
else
{
    obj_Player.timer_sfx_harvest += _delta_time;
    
    harvest_amount = 0;
    
    cooldown_harvest -= _delta_time;
}

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);