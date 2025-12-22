/// @desc Spatial hash map for O(1) chunk lookups
/// Replaces slow instance_position() calls

global.chunk_map = {};

/// @function chunk_map_key(_x, _y)
/// @desc Generate hash key from world coordinates
/// @param {real} _x World X position (pixel)
/// @param {real} _y World Y position (pixel)
/// @returns {string} Hash key
function chunk_map_key(_x, _y)
{
    gml_pragma("forceinline");
    
    return $"{floor(_x / CHUNK_SIZE_DIMENSION)}_{floor(_y / CHUNK_SIZE_DIMENSION)}";
}

/// @function chunk_map_get(_x, _y)
/// @desc Get chunk at world position
/// @param {real} _x World X position (pixel)
/// @param {real} _y World Y position (pixel)
/// @returns {Id.Instance} Chunk instance or noone
function chunk_map_get(_x, _y)
{
    var _key = chunk_map_key(_x, _y);
    return global.chunk_map[$ _key] ?? noone;
}

/// @function chunk_map_get_by_tile(_tile_x, _tile_y)
/// @desc Get chunk at tile position
/// @param {real} _tile_x Tile X coordinate
/// @param {real} _tile_y Tile Y coordinate
/// @returns {Id.Instance} Chunk instance or noone
function chunk_map_get_by_tile(_tile_x, _tile_y)
{
    return chunk_map_get(_tile_x * TILE_SIZE, _tile_y * TILE_SIZE);
}

/// @function chunk_map_register(_inst)
/// @desc Register chunk in the spatial map
/// @param {Id.Instance} _inst Chunk instance
function chunk_map_register(_inst)
{
    var _key = chunk_map_key(_inst.x, _inst.y);
    global.chunk_map[$ _key] = _inst;
}

/// @function chunk_map_unregister(_inst)
/// @desc Remove chunk from the spatial map
/// @param {Id.Instance} _inst Chunk instance
function chunk_map_unregister(_inst)
{
    var _key = chunk_map_key(_inst.x, _inst.y);
    struct_remove(global.chunk_map, _key);
}

/// @function chunk_map_clear()
/// @desc Clear entire chunk map (e.g., on world unload)
function chunk_map_clear()
{
    global.chunk_map = {};
}

/// @function chunk_map_exists(_x, _y)
/// @desc Check if a chunk exists at world position
/// @param {real} _x World X position (pixel)
/// @param {real} _y World Y position (pixel)
/// @returns {bool} True if chunk exists
function chunk_map_exists(_x, _y)
{
    var _key = chunk_map_key(_x, _y);
    return struct_exists(global.chunk_map, _key);
}
