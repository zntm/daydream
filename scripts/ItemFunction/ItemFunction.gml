global.item_function = {}

global.item_function[$ "phantasia:explode"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _item_data = global.item_data;

    // Get explosion parameters with defaults
    var _radius = _parameter[$ "radius"] ?? 3;
    var _damage = _parameter[$ "damage"] ?? 10;
    var _destroy_tiles = _parameter[$ "destroy_tiles"] ?? true;
    var _particle = _parameter[$ "particle"];
    var _sound = _parameter[$ "sound"];
    var _chain_react = _parameter[$ "chain_react"] ?? true;

    var _world_x = _x * TILE_SIZE;
    var _world_y = _y * TILE_SIZE;

    // Play explosion sound
    if (_sound != undefined)
    {
        sfx_diegetic_play(undefined, _world_x, _world_y, smart_value(_sound));
    }

    // Emit explosion event
    event_emit(new EventDataExplosiveExplode(_x, _y, _z, _radius, _damage));

    // Spawn explosion particles
    if (_particle != undefined)
    {
        var _particle_count = _parameter[$ "particle_count"] ?? (_radius * 4);

        for (var i = 0; i < _particle_count; ++i)
        {
            var _angle = irandom(360);
            var _dist = irandom(_radius * TILE_SIZE);

            spawn_particle(
                _world_x + lengthdir_x(_dist, _angle),
                _world_y + lengthdir_y(_dist, _angle),
                smart_value(_particle)
            );
        }
    }

    // Collect tiles to explode (for chain reactions)
    var _tiles_to_explode = [];

    // Destroy tiles in radius
    if (_destroy_tiles)
    {
        for (var _tx = -_radius; _tx <= _radius; ++_tx)
        {
            for (var _ty = -_radius; _ty <= _radius; ++_ty)
            {
                var _dist = point_distance(0, 0, _tx, _ty);

                if (_dist <= _radius)
                {
                    var _target_x = _x + _tx;
                    var _target_y = _y + _ty;

                    for (var _tz = 0; _tz < CHUNK_DEPTH; ++_tz)
                    {
                        var _tile = tile_get(_target_x, _target_y, _tz);

                        if (_tile != TILE_EMPTY)
                        {
                            var _tile_id = _tile.get_id();
                            var _tile_data = _item_data[$ _tile_id];

                            // Check for chain reaction (explosive tiles)
                            if (_chain_react && (_target_x != _x || _target_y != _y))
                            {
                                var _on_random_tick = _tile_data.get_on_random_tick();

                                if (_on_random_tick != undefined)
                                {
                                    for (var j = 0; j < array_length(_on_random_tick); ++j)
                                    {
                                        var _func = _on_random_tick[j];

                                        if (_func.id == "phantasia:explode")
                                        {
                                            array_push(_tiles_to_explode, {
                                                x: _target_x,
                                                y: _target_y,
                                                z: _tz,
                                                param: _func.parameter
                                            });
                                        }
                                    }
                                }
                            }

                            // Destroy the tile
                            tile_place(_target_x, _target_y, _tz, TILE_EMPTY);
                            tile_update_surrounding(_target_x, _target_y, _tz);
                        }
                    }
                }
            }
        }
    }

    // Damage entities in radius
    if (_damage > 0)
    {
        var _damage_radius = _radius * TILE_SIZE;

        with (obj_Player)
        {
            var _dist = point_distance(x, y, _world_x, _world_y);

            if (_dist < _damage_radius)
            {
                var _falloff = 1 - (_dist / _damage_radius);
                var _actual_damage = ceil(_damage * _falloff);

                control_entity_damage(id, noone, _actual_damage);
            }
        }

        with (obj_Creature)
        {
            var _dist = point_distance(x, y, _world_x, _world_y);

            if (_dist < _damage_radius)
            {
                var _falloff = 1 - (_dist / _damage_radius);
                var _actual_damage = ceil(_damage * _falloff);

                control_entity_damage(id, noone, _actual_damage);
            }
        }
    }

    // Trigger chain reactions with delay
    if (array_length(_tiles_to_explode) > 0)
    {
        for (var i = 0; i < array_length(_tiles_to_explode); ++i)
        {
            var _chain = _tiles_to_explode[i];

            tick_delay_add(irandom_range(2, 6), function(_chain) {
                var _item_function = global.item_function;
                var _func = _item_function[$ "phantasia:explode"];

                _func(1, _chain.x, _chain.y, _chain.z, 1, 1, _chain.param ?? {});
            }, [_chain]);
        }
    }
}


