var _menu_data = global.menu_data;

if (!audio_is_playing(global.menu_music))
{
    var _music = choose_weighted(_menu_data.music);
    
    var _gain = _music.gain;
    
    global.menu_music_gain = _gain;
    global.menu_music = audio_play_sound(global.sound_asset[$ _music.id].get_sound(), 0, false, _gain);
}

var _sh = global.window_height;
var _s  = _sh / 540;

/* transition scale & offset */
var _t_scale  = global.menu_transition_scale ?? 1;
var _t_ox     = (global.window_width / 2) * (1 - _t_scale);
var _t_oy     = (_sh / 2) * (1 - _t_scale);

global.gui_mouse_x = (window_mouse_get_x() - _t_ox) / (_t_scale * _s);
global.gui_mouse_y = (window_mouse_get_y() - _t_oy) / (_t_scale * _s);

// Update menu transition animation
menu_transition_update();

/* update proglang ui system (skip when editor is active to block input) */
var _ui_editor_active = (variable_global_exists("ui_editor")) && (global.ui_editor != undefined) && (global.ui_editor.active);

if (variable_global_exists("gui_root")) && (global.gui_root != undefined) && (!_ui_editor_active)
{
	global.ui_input_consumed = false;
	global.ui_hover_consumed = false;
	
	global.gui_root.update();
	
	
	/* update dynamically spawned UI instances (unparented ones) */
	if (variable_global_exists("ui_instances"))
	{
		var _ui_keys = struct_get_names(global.ui_instances);
		var _ui_count = array_length(_ui_keys);
		
		
		for (var i = _ui_count - 1; i >= 0; --i)
		{
			var _ui_inst = global.ui_instances[$ _ui_keys[i]];
			
			
			if (_ui_inst != undefined) && (array_length(_ui_inst.root_elements) > 0) && (_ui_inst.root_elements[0].parent == undefined)
			{
				ui_update(_ui_inst);
			}
		}
	}
	
	ui_clear_events();
}

/* ui editor toggle (dev mode only) */
if (IS_DEVELOPER_MODE)
{
    if (!variable_global_exists("ui_editor")) || (global.ui_editor == undefined)
    {
        ui_editor_init();
    }

    if (keyboard_check_pressed(vk_f4))
    {
        ui_editor_toggle();
    }

    ui_editor_step();
}
