randomize();
os_powersave_enable(false);

audio_stop_all();

enum SURFACE_REFRESH_BOOL {
    GENERATING_WORLD    = 1 << 0,
    LIGHTING            = 1 << 1,
    INVENTORY_BACKPACK  = 1 << 2,
    INVENTORY_CRAFTABLE = 1 << 3,
    INVENTORY_HOTBAR    = 1 << 4,
    HP                  = 1 << 5,
    PAUSE               = 1 << 6,
}

surface_refresh = SURFACE_REFRESH_BOOL.HP
    | SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK
    | SURFACE_REFRESH_BOOL.INVENTORY_CRAFTABLE
    | SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR
    | SURFACE_REFRESH_BOOL.LIGHTING;

enum WORLD_OPENED_BOOL {
    CHAT                = 1 << 0,
    EXIT                = 1 << 1,
    GENERATING_WORLD    = 1 << 2,
    GUI                 = 1 << 3,
    INVENTORY           = 1 << 4,
    INVENTORY_CONTAINER = 1 << 5,
    PAUSE               = 1 << 6,
    MENU                = 1 << 7,
}

is_opened = WORLD_OPENED_BOOL.GENERATING_WORLD
    | WORLD_OPENED_BOOL.GUI;

tile_container_x = 0;
tile_container_y = 0;
tile_container_z = 0;

timer_respawn      = 0;
timer_foliage_sway = 0;

timer_crafting_max = 0.3;
timer_crafting     = timer_crafting_max;

surface_harvest = -1;
surface_pause   = [-1, -1];

spawn_needs_init = true;

enum INVENTORY_MOUSE_SELECT_TYPE {
    NONE,
    LEFT,
    RIGHT,
    CRAFTING
}

inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;

global.inventory_selected_hotbar  = 0;
global.inventory_selected_backpack = {
    index: -1,
    type:  undefined
}
global.inventory_selected_hover = noone;

surface_lighting   = -1;
surface_lighting_colour = -1;
surface_lighting_x = -1;
surface_lighting_y = -1;

surface_hp = -1;

surface_inventory = {
    tooltip: {
        surface:        -1,
        surface_width:   0,
        surface_height:  0
    },
    hotbar: {
        surface_item: -1,
        surface_slot: -1
    },
    base: {
        surface_item: -1,
        surface_slot: -1
    },
    armor_helmet: {
        surface_item: -1,
        surface_slot: -1
    },
    armor_breastplate: {
        surface_item: -1,
        surface_slot: -1
    },
    armor_leggings: {
        surface_item: -1,
        surface_slot: -1
    },
    accessory: {
        surface_item: -1,
        surface_slot: -1
    },
    _craftable: {
        surface_item: -1,
        surface_slot: -1
    },
    _container: {
        surface_item: -1,
        surface_slot: -1
    }
}

chunk_saved_count     = 0;
chunk_saved_count_max = 0;

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

var _camera_x = 0 - (_camera_width  / 2);
var _camera_y = 0 - (_camera_height / 2);

var _gui_scale = 1;

global.camera_width  = _camera_width;
global.camera_height = _camera_height;

global.camera_width_base  = _camera_width;
global.camera_height_base = _camera_height;

global.camera_x      = _camera_x;
global.camera_y      = _camera_y;
global.camera_x_real = _camera_x;
global.camera_y_real = _camera_y;

global.gui_scale = _gui_scale;

control_update_gui_size();
control_camera_pos(_camera_x, _camera_y);

camera_set_view_size(view_camera[0], _camera_width, _camera_height);

init_inventory_instance();

event_clear_all();
statistics_init();
achievement_init();

game_set_speed(display_get_frequency(), gamespeed_fps);

control_instance_unpause();

inst_664AF3B4.x = -1000;
inst_664AF3B4.y = -1000;

timer_creature_spawn = 0;
timer_respawn        = 0;

global.tick_accumulator = 0;

chunk_in_view_x      = infinity;
chunk_in_view_y      = infinity;
chunk_in_view        = [];
chunk_in_view_length = 0;

chunk_queue_init();

/* skip on clients - seed is received via WELCOME packet */
if (global.network_role != RELAY_ROLE.CLIENT)
{
    open_simplex_noise_seed(global.current_world.seed);
}

item_cooldown  = {}
menu_instance  = [];

control_game_menu_hide_instances();

if (IS_DEVELOPER_MODE)
{
    debug_init();
}

global.command_value = {}

chat_message               = "";
chat_message_history_index = 0;

if (!variable_global_exists("chat_history"))
{
    global.chat_history = [];
}

file_load_message_history();

if (!variable_global_exists("message_history"))
{
    global.message_history = [];
}

global.chat_command_hint = undefined;
global.gui_deferred_text = [];

/* init declarative UI system */
var _aspect_ratio = global.window_width / global.window_height;
var _logical_height = 540;
var _logical_width  = _logical_height * _aspect_ratio;

global.gui_root = new UIElement(0, 0, _logical_width, _logical_height);

control_game_ui_init(_logical_width, _logical_height);

PRINT("[Daydream] New UI system initialized");

if (global.relay == undefined) || (global.relay.role == RELAY_ROLE.NONE)
{
    relay_manager_init();
}

timer_network_sync = 0;
timer_auto_backup  = file_backup_get_interval_seconds(global.current_world);

global.async_save_map = {}

inventory_give(obj_Player.x, obj_Player.y, new Inventory("phantasia:copper_bow", 1));
inventory_give(obj_Player.x, obj_Player.y, new Inventory("phantasia:arrow", 999));
inventory_give(obj_Player.x, obj_Player.y, new Inventory("phantasia:oak_chest", 999));

/* register colorgrade pass once */
__colorgrade_pass_registered = false;
