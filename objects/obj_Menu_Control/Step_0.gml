var _menu_data = global.menu_data;

if (!audio_is_playing(global.menu_music))
{
    var _music = choose_weighted(_menu_data.music);
    
    var _gain = _music.gain;
    
    global.menu_music_gain = _gain;
    global.menu_music = audio_play_sound(global.sound_asset[$ _music.id].get_sound(), 0, false, _gain);
}

// Ensure GUI variables are set (since obj_Game_Control might not be present)
global.gui_width = display_get_gui_width();
global.gui_height = display_get_gui_height();

global.gui_mouse_x = device_mouse_x_to_gui(0);
global.gui_mouse_y = device_mouse_y_to_gui(0);

// Update menu transition animation
menu_transition_update();


/* update proglang ui system */
if (variable_global_exists("gui_root")) && (global.gui_root != undefined)
{
	global.ui_input_consumed = false;
	
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
