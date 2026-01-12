// Item functions are now handled by @phantasia:items/ scripts in Daydream

/// @desc Schedule liquid flow with proper delay
function liquid_flow_schedule(_x, _y, _z, _parameter = {})
{
    var _tick_delay = _parameter[$ "tick_delay"] ?? 8;

    tick_delay_add(_tick_delay, function(_chain) {
        function_execute({ id: "@phantasia:tile/liquid/flow", parameters: _chain.parameter }, _chain.x * TILE_SIZE, _chain.y * TILE_SIZE, _chain.z);
    }, [{ x: _x, y: _y, z: _z, parameter: _parameter }]);
}

/// @desc Helper to start liquid flow cycle when water is placed
function liquid_flow_start(_x, _y, _z, _parameter = {})
{
    liquid_flow_schedule(_x, _y, _z, _parameter);
}

// ... collision helper removed/ignored ...




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
            // We use a fixed depth or search for leaves? Usually foliage layers.
            for (var _z = 0; _z < CHUNK_DEPTH; _z++)
            {
                var _check_tile = tile_get(_x + _dx, _y + _dy, _z);
                if (_check_tile != TILE_EMPTY)
                {
                    var _is_natural = _check_tile.get_component("natural");
                    if (_is_natural == true)
                    {
                        // Schedule a decay check with a random delay
                        tick_delay_add(irandom_range(5, 20), function(_chain) {
                            function_execute({ id: "@phantasia:tile/nature/leaf_decay", parameters: {} }, _chain.x * TILE_SIZE, _chain.y * TILE_SIZE, _chain.z);
                        }, [{ x: _x + _dx, y: _y + _dy, z: _z }]);
                    }
                }
            }
        }
    }
});











/// @desc Bucket picks up liquid tile (call from tile on_use)
/// Converts empty bucket in hotbar to filled bucket with liquid level


/// @desc Bucket places liquid tile (call from player_build or item use)
/// Places liquid with stored level and converts filled bucket to empty bucket