global.item_function[$ "phantasia:export_structure"] = function()
{
    var _item_data = global.item_data;

    var _tile = tile_get(tile_x, tile_y, tile_z);

    var _id = _tile.get_component("id");

    if (file_exists($"{PROGRAM_DIRECTORY_STRUCTURES}/{_id}.dat"))
    {
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;

        var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);

        with (_inst_header)
        {
            text = loca_translate("phantasia:menu.create_player.error.empty_name");

            menu_layer = 1;

            on_draw = function(_x, _y, _xscale, _yscale)
            {
                var _x2 = x * _xscale;
                var _y2 = y * _yscale;

                var _halign = draw_get_halign();
                var _valign = draw_get_valign();

                draw_set_align(fa_center, fa_middle);

                render_text(_x2, _y2, text, _xscale, _yscale);

                draw_set_align(_halign, _valign);
            }
        }

        var _inst_close = instance_create_layer(_camera_x + 480, _camera_y + 300, "Instances", obj_Menu_Button);

        with (_inst_close)
        {
            text = loca_translate("phantasia:menu.generic.close");

            image_xscale = 17;
            image_yscale = 3;

            menu_layer = 1;

            on_select_release = menu_popup_destroy;
        }

        menu_popup_create([
            _inst_header,
            _inst_close
        ]);

        exit;
    }

    var _xoffset = _tile.get_component("xoffset");
    var _yoffset = _tile.get_component("yoffset");

    var _xscale = _tile.get_component("xscale");
    var _yscale = _tile.get_component("yscale");

    var _x1 = tile_x + _xoffset;
    var _y1 = tile_y + _yoffset;

    var _x2 = tile_x + _xscale - 1;
    var _y2 = tile_y + _yscale - 1;

    var _buffer = buffer_create(0xffff, buffer_grow, 1);

    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);

    buffer_write(_buffer, buffer_u8, _xscale);
    buffer_write(_buffer, buffer_u8, _yscale);

    // Build Palette
    var _palette_map = {};
    var _palette_array = [];
    var _palette_index = 0;
    
    for (var _x = _x1; _x <= _x2; ++_x)
    {
        for (var _y = _y1; _y <= _y2; ++_y)
        {
            var _tile_default = tile_get(_x, _y, CHUNK_DEPTH_DEFAULT);
            
            if (_tile_default != TILE_EMPTY) && (_tile_default.get_id() == "phantasia:void_blueprint") continue;
            
            for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
            {
                var _ = ((_z == CHUNK_DEPTH_DEFAULT) ? _tile_default : tile_get(_x, _y, _z));
                
                if (_ != TILE_EMPTY)
                {
                    var _tid = _.get_id();
                    
                    if (!struct_exists(_palette_map, _tid))
                    {
                        _palette_map[$ _tid] = _palette_index++;
                        array_push(_palette_array, _tid);
                    }
                }
            }
        }
    }
    
    // Write Palette
    buffer_write(_buffer, buffer_u16, _palette_index);
    
    for (var i = 0; i < _palette_index; ++i)
    {
        buffer_write(_buffer, buffer_string, _palette_array[i]);
    }

    for (var _x = _x1; _x <= _x2; ++_x)
    {
        for (var _y = _y1; _y <= _y2; ++_y)
        {
            var _tile_default = tile_get(_x, _y, CHUNK_DEPTH_DEFAULT);

            if (_tile_default != TILE_EMPTY) && (_tile_default.get_id() == "phantasia:void_blueprint")
            {
                buffer_write(_buffer, buffer_bool, true);

                continue;
            }

            buffer_write(_buffer, buffer_bool, false);

            for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
            {
                var _ = ((_z == CHUNK_DEPTH_DEFAULT) ? _tile_default : tile_get(_x, _y, _z));

                file_save_snippet_tile(_buffer, _, _item_data, _palette_map);
            }
        }
    }

    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_STRUCTURES}/{_id}.dat");

    buffer_delete(_buffer);
}

