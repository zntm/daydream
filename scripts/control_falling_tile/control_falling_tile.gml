#macro FALLING_TILE_INITIAL_X_SPREAD  0.15
#macro FALLING_TILE_X_FRICTION        0.92
#macro FALLING_TILE_X_TERMINAL        3.0

/// @desc Control logic for falling tile entities.
/// @function control_falling_tile()
function control_falling_tile()
{
    /* update previous position for interpolation */
    x_previous = x;
    y_previous = y;

    /* apply friction to x velocity manually as it's not a standard input-driven entity */
    physics_body.vel_x *= FALLING_TILE_X_FRICTION;

    if (abs(physics_body.vel_x) < 0.01)
    {
        physics_body.vel_x = 0;
    }

    /* clamp x velocity */
    physics_body.vel_x = clamp(physics_body.vel_x, -FALLING_TILE_X_TERMINAL, FALLING_TILE_X_TERMINAL);

    /* step physics system */
    physics_body.sync_from_instance(id);
    
    physics_step(physics_body, input_state);
    
    physics_body.sync_to_instance(id);

    /* check for landing */
    if (physics_body.collision.ground) || (physics_body.collision.wall_left) || (physics_body.collision.wall_right)
    {
        var _world_x = round(x / TILE_SIZE);
        var _world_y = floor((y - 2) / TILE_SIZE);
        
        /* if we hit a wall but not ground, we might need to nudge to find the landing tile */
        if (!physics_body.collision.ground)
        {
            /* nudge down slightly to see if we're actually above a tile */
            var _check_y = round((y + TILE_SIZE / 2) / TILE_SIZE);
            
            if (_check_y > _world_y)
            {
                _world_y = _check_y;
            }
        }

        /* check if the landing position is available */
        var _existing = tile_get(_world_x, _world_y, tile_z);

        if (_existing == TILE_EMPTY)
        {
            var _new_tile = new Tile(tile_id);

            _new_tile.set_index(tile_index);

            /* copy components if they existed */
            if (tile_components != undefined)
            {
                var _comp_names = struct_get_names(tile_components);

                for (var i = array_length(_comp_names) - 1; i >= 0; --i)
                {
                    var _name = _comp_names[i];

                    if (string_char_at(_name, 1) != "_")
                    {
                        _new_tile.set_component(_name, tile_components.get_component(_name));
                    }
                }
            }

            tile_place(_world_x, _world_y, tile_z, _new_tile);

            event_emit(new EventDataTileFallingLand(_world_x, _world_y, tile_z, _new_tile));

            /* play landing sound */
            var _item_data = global.item_data[$ tile_id];
            var _sfx       = _item_data.get_tile_sfx();

            if (_sfx != undefined)
            {
                var _harvest_sfx = _sfx.get_harvest();

                if (_harvest_sfx != undefined)
                {
                    sfx_diegetic_play(undefined, x, y, _harvest_sfx.get_id(), global.settings.audio_sfx);
                }
            }

            /* spawn landing particles */
            var _harvest = _item_data.get_tile_harvest();

            if (_harvest != undefined)
            {
                var _particle = _harvest.get_particle();

                if (_particle != undefined)
                {
                    var _particle_colour = _particle.get_colours();

                    repeat (4)
                    {
                        spawn_particle(
                            _world_x * TILE_SIZE + random_range(-4, 4),
                            _world_y * TILE_SIZE + random_range(-2, 2),
                            "phantasia:particle/debris",
                            is_array_choose(_particle_colour)
                        );
                    }
                }
            }

            /* rebuild vertex buffer for the landing chunk */
            var _chunk = chunk_map_get(_world_x * TILE_SIZE, _world_y * TILE_SIZE);

            if (_chunk != undefined)
            {
                var _vertex_buffer = _chunk.chunk_vertex_buffer[tile_z];

                if (vertex_buffer_exists(_vertex_buffer))
                {
                    vertex_delete_buffer(_vertex_buffer);
                }
            }

            /* check if tile above the original position should also fall */
            falling_tile_check(_world_x, origin_y - 1, tile_z);

            /* update surrounding tiles for connectivity */
            tile_update_surrounding(_world_x, _world_y, tile_z, 1, 1);
        }
        else
        {
            /* position is blocked - drop as item instead */
            spawn_item_drop(x, y, new Inventory(tile_id, 1));
        }

        instance_destroy();

        exit;
    }

    /* check world bounds */
    var _world_data   = global.world_data[$ global.current_world.dimension];
    var _world_height = _world_data.get_world_height();

    if (y >= _world_height * TILE_SIZE)
    {
        instance_destroy();

        exit;
    }
}
