randomize();

is_opened_inventory = false;

enum SURFACE_REFRESH_BOOLEAN {
    INVENTORY = 1
}

surface_refresh = SURFACE_REFRESH_BOOLEAN.INVENTORY;

show_debug_overlay(true);

global.delta_time = 1;

var _world_data = global.world_data[$ "phantasia:playground"];

global.world = {
    seed: random_get_seed(),
    dimension: "phantasia:playground",
    time: _world_data.get_time_start(),
    wind: random_range(-1, 1)
}

obj_Player.y = (worldgen_get_surface_height(0, global.world.seed) - 1) * TILE_SIZE;

global.inventory_selected_hotbar = 0;

surface_inventory = {
    tooltip: {
        surface: 0,
        surface_width: 0,
        surface_height: 0,
        type: "",
        index: -1
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
    craftable: {
        surface_item: -1,
        surface_slot: -1
    },
    container: {
        surface_item: -1,
        surface_slot: -1
    }
}

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

var _camera_x = obj_Player.x - (_camera_width  / 2);
var _camera_y = obj_Player.y - (_camera_height / 2);

var _gui_scale = 1;

var _gui_width  = round(_gui_scale * window_get_width());
var _gui_height = round(_gui_scale * window_get_height());

global.camera_width  = _camera_width;
global.camera_height = _camera_height;

global.camera_x = _camera_x;
global.camera_y = _camera_y;

global.camera_x_real = _camera_x;
global.camera_y_real = _camera_y;

global.gui_scale = _gui_scale;

global.gui_width  = _gui_width;
global.gui_height = _gui_height;

global.gui_mouse_x = 0;
global.gui_mouse_y = 0;

control_camera_pos(_camera_x, _camera_y);
camera_set_view_size(view_camera[0], _camera_width, _camera_height);

global.structure_range_surface = {
    min:  infinity,
    max: -infinity
}

window_width  = window_get_width();
window_height = window_get_height();

window_focus = true;

init_inventory_instance();

game_set_speed(display_get_frequency(), gamespeed_fps);

var _splash_data = global.splash_data;
var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];

window_set_caption($"{PROGRAM_NAME}: {array_choose(((chance(0.5)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data[$ "default"])}");