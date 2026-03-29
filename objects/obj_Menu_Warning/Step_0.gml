var _delta_time = delta_time / 1_000_000;

global.delta_time = _delta_time;

if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
{
    global.gui_root = ui_create_root();
    global.gui_root.element_name = "gui_root";
}

if (!variable_instance_exists(id, "ui_warning")) || (ui_warning == undefined)
{
    if (variable_global_exists("ui_warning_screen")) && (global.ui_warning_screen != undefined)
    {
        ui_destroy(global.ui_warning_screen);
    }

    ui_invalidate_definition("ui/menu/warning.ui");

    var _warning_def = ui_load("ui/menu/warning.ui");

    if (_warning_def != undefined)
    {
        var _warning_link = {
            header: method(id, function() { return text_header; }),
            description: method(id, function() { return text_description; })
        }

        ui_warning = ui_spawn(_warning_def, {
            link: _warning_link,
            parent: global.gui_root
        });

        global.ui_warning_screen = ui_warning;
    }
}

if (ui_warning != undefined)
{
    global.ui_input_consumed = false;
    global.ui_hover_consumed = false;

    ui_update(ui_warning);
}

if (!instance_exists(obj_Menu_Fade))
{
    timer += _delta_time;
    
    if (timer > transition_seconds) || (keyboard_check_pressed(vk_anykey))
    {
        var _transition_room = transition_room;
        
        with (instance_create_layer(0, 0, "Instances", obj_Menu_Fade))
        {
            image_alpha = 0;
            
            transition_speed = MENU_TRANSITION_FADE_SPEED;
            transition_room = _transition_room;
        }
    }
}

for (var i = 0; i < glow_length; ++i)
{
    var _glow = glow[i];
    
    _glow.x += _glow.xvelocity * _delta_time;
    _glow.y += _glow.yvelocity * _delta_time;
}
