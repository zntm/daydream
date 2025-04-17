var _player_x = obj_Player.x;
var _player_y = obj_Player.y;

if (keyboard_check_pressed(ord("R")))
{
    room_restart();
}

if (keyboard_check_pressed(vk_escape))
{
    game_end();
}

if (keyboard_check_pressed(vk_f11))
{
    window_set_fullscreen(!window_get_fullscreen());
}

var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height);

var _collect = false;

with (obj_Chunk)
{
    var _x1 = x - (TILE_SIZE / 2);
    var _y1 = y - (TILE_SIZE / 2);
    var _x2 = _x1 + CHUNK_SIZE_DIMENSION;
    var _y2 = _y1 + CHUNK_SIZE_DIMENSION;
    
    var _is_in_view = rectangle_in_rectangle(_x1, _y1, _x2, _y2, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height);
    
    if (!_is_in_view)
    {
        if (chunk_surface_display) && (chunk_render) && (!rectangle_in_rectangle(_x1, _y1, _x2, _y2, _camera_x - (CHUNK_SIZE_DIMENSION * 4), _camera_y - (CHUNK_SIZE_DIMENSION * 4), _camera_x + _camera_width + (CHUNK_SIZE_DIMENSION * 4), _camera_y + _camera_height + (CHUNK_SIZE_DIMENSION * 4)))
        {
            for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
            {
                var _vertex_buffer = chunk_vertex_buffer[_z];
                
                if (vertex_buffer_exists(_vertex_buffer))
                {
                    _collect = true;
                    
                    vertex_delete_buffer(_vertex_buffer);
                }
            }
            
            instance_destroy();
            
            continue;
        }
    }
    
    is_in_view = _is_in_view;
}

if (_collect)
{
    gc_collect();
}