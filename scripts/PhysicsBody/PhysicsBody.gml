/// @desc Physics body state - encapsulates all physics-related data for an entity
/// @param {Struct.Attribute} _attribute The attribute configuration for this body

enum MOVEMENT_MODE {
    GROUND,    // Normal gravity-based horizontal movement
    FLY,       // No gravity, 360° movement
    SWIM,      // Buoyancy, drag, 360° movement  
    CLIMB,     // Wall-attached vertical movement
    MOUNTED    // Physics delegated to mount
}

function PhysicsBody(_attribute = undefined) constructor
{
    // Position
    pos_x = 0;
    pos_y = 0;
    
    // Velocity
    vel_x = 0;
    vel_y = 0;
    
    // Movement mode
    mode = MOVEMENT_MODE.GROUND;
    mode_prev = MOVEMENT_MODE.GROUND;
    
    // Attribute reference
    attribute = _attribute;
    
    // Jump state
    jump = {
        count: 0,
        held_time: 0,
        coyote_time: 0,
        max_count: (_attribute != undefined) ? _attribute.get_jump_count_max() : 1
    }
    
    // Collision state (updated each physics step)
    collision = {
        ground: false,
        ceiling: false,
        wall_left: false,
        wall_right: false,
        in_liquid: false,
        liquid_type: ""
    }
    
    // Mount system
    mount = undefined;
    rider = undefined;
    mount_id = "";
    
    // Scale
    scale_x = 1;
    scale_y = 1;
    
    /// @desc Sync position from instance
    static sync_from_instance = function(_inst)
    {
        pos_x = _inst.x;
        pos_y = _inst.y;
        scale_x = _inst.image_xscale;
        scale_y = _inst.image_yscale;
        return self;
    }
    
    /// @desc Sync position to instance
    static sync_to_instance = function(_inst)
    {
        _inst.x = pos_x;
        _inst.y = pos_y;
        return self;
    }
    
    /// @desc Reset jump state (called when landing)
    static reset_jump = function()
    {
        jump.count = 0;
        jump.held_time = 0;
        jump.coyote_time = 0;
        return self;
    }
    
    /// @desc Serialize for network/save
    static serialize = function()
    {
        return {
            px: pos_x,
            py: pos_y,
            vx: vel_x,
            vy: vel_y,
            mode: mode,
            jump_count: jump.count,
            mount_id: mount_id
        }
    }
    
    /// @desc Deserialize from network/save
    static deserialize = function(_data)
    {
        pos_x = _data.px;
        pos_y = _data.py;
        vel_x = _data.vx;
        vel_y = _data.vy;
        mode = _data.mode;
        jump.count = _data.jump_count;
        mount_id = _data.mount_id;
        return self;
    }
}