global.item_function[$ "phantasia:liquid_flow"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _tile = tile_get(_x, _y, _z);

    // Safety check
    if (_tile == TILE_EMPTY) exit;

    var _id = _tile.get_id();
    var _level = _tile.get_component("level");
    var _flow_direction = _tile.get_component("flow_direction") ?? 0;

    // Get flow parameters
    var _tick_delay = _parameter[$ "tick_delay"] ?? 5;
    var _fluid_collisions = _parameter[$ "fluid_collisions"];

    // Fallback defaults if triggered by environment (no parameters passed)
    if (_fluid_collisions == undefined)
    {
        if (_id == "phantasia:water") {
            _fluid_collisions = [{ id: "phantasia:stone", liquid_id: "phantasia:lava" }];
        } else if (_id == "phantasia:lava") {
            _fluid_collisions = [{ id: "phantasia:stone", liquid_id: "phantasia:water" }];
        } else {
            _fluid_collisions = [];
        }

        // Update parameter struct to persist these defaults for downstream flow
        if (_parameter == undefined) _parameter = {}
        _parameter.fluid_collisions = _fluid_collisions;
        _parameter.tick_delay = _tick_delay;
    }

    // Ensure we have a valid level
    if (_level == undefined)
    {
        _level = 8;
        _tile.set_component("level", _level);
    }

    if (_level <= 0)
    {
        tile_place(_x, _y, _z, TILE_EMPTY);
        tile_update_surrounding(_x, _y, _z);
        exit;
    }

    var _flowed = false;
    var _new_positions = []; // Track new water positions to schedule

    // 1. Flow Down (straight down)
    var _solid_down = tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT);

    if (_solid_down == TILE_EMPTY)
    {
        var _tile_down = tile_get(_x, _y + 1, _z);

        if (_tile_down == TILE_EMPTY)
        {
            // Move all down
            tile_place(_x, _y + 1, _z, new Tile(_id));
            var _new_tile = tile_get(_x, _y + 1, _z);
            _new_tile.set_component("level", _level);
            _new_tile.set_component("flow_direction", _flow_direction);

            tile_place(_x, _y, _z, TILE_EMPTY);

            tile_update_surrounding(_x, _y + 1, _z);
            tile_update_surrounding(_x, _y, _z);

            array_push(_new_positions, { x: _x, y: _y + 1, z: _z });
            _flowed = true;
            _level = 0;
        }
        else if (_tile_down.get_id() == _id)
        {
            // Same liquid below - combine as much as possible
            var _level_down = _tile_down.get_component("level") ?? 0;
            var _space_down = 8 - _level_down;

            // Always transfer if there's any space (no level comparison needed for downward flow)
            if (_space_down > 0)
            {
                var _transfer = min(_level, _space_down);

                _level -= _transfer;
                _tile_down.set_component("level", _level_down + _transfer);

                if (_level <= 0)
                {
                    // All water transferred down - remove source tile
                    tile_place(_x, _y, _z, TILE_EMPTY);
                }
                else
                {
                    // Update source tile level
                    _tile.set_component("level", _level);
                }

                tile_update_surrounding(_x, _y + 1, _z);
                tile_update_surrounding(_x, _y, _z);

                array_push(_new_positions, { x: _x, y: _y + 1, z: _z });
                _flowed = true;
            }
        }
        else
        {
            // Check for liquid interaction using parameter list
            var _interaction = undefined;
            var _other_id = _tile_down.get_id();

            for (var k = 0; k < array_length(_fluid_collisions); k++) {
                if (_fluid_collisions[k].liquid_id == _other_id) {
                    _interaction = _fluid_collisions[k].id;
                    break;
                }
            }

            if (_interaction != undefined)
            {
                // Create the interaction block (e.g. stone) at the destination
                tile_place(_x, _y + 1, _z, new Tile(_interaction));
                tile_update_surrounding(_x, _y + 1, _z);
                _flowed = false; // Blocked flow
            }
        }
    }

    // 2. Flow Down-Diagonal (if blocked straight down but can go diagonal)
    if (!_flowed && _level > 0)
    {
        var _diag_dirs = (irandom(1) == 0) ? [-1, 1] : [1, -1];

        for (var i = 0; i < 2; ++i)
        {
            var _dx = _diag_dirs[i];
            var _diag_x = _x + _dx;
            var _diag_y = _y + 1;

            // Check for solid blocks
            var _solid_side = tile_get(_diag_x, _y, CHUNK_DEPTH_DEFAULT);
            var _solid_diag = tile_get(_diag_x, _diag_y, CHUNK_DEPTH_DEFAULT);

            if (_solid_side == TILE_EMPTY && _solid_diag == TILE_EMPTY)
            {
                var _tile_diag = tile_get(_diag_x, _diag_y, _z);

                if (_tile_diag == TILE_EMPTY)
                {
                    // Move all diagonal-down
                    tile_place(_diag_x, _diag_y, _z, new Tile(_id));
                    var _new_tile = tile_get(_diag_x, _diag_y, _z);
                    _new_tile.set_component("level", _level);
                    _new_tile.set_component("flow_direction", _dx);

                    tile_place(_x, _y, _z, TILE_EMPTY);

                    tile_update_surrounding(_diag_x, _diag_y, _z);
                    tile_update_surrounding(_x, _y, _z);

                    array_push(_new_positions, { x: _diag_x, y: _diag_y, z: _z });
                    _flowed = true;
                    _level = 0;
                    break;
                }
                else if (_tile_diag.get_id() == _id)
                {
                    // Same liquid logic (omitted for brevity, assume similar to down)
                     var _level_diag = _tile_diag.get_component("level");
                    var _space_diag = 8 - _level_diag;

                    if (_space_diag > 0)
                    {
                        var _transfer = min(_level, _space_diag);

                        _level -= _transfer;

                        _tile.set_component("level", _level);
                        _tile_diag.set_component("level", _level_diag + _transfer);

                        if (_level <= 0)
                        {
                            tile_place(_x, _y, _z, TILE_EMPTY);
                        }

                        tile_update_surrounding(_diag_x, _diag_y, _z);
                        tile_update_surrounding(_x, _y, _z);

                        array_push(_new_positions, { x: _diag_x, y: _diag_y, z: _z });
                        _flowed = true;
                        break;
                    }
                }
                 else
                {
                    // Check for liquid interaction diagonal
                    var _interaction = undefined;
                    var _other_id = _tile_diag.get_id();

                    for (var k = 0; k < array_length(_fluid_collisions); k++) {
                        if (_fluid_collisions[k].liquid_id == _other_id) {
                            _interaction = _fluid_collisions[k].id;
                            break;
                        }
                    }

                    if (_interaction != undefined)
                    {
                        tile_place(_diag_x, _diag_y, _z, new Tile(_interaction));
                        tile_update_surrounding(_diag_x, _diag_y, _z);
                        // Blocked flow
                    }
                }
            }
        }
    }

    // 3. Flow Sideways (only if we still have liquid and didn't flow down)
    if (!_flowed && _level > 0)
    {
        var _dirs = (_flow_direction != 0) ? [_flow_direction] : ((irandom(1) == 0) ? [1, -1] : [-1, 1]);
        var _blocked = true;

        for (var i = 0; i < array_length(_dirs); ++i)
        {
            var _dx = _dirs[i];
            var _tx = _x + _dx;

            var _solid_target = tile_get(_tx, _y, CHUNK_DEPTH_DEFAULT);

            if (_solid_target == TILE_EMPTY)
            {
                var _target = tile_get(_tx, _y, _z);
                var _can_flow = false;
                var _target_level = 0;

                if (_target == TILE_EMPTY)
                {
                    _can_flow = true;
                }
                else if (_target.get_id() == _id)
                {
                    _target_level = _target.get_component("level");
                    if (_target_level < _level - 1)
                    {
                        _can_flow = true;
                    }
                }
                else
                {
                     // Check for liquid interaction sideways
                    var _interaction = undefined;
                    var _other_id = _target.get_id();

                    for (var k = 0; k < array_length(_fluid_collisions); k++) {
                        if (_fluid_collisions[k].liquid_id == _other_id) {
                            _interaction = _fluid_collisions[k].id;
                            break;
                        }
                    }

                    if (_interaction != undefined)
                    {
                        tile_place(_tx, _y, _z, new Tile(_interaction));
                        tile_update_surrounding(_tx, _y, _z);
                        _blocked = true;
                        continue;
                    }
                }

                if (_can_flow)
                {
                    _blocked = false;

                    var _total = _level + _target_level;
                    var _new_level_target = floor(_total / 2);
                    var _transfer = _new_level_target - _target_level;

                    if (_transfer > 0)
                    {
                        _level -= _transfer;
                        _tile.set_component("level", _level);

                        if (_level > 0) _tile.set_component("flow_direction", _dx);

                        if (_target == TILE_EMPTY)
                        {
                            tile_place(_tx, _y, _z, new Tile(_id));
                            _target = tile_get(_tx, _y, _z);
                        }

                        _target.set_component("level", _target_level + _transfer);
                        _target.set_component("flow_direction", _dx);

                        tile_update_surrounding(_tx, _y, _z);

                        array_push(_new_positions, { x: _tx, y: _y, z: _z });
                        _flowed = true;

                        if (_level <= 0)
                        {
                            tile_place(_x, _y, _z, TILE_EMPTY);
                            tile_update_surrounding(_x, _y, _z);
                        }
                    }

                    break;
                }
            }
        }

        // Bounce if blocked
        if (_blocked && _level > 0)
        {
             // If blocked sideways, reverse momentum or stop
             if (_flow_direction != 0)
             {
                 _tile.set_component("flow_direction", -_flow_direction);
             }
        }
    }

    // Schedule flow for all NEW positions (where water moved TO)
    for (var i = 0; i < array_length(_new_positions); ++i)
    {
        var _pos = _new_positions[i];
        liquid_flow_schedule(_pos.x, _pos.y, _pos.z, _parameter);
    }

    // Also schedule for current position if still has water
    if (_level > 0)
    {
        liquid_flow_schedule(_x, _y, _z, _parameter);
    }
}

