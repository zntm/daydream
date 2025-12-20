/// @desc Spawn a falling tile entity from a static tile
/// @function spawn_falling_tile(_world_x, _world_y, _tile_z, _tile)
/// @param {real} _world_x World X coordinate of the tile
/// @param {real} _world_y World Y coordinate of the tile
/// @param {real} _tile_z Z layer of the tile
/// @param {Struct.Tile} _tile The tile to convert to falling entity

function spawn_falling_tile(_world_x, _world_y, _tile_z, _tile)
{
    var _tile_id = _tile.get_id();
    var _data = global.item_data[$ _tile_id];
    
    // Get falling properties
    var _falling = _data.get_falling();
    
    if (_falling == undefined) return noone;
    
    var _pixel_x = _world_x * TILE_SIZE;
    var _pixel_y = _world_y * TILE_SIZE;
    
    var _inst = instance_create_layer(_pixel_x, _pixel_y, "Instances", obj_Falling_Tile);
    
    with (_inst)
    {
        tile_id = _tile_id;
        tile_index = _tile.get_index();
        tile_z = _tile_z;
        tile_components = _tile.get_components_length() > 0 ? _tile : undefined;
        
        // Initialize physics
        xvelocity = 0;
        yvelocity = 0;
        
        // Use custom gravity if specified, otherwise use global
        gravity_value = _falling[$ "gravity"] ?? PHYSICS_GLOBAL_GRAVITY;
        
        // Fall delay (in game ticks)
        fall_delay = _falling[$ "delay"] ?? 2;  // Default 2 tick delay like Minecraft
        
        // Track original position for placing back if needed
        origin_x = _world_x;
        origin_y = _world_y;
        
        // Set up collision box (tile-sized)
        attribute = new Attribute()
            .set_collision_box(TILE_SIZE, TILE_SIZE)
            .set_gravity(gravity_value);
        
        // Visual setup
        entity_xscale = 1;
        entity_yscale = 1;
        
        // Set sprite from tile data
        var _sprite = global.sprite_asset[$ _data.get_sprite()];
        if (_sprite != undefined)
        {
            sprite_index = _sprite.get_sprite();
            image_index = tile_index;
        }
    }
    
    // Remove the static tile from the world
    tile_place(_world_x, _world_y, _tile_z, TILE_EMPTY);
    
    // Mark chunk as needing vertex buffer rebuild
    var _chunk = instance_position(_pixel_x, _pixel_y, obj_Chunk);
    if (instance_exists(_chunk))
    {
        _chunk.boolean |= CHUNK_BOOLEAN.DIRTY;
    }
    
    return _inst;
}

/// @desc Check if a tile should start falling
/// @function falling_tile_check(_world_x, _world_y, _tile_z)
/// @param {real} _world_x World X coordinate
/// @param {real} _world_y World Y coordinate
/// @param {real} _tile_z Z layer
function falling_tile_check(_world_x, _world_y, _tile_z)
{
    var _tile = tile_get(_world_x, _world_y, _tile_z);
    
    if (_tile == TILE_EMPTY) exit;
    
    var _data = global.item_data[$ _tile.get_id()];
    
    // Check if this is a falling tile type
    var _falling = _data.get_falling();
    if (_falling == undefined) exit;
    
    // Check if there's air below
    var _tile_below = tile_get(_world_x, _world_y + 1, _tile_z);
    
    if (_tile_below == TILE_EMPTY)
    {
        // Also check for platform/solid types in case of layered tiles
        var _solid_below = false;
        
        for (var z = 0; z < CHUNK_DEPTH; z++)
        {
            var _check = tile_get(_world_x, _world_y + 1, z);
            if (_check != TILE_EMPTY)
            {
                var _check_data = global.item_data[$ _check.get_id()];
                if (_check_data.get_type() & (ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM))
                {
                    _solid_below = true;
                    break;
                }
            }
        }
        
        if (!_solid_below)
        {
            spawn_falling_tile(_world_x, _world_y, _tile_z, _tile);
        }
    }
}
