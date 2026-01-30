/// @desc Input device types and action bindings

enum INPUT_DEVICE {
    KEYBOARD,
    GAMEPAD,
    TOUCH
}

enum INPUT_ACTION {
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    JUMP,
    ATTACK,
    USE,
    INVENTORY,
    MOUNT,
    PAUSE,
    SPRINT,
    // Mouse buttons (raw)
    MOUSE_LEFT,
    MOUSE_RIGHT,
    MOUSE_MIDDLE,
    // Extend as needed
    __SIZE
}

/// @desc Initialize default input bindings
function input_bindings_init()
{
    global.input_bindings = array_create(INPUT_ACTION.__SIZE);
    
    // Default keyboard bindings
    global.input_bindings[INPUT_ACTION.MOVE_LEFT]  = { keyboard: ord("A"), keyboard_alt: vk_left,  gamepad: undefined }
    global.input_bindings[INPUT_ACTION.MOVE_RIGHT] = { keyboard: ord("D"), keyboard_alt: vk_right, gamepad: undefined }
    global.input_bindings[INPUT_ACTION.MOVE_UP]    = { keyboard: ord("W"), keyboard_alt: vk_up,    gamepad: undefined }
    global.input_bindings[INPUT_ACTION.MOVE_DOWN]  = { keyboard: ord("S"), keyboard_alt: vk_down,  gamepad: undefined }
    global.input_bindings[INPUT_ACTION.JUMP]       = { keyboard: vk_space, keyboard_alt: undefined, gamepad: gp_face1 }
    global.input_bindings[INPUT_ACTION.ATTACK]     = { keyboard: undefined, keyboard_alt: undefined, gamepad: gp_face3, mouse: mb_left }
    global.input_bindings[INPUT_ACTION.USE]        = { keyboard: undefined, keyboard_alt: undefined, gamepad: gp_face2, mouse: mb_right }
    global.input_bindings[INPUT_ACTION.INVENTORY]  = { keyboard: ord("E"), keyboard_alt: vk_tab, gamepad: gp_select }
    global.input_bindings[INPUT_ACTION.MOUNT]      = { keyboard: ord("R"), keyboard_alt: undefined, gamepad: gp_face4 }
    global.input_bindings[INPUT_ACTION.SPRINT]     = { keyboard: vk_shift, keyboard_alt: undefined, gamepad: gp_stickl }
    global.input_bindings[INPUT_ACTION.PAUSE]      = { keyboard: vk_escape, keyboard_alt: undefined, gamepad: gp_start }
    
    // Mouse buttons (raw)
    global.input_bindings[INPUT_ACTION.MOUSE_LEFT]   = { keyboard: undefined, keyboard_alt: undefined, mouse: mb_left, gamepad: undefined }
    global.input_bindings[INPUT_ACTION.MOUSE_RIGHT]  = { keyboard: undefined, keyboard_alt: undefined, mouse: mb_right, gamepad: undefined }
    global.input_bindings[INPUT_ACTION.MOUSE_MIDDLE] = { keyboard: undefined, keyboard_alt: undefined, mouse: mb_middle, gamepad: undefined }
    
    // Player input device preference (can be auto-detected or set)
    global.player_input_device = INPUT_DEVICE.KEYBOARD;
    global.player_gamepad_slot = 0;
    
    // Double tap tracking
    global.input_last_press_time = array_create(INPUT_ACTION.__SIZE, -1000);
    global.input_double_tap_threshold = 250; // ms
}

/// @desc Check if an action is currently held
/// @param {Enum.INPUT_ACTION} _action
/// @returns {Bool}
function input_check(_action)
{
    var _binding = global.input_bindings[_action];
    var _device = global.player_input_device;
    
    switch (_device)
    {
        case INPUT_DEVICE.KEYBOARD:
            if (_binding.keyboard != undefined && keyboard_check(_binding.keyboard)) return true;
            if (_binding.keyboard_alt != undefined && keyboard_check(_binding.keyboard_alt)) return true;
            if (_binding[$ "mouse"] != undefined && mouse_check_button(_binding.mouse)) return true;
            return false;
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) return false;
            if (_binding.gamepad != undefined && gamepad_button_check(_slot, _binding.gamepad)) return true;
            return false;
            
        case INPUT_DEVICE.TOUCH:
            // Touch input handled separately via virtual buttons
            return false;
    }
    
    return false;
}

