/// @desc Handles one frame of world generation: acquires chunks, advances queued generation, manages loading UI.
function control_game_world_generate()
{
    var _camera_x = global.camera_x_real;
    var _camera_y = global.camera_y_real;

    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;

    var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;

    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;

    var _world_data   = global.world_data[$ global.current_world.dimension];
    var _world_height = _world_data.get_world_height();
    var _acquired_one = false;

    for (var i = -_a; i <= _a; ++i)
    {
        var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);

        for (var j = -_b; j <= _b; ++j)
        {
            var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);

            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;

            if (!chunk_map_exists(_x, _y))
            {
                global.chunk_pool.acquire(_x, _y, true);
                _acquired_one = true;
                break;
            }
        }

        if (_acquired_one) break;
    }

    control_update_chunk_in_view();

    var _focus_x = _camera_x + (_camera_width / 2);
    var _focus_y = _camera_y + (_camera_height / 2);

    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];

        if (_c == undefined) || (_c.boolean & (CHUNK_BOOL.GENERATED | CHUNK_BOOL.QUEUED)) continue;

        chunk_queue_add(_c, point_distance(_focus_x, _focus_y, _c.xcenter, _c.ycenter));
    }

    chunk_queue_process(_focus_x, _focus_y);

    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _c = chunk_in_view[i];

        if (_c == undefined)
        {
            exit;
        }

        if ((_c.boolean & (CHUNK_BOOL.GENERATED | CHUNK_BOOL.TILE_PROCESSED)) != (CHUNK_BOOL.GENERATED | CHUNK_BOOL.TILE_PROCESSED))
        {
            exit;
        }
    }

    if (variable_instance_exists(obj_Game_Control, "ui_loading")) && (obj_Game_Control.ui_loading != undefined)
    {
        ui_instance_destroy(obj_Game_Control.ui_loading);

        obj_Game_Control.ui_loading = undefined;
    }

    obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.GENERATING_WORLD;
}
