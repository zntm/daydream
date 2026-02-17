/// @desc StructurePooling system using constructor-based structs
/// Replaces obj_Structure instances with lightweight struct management

// Note: Ensure Pool script is loaded before this or in same group

/// @function Structure(_x, _y, _width, _height, _id)
/// @desc Constructor for structure data struct - replaces obj_Structure
/// @param {real} _x Tile X position (top-left)
/// @param {real} _y Tile Y position (top-left)
/// @param {real} _width Width in tiles
/// @param {real} _height Height in tiles
/// @param {string} _id Structure ID
function Structure(_x, _y, _width, _height, _id) constructor
{
    x = _x;
    y = _y;
    width = _width;
    height = _height;
    structure_id = _id;
    
    // Data storage
    data  = undefined;
    count = 0;
}

/// @function StructurePool()
/// @desc Pool manager for structure structs
function StructurePool() : Pool() constructor
{
    active_structures = [];
    
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
        _struct.width  = _width;
        _struct.height = _height;
        _struct.structure_id = _id;
        
        _struct.data  = undefined;
        _struct.count = 0;
        
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
        
        // Reset heavy data
        if (_struct.data != undefined && is_array(_struct.data))
        {
            _struct.data = undefined;
        }
        
        // Parent release puts it back in pool array
        on_release(_struct);
        array_push(pool, _struct);
    }
    
    /// @function query_range(_x1, _y1, _x2, _y2)
    /// @desc Returns an array of structures overlapping the rectangle (tile coords)
    static query_range = function(_x1, _y1, _x2, _y2)
    {
        var _results = [];
        
        for (var i = array_length(active_structures) - 1; i >= 0; --i)
        {
            var _struct = active_structures[i];
            
            if (_struct.x < _x2) && (_struct.x + _struct.width > _x1)
                && (_struct.y < _y2) && (_struct.y + _struct.height > _y1)
            {
                array_push(_results, _struct);
            }
        }
        
        return _results;
    }
    
    /// @function clear_all()
    /// @desc Clear all active structures and pool.
    static clear_all = function()
    {
        for (var i = array_length(active_structures) - 1; i >= 0; --i)
        {
            array_delete(active_structures, i, 1);
        }
        
        for (var i = array_length(pool) - 1; i >= 0; --i)
        {
            array_delete(pool, i, 1);
        }
    }
    
    /// @function query_position(_x, _y)
    /// @desc Returns a structure at the specific tile point.
    static query_position = function(_x, _y)
    {
        for (var i = array_length(active_structures) - 1; i >= 0; --i)
        {
            var _struct = active_structures[i];
            
            if (_x >= _struct.x) && (_x < _struct.x + _struct.width)
                && (_y >= _struct.y) && (_y < _struct.y + _struct.height)
            {
                return _struct;
            }
        }
        
        return noone;
    }
}

global.structure_pool = new StructurePool();