/// @desc Check if an action was just pressed this frame
/// @param {Enum.INPUT_ACTION} _action
/// @returns {Bool}
function input_check_pressed(_action)
{
    var _binding = global.input_bindings[_action];
    var _device = global.player_input_device;
    var _pressed = false;
    
    switch (_device)
    {
        case INPUT_DEVICE.KEYBOARD:
            if (_binding.keyboard != undefined && keyboard_check_pressed(_binding.keyboard)) _pressed = true;
            if (!_pressed && _binding.keyboard_alt != undefined && keyboard_check_pressed(_binding.keyboard_alt)) _pressed = true;
            if (!_pressed && _binding[$ "mouse"] != undefined && mouse_check_button_pressed(_binding.mouse)) _pressed = true;
            break;
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) break;
            if (_binding.gamepad != undefined && gamepad_button_check_pressed(_slot, _binding.gamepad)) _pressed = true;
            break;
            
        case INPUT_DEVICE.TOUCH:
            break;
    }
    
    return _pressed;
}

/// @desc Check if an action was double-pressed
/// @param {Enum.INPUT_ACTION} _action
/// @returns {Bool}
function input_check_double_pressed(_action)
{
    if (input_check_pressed(_action))
    {
        var _now = current_time;
        var _last = global.input_last_press_time[_action];
        var _is_double = (_now - _last) < global.input_double_tap_threshold;
        
        // Update last press time
        // If it was a double tap, we reset last press time to a very old one 
        // to prevent "triple tap" being two double taps in a row.
        global.input_last_press_time[_action] = _is_double ? -1000 : _now;
        
        return _is_double;
    }
    
    return false;
}

/// @desc Get analog axis value for movement
/// @param {Bool} _horizontal True for X axis, false for Y axis
/// @returns {Real} -1.0 to 1.0
function input_get_axis(_horizontal)
{
    var _device = global.player_input_device;
    
    switch (_device)
    {
        case INPUT_DEVICE.KEYBOARD:
            if (_horizontal)
            {
                return input_check(INPUT_ACTION.MOVE_RIGHT) - input_check(INPUT_ACTION.MOVE_LEFT);
            }
            else
            {
                return input_check(INPUT_ACTION.MOVE_DOWN) - input_check(INPUT_ACTION.MOVE_UP);
            }
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) return 0;
            
            var _value = _horizontal 
                ? gamepad_axis_value(_slot, gp_axislh)
                : gamepad_axis_value(_slot, gp_axislv);
            
            // Apply deadzone
            var _deadzone = 0.2;
            if (abs(_value) < _deadzone) return 0;
            return sign(_value) * ((abs(_value) - _deadzone) / (1 - _deadzone));
            
        case INPUT_DEVICE.TOUCH:
            return 0;
    }
    
    return 0;
}

/// @desc Get aim direction (mouse or right stick)
/// @returns {Struct} { x, y, angle }
function input_get_aim()
{
    var _device = global.player_input_device;
    
    switch (_device)
    {
        case INPUT_DEVICE.KEYBOARD:
            // Mouse-based aiming relative to player
            if (instance_exists(obj_Player))
            {
                var _dx = mouse_x - obj_Player.x;
                var _dy = mouse_y - obj_Player.y;
                var _dist = point_distance(0, 0, _dx, _dy);
                
                return {
                    x: (_dist > 0) ? _dx / _dist : 0,
                    y: (_dist > 0) ? _dy / _dist : 0,
                    angle: point_direction(0, 0, _dx, _dy)
                }
            }
            return { x: 1, y: 0, angle: 0 }
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) return { x: 0, y: 0, angle: 0 }
            
            var _rx = gamepad_axis_value(_slot, gp_axisrh);
            var _ry = gamepad_axis_value(_slot, gp_axisrv);
            var _dist = point_distance(0, 0, _rx, _ry);
            
            if (_dist < 0.3) return { x: 0, y: 0, angle: 0 }
            
            return {
                x: _rx / _dist,
                y: _ry / _dist,
                angle: point_direction(0, 0, _rx, _ry)
            }
            
        case INPUT_DEVICE.TOUCH:
            return { x: 0, y: 0, angle: 0 }
    }
    
    return { x: 0, y: 0, angle: 0 }
}
