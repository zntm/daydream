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
    EXIT                = 1 << 6
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
    show_debug_overlay(true);
    
    global.inventory.base[@ 0] = new Inventory("phantasia:water_bucket");
    global.inventory.base[@ 1] = new Inventory("phantasia:lava_bucket");
    global.inventory.base[@ 2] = new Inventory("phantasia:torch");
    
    global.debug_reload = {};
    
    global.dbg_settings = {
        delta_time: true,
        display_background_celestial: true,
        display_background_parallax: true,
        display_chunk_boundary: false,
        display_chunk_information: false,
        instances: true,
        sun_ray: true,
        creature: true,
        lighting: true,
        physics: true,
        camera_size: 1,
        fly_speed: 1,
        // force_surface: "-1",
        // force_cave: "-1",
        time_speed: 1
    };
    
    debug_view = dbg_view("Debug", true, -1, -1, 800, 600);
    debug_text = "";
    
    debug_overlay = "F3 to enable/disable debug overlay";
    
    dbg_text(ref_create(id, "debug_overlay"));
    
    dbg_text_separator("Reload");
    dbg_button("Reload", function()
    {
        // init_data_reload($"{DATAFILES_RESOURCES}/data", "phantasia", INIT_TYPE.OVERRIDE | INIT_TYPE.RESET);
        
        // chat_add("Debug", "Data Reloaded!");
    });
    
    dbg_same_line();
    dbg_button("Select All", function()
    {
        var _names = struct_get_names(global.debug_reload);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            global.debug_reload[$ _names[i]] = true;
        }
    });
    
    dbg_same_line();
    dbg_button("Deselect All", function()
    {
        var _names = struct_get_names(global.debug_reload);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            global.debug_reload[$ _names[i]] = false;
        }
    });
    
    var _names = struct_get_names(global.debug_reload);
    var _length = array_length(_names);
    
    array_sort(_names, sort_alphabetical_descending);
    
    for (var i = 0; i < _length; ++i)
    {
        dbg_checkbox(ref_create(global.debug_reload, _names[i]));
    }
    
    dbg_text_separator("Controls");
    
    dbg_checkbox(ref_create(global.dbg_settings, "delta_time"), "Delta Time");
    
    dbg_text_separator("Display");
    dbg_checkbox(ref_create(global.dbg_settings, "display_background_celestial"), "Display Background");
    dbg_checkbox(ref_create(global.dbg_settings, "display_background_parallax"), "Display Background");
    dbg_checkbox(ref_create(global.dbg_settings, "display_chunk_boundary"),      "Display Chunk Boundary");
    dbg_checkbox(ref_create(global.dbg_settings, "display_chunk_information"),      "Display Chunk Information");
    dbg_checkbox(ref_create(global.dbg_settings, "instances"),  "Display Instances");
    dbg_checkbox(ref_create(global.dbg_settings, "sun_ray"),    "Display Sun Rays");
    
    dbg_text_separator("Config");
    dbg_checkbox(ref_create(global.dbg_settings, "creature"),   "Enable Creature Spawning");
    dbg_checkbox(ref_create(global.dbg_settings, "lighting"),   "Enable Lighting");
    dbg_checkbox(ref_create(global.dbg_settings, "physics"),    "Enable Physics");
    
    dbg_slider(ref_create(global.dbg_settings, "camera_size"), 0.25, 2, "Camera Size", 0.25);
    dbg_slider(ref_create(global.dbg_settings, "fly_speed"), 0.5, 64, "Fly Speed");
    /*
    var _biome_names_surface = array_filter(struct_get_names(global.biome_data), function(_value)
    {
        return (global.biome_data[$ _value].type == BIOME_TYPE.SURFACE);
    });
    
    dbg_drop_down(ref_create(global.dbg_settings, "force_surface"), array_concat([ "-1" ], _biome_names_surface));
    
    var _biome_names_cave = array_filter(struct_get_names(global.biome_data), function(_value)
    {
        return (global.biome_data[$ _value].type == BIOME_TYPE.CAVE);
    });
    
    dbg_drop_down(ref_create(global.dbg_settings, "force_cave"), array_concat([ "-1" ], _biome_names_cave));
    */
    dbg_text_separator("Inventory");
    dbg_button("Random Inventory", function()
    {
        var _item_data = global.item_data;
        
        var _names  = struct_get_names(_item_data);
        var _length = array_length(_names) - 1;
        
        for (var i = 0; i < global.inventory_length.base; ++i)
        {
            var _item_id = _names[irandom(_length)];
            var _data = _item_data[$ _item_id];
            
            var _item = new Inventory(_item_id, _data.get_inventory_max());
            
            var _item_durability = _data.get_item_durability();
            
            if (_item_durability != undefined)
            {
                _item.set_durability(irandom_range(1, _item_durability.get_amount()));
            }
            
            global.inventory.base[@ i] = _item;
        }
        
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
        
        inventory_refresh_craftable(true);
    });
    
    dbg_same_line();
    dbg_button("Clear Inventory", function()
    {
        global.inventory.base = array_create(global.inventory_length.base, INVENTORY_EMPTY);
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
    });
    
    dbg_text_separator("Environment");
    dbg_slider(ref_create(global.world_save_data, "time"), 0, 54_000, "Time");
    dbg_slider(ref_create(global.dbg_settings, "time_speed"), 0, 24, "Time Speed", 0.25);
    
    if (variable_struct_exists(global.world_save_data, "weather_wind"))
    {
        dbg_slider(ref_create(global.world_save_data, "weather_wind"), -1, 1, "Wind");
    }
    
    if (variable_struct_exists(global.world_save_data, "weather_storm"))
    {
        dbg_slider(ref_create(global.world_save_data, "weather_storm"), 0, 1, "Storm");
    }
    
    /*
    debug_section_resources = dbg_section("Resources", false);
    
    var _debug_resources = global.debug_resources;
    var _names2 = global.debug_resources_names;
    var _length2 = array_length(_names2);
    
    for (var i = 0; i < _length2; ++i)
    {
        var _name = _names2[i];
        
        dbg_text_separator(_name, 1);
        
        var _data = _debug_resources[$ _name];
        var _length3 = array_length(_data);
        
        for (var j = 0; j < _length3; j += 2)
        {
            dbg_watch(ref_create(global.debug_resource_counts, $"{_data[j]}Count"), $"{_data[j + 1]} Count");
        }
    }
    */
    
    debug_section_info = dbg_section("Information", false);
    
    dbg_text(ref_create(id, "debug_text"));
}

// Initialize the modular GUI system
gui_init_modular();
