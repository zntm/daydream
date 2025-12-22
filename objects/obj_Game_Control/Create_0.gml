randomize();

audio_stop_all();

enum SURFACE_REFRESH_BOOLEAN {
    GENERATING_WORLD    = 1 << 0,
    PAUSE               = 1 << 1,
    INVENTORY_HOTBAR    = 1 << 2,
    INVENTORY_BACKPACK  = 1 << 3,
    INVENTORY_CRAFTABLE = 1 << 4,
    HP                  = 1 << 5,
    LIGHTING            = 1 << 6,
}

surface_refresh =
    SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR    |
    SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK  |
    SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE |
    SURFACE_REFRESH_BOOLEAN.HP                  |
    SURFACE_REFRESH_BOOLEAN.LIGHTING;

enum IS_OPENED_BOOLEAN {
    GENERATING_WORLD    = 1 << 0,
    GUI                 = 1 << 1,
    INVENTORY           = 1 << 2,
    INVENTORY_CONTAINER = 1 << 3,
    PAUSE               = 1 << 4,
    MENU                = 1 << 5,
    EXIT                = 1 << 6,
    CHAT                = 1 << 7
}

is_opened =
    IS_OPENED_BOOLEAN.GENERATING_WORLD |
    IS_OPENED_BOOLEAN.GUI;

tile_container_x = 0;
tile_container_y = 0;
tile_container_z = 0;

tile_harvest_x = 0;
tile_harvest_y = 0;
tile_harvest_z = 0;

timer_harvest = 0;

timer_respawn = 0;
timer_foliage_sway = 0;

timer_crafting_max = 0.3;
timer_crafting = timer_crafting_max;

cooldown_build = 0;

cooldown_harvest = 0;

surface_harvest = -1;
surface_pause = [ -1, -1 ];

var _world_save_data = global.world_save_data;

var _world_data = global.world_data[$ _world_save_data.dimension];

//Defer spawn calculation to Room Creation Code after all instances are created
spawn_needs_init = true;

global.inventory_selected_hotbar = 0;
global.inventory_selected_backpack = {
    index: -1,
    type: undefined
}

enum INVENTORY_MOUSE_SELECT_TYPE {
    NONE,
    LEFT,
    RIGHT,
    CRAFTING
}

inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;

global.inventory_selected_hover = noone;

surface_lighting = -1;
surface_lighting_x = -1;
surface_lighting_y = -1;

surface_inventory = {
    tooltip: {
        surface: -1,
        surface_width: 0,
        surface_height: 0
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

surface_hp = -1;

chunk_saved_count = 0;
chunk_saved_count_max = 0;

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

var _camera_x = 0 - (_camera_width  / 2);
var _camera_y = 0 - (_camera_height / 2);

var _gui_scale = 2;

var _gui_width  = round(_gui_scale * global.window_width);
var _gui_height = round(_gui_scale * global.window_height);

global.camera_width  = _camera_width;
global.camera_height = _camera_height;

global.camera_width_base  = _camera_width;
global.camera_height_base = _camera_height;

global.camera_x = _camera_x;
global.camera_y = _camera_y;

global.camera_x_real = _camera_x;
global.camera_y_real = _camera_y;

global.gui_scale = _gui_scale;

control_update_gui_size(_gui_width, _gui_height);

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
timer_respawn = 0;

global.tick_accumulator = 0;

chunk_in_view_x = infinity;
chunk_in_view_y = infinity;

chunk_in_view = [];
chunk_in_view_length = 0;

// Initialize chunk generation queue for time-sliced worldgen
chunk_queue_init();

open_simplex_noise_seed(global.world_save_data.seed);

item_cooldown = {}

menu_instance = [];

with (obj_Menu_Anchor)
{
    y = -1000;
}

with (obj_Menu_Button)
{
    y = -1000;
}

with (obj_Menu_Dropdown)
{
    y = -1000;
}


with (obj_Menu_Textbox)
{
    y = -1000;
}

if (IS_DEVELOPER_MODE)
{
    debug_init();
}

// Global command values
global.command_value = {};

// Note: Chat open state is now in is_opened & IS_OPENED_BOOLEAN.CHAT
chat_message = "";
chat_message_history_index = 0;


// Initialize chat history if not exists
if (!variable_global_exists("chat_history"))
{
    global.chat_history = [];
}

// Load chat history
file_load_message_history();

// Initialize message history (for up/down arrow history)
if (!variable_global_exists("message_history"))
{
    global.message_history = [];
}

// Initialize command hint
global.chat_command_hint = undefined;

// Initialize the modular GUI system
gui_init_modular();
