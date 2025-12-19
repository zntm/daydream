/// @desc Particle Pool System - Array-based particle management for performance
/// Replaces instance-based particles with pooled struct arrays

#macro PARTICLE_POOL_SIZE 2000
#macro PARTICLE_POOL_GROWTH 500

/// @function ParticlePool()
/// @desc Constructor for particle pool with pre-allocated arrays
function ParticlePool() constructor
{
    // Core particle arrays - Structure of Arrays (SoA) for cache efficiency
    active = array_create(PARTICLE_POOL_SIZE, false);
    
    // Position and velocity
    px = array_create(PARTICLE_POOL_SIZE, 0);
    py = array_create(PARTICLE_POOL_SIZE, 0);
    vx = array_create(PARTICLE_POOL_SIZE, 0);
    vy = array_create(PARTICLE_POOL_SIZE, 0);
    
    // Appearance
    particle_id = array_create(PARTICLE_POOL_SIZE, "");
    sprite_index_cached = array_create(PARTICLE_POOL_SIZE, 0);
    image_index = array_create(PARTICLE_POOL_SIZE, 0);
    scale = array_create(PARTICLE_POOL_SIZE, 1);
    rotation = array_create(PARTICLE_POOL_SIZE, 0);
    rotation_increment = array_create(PARTICLE_POOL_SIZE, 0);
    colour = array_create(PARTICLE_POOL_SIZE, c_white);
    alpha = array_create(PARTICLE_POOL_SIZE, 1);
    
    // Lifetime
    timer_life = array_create(PARTICLE_POOL_SIZE, 0);
    timer_life_max = array_create(PARTICLE_POOL_SIZE, 0);
    
    // Physics
    has_gravity = array_create(PARTICLE_POOL_SIZE, false);
    gravity = array_create(PARTICLE_POOL_SIZE, 0);
    has_collision = array_create(PARTICLE_POOL_SIZE, false);
    
    // Flags
    is_additive = array_create(PARTICLE_POOL_SIZE, false);
    is_fade_out = array_create(PARTICLE_POOL_SIZE, false);
    
    // Pool management
    active_count = 0;
    pool_size = PARTICLE_POOL_SIZE;
    
    // Free index stack for O(1) allocation
    free_stack = array_create(PARTICLE_POOL_SIZE);
    free_stack_top = PARTICLE_POOL_SIZE - 1;
    
    for (var i = 0; i < PARTICLE_POOL_SIZE; ++i)
    {
        free_stack[@ i] = i;
    }
    
    /// @function allocate()
    /// @desc Get a free particle index from the pool
    /// @returns {real} Index of free particle, or -1 if pool is full
    static allocate = function()
    {
        if (free_stack_top < 0)
        {
            // Pool exhausted - could grow here if needed
            return -1;
        }
        
        var _index = free_stack[free_stack_top];
        free_stack_top--;
        active_count++;
        
        return _index;
    }
    
    /// @function release(_index)
    /// @desc Return a particle index to the pool
    /// @param {real} _index The particle index to release
    static release = function(_index)
    {
        if (_index < 0 || _index >= pool_size) return;
        if (!active[_index]) return;
        
        active[@ _index] = false;
        free_stack_top++;
        free_stack[@ free_stack_top] = _index;
        active_count--;
    }
    
    /// @function spawn(_x, _y, _particle_id, _colour)
    /// @desc Spawn a new particle at the given position
    /// @param {real} _x X position
    /// @param {real} _y Y position
    /// @param {string} _particle_id Particle data ID
    /// @param {real} _colour Blend colour
    /// @returns {real} Index of spawned particle, or -1 if failed
    static spawn = function(_x, _y, _particle_id, _colour = c_white)
    {
        var _data = global.particle_data[$ _particle_id];
        if (_data == undefined) return -1;
        
        var _index = allocate();
        if (_index < 0) return -1;
        
        // Initialize particle
        active[@ _index] = true;
        
        px[@ _index] = _x;
        py[@ _index] = _y;
        
        // Calculate initial velocity
        if (_data.get_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _xspeed = world_get_reference(_data.get_xspeed());
            vx[@ _index] = (smart_value(_xspeed) + smart_value(_data.get_xspeed_offset())) * smart_value(_data.get_xspeed_multiplier());
        }
        else
        {
            vx[@ _index] = smart_value(_data.get_xspeed());
        }
        
        if (_data.get_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _yspeed = world_get_reference(_data.get_yspeed());
            vy[@ _index] = (smart_value(_yspeed) + smart_value(_data.get_yspeed_offset())) * smart_value(_data.get_yspeed_multiplier());
        }
        else
        {
            vy[@ _index] = smart_value(_data.get_yspeed());
        }
        
        // Appearance
        particle_id[@ _index] = _particle_id;
        scale[@ _index] = smart_value(_data.get_scale());
        rotation[@ _index] = smart_value(_data.get_rotation());
        rotation_increment[@ _index] = smart_value(_data.get_rotation_increment());
        colour[@ _index] = _colour;
        alpha[@ _index] = 1;
        image_index[@ _index] = 0;
        
        // Lifetime
        var _lifetime = smart_value(_data.get_lifetime());
        timer_life[@ _index] = _lifetime;
        timer_life_max[@ _index] = _lifetime;
        
        // Physics
        var _attribute = _data.get_attribute();
        if (_attribute != undefined)
        {
            has_gravity[@ _index] = true;
            gravity[@ _index] = _attribute.get_gravity();
            has_collision[@ _index] = _attribute.has_collision_box();
        }
        else
        {
            has_gravity[@ _index] = false;
            gravity[@ _index] = 0;
            has_collision[@ _index] = false;
        }
        
        // Flags
        is_additive[@ _index] = _data.is_additive();
        is_fade_out[@ _index] = _data.is_fade_out();
        
        return _index;
    }
}

// Initialize global particle pool
global.particle_pool = new ParticlePool();

/// @function particle_pool_spawn(_x, _y, _id, _colour)
/// @desc Wrapper function to spawn particle using pool
function particle_pool_spawn(_x, _y, _id, _colour = c_white)
{
    return global.particle_pool.spawn(_x, _y, _id, _colour);
}