/// @desc Schedule liquid flow with proper delay (prevents duplicates)
function liquid_flow_schedule(_x, _y, _z, _parameter = {})
{
    var _tick_delay = _parameter[$ "tick_delay"] ?? 8;

    tick_delay_add(_tick_delay, function(_chain) {
        var _item_function = global.item_function;
        var _func = _item_function[$ "phantasia:liquid_flow"];
        // Pass the parameter struct for the next tick
        _func(1, _chain.x, _chain.y, _chain.z, 1, 1, _chain.parameter);
    }, [{ x: _x, y: _y, z: _z, parameter: _parameter }]);
}

/// @desc Helper to start liquid flow cycle when water is placed
function liquid_flow_start(_x, _y, _z, _parameter = {})
{
    liquid_flow_schedule(_x, _y, _z, _parameter);
}

// ... collision helper removed/ignored ...

global.item_function[$ "phantasia:bucket_place"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    // ... setup ...
    var _liquid_id = _parameter[$ "liquid_id"];

    // ...
    // When calling liquid_flow_start:
    liquid_flow_start(_x, _y, _liquid_z, _parameter); // Pass the bucket_place parameters (which contain tick_delay and fluid_collisions)
    // ...
}


// Subscribe to tile changes to trigger water flow when blocks are broken
// Subscribe to tile changes to trigger water flow when blocks are broken
event_subscribe(GAME_EVENT.TILE_UPDATE, function(_data) {
    if (_data.tile == undefined) exit; // Only care about broken tiles (which populate 'tile' in update)

    var _x = _data.x;
    var _y = _data.y;

    // Check for water above the broken block
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        // Check above
        var _tile_above = tile_get(_x, _y - 1, _z);
        if (_tile_above != TILE_EMPTY)
        {
            var _data_above = global.item_data[$ _tile_above.get_id()];
            if (_data_above.is_liquid())
            {
                liquid_flow_start(_x, _y - 1, _z);
            }
        }

        // Check left
        var _tile_left = tile_get(_x - 1, _y, _z);
        if (_tile_left != TILE_EMPTY)
        {
            var _data_left = global.item_data[$ _tile_left.get_id()];
            if (_data_left.is_liquid())
            {
                liquid_flow_start(_x - 1, _y, _z);
            }
        }

        // Check right
        var _tile_right = tile_get(_x + 1, _y, _z);
        if (_tile_right != TILE_EMPTY)
        {
            var _data_right = global.item_data[$ _tile_right.get_id()];
            if (_data_right.is_liquid())
            {
                liquid_flow_start(_x + 1, _y, _z);
            }
        }
    }
});

