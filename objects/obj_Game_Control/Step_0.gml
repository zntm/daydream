var _item_data = global.item_data;

if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD)
{
    var _camera_x = global.camera_x_real;
    var _camera_y = global.camera_y_real;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    
    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    var _refresh = false;
    
    for (var i = -_a; i <= _a; ++i)
    {
        var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);
        
        for (var j = -_b; j <= _b; ++j)
        {
            var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            if (!chunk_map_exists(_x, _y))
            {
                global.chunk_pool.acquire(_x, _y);
                
                exit;
            }
        }
    }
    
    control_update_chunk_in_view();
    
    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _chunk = chunk_in_view[i];
        
        if (_chunk == undefined) || (_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        _chunk.boolean |= CHUNK_BOOLEAN.GENERATED | CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
        
        // Trigger global lighting refresh for newly generated chunks
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _chunk_data = _chunk.chunk;
        
        for (var _tile_z = 0; _tile_z < CHUNK_DEPTH; ++_tile_z)
        {
            if !(_chunk.chunk_display & (1 << _tile_z)) continue;
            
            for (var _tile_y = 0; _tile_y < CHUNK_SIZE; ++_tile_y)
            {
                for (var _tile_x = 0; _tile_x < CHUNK_SIZE; ++_tile_x)
                {
                    var _world_x = _chunk.chunk_xstart + _tile_x;
                    var _world_y = _chunk.chunk_ystart + _tile_y;
                    
                    var _tile = _chunk_data[tile_index_xyz(_world_x, _world_y, _tile_z)];
                    
                    if (_tile == TILE_EMPTY) continue;
                    
                    var _data = _item_data[$ _tile.get_id()];
                    
                    tile_instance_create(_world_x, _world_y, _tile_z, _tile);
                    
                    tile_connect(_world_x, _world_y, _tile_z, _tile);
                }
            }
        }
    }
    
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.GENERATING_WORLD;
}

if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.EXIT)
{
    var _world_save_data = global.world_save_data;
    
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
    
    // Clear all chunks using chunk_map
    var _all_chunks = chunk_map_get_all();
    var _chunks_length = array_length(_all_chunks);
    
    for (var i = 0; i < _chunks_length; ++i)
    {
        chunk_clear(_all_chunks[i]);
    }
    
    exit;
}

if (is_opened & IS_OPENED_BOOLEAN.PAUSE) exit;

var _delta_time = global.delta_time;

if (IS_DEVELOPER_MODE)
{
    debug_step();
    
    var _debug_settings = global.dbg_settings;
    
    if (!_debug_settings.delta_time)
    {
        _delta_time = 1 / GAME_TICK;
    }
    
    _delta_time *= _debug_settings.time_speed;
    
    var _size = _debug_settings.camera_size;
    
    global.camera_width  = global.camera_width_base  * _size;
    global.camera_height = global.camera_height_base * _size;
    
    camera_set_view_size(view_camera[0], global.camera_width, global.camera_height);
}

var _dt = GAME_TICK * _delta_time;

var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

var _world_data = global.world_data[$ global.world_save_data.dimension];

var _settings = global.settings;

with (obj_Player)
{
    if (obj_Game_Control.is_opened & (IS_OPENED_BOOLEAN.MENU | IS_OPENED_BOOLEAN.CHAT))
    {
        input_left  = false;
        input_right = false;
        
        input_climb_up   = false;
        input_climb_down = false;
        
        input_jump = false;
        input_jump_pressed = false;
    }
    else
    {
        input_left  = keyboard_check(_settings.input_keyboard_left);
        input_right = keyboard_check(_settings.input_keyboard_right);
        
        input_climb_up   = keyboard_check(_settings.input_keyboard_climb_up);
        input_climb_down = keyboard_check(_settings.input_keyboard_climb_down);
        
        input_jump = keyboard_check(_settings.input_keyboard_jump);
        input_jump_pressed = keyboard_check_pressed(_settings.input_keyboard_jump);
    }
}

control_gametick(_delta_time);

// Cleanup temporary audio emitters that have finished playing
sfx_emitter_cleanup();

control_floating_text(_dt);

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
            sfx_diegetic_play(audio_emitter, x, y, smart_value(_data.get_sfx_idle()), global.settings.audio_creature_passive);
            
            timer_sfx_idle = smart_value(_interval);
        }
    }
}

