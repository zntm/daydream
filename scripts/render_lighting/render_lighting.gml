#macro SURFACE_LIGHTING_SIZE (1 / 16)

#macro RENDER_LIGHTING_RESIZE 16
#macro RENDER_LIGHTING_PADDING 16

function render_lighting(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _surface_lighting_width  = ceil(_camera_width  / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);
    var _surface_lighting_height = ceil(_camera_height / RENDER_LIGHTING_RESIZE) + (RENDER_LIGHTING_PADDING * 2);

    var _surface_x = round(_camera_x / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;
    var _surface_y = round(_camera_y / RENDER_LIGHTING_RESIZE) * RENDER_LIGHTING_RESIZE;

    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _chunk = chunk_in_view[i];

        if (_chunk != undefined) && (_chunk.boolean & (CHUNK_BOOLEAN.GENERATED | CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH))
        {
            surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;

            break;
        }
    }

    if (_surface_x != obj_Game_Control.surface_lighting_x) || (_surface_y != obj_Game_Control.surface_lighting_y)
    {
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }

    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.LIGHTING)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.LIGHTING;

        obj_Game_Control.surface_lighting_x = _surface_x;
        obj_Game_Control.surface_lighting_y = _surface_y;

        /* cache padding offset once */
        var _padding_offset = RENDER_LIGHTING_PADDING / 2;

        /* create/update per-chunk lighting surfaces */
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];

            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;

            var _needs_update = false;

            if (!surface_exists(_chunk.surface_lighting))
            {
                _chunk.surface_lighting = surface_create(CHUNK_SIZE + RENDER_LIGHTING_PADDING, CHUNK_SIZE + RENDER_LIGHTING_PADDING);

                _needs_update = true;
            }

            if (_chunk.boolean & CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH)
            {
                _chunk.boolean ^= CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;

                _needs_update = true;
            }

            if (!_needs_update) continue;

            surface_set_target(_chunk.surface_lighting);
            draw_clear_alpha(c_black, 1);

            var _chunk_covered = _chunk.chunk_covered;

            var l = 0;

            while (l < CHUNK_SIZE)
            {
                var _data = _chunk_covered[l];

                var _xscale = 1;

                /* skip row entirely if all bits are set (all covered) */
                if (_data != (1 << CHUNK_SIZE) - 1)
                {
                    var _x2 = _padding_offset + l + ((_xscale - 1) / 2);

                    if (_data == 0)
                    {
                        /* entire column uncovered — full white light */
                        draw_sprite_ext(spr_Light, 0, _x2, _padding_offset + CHUNK_SIZE - 1, _xscale, CHUNK_SIZE, 0, c_white, 1);
                    }
                    else
                    {
                        var _c = 0;

                        for (var m = 0; m < CHUNK_SIZE; ++m)
                        {
                            if !(_data & (1 << m))
                            {
                                ++_c;
                            }
                            else if (_c > 0)
                            {
                                draw_sprite_ext(spr_Light, 0, _x2, _padding_offset + m, _xscale, _c, 0, c_white, 1);

                                _c = 0;
                            }
                        }

                        if (_c > 0)
                        {
                            draw_sprite_ext(spr_Light, 0, _x2, _padding_offset + CHUNK_SIZE - 1 - _c, _xscale, _c, 0, c_white, 1);
                        }
                    }
                }

                l += _xscale;
            }

            surface_reset_target();
        }

        if (!surface_exists(surface_lighting))
        {
            surface_lighting = surface_create(_surface_lighting_width, _surface_lighting_height);
        }

        surface_set_target(surface_lighting);
        draw_clear_alpha(c_black, 1);

        gpu_set_blendmode(bm_add);

        /* composite per-chunk sky lighting */
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];

            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;

            if (surface_exists(_chunk.surface_lighting))
            {
                var _x2 = ((_chunk.x - _surface_x) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);
                var _y2 = ((_chunk.y - _surface_y) / RENDER_LIGHTING_RESIZE) - (RENDER_LIGHTING_PADDING / 2);

                draw_surface(_chunk.surface_lighting, _x2, _y2 + 8);
            }
        }

        /* composite point lights additively (color + intensity combined) */
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];

            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;

            var _lights        = _chunk.chunk_lights;
            var _lights_length = array_length(_lights);

            for (var j = 0; j < _lights_length; ++j)
            {
                var _light = _lights[j];

                var _x = ((_light.x + RENDER_LIGHTING_PADDING - _surface_x) / RENDER_LIGHTING_RESIZE);
                var _y = ((_light.y + RENDER_LIGHTING_PADDING - _surface_y) / RENDER_LIGHTING_RESIZE);

                var _xf = floor(_x);
                var _yf = floor(_y);

                var _xnormalized = _x - _xf;
                var _ynormalized = _y - _yf;

                var _xdraw = _xf + 0.5;
                var _ydraw = _yf + 8 + 0.5;

                draw_sprite_ext(spr_Light, 0, _xdraw + 1, _ydraw, 1, 1, 0, _light.image_blend,      (_xnormalized) * 0.5);
                draw_sprite_ext(spr_Light, 0, _xdraw - 1, _ydraw, 1, 1, 0, _light.image_blend, (1 - _xnormalized) * 0.5);

                draw_sprite_ext(spr_Light, 0, _xdraw, _ydraw + 1, 1, 1, 0, _light.image_blend,      (_ynormalized) * 0.5);
                draw_sprite_ext(spr_Light, 0, _xdraw, _ydraw - 1, 1, 1, 0, _light.image_blend, (1 - _ynormalized) * 0.5);
            }
        }

        surface_reset_target();

        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    }

    if (surface_exists(surface_lighting))
    {
        gpu_set_blendmode_ext(bm_dest_colour, bm_zero);

        shader_set(shd_Lighting);

        var _x2 = _surface_x - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2) + TILE_SIZE;
        var _y2 = _surface_y - RENDER_LIGHTING_PADDING - (RENDER_LIGHTING_PADDING / 2) + TILE_SIZE;

        draw_surface_ext(surface_lighting, _x2, _y2, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 0.8);

        gpu_set_tex_filter(true);

        draw_surface_ext(surface_lighting, _x2, _y2, RENDER_LIGHTING_RESIZE, RENDER_LIGHTING_RESIZE, 0, c_white, 1);

        gpu_set_tex_filter(false);

        shader_reset();
    }

    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
}