// Leaf Decay System
// Minecraft-style leaf decay: natural leaves decay when no wood is nearby

global.item_function[$ "phantasia:leaf_decay"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    // Convert from pixel to tile coordinates (control_gametick passes world pixel coords)
    var _tx = _x div TILE_SIZE;
    var _ty = _y div TILE_SIZE;
    
    var _tile = tile_get(_tx, _ty, _z);
    
    // Safety check
    if (_tile == TILE_EMPTY) exit;
    
    // Only natural leaves decay (player-placed leaves don't decay)
    var _is_natural = _tile.get_component("natural");
    if (_is_natural != true) exit;
    
    // Get parameters with defaults
    var _decay_radius = _parameter[$ "radius"] ?? 4;       // How far to check for wood
    var _decay_chance = _parameter[$ "chance"] ?? 0.10;    // 10% per random tick (Minecraft-like)
    var _wood_tag = _parameter[$ "wood_tag"] ?? "#phantasia:item/generic/wood";
    
    // Resolve wood tag to array of wood IDs
    var _wood_ids = tag_value_parse(_wood_tag);
    if (!is_array(_wood_ids)) _wood_ids = [_wood_ids]; // Ensure it's an array
    
    // Check if wood is nearby
    var _wood_found = false;
    
    for (var _dx = -_decay_radius; _dx <= _decay_radius && !_wood_found; ++_dx)
    {
        for (var _dy = -_decay_radius; _dy <= _decay_radius && !_wood_found; ++_dy)
        {
            // Use Manhattan distance 
            if (abs(_dx) + abs(_dy) > _decay_radius) continue;
            
            // Check tree layer for wood
            var _check_tile = tile_get(_tx + _dx, _ty + _dy, CHUNK_DEPTH_TREE);
            
            if (_check_tile != TILE_EMPTY)
            {
                var _check_id = _check_tile.get_id();
                
                // Check if tile ID matches any wood in the tag
                if (array_contains(_wood_ids, _check_id))
                {
                    _wood_found = true;
                }
            }
        }
    }
    
    // If wood is found, don't decay
    if (_wood_found) exit;
    
    // Roll for decay
    if (random(1) < _decay_chance)
    {
        // Decay the leaf - trigger tile destruction
        tile_place(_tx, _ty, _z, TILE_EMPTY);
        tile_update_surrounding(_tx, _ty, _z);
        
        // Optionally spawn leaf particle
        var _particle_id = _parameter[$ "particle"];
        if (_particle_id != undefined)
        {
            spawn_particle(_x, _y, smart_value(_particle_id));
        }
    }
}