var _particle_data = global.particle_data;

// Update pooled particles (visual properties and non-colliding movement)
global.particle_pool.update_visuals(_delta_time);

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

// Update liquid wave forces (for splash effects)
control_chunk_liquid(_delta_time, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

if !(is_opened & IS_OPENED_BOOLEAN.CHAT)
{
    control_inventory();
}

control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height);

if !(is_opened & (IS_OPENED_BOOLEAN.MENU | IS_OPENED_BOOLEAN.CHAT))
{
    if (mouse_check_button_pressed(mb_right))
    {
        for (var i = CHUNK_DEPTH - 1; i >= 0; --i)
        {
            var _tile = tile_get(_tile_x, _tile_y, i);
            
            if (_tile != TILE_EMPTY)
            {
                var _data = _item_data[$ _tile.get_id()];
                
                var _on_tile_use = _data.get_on_tile_use();
                var _on_tile_use_length = _data.get_on_tile_use_length();
                
                for (var j = 0; j < _on_tile_use_length; ++j)
                {
                    function_execute(_on_tile_use[j], _tile_x, _tile_y, i, 1, 1, 1);
                }
                
                break;
            }
        }
    }
    
    var _mouse_distance = rectangle_distance(mouse_x, mouse_y, obj_Player.bbox_left, obj_Player.bbox_top, obj_Player.bbox_right, obj_Player.bbox_bottom);
    
    if (cooldown_build <= 0) && (_mouse_distance < ATTRIBUTE_DEFAULT_BUILD_REACH) && (mouse_check_button(mb_right))
    {
        player_build(_delta_time, _tile_x, _tile_y);
    }
    else
    {
        cooldown_build -= _delta_time;
    }
    
    if (cooldown_harvest <= 0) && (_mouse_distance < ATTRIBUTE_DEFAULT_HARVEST_REACH) && (mouse_check_button(mb_left))
    {
        player_harvest(_delta_time, _tile_x, _tile_y);
    }
    else
    {
        obj_Player.timer_sfx_harvest += _delta_time;
        
        timer_harvest = 0;
        
        cooldown_harvest -= _delta_time;
    }
}

control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);

if (keyboard_check_pressed(vk_f1))
{
    is_opened ^= IS_OPENED_BOOLEAN.GUI;
}

// Network debug keybinds (developer mode only)
if (IS_DEVELOPER_MODE)
{
    // F5: Start Server
    if (keyboard_check_pressed(vk_f5))
    {
        if (global.network_role == NETWORK_ROLE.NONE)
        {
            if (network_start_server(6510))
            {
                chat_add("System", "Server started on port 6510");
            }
            else
            {
                chat_add("System", "Failed to start server");
            }
        }
        else
        {
            chat_add("System", "Already in a network session");
        }
    }
    
    // F6: Connect to Server
    if (keyboard_check_pressed(vk_f6))
    {
        if (global.network_role == NETWORK_ROLE.NONE)
        {
            var _ip = get_string("Enter Server IP Address:", "127.0.0.1");
            var _port = (variable_global_exists("network_port") ? global.network_port : 6510);
            _port = get_integer("Enter Port:", _port);
            
            if (_ip != "" && _port > 0)
            {
                if (network_connect_to_server(_ip, _port))
                {
                    chat_add("System", $"Connecting to {_ip}:{_port}...");
                }
                else
                {
                    chat_add("System", "Failed to initiate connection");
                }
            }
        }
        else
        {
            chat_add("System", "Already in a network session");
        }
    }
    
    // F7: Disconnect
    if (keyboard_check_pressed(vk_f7))
    {
        if (global.network_role != NETWORK_ROLE.NONE)
        {
            network_disconnect();
            chat_add("System", "Disconnected from network");
        }
    }
}

