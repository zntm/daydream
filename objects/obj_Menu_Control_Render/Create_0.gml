xoffset = 0;
yoffset = 0;

xscale = 1;
yscale = 1;

surface_index_shader = [ undefined ];
surface_index_boundary = [ undefined ];
surface_index_length = 1;

surfaces = [];

// Initial centering logic (will be updated by obj_Menu_Control on resize)
var _gui_scale = global.gui_scale;
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();

xoffset = (_gui_width / _gui_scale - 960) / 2;
yoffset = (_gui_height / _gui_scale - 540) / 2;

xscale = _gui_scale;
yscale = _gui_scale;

// Fix for stuck transition state when entering game world
if (room == rm_World)
{
    global.menu_transition_phase = 0;
    global.menu_transition_alpha = 1;
    global.menu_transition_scale = 1;
    global.menu_blur_alpha = 0;
}