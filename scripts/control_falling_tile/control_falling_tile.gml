/// @desc Control logic for falling tile entities
/// @function control_falling_tile(_dt)
/// @param {real} _dt Delta time

function control_falling_tile(_dt)
{
    // Handle fall delay
    if (fall_delay > 0)
    {
        fall_delay -= _dt / GAME_TICK;
        exit;
    }
    
    // Apply gravity
    yvelocity += gravity_value * _dt;
    
    // Cap at terminal velocity
    if (yvelocity > PHYSICS_TERMINAL_YVELOCITY)
    {
        yvelocity = PHYSICS_TERMINAL_YVELOCITY;
    }
    
    // Calculate new position
    var _new_y = y + (yvelocity * _dt);
    
    // Check for collision with solid tiles below
    var _world_x = floor(x / TILE_SIZE);
    var _world_y_current = floor(y / TILE_SIZE);
    var _world_y_new = floor(_new_y / TILE_SIZE);
    
    var _landed = false;
    var _land_y = _world_y_new;
    
    // Check each tile position we're passing through
    for (var _check_y = _world_y_current; _check_y <= _world_y_new; _check_y++)
    {
        // Check for solid tile at this position
        var _has_solid = false;
        
        for (var z = 0; z < CHUNK_DEPTH; z++)
        {
            var _tile_below = tile_get(_world_x, _check_y + 1, z);
            
            if (_tile_below != TILE_EMPTY)
            {
                var _data = global.item_data[$ _tile_below.get_id()];
                
                if (_data.get_type() & (ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM))
                {
                    _has_solid = true;
                    break;
                }
            }
        }
        
        if (_has_solid)
        {
            _landed = true;
            _land_y = _check_y;
            break;
        }
    }
    
    if (_landed)
    {
        // Check if the landing position is valid (not occupied)
        var _existing = tile_get(_world_x, _land_y, tile_z);
        
        if (_existing == TILE_EMPTY)
        {
            // Place the tile at landing position
            var _new_tile = new Tile(tile_id);
            _new_tile.set_index(tile_index);
            
            // Copy components if they existed
            if (tile_components != undefined)
            {
                var _comp_names = struct_get_names(tile_components);
                for (var i = 0; i < array_length(_comp_names); i++)
                {
                    var _name = _comp_names[i];
                    if (string_char_at(_name, 1) != "_")  // Skip private fields
                    {
                        _new_tile.set_component(_name, tile_components.get_component(_name));
                    }
                }
            }
            
            tile_place(_world_x, _land_y, tile_z, _new_tile);
            
            // Emit event
            event_emit(GAME_EVENT.TILE_CHANGED, {
                x: _world_x,
                y: _land_y,
                z: tile_z,
                id: tile_id,
                action: "fall_land"
            });
            
            // Play landing sound
            var _data = global.item_data[$ tile_id];
            var _sfx = _data.get_sfx();
            if (_sfx != undefined)
            {
                sfx_diegetic_play(undefined, x, y, _sfx.get_id(), _sfx.get_gain(), global.settings.audio_sfx);
            }
            
            // Spawn landing particles
            var _harvest = _data.get_harvest();
            if (_harvest != undefined)
            {
                var _particle = _harvest.get_particle();
                if (_particle != undefined)
                {
                    for (var p = 0; p < 4; p++)
                    {
                        spawn_particle(
                            x + random_range(-4, 4),
                            y + random_range(-2, 2),
                            "phantasia:particle/debris",
                            _particle.get_colour()
                        );
                    }
                }
            }
            
            // Check if tile above should also fall
            falling_tile_check(_world_x, origin_y - 1, tile_z);
        }
        else
        {
            // Position is blocked - drop as item instead
            spawn_item_drop(x, y, tile_id, 1);
        }
        
        instance_destroy();
        exit;
    }
    
    // Check world bounds
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    if (_world_y_new >= _world_height)
    {
        // Fell out of world - just destroy
        instance_destroy();
        exit;
    }
    
    // Move to new position
    y = _new_y;
}
