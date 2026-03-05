/// @desc Spawn a falling tile entity from a static tile.
/// @function spawn_falling_tile(_world_x, _world_y, _tile_z, _tile)
/// @param {real} _world_x World X coordinate of the tile
/// @param {real} _world_y World Y coordinate of the tile
/// @param {real} _tile_z Z layer of the tile
/// @param {Struct.Tile} _tile The tile to convert to falling entity

function spawn_falling_tile(_world_x, _world_y, _tile_z, _tile)
{
    var _tile_id = _tile.get_id();
    var _data    = global.item_data[$ _tile_id];

    var _falling = _data.get_falling();

    if (_falling == undefined)
    {
        return noone;
    }

    var _pixel_x = _world_x * TILE_SIZE;
    var _pixel_y = _world_y * TILE_SIZE;

    var _inst = instance_create_layer(_pixel_x, _pixel_y, "Instances", obj_Falling_Tile);

    with (_inst)
    {
        tile_id         = _tile_id;
        tile_index      = _tile.get_index();
        tile_z          = _tile_z;
        tile_components = _tile.get_components_length() > 0 ? _tile : undefined;

        /* track original position for cascade checks */
        origin_x = _world_x;
        origin_y = _world_y;

        x_previous = x;
        y_previous = y;

        /* attribute setup */
        attribute = new Attribute()
            .set_collision_box(TILE_SIZE, TILE_SIZE)
            .set_gravity(_falling[$ "gravity"] ?? PHYSICS_GRAVITY_DEFAULT);

        /* initialize physics body */
        physics_body = new PhysicsBody(attribute);
        physics_body.sync_from_instance(id);
        
        /* apply initial perturbation */
        physics_body.vel_x = random_range(-FALLING_TILE_INITIAL_X_SPREAD, FALLING_TILE_INITIAL_X_SPREAD);
        physics_body.vel_y = 0;

        /* visual setup */
        entity_xscale = 1;
        entity_yscale = 1;

        var _sprite = global.sprite_asset[$ _data.get_sprite()];

        if (_sprite != undefined)
        {
            sprite_index = _sprite.get_sprite();
            image_index  = tile_index;
        }
    }

    /* remove the static tile from the world */
    tile_place(_world_x, _world_y, _tile_z, TILE_EMPTY);

    var _chunk = chunk_map_get(_pixel_x, _pixel_y);

    if (_chunk != undefined)
    {
        var _vertex_buffer = _chunk.chunk_vertex_buffer[_tile_z];

        if (vertex_buffer_exists(_vertex_buffer))
        {
            vertex_delete_buffer(_vertex_buffer);
        }
    }

    return _inst;
}

/// @desc Check if a tile should start falling.
/// @function falling_tile_check(_world_x, _world_y, _tile_z)
/// @param {real} _world_x World X coordinate
/// @param {real} _world_y World Y coordinate
/// @param {real} _tile_z Z layer
function falling_tile_check(_world_x, _world_y, _tile_z)
{
    var _tile = tile_get(_world_x, _world_y, _tile_z);

    if (_tile == TILE_EMPTY) exit;

    var _data = global.item_data[$ _tile.get_id()];

    if (!_data.is_falling_tile()) exit;

    /* check if there's air below on the same z layer */
    var _tile_below = tile_get(_world_x, _world_y + 1, _tile_z);

    if (_tile_below != TILE_EMPTY) exit;

    /* check all z layers for any solid/platform support */
    for (var z = CHUNK_DEPTH - 1; z >= 0; --z)
    {
        var _check = tile_get(_world_x, _world_y + 1, z);

        if (_check == TILE_EMPTY) continue;

        var _check_data = global.item_data[$ _check.get_id()];

        if (_check_data.get_type() & (ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM)) exit;
    }

    spawn_falling_tile(_world_x, _world_y, _tile_z, _tile);
}
