/// @desc Spatial hash map for O(1) chunk lookups
/// Stores chunk structs instead of instance IDs

global.chunk_map = {}
global.chunk_cache_x = -1;
global.chunk_cache_y = -1;
global.chunk_cache   = undefined;

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
/// @returns {Struct.Chunk} Chunk struct or undefined
function chunk_map_get(_x, _y)
{
    var _cx = floor(_x / CHUNK_SIZE_DIMENSION);
    var _cy = floor(_y / CHUNK_SIZE_DIMENSION);
    
    if (_cx == global.chunk_cache_x && _cy == global.chunk_cache_y)
    {
        return global.chunk_cache;
    }
    
    var _key = $"{_cx}_{_cy}";
    var _chunk = global.chunk_map[$ _key];
    
    global.chunk_cache_x = _cx;
    global.chunk_cache_y = _cy;
    global.chunk_cache    = _chunk;
    
    return _chunk;
}

/// @function chunk_map_get_by_tile(_tile_x, _tile_y)
/// @desc Get chunk at tile position
/// @param {real} _tile_x Tile X coordinate
/// @param {real} _tile_y Tile Y coordinate
/// @returns {Struct.Chunk} Chunk struct or undefined
function chunk_map_get_by_tile(_tile_x, _tile_y)
{
    var _cx = floor(_tile_x / CHUNK_SIZE);
    var _cy = floor(_tile_y / CHUNK_SIZE);
    
    if (_cx == global.chunk_cache_x && _cy == global.chunk_cache_y)
    {
        return global.chunk_cache;
    }
    
    var _key = $"{_cx}_{_cy}";
    var _chunk = global.chunk_map[$ _key];
    
    global.chunk_cache_x = _cx;
    global.chunk_cache_y = _cy;
    global.chunk_cache   = _chunk;
    
    return _chunk;
}

/// @function chunk_map_register(_chunk)
/// @desc Register chunk in the spatial map
/// @param {Struct.Chunk} _chunk Chunk struct
function chunk_map_register(_chunk)
{
    var _key = chunk_map_key(_chunk.x, _chunk.y);
    global.chunk_map[$ _key] = _chunk;
}

/// @function chunk_map_unregister(_chunk)
/// @desc Remove chunk from the spatial map
/// @param {Struct.Chunk} _chunk Chunk struct
function chunk_map_unregister(_chunk)
{
    var _key = chunk_map_key(_chunk.x, _chunk.y);
    struct_remove(global.chunk_map, _key);
    
    // Invalidate cache if this chunk was cached
    global.chunk_cache_x = -1;
    global.chunk_cache_y = -1;
    global.chunk_cache   = undefined;
}

/// @function chunk_map_clear()
/// @desc Clear entire chunk map (e.g., on world unload)
function chunk_map_clear()
{
    global.chunk_map = {}
    global.chunk_cache_x = -1;
    global.chunk_cache_y = -1;
    global.chunk_cache   = undefined;
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

/// @function chunk_map_get_all()
/// @desc Get array of all chunk structs
/// @returns {array} Array of Chunk structs
function chunk_map_get_all()
{
    var _keys = struct_get_names(global.chunk_map);
    var _count = array_length(_keys);
    var _chunks = array_create(_count);
    
    for (var i = 0; i < _count; ++i)
    {
        _chunks[i] = global.chunk_map[$ _keys[i]];
    }
    
    return _chunks;
}

/// @function chunk_map_count()
/// @desc Get number of loaded chunks
/// @returns {real} Number of chunks
function chunk_map_count()
{
    return struct_names_count(global.chunk_map);
}
