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
    
    var _world_data = global.world_data[$ global.current_world.dimension];
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
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || (_c.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        _c.boolean |= CHUNK_BOOLEAN.GENERATED | CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _chunk_xstart = _c.chunk_xstart;
        var _chunk_ystart = _c.chunk_ystart;
        
        var _chunk = _c.chunk;
        var _chunk_display = _c.chunk_display;
        
        for (var _tz = CHUNK_DEPTH - 1; _tz >= 0; --_tz)
        {
            if !(_chunk_display & (1 << _tz)) continue;
            
            for (var _ty = CHUNK_SIZE - 1; _ty >= 0; --_ty)
            {
                for (var _tx = CHUNK_SIZE - 1; _tx >= 0; --_tx)
                {
                    var _x = _chunk_xstart + _tx;
                    var _y = _chunk_ystart + _ty;
                    
                    var _tile = _chunk[tile_index_xyz(_x, _y, _tz)];
                    
                    if (_tile == TILE_EMPTY) continue;
                    
                    tile_instance_create(_x, _y, _tz, _tile);
                    
                    tile_connect(_x, _y, _tz, _tile);
                }
            }
        }
    }
    
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.GENERATING_WORLD;
}

if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.EXIT)
{
    var _current_world = global.current_world;
    
    if (chunk_saved_count >= chunk_saved_count_max)
    {
        audio_stop_all();
        

        var _current_player = global.current_player;
        
        var _lp = noone;
        with (obj_Player) { if (is_local) { _lp = id; break; } }
        
        // If player doesn't exist (e.g. error or already destroyed), try to rescue or skip
        if (_lp == noone)
        {
            // Fallback or exit? If we can't find the player, we can't save hp/saturation accurately.
            // But we might have just loaded the menu.
            // Assuming we want to save *current* state.
            // If _lp is noone, maybe use default values or values from save data?
            // For now, let's just use the global save data itself if the instance is missing?
            // But the args are _lp.hp.
            
            // Let's create a dummy struct for safety or use save data accessors if available.
            // Actually, simply finding it should work if the player exists.
        }

        
        if (_lp != noone)
        {
            _current_player.hp = _lp.hp;
            _current_player.hp_max = _lp.hp_max;
        }

        file_save_player_global(_current_player);
        file_save_player_inventory(_current_player);
        
        file_save_world_global(_current_world);
        
        with (obj_Player)
        {
            if (is_local) file_save_world_spawn(_current_world, id);
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
        
        // Disconnect from network before going to menu
        if (global.relay != undefined && global.relay.role != RELAY_ROLE.NONE)
        {
            global.relay_manager.leave_session();
        }
        
        world_cleanup();
        
        room_goto(rm_Menu_Title);
        
        exit;
    }
    
    ++chunk_saved_count;
    
    if (os_type == os_windows)
    {
        window_progress(window_progress_normal, chunk_saved_count, chunk_saved_count_max);
    }
    
    var _chunks = chunk_map_get_all();
    
    for (var i = array_length(_chunks) - 1; i >= 0; --i)
    {
        chunk_clear(_chunks[i]);
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

var _lp = noone;
with (obj_Player) { if (is_local) { _lp = id; break; } }
if (_lp == noone) exit;

var _player_x = _lp.x;
var _player_y = _lp.y;

var _world_data = global.world_data[$ global.current_world.dimension];

var _settings = global.settings;

// Redundant keyboard polling removed - handled by control_player and input_state.poll_player()

control_gametick(_delta_time);

// Network Time Sync (Host only)
if (global.relay != undefined && global.relay.role == RELAY_ROLE.HOST)
{
    timer_network_sync += _delta_time;
    
    if (timer_network_sync >= 1.0) // Sync every second
    {
        timer_network_sync = 0;
        relay_send_time_update(global.current_world.time);
    }
}

// Auto Backup
if (IS_ENABLED_BACKUP)
{
    timer_auto_backup -= _delta_time;
    
    if (timer_auto_backup <= 0)
    {
        timer_auto_backup = BACKUP_INTERVAL_SECONDS;
        
        var _current_player = global.current_player;
        var _lp = noone;
        with (obj_Player) { if (is_local) { _lp = id; break; } }
        
        if (_lp != noone)
        {
            file_backup_player(_current_player, _lp);
        }
        
        var _current_world = global.current_world;
        file_backup_world_global(_current_world);
        
        // Backup chunks that are currently in memory
        var _chunks = chunk_map_get_all();
        for (var i = 0; i < array_length(_chunks); ++i)
        {
            file_backup_world_chunk(_current_world, _chunks[i]);
        }
        
        chat_system_push("Auto-backup complete!");
        
        /* show saving indicator */
        if (!variable_instance_exists(id, "ui_saving")) || (ui_saving == undefined)
        {
            var _saving_def = ui_load("ui/menu/saving.ui");
            
            if (_saving_def != undefined)
            {
                ui_saving_link = {
                    is_visible: true
                }
                
                ui_saving = ui_spawn(_saving_def, {
                    link: ui_saving_link,
                    parent: global.gui_root
                });
            }
        }
        else
        {
            ui_saving_link.is_visible = true;
            
            ui_mark_dirty(ui_saving);
        }
        
        timer_saving_ui = 2.0;
    }
    
    /* hide saving indicator after timeout */
    if (variable_instance_exists(id, "timer_saving_ui")) && (timer_saving_ui > 0)
    {
        timer_saving_ui -= _delta_time;
        
        if (timer_saving_ui <= 0)
        {
            if (variable_instance_exists(id, "ui_saving")) && (ui_saving != undefined)
            {
                ui_saving_link.is_visible = false;
                
                ui_mark_dirty(ui_saving);
            }
        }
    }
}

// Update relay validator (P2P validation checks)
if (global.relay_manager != undefined)
{
    global.relay_manager.update();
}

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
    
    control_chunk_foliage(_delta_time);
}

// Update liquid wave forces (for splash effects)
control_chunk_liquid(_delta_time, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

if !(is_opened & IS_OPENED_BOOLEAN.CHAT) && (_lp.hp > 0)
{
    control_inventory();
}

control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height);

if !(is_opened & (IS_OPENED_BOOLEAN.MENU | IS_OPENED_BOOLEAN.CHAT)) && (_lp.hp > 0)
{
    if (mouse_check_button_pressed(mb_right))
    {
        for (var i = CHUNK_DEPTH - 1; i >= 0; --i)
        {
            var _tile = tile_get(_tile_x, _tile_y, i);
            
            if (_tile == TILE_EMPTY) continue;
            
            var _data = _item_data[$ _tile.get_id()];
            
            var _on_tile_use = _data.get_on_tile_use();
            
            if (_on_tile_use != undefined)
            {
                for (var j = _data.get_on_tile_use_length() - 1; j >= 0; --j)
                {
                    function_execute(_on_tile_use[j], _tile_x, _tile_y, i, 1, 1, 1);
                }
            }
            
            break;
        }
    }
    
    control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height);
}

if (keyboard_check_pressed(vk_f1))
{
    is_opened ^= IS_OPENED_BOOLEAN.GUI;
}

// Network debug keybinds (developer mode only)
if (IS_DEVELOPER_MODE)
{
    // F5: Host Session
    if (IS_MULTIPLAYER_ENABLED && keyboard_check_pressed(vk_f5))
    {
        if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE)
        {
            var _code = global.relay_manager.host_session(6510);
            if (_code != "")
            {
                chat_system_push($"Hosting session! Invite code: {invite_code_format(_code)}");
                invite_code_copy();
                chat_system_push("Invite code copied to clipboard");
            }
            else
            {
                chat_system_push("Failed to start session");
            }
        }
        else
        {
            chat_system_push("Already in a session");
        }
    }
    
    // F6: Join Session
    if (IS_MULTIPLAYER_ENABLED && keyboard_check_pressed(vk_f6))
    {
        if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE)
        {
            var _code = get_string("Enter Invite Code:", "");
            
            if (_code != "")
            {
                if (global.relay_manager.join_session(_code))
                {
                    chat_system_push("Connecting...");
                }
                else
                {
                    chat_system_push("Failed to join session - invalid code?");
                }
            }
        }
        else
        {
            chat_system_push("Already in a session");
        }
    }
    
    // F7: Leave Session
    if (keyboard_check_pressed(vk_f7))
    {
        if (global.relay != undefined && global.relay.role != RELAY_ROLE.NONE)
        {
            global.relay_manager.leave_session();
            chat_system_push("Left session");
        }
    }
}

