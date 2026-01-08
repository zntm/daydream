/// @desc Unified physics step - processes input and movement for a PhysicsBody
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt Delta time

function physics_step(_body, _input)
{
    // If mounted, delegate physics to mount
    if (_body.mount != undefined)
    {
        physics_mode_mounted(_body, _input);
        return;
    }
    
    // Detect and handle mode transitions
    physics_detect_mode(_body);
    
    // Apply movement based on current mode
    switch (_body.mode)
    {
        case MOVEMENT_MODE.GROUND:
            physics_mode_ground(_body, _input);
            break;
            
        case MOVEMENT_MODE.FLY:
            physics_mode_fly(_body, _input);
            break;
            
        case MOVEMENT_MODE.SWIM:
            physics_mode_swim(_body, _input);
            break;
            
        case MOVEMENT_MODE.CLIMB:
            physics_mode_climb(_body, _input);
            break;
    }
    
    // Collision resolution (skip if noclip is enabled)
    var _noclip = false;
    if (IS_DEVELOPER_MODE && _body.mode == MOVEMENT_MODE.FLY)
    {
        var _dbg = variable_global_exists("dbg_settings") ? global.dbg_settings : undefined;
        if (_dbg != undefined && (_dbg[$ "noclip"] || !_dbg[$ "enable_physics"]))
        {
            _noclip = true;
        }
    }
    
    if (!_noclip)
    {
        physics_move_contact_x(_body);
        physics_move_contact_y(_body);
    }
    else
    {
        // Noclip: just apply velocity directly, no collision
        _body.x += _body.vel_x;
        _body.y += _body.vel_y;
    }
    
    // Resolve entity collisions using SpatialGrid
    // physics_resolve_entity(_body, global.spatial_grid);
    
    // Reset jump state if landed
    if (_body.collision.ground && _body.mode == MOVEMENT_MODE.GROUND)
    {
        _body.reset_jump();
    }
}

/// @desc Detect and set the appropriate movement mode
/// @param {Struct.PhysicsBody} _body
function physics_detect_mode(_body)
{
    _body.mode_prev = _body.mode;
    
    // Don't change mode if mounted
    if (_body.mount != undefined)
    {
        _body.mode = MOVEMENT_MODE.MOUNTED;
        return;
    }
    
    // Check for liquid (swim mode)
    if (_body.collision.in_liquid)
    {
        _body.mode = MOVEMENT_MODE.SWIM;
        return;
    }
    
    // Check for wall cling (climb mode) - requires attribute support
    if (_body.attribute != undefined)
    {
        var _can_climb = _body.attribute[$ "___can_climb"] ?? false;
        
        if (_can_climb && (_body.collision.wall_left || _body.collision.wall_right))
        {
            _body.mode = MOVEMENT_MODE.CLIMB;
            return;
        }
        
        // Check for flight ability
        var _can_fly = _body.attribute[$ "___can_fly"] ?? false;
        
        if (_can_fly)
        {
            _body.mode = MOVEMENT_MODE.FLY;
            return;
        }
    }
    
    // Default to ground
    _body.mode = MOVEMENT_MODE.GROUND;
}
