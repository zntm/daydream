if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.EXIT)
{
    var _world_save_data = global.world_save_data;
    
    chunk_saved_count_max = instance_number(obj_Chunk);
    
    if (chunk_saved_count >= chunk_saved_count_max)
    {
        audio_stop_all();
        
        var _player_save_data = global.player_save_data;
        
        file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_player_save_data.uuid}", _player_save_data.name, _player_save_data.attire, obj_Player.hp, obj_Player.hp_max, obj_Player.saturation, {});
        file_save_player_inventory(_player_save_data);
        
        file_save_world_global(_world_save_data);
        
        with (obj_Player)
        {
            file_save_world_spawn(_world_save_data, id);
        }
        
        window_progress(window_progress_none);
        
        var _names = struct_get_names(surface_inventory);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = _names[i];
            var _data = surface_inventory[$ _name];
            
            if (surface_exists(_data[$ "surface"] ?? -1))
            {
                surface_free(_data.surface);
            }
            
            if (surface_exists(_data[$ "surface_slot"] ?? -1))
            {
                surface_free(_data.surface_slot);
            }
            
            if (surface_exists(_data[$ "surface_item"] ?? -1))
            {
                surface_free(_data.surface_item);
            }
        }
        
        room_goto(rm_Menu_Title);
        
        exit;
    }
    
    ++chunk_saved_count;
    
    window_progress(window_progress_normal, chunk_saved_count, chunk_saved_count_max);
    
    with (obj_Chunk)
    {
        chunk_clear(id);
        
        instance_destroy();
    }
    
    exit;
}

if (is_opened & IS_OPENED_BOOLEAN.PAUSE) exit;

var _delta_time = global.delta_time;
var _dt = GAME_TICK * _delta_time;

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

control_game_tick(_delta_time);

var _creature_data = global.creature_data;

with (obj_Creature)
{
    var _data = _creature_data[$ _id];
    
    var _interval = _data.get_sfx_interval();
    
    if (_interval != undefined)
    {
        timer_sfx_idle -= _delta_time;
        
        if (timer_sfx_idle <= 0)
        {
            sfx_diegetic_play(audio_emitter, x, y, smart_value(_data.get_sfx_idle()));
            
            timer_sfx_idle = smart_value(_interval);
        }
    }
}

var _particle_data = global.particle_data;

with (obj_Particle)
{
    var _data = _particle_data[$ _id];
    
    if (!attribute.has_collision_box())
    {
        x += xvelocity * _dt;
        y += yvelocity * _dt;
        
        yvelocity += attribute.get_gravity() * _dt;
    }
    
    image_angle += rotation_increment * _dt;
}

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

control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height);

if (cooldown_build <= 0) && (mouse_check_button(mb_right))
{
    player_build(_delta_time, _tile_x, _tile_y);
}
else
{
    cooldown_build -= _delta_time;
}

if (cooldown_harvest <= 0) && (mouse_check_button(mb_left))
{
    player_harvest(_delta_time, _tile_x, _tile_y);
}
else
{
    obj_Player.timer_sfx_harvest += _delta_time;
    
    harvest_amount = 0;
    
    cooldown_harvest -= _delta_time;
}

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);

if (keyboard_check_pressed(vk_f2))
{
    sfx_play("phantasia:menu.screenshot");
    
    surface_save(application_surface, $"{PROGRAM_DIRECTORY_SCREENSHOTS}/{datetime_to_unix()}.png");
}