/// @desc Handles one frame of world generation: acquires chunks, finalises generated chunks, manages loading UI.
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

    for (var i = -_a; i <= _a; ++i)
    {
        var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);

        for (var j = -_b; j <= _b; ++j)
        {
            var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);

            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;

            if (!chunk_map_exists(_x, _y))
            {
                global.chunk_pool.acquire(_x, _y);

                exit;
            }
        }
    }

    control_update_chunk_in_view();

    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _c = chunk_in_view[i];

        if (_c == undefined) || (_c.boolean & CHUNK_BOOL.GENERATED) continue;

        _c.boolean |= CHUNK_BOOL.GENERATED | CHUNK_BOOL.SURFACE_LIGHTING_REFRESH;

        surface_refresh |= SURFACE_REFRESH_BOOL.LIGHTING;

        var _chunk_xstart = _c.chunk_xstart;
        var _chunk_ystart = _c.chunk_ystart;

        var _chunk         = _c.chunk;
        var _chunk_display = _c.chunk_display;

        for (var _tz = CHUNK_DEPTH - 1; _tz >= 0; --_tz)
        {
            if !(_chunk_display & (1 << _tz)) continue;

            for (var _ty = CHUNK_SIZE - 1; _ty >= 0; --_ty)
            {
                for (var _tx = CHUNK_SIZE - 1; _tx >= 0; --_tx)
                {
                    var _x = _chunk_xstart + _tx;
                    var _y = _chunk_ystart + _ty;

                    var _tile = _chunk[tile_index_xyz(_x, _y, _tz)];

                    if (_tile == TILE_EMPTY) continue;

                    tile_instance_create(_x, _y, _tz, _tile);

                    tile_connect(_x, _y, _tz, _tile);
                }
            }
        }
    }

    if (variable_instance_exists(obj_Game_Control, "ui_loading")) && (obj_Game_Control.ui_loading != undefined)
    {
        ui_instance_destroy(obj_Game_Control.ui_loading);

        obj_Game_Control.ui_loading = undefined;
    }

    obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.GENERATING_WORLD;
}