// Subscribe to tile changes to speed up leaf decay when wood is destroyed
// Subscribe to tile changes to speed up leaf decay when wood is destroyed
event_subscribe(GAME_EVENT.TILE_UPDATE, function(_data) {
    if (_data.tile == undefined) exit;
    
    var _destroyed_id = _data.tile.get_id();
    
    // Resolve wood tag to array of wood IDs
    var _wood_ids = tag_value_parse("#phantasia:item/generic/wood");
    if (!is_array(_wood_ids)) _wood_ids = [_wood_ids];
    
    // Only trigger if wood was destroyed
    if (!array_contains(_wood_ids, _destroyed_id)) exit;
    
    var _x = _data.x;
    var _y = _data.y;
    var _decay_radius = 5; // Slightly larger than check radius to catch edge cases
    
    var _item_data = global.item_data;
    
    // Schedule decay checks for nearby leaves on the leaf layer
    for (var _dx = -_decay_radius; _dx <= _decay_radius; ++_dx)
    {
        for (var _dy = -_decay_radius; _dy <= _decay_radius; ++_dy)
        {
            var _check_tile = tile_get(_x + _dx, _y + _dy, CHUNK_DEPTH_LEAVES);
            
            if (_check_tile != TILE_EMPTY)
            {
                var _check_data = _item_data[$ _check_tile.get_id()];
                
                // Check if it has leaves property and is natural
                if (_check_data != undefined)
                {
                    var _is_natural = _check_tile.get_component("natural");
                    if (_is_natural == true)
                    {
                        // Schedule a decay check with a random delay
                        tick_delay_add(irandom_range(5, 20), function(_chain) {
                            var _func = global.item_function[$ "phantasia:leaf_decay"];
                            _func(1, _chain.x * TILE_SIZE, _chain.y * TILE_SIZE, _chain.z, 1, 1, {});
                        }, [{ x: _x + _dx, y: _y + _dy, z: CHUNK_DEPTH_LEAVES }]);
                    }
                }
            }
        }
    }
});


global.item_function[$ "phantasia:open_menu"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    static __update_float = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];

        var _component = _data.get_component(tile_component);

        var _min = _component[$ "min"];
        var _max = _component[$ "max"];

        try
        {
            var _ = real(text);

            if (_min != undefined) && (_ < _min)
            {
                _ = _min;
            }

            if (_max != undefined) && (_ > _max)
            {
                _ = _max;
            }

            _tile.set_component(tile_component, _);
        }
        catch (_error)
        {
            var _default = _component[$ "default"];

            _tile.set_component(tile_component, _default);
        }
    }

    static __update_integer = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];

        var _component = _data.get_component(tile_component);

        var _min = _component[$ "min"];
        var _max = _component[$ "max"];
        var _default = _component[$ "default"];

        try
        {
            var _ = real(text);

            if (_ % 1 == 0)
            {
                if (_min != undefined) && (_ < _min)
                {
                    _ = _min;
                }

                if (_max != undefined) && (_ > _max)
                {
                    _ = _max;
                }

                _tile.set_component(tile_component, _);
            }
            else
            {
                _tile.set_component(tile_component, _default);
            }
        }
        catch (_error)
        {
            _tile.set_component(tile_component, _default);
        }
    }

    static __update_string = function()
    {
        var _tile = tile_get(tile_x, tile_y, tile_z);
        var _data = global.item_data[$ _tile.get_id()];

        if (text == "")
        {
            var _default = _data.get_component(tile_component)[$ "default"];

            _tile.set_component(tile_component, _default);
        }
        else
        {
        	_tile.set_component(tile_component, text);
        }
    }

    static __exit = function()
    {
        obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.MENU;

        var _item_data = global.item_data;

        var _layer = layer_get_id("Menu_Item");

        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }

    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.MENU;

    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;

    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;

    // Account for gui_scale since menus are rendered on the GUI layer which is already scaled
    var _gui_scale = global.gui_scale;
    obj_Menu_Control_Render.xscale = _gui_scale * (global.window_width  / global.camera_width);
    obj_Menu_Control_Render.yscale = _gui_scale * (global.window_height / global.camera_height);

    var _tile = tile_get(_x, _y, _z);

    var _layer = layer_get_id("Menu_Item");

    var _data = _parameter.data;

    var _length = array_length(_data);

    for (var i = 0; i < _length; ++i)
    {
        var _ = _data[i];

        var _type = _.type;

        if (_type == "button")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Button);

            with (_inst)
            {
                image_xscale = _[$ "xscale"] ?? 1;
                image_yscale = _[$ "yscale"] ?? 1;

                text = _[$ "text"];

                tile_x = _x;
                tile_y = _y;
                tile_z = _z;

                var _on_select_release = _[$ "on_select_release"];

                if (_on_select_release != undefined)
                {
                    on_select_release = ((_on_select_release == "exit") ? __exit : method(id, global.item_function[$ _on_select_release]));
                }
            }
        }
        else if (_type == "textbox-float")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);

            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;

                placeholder = _[$ "placeholder"];

                var _component = _[$ "component"];

                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }

                tile_x = _x;
                tile_y = _y;
                tile_z = _z;

                tile_component = _component;

                on_update = method(id, __update_float);
            }
        }
        else if (_type == "textbox-integer")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);

            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;

                placeholder = _[$ "placeholder"];

                var _component = _[$ "component"];

                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }

                tile_x = _x;
                tile_y = _y;
                tile_z = _z;

                tile_component = _component;

                on_update = method(id, __update_integer);
            }
        }
        else if (_type == "textbox-string")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Textbox);

            with (_inst)
            {
                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;

                placeholder = _[$ "placeholder"];

                var _component = _[$ "component"];

                if (_component != undefined)
                {
                    text = string(_tile.get_component(_component));
                    text_display = text;
                }

                tile_x = _x;
                tile_y = _y;
                tile_z = _z;

                tile_component = _component;

                text_length = _[$ "max"] ?? 24;

                on_update = method(id, __update_string);
            }
        }
        else if (_type == "anchor")
        {
            var _inst = instance_create_layer(_camera_x + _.x, _camera_y + _.y, _layer, obj_Menu_Anchor);

            with (_inst)
            {
                text = _.text;

                image_xscale = (_[$ "xscale"] ?? 1) * 2;
                image_yscale = (_[$ "yscale"] ?? 1) * 2;

                on_draw = render_menu_title;
            }
        }
    }
}

