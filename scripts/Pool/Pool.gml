/// @desc Generic Pool System Base Class
function Pool() constructor
{
    pool = [];
    
    /// @function get_free_item()
    /// @desc Internal method to get an item from the pool or create a new one
    static get_free_item = function()
    {
        if (array_length(pool) > 0)
        {
            return array_pop(pool);
        }
        
        return create();
    }
    
    /// @function release(_item)
    /// @desc Returns an item to the pool
    static release = function(_item)
    {
        on_release(_item);
        array_push(pool, _item);
    }
    
    /// @function clear()
    /// @desc Clears the pool and destroys all items in it
    static clear = function()
    {
        var _length = array_length(pool);
        for (var i = 0; i < _length; ++i)
        {
            destroy(pool[i]);
        }
        array_resize(pool, 0);
    }
    
    /// @function create()
    /// @desc Virtual method to create a new item. Must be overridden.
    static create = function()
    {
        show_error("Pool.create() must be overridden", true);
        return undefined;
    }
    
    /// @function destroy(_item)
    /// @desc Virtual method to destroy an item. Optional override.
    static destroy = function(_item)
    {
        // Default implementation does nothing (for structs/GC)
        // Override for instances or manual cleanup
    }
    
    /// @function on_release(_item)
    /// @desc Virtual method called before returning to pool. Optional override.
    static on_release = function(_item)
    {
        // Default implementation does nothing
    }

    /// @function clear_list(_list)
    /// @desc Releases all items in the provided list back to the pool and clears the list
    static clear_list = function(_list)
    {
        var _length = array_length(_list);
        for (var i = 0; i < _length; ++i)
        {
            release(_list[i]);
        }
        array_resize(_list, 0);
    }
    
    /// @function get_size()
    /// @desc Returns current pool size
    static get_size = function()
    {
        return array_length(pool);
    }
}
