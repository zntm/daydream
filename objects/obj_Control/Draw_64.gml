var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

var _gui_width  = display_get_gui_width();
var _gui_height = display_get_gui_height();

render_gui_vignette(_player_y, _gui_width, _gui_height);

draw_text(16, 16,
    $"FPS: {fps}\n" +
    $"X/Y: {_player_x}/{_player_y}\n" +
    $"Num: {instance_number(obj_Chunk)}\n"
);