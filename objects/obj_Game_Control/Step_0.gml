var _item_data = global.item_data;

if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.GENERATING_WORLD)
{
    control_game_world_generate();

    exit;
}

if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.EXIT)
{
    control_game_exit();

    exit;
}

if (is_opened & WORLD_OPENED_BOOL.PAUSE) exit;

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
var _settings   = global.settings;

control_gametick(_delta_time);

/* network time sync (host only) */
if (global.relay != undefined) && (global.relay.role == RELAY_ROLE.HOST)
{
    timer_network_sync += _delta_time;

    if (timer_network_sync >= 1.0)
    {
        timer_network_sync = 0;

        relay_send_time_update(global.current_world.time);
    }
}

/* auto backup */
if (IS_ENABLED_BACKUP)
{
    timer_auto_backup -= _delta_time;

    if (timer_auto_backup <= 0)
    {
        timer_auto_backup = BACKUP_INTERVAL_SECONDS;

        var _current_player = global.current_player;
        var _backup_lp      = noone;
        with (obj_Player) { if (is_local) { _backup_lp = id; break; } }

        if (_backup_lp != noone)
        {
            file_backup_player(_current_player, _backup_lp);
        }

        var _current_world = global.current_world;

        file_backup_world_global(_current_world);

        var _chunks = chunk_map_get_all();

        for (var i = array_length(_chunks) - 1; i >= 0; --i)
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
                };

                ui_saving = ui_spawn(_saving_def, {
                    link:   ui_saving_link,
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

if (global.relay_manager != undefined)
{
    global.relay_manager.update();
}

sfx_emitter_cleanup();

control_floating_text(_dt);

var _creature_data = global.creature_data;

with (obj_Creature)
{
    var _data     = _creature_data[$ _id];
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

control_chunk_liquid(_delta_time, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

var _tile_x = round(mouse_x / TILE_SIZE);
var _tile_y = round(mouse_y / TILE_SIZE);

if !(is_opened & WORLD_OPENED_BOOL.CHAT) && (_lp.hp > 0)
{
    control_inventory();
}

control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height);

if !(is_opened & (WORLD_OPENED_BOOL.MENU | WORLD_OPENED_BOOL.CHAT)) && (_lp.hp > 0)
{
    if (mouse_check_button_pressed(mb_right))
    {
        for (var i = CHUNK_DEPTH - 1; i >= 0; --i)
        {
            var _tile = tile_get(_tile_x, _tile_y, i);

            if (_tile == TILE_EMPTY) continue;

            var _data        = _item_data[$ _tile.get_id()];
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
    is_opened ^= WORLD_OPENED_BOOL.GUI;
}

if (IS_DEVELOPER_MODE)
{
    control_game_debug_network();
}

control_game_gui_visibility();

control_game_chat();