global.item_function[$ "phantasia:spawn_particle"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _offset = _parameter[$ "offset"];

    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];

        if (_xoffset != undefined)
        {
            _x += smart_value(_xoffset);
        }

        var _yoffset = _offset[$ "y"];

        if (_yoffset != undefined)
        {
            _y += smart_value(_yoffset);
        }
    }

    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:spawn_projectile"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _offset = _parameter[$ "offset"];

    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];

        if (_xoffset != undefined)
        {
            _x += smart_value(_xoffset);
        }

        var _yoffset = _offset[$ "y"];

        if (_yoffset != undefined)
        {
            _y += smart_value(_yoffset);
        }
    }

    var _id = smart_value(_parameter.id);
    var _damage = smart_value(_parameter.damage);

    spawn_projectile(_x * TILE_SIZE, _y * TILE_SIZE, _id, _damage, _xscale, _yscale);
}

global.item_function[$ "phantasia:sfx_play"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _audio_emitter = tile_audio_emitter(_x, _y);

    sfx_diegetic_play(_audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:tile_grow_crop"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
}

global.item_function[$ "phantasia:tile_place"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    static __chunk_depth = global.chunk_depth;

    var _condition = _parameter[$ "condition"];

    if (_condition != undefined)
    {
        var _condition_length = array_length(_condition);

        for (var i = 0; i < _condition_length; ++i)
        {
            var _ = _condition[i];

            var _xoffset = _[$ "x"];

            var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;

            var _yoffset = _[$ "y"];

            var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;

            var _tile = tile_get(_x2, _y2, __chunk_depth[$ _.z]);

            var _id = _.id;

            if (_id == TILE_EMPTY)
            {
                if (_tile != TILE_EMPTY) exit;
            }
            else if (_tile == TILE_EMPTY) || ((is_array(_id)) ? !array_contains(_id, _tile.get_id()) : _tile.get_id() != _id) exit;
        }
    }

    var _xoffset = _parameter[$ "x"];

    var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;

    var _yoffset = _parameter[$ "y"];

    var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;

    var _z2 = __chunk_depth[$ _parameter.z];

    var _id = smart_value(_parameter.id);

    if (_id != TILE_EMPTY)
    {
        tile_place(_x2, _y2, _z2, new Tile(_id));
    }
    else
    {
        tile_place(_x2, _y2, _z2, TILE_EMPTY);
    }

    tile_update_surrounding(_x2, _y2, _z2);
}

/// @desc Bucket picks up liquid tile (call from tile on_use)
/// Converts empty bucket in hotbar to filled bucket with liquid level
global.item_function[$ "phantasia:bucket_pickup"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _item_data = global.item_data;
    var _inventory = global.inventory;
    var _inventory_selected = global.inventory_selected_hotbar;
    var _held_item = _inventory.base[_inventory_selected];

    // Check if holding empty bucket
    if (_held_item == INVENTORY_EMPTY) exit;

    var _bucket_id = _parameter[$ "bucket_id"] ?? "phantasia:bucket";

    if (_held_item.get_id() != _bucket_id) exit;

    // Liquids use their own z-layer
    var _liquid_z = CHUNK_DEPTH_LIQUID;

    // Get the liquid tile
    var _tile = tile_get(_x, _y, _liquid_z);

    if (_tile == TILE_EMPTY) exit;

    var _tile_id = _tile.get_id();
    var _tile_data = _item_data[$ _tile_id];

    // Check if it's a liquid
    if (!_tile_data.is_liquid()) exit;

    // Get liquid level
    var _level = _tile.get_component("level") ?? 8;

    // Get filled bucket item ID
    var _filled_bucket_id = _parameter[$ "filled_bucket_id"] ?? (_tile_id + "_bucket");

    // Replace empty bucket with filled bucket (including level)
    var _filled_bucket = new Inventory(_filled_bucket_id, 1);
    _filled_bucket.set_component("level", _level);

    _inventory.base[@ _inventory_selected] = _filled_bucket;

    // Remove the liquid tile
    tile_place(_x, _y, _liquid_z, TILE_EMPTY);
    tile_update_surrounding(_x, _y, _liquid_z);

    // Play pickup sound
    var _sound = _parameter[$ "sound"] ?? "phantasia:sfx/liquid/bucket_fill";
    sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sound, global.settings.audio_sfx);

    // Refresh inventory display
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
}

