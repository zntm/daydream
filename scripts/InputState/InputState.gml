/// @desc Device-agnostic input state snapshot for one frame
/// @desc Can be created from player input or AI decisions

function InputState() constructor
{
    // Analog movement (-1.0 to 1.0)
    move_x = 0;
    move_y = 0;
    
    // Digital actions - held state
    jump_held = false;
    attack_held = false;
    use_held = false;
    
    // Digital actions - just pressed this frame
    jump_pressed = false;
    attack_pressed = false;
    use_pressed = false;
    mount_pressed = false;
    
    // Digital actions - double pressed
    move_left_double_pressed = false;
    move_right_double_pressed = false;
    move_up_double_pressed = false;
    move_down_double_pressed = false;
    jump_double_pressed = false;
    attack_double_pressed = false;
    use_double_pressed = false;
    mouse_left_double_pressed = false;
    mouse_right_double_pressed = false;
    mouse_middle_double_pressed = false;
    
    // Aim direction (normalized)
    aim_x = 0;
    aim_y = 0;
    aim_angle = 0;
    
    /// @desc Poll input from player's current device
    static poll_player = function()
    {
        // Movement axes
        move_x = input_get_axis(true);
        move_y = input_get_axis(false);
        
        // Digital Actions
        jump_held = input_check(INPUT_ACTION.JUMP);
        jump_pressed = input_check_pressed(INPUT_ACTION.JUMP);
        attack_held = input_check(INPUT_ACTION.ATTACK);
        attack_pressed = input_check_pressed(INPUT_ACTION.ATTACK);
        use_held = input_check(INPUT_ACTION.USE);
        use_pressed = input_check_pressed(INPUT_ACTION.USE);
        mount_pressed = input_check_pressed(INPUT_ACTION.MOUNT);
        
        // Double Taps
        move_left_double_pressed  = input_check_double_pressed(INPUT_ACTION.MOVE_LEFT);
        move_right_double_pressed = input_check_double_pressed(INPUT_ACTION.MOVE_RIGHT);
        move_up_double_pressed    = input_check_double_pressed(INPUT_ACTION.MOVE_UP);
        move_down_double_pressed  = input_check_double_pressed(INPUT_ACTION.MOVE_DOWN);
        jump_double_pressed       = input_check_double_pressed(INPUT_ACTION.JUMP);
        attack_double_pressed     = input_check_double_pressed(INPUT_ACTION.ATTACK);
        use_double_pressed        = input_check_double_pressed(INPUT_ACTION.USE);
        
        // Mouse raw double taps
        mouse_left_double_pressed   = input_check_double_pressed(INPUT_ACTION.MOUSE_LEFT);
        mouse_right_double_pressed  = input_check_double_pressed(INPUT_ACTION.MOUSE_RIGHT);
        mouse_middle_double_pressed = input_check_double_pressed(INPUT_ACTION.MOUSE_MIDDLE);
        
        // Aim
        var _aim = input_get_aim();
        aim_x = _aim.x;
        aim_y = _aim.y;
        aim_angle = _aim.angle;
        
        return self;
    }
    
    /// @desc Create input state from AI decisions
    /// @param {Real} _move_x Horizontal movement direction (-1, 0, 1)
    /// @param {Real} _move_y Vertical movement direction (-1, 0, 1)
    /// @param {Bool} _wants_jump Whether AI wants to jump
    /// @param {Bool} _wants_attack Whether AI wants to attack
    static from_ai = function(_move_x, _move_y, _wants_jump = false, _wants_attack = false)
    {
        move_x = _move_x;
        move_y = _move_y;
        
        jump_held = _wants_jump;
        jump_pressed = _wants_jump;
        jump_double_pressed = false;
        
        attack_held = _wants_attack;
        attack_pressed = _wants_attack;
        attack_double_pressed = false;
        
        use_held = false;
        
        move_left_double_pressed = false;
        move_right_double_pressed = false;
        move_up_double_pressed = false;
        move_down_double_pressed = false;
        use_pressed = false;
        use_double_pressed = false;
        mount_pressed = false;
        mouse_left_double_pressed = false;
        mouse_right_double_pressed = false;
        mouse_middle_double_pressed = false;
        
        aim_x = sign(_move_x);
        aim_y = 0;
        aim_angle = (_move_x >= 0) ? 0 : 180;
        
        return self;
    }
    
    /// @desc Clear all input (for when entity shouldn't move)
    static clear = function()
    {
        move_x = 0;
        move_y = 0;
        jump_held = false;
        jump_pressed = false;
        jump_double_pressed = false;
        attack_held = false;
        attack_pressed = false;
        attack_double_pressed = false;
        use_held = false;
        move_left_double_pressed = false;
        move_right_double_pressed = false;
        move_up_double_pressed = false;
        move_down_double_pressed = false;
        use_pressed = false;
        use_double_pressed = false;
        mount_pressed = false;
        mouse_left_double_pressed = false;
        mouse_right_double_pressed = false;
        mouse_middle_double_pressed = false;
        aim_x = 0;
        aim_y = 0;
        aim_angle = 0;
        
        return self;
    }
    
    /// @desc Serialize for network transmission
    static serialize = function()
    {
        var _flags = 0;
        if (jump_held)      _flags |= 1 << 0;
        if (jump_pressed)   _flags |= 1 << 1;
        if (attack_held)    _flags |= 1 << 2;
        if (attack_pressed) _flags |= 1 << 3;
        if (use_pressed)    _flags |= 1 << 4;
        if (mount_pressed)  _flags |= 1 << 5;
        if (jump_double_pressed)   _flags |= 1 << 6;
        if (attack_double_pressed) _flags |= 1 << 7;
        if (use_double_pressed)    _flags |= 1 << 8;
        
        // Additional double tap flags
        if (move_left_double_pressed)  _flags |= 1 << 9;
        if (move_right_double_pressed) _flags |= 1 << 10;
        if (move_up_double_pressed)    _flags |= 1 << 11;
        if (move_down_double_pressed)  _flags |= 1 << 12;
        if (mouse_left_double_pressed)   _flags |= 1 << 13;
        if (mouse_right_double_pressed)  _flags |= 1 << 14;
        if (mouse_middle_double_pressed) _flags |= 1 << 15;
        if (use_held) _flags |= 1 << 16;
        
        return {
            mx: move_x,
            my: move_y,
            flags: _flags,
            ax: aim_x,
            ay: aim_y
        }
    }
    
    /// @desc Deserialize from network
    static deserialize = function(_data)
    {
        move_x = _data.mx;
        move_y = _data.my;
        
        var _flags = _data.flags;
        jump_held =      !!(_flags & (1 << 0));
        jump_pressed =   !!(_flags & (1 << 1));
        attack_held =    !!(_flags & (1 << 2));
        attack_pressed = !!(_flags & (1 << 3));
        use_pressed =    !!(_flags & (1 << 4));
        mount_pressed =  !!(_flags & (1 << 5));
        jump_double_pressed =   !!(_flags & (1 << 6));
        attack_double_pressed = !!(_flags & (1 << 7));
        use_double_pressed =    !!(_flags & (1 << 8));
        
        move_left_double_pressed =  !!(_flags & (1 << 9));
        move_right_double_pressed = !!(_flags & (1 << 10));
        move_up_double_pressed =    !!(_flags & (1 << 11));
        move_down_double_pressed =  !!(_flags & (1 << 12));
        mouse_left_double_pressed =   !!(_flags & (1 << 13));
        mouse_right_double_pressed =  !!(_flags & (1 << 14));
        mouse_middle_double_pressed = !!(_flags & (1 << 15));
        use_held = !!(_flags & (1 << 16));
        
        aim_x = _data.ax;
        aim_y = _data.ay;
        aim_angle = point_direction(0, 0, aim_x, aim_y);
        
        return self;
    }
}

/// @desc Poll player input and return a new InputState
/// @returns {Struct.InputState}
function input_poll()
{
    return new InputState().poll_player();
}
