/// @desc StructurePooling system using constructor-based structs
/// Replaces obj_Structure instances with lightweight struct management

// Note: Ensure Pool script is loaded before this or in same group

/// @function Structure(_x, _y, _width, _height, _id)
/// @desc Constructor for structure data struct - replaces obj_Structure
/// @param {real} _x Pixel X position
/// @param {real} _y Pixel Y position
/// @param {real} _width Width in tiles (or pixels if matches sprite)
/// @param {real} _height Height in tiles (or pixels if matches sprite)
/// @param {string} _id Structure ID
function Structure(_x, _y, _width, _height, _id) constructor
{
    // Properties matching obj_Structure for compatibility
    x = _x;
    y = _y;
    image_xscale = _width; // Kept as image_xscale for compatibility
    image_yscale = _height; // Kept as image_yscale for compatibility
    structure_id = _id;
    
    var _half_width_pixels = (_width * TILE_SIZE) / 2;
    var _half_height_pixels = (_height * TILE_SIZE) / 2;
    
    // Calculated properties
    bbox_left = _x - _half_width_pixels;
    bbox_top = _y - _half_height_pixels;
    bbox_right = _x + _half_width_pixels;
    bbox_bottom = _y + _half_height_pixels;
    
    structure_xrelative = ceil(bbox_left / TILE_SIZE);
    structure_yrelative = ceil(bbox_top  / TILE_SIZE);
    
    // Data storage
    data = undefined;
    count = 0;
}

/// @function StructurePool()
/// @desc Pool manager for structure structs
function StructurePool() : Pool() constructor
{
    active_structures = [];
    spatial_grid = new SpatialGrid(CHUNK_SIZE_DIMENSION);
    
    static create = function()
    {
        return new Structure(0, 0, 1, 1, "null");
    }
    
    /// @function acquire(_x, _y, _width, _height, _id)
    /// @desc Get a structure from pool and initialize it
    static acquire = function(_x, _y, _width, _height, _id)
    {
        var _struct = get_free_item();
        
        // Initialize
        _struct.x = _x;
        _struct.y = _y;
        _struct.image_xscale = _width;
        _struct.image_yscale = _height;
        _struct.structure_id = _id;
        
        var _half_width_pixels = (_width * TILE_SIZE) / 2;
        var _half_height_pixels = (_height * TILE_SIZE) / 2;
        
        _struct.bbox_left = _x - _half_width_pixels;
        _struct.bbox_top = _y - _half_height_pixels;
        _struct.bbox_right = _x + _half_width_pixels;
        _struct.bbox_bottom = _y + _half_height_pixels;
        
        _struct.structure_xrelative = ceil(_struct.bbox_left / TILE_SIZE);
        _struct.structure_yrelative = ceil(_struct.bbox_top  / TILE_SIZE);
        
        _struct.data = undefined;
        _struct.count = 0;
        
        // Prepare body properties for SpatialGrid
        _struct.pos_x = _x;
        _struct.pos_y = _y;
        _struct.width = _width * TILE_SIZE;
        _struct.height = _height * TILE_SIZE;
        _struct.id = string(ptr(_struct)); // Unique ID for grid tracking
        
        spatial_grid.add(_struct);
        array_push(active_structures, _struct);
        
        return _struct;
    }
    
    /// @function release(_struct)
    /// @desc Release a structure back to the pool
    static release = function(_struct)
    {
        var _index = array_get_index(active_structures, _struct);
        if (_index != -1)
        {
            array_delete(active_structures, _index, 1);
        }
        
        spatial_grid.remove(_struct);
        
        // Reset heavy data
        if (_struct.data != undefined && is_array(_struct.data))
        {
            _struct.data = undefined;
        }
        
        // Parent release puts it back in pool array
        // We call the base Pool.release
        on_release(_struct);
        array_push(pool, _struct);
    }
    
    /// @function query_range(_x1, _y1, _x2, _y2)
    /// @desc Returns an array of structures overlapping the rectangle
    /// @param {real} _x1 Left coordinate
    /// @param {real} _y1 Top coordinate
    /// @param {real} _x2 Right coordinate
    /// @param {real} _y2 Bottom coordinate
    static query_range = function(_x1, _y1, _x2, _y2)
    {
        return spatial_grid.query_rect(_x1, _y1, _x2, _y2);
    }
    
    /// @function query_position(_x, _y)
    /// @desc Returns a structure at the specific point (or undefined)
    /// @param {real} _x X coordinate
    /// @param {real} _y Y coordinate
    static query_position = function(_x, _y)
    {
        var _list = spatial_grid.query_point(_x, _y);
        return (array_length(_list) > 0) ? _list[0] : noone;
    }
}

global.structure_pool = new StructurePool();