// Update modular GUI visibility and state
if (global.gui_root != undefined)
{
    // Hotbar: visible when GUI is open and not in menu or chat
    if (global.gui_panel_hotbar_modular != undefined)
    {
        global.gui_panel_hotbar_modular.visible = ((is_opened & IS_OPENED_BOOLEAN.GUI) && !(is_opened & IS_OPENED_BOOLEAN.MENU) && !(is_opened & IS_OPENED_BOOLEAN.CHAT)) || ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT));
    }
    
    // Inventory: visible when inventory is open and chat is not open
    if (global.gui_panel_inventory_modular != undefined)
    {
        global.gui_panel_inventory_modular.visible = (is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT);
    }
    
    // Crafting: visible when inventory is open, chat is not open, and has content
    if (variable_global_exists("gui_panel_crafting_modular")) && (global.gui_panel_crafting_modular != undefined)
    {
        global.gui_panel_crafting_modular.visible = (is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT) && (array_length(global.gui_panel_crafting_modular.children) > 0);
    }
    
    global.gui_root.update();
}

// Chat panel visibility
if (variable_global_exists("gui_panel_chat") && (global.gui_panel_chat != undefined))
{
    global.gui_panel_chat.visible = (is_opened & IS_OPENED_BOOLEAN.GUI) && !(is_opened & IS_OPENED_BOOLEAN.MENU);
}

// Chat input handling
if (is_opened & IS_OPENED_BOOLEAN.CHAT)
{
    // Update chat message from keyboard_string
    chat_message = keyboard_string;
    
    // Refresh suggestions (lightweight, handles its own change detection internally)
    chat_refresh_suggestions();
    
    // Handle Enter to send message
    if (keyboard_check_pressed(vk_enter))
    {
        var _message = string_trim(chat_message);
        
        if (string_length(_message) > 0)
        {
            // Check if it's a command
            if (string_char_at(_message, 1) == CHAT_COMMAND_PREFIX)
            {
                var _command = string_delete(_message, 1, 1);
                chat_command_execute(_command);
            }
            else
            {
                // Add as regular chat message
                chat_add(global.player_save_data.name, _message);
            }
            
            // Add to message history
            array_insert(global.message_history, 0, _message);
            
            if (array_length(global.message_history) > 50)
            {
                array_resize(global.message_history, 50);
            }
        }
        
        chat_disable();
    }
    // Handle Escape to cancel
    else if (keyboard_check_pressed(vk_escape))
    {
        chat_disable();
    }
    // Handle Up arrow - navigate commands if visible, otherwise history
    else if (keyboard_check_pressed(vk_up))
    {
        if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
        {
            global.gui_panel_choices.selected_index = max(0, global.gui_panel_choices.selected_index - 1);
        }
        else
        {
            var _history = global.message_history;
            var _history_length = array_length(_history);
            
            if (_history_length > 0) && (chat_message_history_index > 0)
            {
                chat_message_history_index--;
                keyboard_string = _history[chat_message_history_index];
                chat_message = keyboard_string;
            }
        }
    }
    // Handle Down arrow - navigate commands if visible, otherwise history
    else if (keyboard_check_pressed(vk_down))
    {
        if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
        {
            var _choice_count = array_length(global.gui_panel_choices.choices);
            global.gui_panel_choices.selected_index = min(_choice_count - 1, global.gui_panel_choices.selected_index + 1);
        }
        else
        {
            var _history = global.message_history;
            var _history_length = array_length(_history);
            
            if (chat_message_history_index < _history_length - 1)
            {
                chat_message_history_index++;
                keyboard_string = _history[chat_message_history_index];
                chat_message = keyboard_string;
            }
            else
            {
                chat_message_history_index = _history_length;
                keyboard_string = "";
                chat_message = "";
            }
        }
    }
    // Handle Tab for autocomplete
    else if (keyboard_check_pressed(vk_tab))
    {
        if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
        {
            global.gui_panel_choices.select_choice(global.gui_panel_choices.selected_index);
        }
        else
        {
            chat_refresh_suggestions();
        }
    }
}
else
{
    // Open chat with T key
    if (keyboard_check_pressed(ord("T"))) && !(is_opened & IS_OPENED_BOOLEAN.MENU) && !(is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        chat_enable();
    }
    // Open command prompt with / key
    else if (keyboard_check_pressed(vk_divide) || keyboard_check_pressed(191)) && !(is_opened & IS_OPENED_BOOLEAN.MENU) && !(is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        chat_enable();
        keyboard_string = "/";
        obj_Game_Control.chat_message = "/";
        chat_refresh_suggestions();
    }
}