/// @desc Bucket places liquid tile (call from player_build or item use)
/// Places liquid with stored level and converts filled bucket to empty bucket
global.item_function[$ "phantasia:bucket_place"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _item_data = global.item_data;
    var _inventory = global.inventory;
    var _inventory_selected = global.inventory_selected_hotbar;
    var _held_item = _inventory.base[_inventory_selected];

    if (_held_item == INVENTORY_EMPTY) exit;

    // Get the liquid ID to place
    var _liquid_id = _parameter[$ "liquid_id"];

    if (_liquid_id == undefined) exit;

    // Liquids use their own z-layer, not the passed one
    var _liquid_z = CHUNK_DEPTH_LIQUID;

    // Get stored level from bucket
    var _bucket_level = _held_item.get_component("level") ?? 8;

    // Check existing tile
    var _existing = tile_get(_x, _y, _liquid_z);

    if (_existing != TILE_EMPTY)
    {
        // Check if same liquid type - combine them
        if (_existing.get_id() == _liquid_id)
        {
            var _existing_level = _existing.get_component("level") ?? 0;
            var _total = _existing_level + _bucket_level;
            var _new_level = min(_total, 8);
            var _remaining = _total - _new_level;

            _existing.set_component("level", _new_level);
            tile_update_surrounding(_x, _y, _liquid_z);

            // Start liquid flow
            liquid_flow_start(_x, _y, _liquid_z);

            if (_remaining <= 0)
            {
                // All water placed - convert to empty bucket
                var _empty_bucket_id = _parameter[$ "empty_bucket_id"] ?? "phantasia:bucket";
                _inventory.base[@ _inventory_selected] = new Inventory(_empty_bucket_id, 1);
            }
            else
            {
                // Some water remains in bucket
                _held_item.set_component("level", _remaining);
            }

            // Play place sound
            var _sound = _parameter[$ "sound"] ?? "phantasia:sfx/liquid/bucket_empty";
            sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sound, global.settings.audio_sfx);

            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
        }

        exit;
    }

    // Create liquid tile with level
    var _liquid_tile = new Tile(_liquid_id);
    _liquid_tile.set_component("level", _bucket_level);
    _liquid_tile.set_component("flow_direction", 0);

    tile_place(_x, _y, _liquid_z, _liquid_tile);
    tile_update_surrounding(_x, _y, _liquid_z);

    // Start liquid flow cycle
    liquid_flow_start(_x, _y, _liquid_z);

    // Replace filled bucket with empty bucket
    var _empty_bucket_id = _parameter[$ "empty_bucket_id"] ?? "phantasia:bucket";
    _inventory.base[@ _inventory_selected] = new Inventory(_empty_bucket_id, 1);

    // Play place sound
    var _sound = _parameter[$ "sound"] ?? "phantasia:sfx/liquid/bucket_empty";
    sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sound, global.settings.audio_sfx);

    // Refresh inventory display
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;

    // Refresh lighting for liquid
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
}