// Update modular GUI visibility and state
if (global.gui_root != undefined)
{
    // Hotbar: visible when GUI is open and not in menu or chat
    if (global.gui_panel_hotbar_modular != undefined)
    {
        global.gui_panel_hotbar_modular.visible = !(is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) && (((is_opened & IS_OPENED_BOOLEAN.GUI) && !(is_opened & IS_OPENED_BOOLEAN.MENU) && !(is_opened & IS_OPENED_BOOLEAN.CHAT)) || ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT)));
    }
    
    // Inventory: visible when inventory is open and chat is not open
    if (global.gui_panel_inventory_modular != undefined)
    {
        global.gui_panel_inventory_modular.visible = !(is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) && (is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT);
    }
    
    // Crafting: visible when inventory is open, chat is not open, and has content
    if (variable_global_exists("gui_panel_crafting_modular")) && (global.gui_panel_crafting_modular != undefined)
    {
        global.gui_panel_crafting_modular.visible = !(is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) && (is_opened & IS_OPENED_BOOLEAN.INVENTORY) && !(is_opened & IS_OPENED_BOOLEAN.CHAT) && (array_length(global.gui_panel_crafting_modular.children) > 0);
    }
    
    global.ui_input_consumed = false;
    
    global.gui_root.update();
    
    // Update new declarative UI instances
    if (variable_global_exists("ui_hotbar") && global.ui_hotbar != undefined) {
        ui_mark_dirty(global.ui_hotbar);
        ui_update(global.ui_hotbar);
    }
    if (variable_global_exists("ui_inventory") && global.ui_inventory != undefined) {
        ui_mark_dirty(global.ui_inventory);
        ui_update(global.ui_inventory);
    }
    ui_clear_events();
    
    /* update dynamically spawned UI instances (blueprints, etc.) */
    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);
        
        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];
            
            if (_ui_inst != undefined) ui_update(_ui_inst);
        }
    }
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
                chat_user_push(global.current_player.name, _message);
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
