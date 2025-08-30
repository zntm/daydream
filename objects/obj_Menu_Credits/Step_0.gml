if (keyboard_check_pressed(vk_escape))
{
    room_goto(rm_Menu_Title);
}

var _delta_time = (delta_time / 1_000_000) * game_get_speed(gamespeed_fps);

var _string_height = font_get_size(draw_get_font()) + 8;

var _x = room_width / 2;
var _y = room_height + list_offset;

var _ystart = room_height * 0.25;
var _yend   = room_height * 0.75;

var _credit_data = global.credit_data;

var _offset = 0;

var _length = array_length(_credit_data);

for (var i = 0; i < _length; ++i)
{
    var _credits = _credit_data[i];
    
    var _colour = _credits.colour;
    
    _offset += _string_height;
    
    var _y2 = _y + _offset;
    
    if (_y2 > _ystart) && (_y2 < _yend)
    {
        hue = lerp_delta(hue, colour_get_hue(_colour), 0.02, _delta_time);
    }
    
    _offset += _credits.entries_length * _string_height * 0.8;
}

if (_y + _offset <= 0)
{
    room_goto(rm_Menu_Title);
    
    is_escaping = true;
}
else
{
    var _wheel = ((mouse_wheel_up()) || (keyboard_check(vk_up))) - ((mouse_wheel_down()) || (keyboard_check(vk_down)));
    
    if (_wheel != 0)
    {
        scroll_speed = _wheel * 8;
    }
    else
    {
        list_offset -= _delta_time * 0.3;
    }
    
    scroll_speed = lerp_delta(scroll_speed, 0, 0.2, _delta_time);
    
    list_offset += scroll_speed;
}