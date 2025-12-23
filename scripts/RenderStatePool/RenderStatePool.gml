/// @desc Pool system for render state structs
function RenderStatePool() : Pool() constructor
{
    static create = function()
    {
        return {
            x: 0,
            y: 0,
            z: 0,
            data: undefined
        };
    }
    
    static acquire = function(_x, _y, _z, _data)
    {
        var _struct = get_free_item();
        
        _struct.x = _x;
        _struct.y = _y;
        _struct.z = _z;
        _struct.data = _data;
        
        return _struct;
    }
}

global.render_state_pool = new RenderStatePool();

// Maintain legacy API for compatibility if needed, using the global instance
// But we decided to replace usage in 'Usage Updates' section.
// Keeping these functions as wrappers for now during transition might be safer, 
// OR we can delete them if we are sure we update all usages.
// The plan said "Remove old functional API" and "Replace ... with ...".
// So I will remove the old functions entirely as per plan.
