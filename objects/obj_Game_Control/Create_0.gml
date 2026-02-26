randomize();
os_powersave_enable(false); // Fix for server stopping when window loses focus

audio_stop_all();

enum SURFACE_REFRESH_BOOLEAN {
    GENERATING_WORLD    = 1 << 0,
    LIGHTING            = 1 << 1,
    INVENTORY_BACKPACK  = 1 << 2,
    INVENTORY_CRAFTABLE = 1 << 3,
    INVENTORY_HOTBAR    = 1 << 4,
    HP                  = 1 << 5,
    PAUSE               = 1 << 6,
}

surface_refresh = SURFACE_REFRESH_BOOLEAN.HP
    | SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK
    | SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE
    | SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR
    | SURFACE_REFRESH_BOOLEAN.LIGHTING;

enum IS_OPENED_BOOLEAN {
    CHAT                = 1 << 0,
    EXIT                = 1 << 1,
    GENERATING_WORLD    = 1 << 2,
    GUI                 = 1 << 3,
    INVENTORY           = 1 << 4,
    INVENTORY_CONTAINER = 1 << 5,
    PAUSE               = 1 << 6,
    MENU                = 1 << 7,
}

is_opened = IS_OPENED_BOOLEAN.GENERATING_WORLD
    | IS_OPENED_BOOLEAN.GUI;

tile_container_x = 0;
tile_container_y = 0;
tile_container_z = 0;

timer_respawn = 0;
timer_foliage_sway = 0;

timer_crafting_max = 0.3;
timer_crafting = timer_crafting_max;

surface_harvest = -1;
surface_pause = [ -1, -1 ];

var _current_world = global.current_world;

var _world_data = global.world_data[$ _current_world.dimension];

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

// Initialize seed - SKIP for clients, they receive the seed via WELCOME packet
if (global.network_role != RELAY_ROLE.CLIENT)
{
    open_simplex_noise_seed(global.current_world.seed);
}

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
global.command_value = {}

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

// Initialize deferred text rendering
global.gui_deferred_text = [];

// Initialize the new declarative UI system
var _design_w = 960;

var _logical_width = _design_w / global.gui_scale;
var _logical_height = global.gui_height / (global.gui_width / _logical_width);

global.gui_root = new UIElement(0, 0, _logical_width, _logical_height);

// Load hotbar
var _hotbar_def = ui_load("ui/hotbar.ui");
global.ui_hotbar = ui_spawn(_hotbar_def, {
    link: {},
    parent: global.gui_root
}, ["inventory_changed"]);
global.gui_panel_hotbar_modular = global.ui_hotbar;

// Load inventory
var _inventory_def = ui_load("ui/inventory.ui");
global.ui_inventory = ui_spawn(_inventory_def, {
    link: {},
    parent: global.gui_root
}, ["inventory_changed"]);
global.gui_panel_inventory_modular = global.ui_inventory;
global.ui_inventory.visible = false;

// Load crafting
global.ui_crafting_def = ui_load("ui/crafting.ui");
global.ui_crafting_slot_def = ui_load("ui/crafting_slot.ui");
global.ui_crafting = ui_spawn(global.ui_crafting_def, {
    link: {},
    parent: global.gui_root
});
global.ui_crafting.visible = false;
global.gui_panel_crafting_modular = global.ui_crafting.root_elements[0];

// Initialize HUD components (refactored to UIElement)
global.gui_panel_chat = new GUIChatHistory(8, _logical_height - 160, 300, 128, 8);
global.gui_root.add_child(global.gui_panel_chat);

global.gui_panel_choices = new GUIChoicePanel((_logical_width - 300) / 2, _logical_height / 2 - 50, 300);
global.gui_panel_choices.visible = false;
global.gui_root.add_child(global.gui_panel_choices);

global.gui_panel_effects = new GUIEffectPanel(0, 0);
global.gui_panel_effects.offset_x = 16;
global.gui_panel_effects.offset_y = 16;
global.gui_panel_effects.set_anchor("right", "bottom");
global.gui_root.add_child(global.gui_panel_effects);

show_debug_message("[Daydream] New UI system initialized");

// Initialize network globals ONLY if not already in a session
if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE)
{
    relay_manager_init();
}

timer_network_sync = 0;

timer_auto_backup = BACKUP_INTERVAL_SECONDS;
global.async_save_map = {}

inventory_give(obj_Player.x, obj_Player.y, new Inventory("phantasia:arrow", 999))

/* register colorgrade pass once */
__colorgrade_pass_registered = false;