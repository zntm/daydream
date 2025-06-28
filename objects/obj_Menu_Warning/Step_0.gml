var _delta_time = delta_time / 1_000_000;

global.delta_time = _delta_time;

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