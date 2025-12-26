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
    // Extend as needed
    __SIZE
}

/// @desc Initialize default input bindings
function input_bindings_init()
{
    global.input_bindings = array_create(INPUT_ACTION.__SIZE);
    
    // Default keyboard bindings
    global.input_bindings[INPUT_ACTION.MOVE_LEFT]  = { keyboard: ord("A"), keyboard_alt: vk_left,  gamepad: undefined };
    global.input_bindings[INPUT_ACTION.MOVE_RIGHT] = { keyboard: ord("D"), keyboard_alt: vk_right, gamepad: undefined };
    global.input_bindings[INPUT_ACTION.MOVE_UP]    = { keyboard: ord("W"), keyboard_alt: vk_up,    gamepad: undefined };
    global.input_bindings[INPUT_ACTION.MOVE_DOWN]  = { keyboard: ord("S"), keyboard_alt: vk_down,  gamepad: undefined };
    global.input_bindings[INPUT_ACTION.JUMP]       = { keyboard: vk_space, keyboard_alt: undefined, gamepad: gp_face1 };
    global.input_bindings[INPUT_ACTION.ATTACK]     = { keyboard: undefined, keyboard_alt: undefined, gamepad: gp_face3, mouse: mb_left };
    global.input_bindings[INPUT_ACTION.USE]        = { keyboard: undefined, keyboard_alt: undefined, gamepad: gp_face2, mouse: mb_right };
    global.input_bindings[INPUT_ACTION.INVENTORY]  = { keyboard: ord("E"), keyboard_alt: vk_tab, gamepad: gp_select };
    global.input_bindings[INPUT_ACTION.MOUNT]      = { keyboard: ord("R"), keyboard_alt: undefined, gamepad: gp_face4 };
    global.input_bindings[INPUT_ACTION.PAUSE]      = { keyboard: vk_escape, keyboard_alt: undefined, gamepad: gp_start };
    
    // Player input device preference (can be auto-detected or set)
    global.player_input_device = INPUT_DEVICE.KEYBOARD;
    global.player_gamepad_slot = 0;
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
    
    switch (_device)
    {
        case INPUT_DEVICE.KEYBOARD:
            if (_binding.keyboard != undefined && keyboard_check_pressed(_binding.keyboard)) return true;
            if (_binding.keyboard_alt != undefined && keyboard_check_pressed(_binding.keyboard_alt)) return true;
            if (_binding[$ "mouse"] != undefined && mouse_check_button_pressed(_binding.mouse)) return true;
            return false;
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) return false;
            if (_binding.gamepad != undefined && gamepad_button_check_pressed(_slot, _binding.gamepad)) return true;
            return false;
            
        case INPUT_DEVICE.TOUCH:
            return false;
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
                };
            }
            return { x: 1, y: 0, angle: 0 };
            
        case INPUT_DEVICE.GAMEPAD:
            var _slot = global.player_gamepad_slot;
            if (!gamepad_is_connected(_slot)) return { x: 0, y: 0, angle: 0 };
            
            var _rx = gamepad_axis_value(_slot, gp_axisrh);
            var _ry = gamepad_axis_value(_slot, gp_axisrv);
            var _dist = point_distance(0, 0, _rx, _ry);
            
            if (_dist < 0.3) return { x: 0, y: 0, angle: 0 };
            
            return {
                x: _rx / _dist,
                y: _ry / _dist,
                angle: point_direction(0, 0, _rx, _ry)
            };
            
        case INPUT_DEVICE.TOUCH:
            return { x: 0, y: 0, angle: 0 };
    }
    
    return { x: 0, y: 0, angle: 0 };
}
