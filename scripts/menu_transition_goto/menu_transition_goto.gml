/// @desc Menu transition with shrink/fade out, then fade in/bulge effect
/// @param {Asset.GMRoom} _room Target room to transition to

// Initialize transition globals
global.menu_transition_target = noone;
global.menu_transition_phase = 0;  // 0=none, 1=shrink+fade, 2=fade+bulge
global.menu_transition_progress = 0;

function menu_transition_goto(_room)
{
    if (global.menu_transition_phase != 0) exit;
    
    global.menu_transition_target = _room;
    global.menu_transition_phase = 1;  // Start shrink+fade phase
    global.menu_transition_progress = 0;
}

/// @desc Update menu transition (call from obj_Menu_Control Step)
/// @returns {bool} True if transition is active
function menu_transition_update()
{
    if (global.menu_transition_phase == 0) return false;
    
    var _duration = max(0.001, global.settings.graphics_menu_transition_fade_speed);
    var _dt = global.delta_time;
    
    global.menu_transition_progress += _dt / _duration;
    
    // Scale macros
    var _scale_min = MENU_TRANSITION_SCALE_MIN;
    var _scale_max = MENU_TRANSITION_SCALE_MAX;
    
    // Manage blur alpha (persistent based on target room)
    var _target_blur = (global.menu_transition_target != rm_Menu_Title && global.menu_transition_target != rm_World) ? 1 : 0;
    
    if (global.menu_transition_phase != 0)
    {
        // During transition, lerp towards target blur
        var _blur_speed = 1.0 / _duration;
        if (global.menu_blur_alpha < _target_blur)
        {
            global.menu_blur_alpha = min(_target_blur, global.menu_blur_alpha + _dt * _blur_speed);
        }
        else
        {
            global.menu_blur_alpha = max(_target_blur, global.menu_blur_alpha - _dt * _blur_speed);
        }
    }
    
    if (global.menu_transition_phase == 1)  // Shrink + fade out
    {
        // Capture background for blur if just starting
        if (global.menu_transition_progress <= (_dt / _duration) * 2) 
        {
            global.menu_capture_blur = true;
        }
        
        var _t = clamp(global.menu_transition_progress, 0, 1);
        var _eased = power(_t, 2);  // Ease in (accelerating)
        
        // Apply shrink and fade
        global.menu_transition_scale = lerp(_scale_max, _scale_min, _eased);
        
        // Alpha will be handled separately via global for surface drawing
        global.menu_transition_alpha = 1 - _eased;
        
        if (_t >= 1)
        {
            room_goto(global.menu_transition_target);
            global.menu_transition_phase = 2;  // Start fade in + bulge (expand)
            global.menu_transition_progress = 0;
            global.menu_transition_scale = _scale_min;
        }
    }
    else if (global.menu_transition_phase == 2)  // Fade in + Expand (Ease Out)
    {
        var _t = clamp(global.menu_transition_progress, 0, 1);
        
        // Ease out (decelerating) - cubic ease out for smoothness
        var _eased = 1 - power(1 - _t, 3);
        
        // Expand: min -> max
        var _scale = lerp(_scale_min, _scale_max, _eased);
        
        global.menu_transition_scale = _scale;
        
        global.menu_transition_alpha = _eased;
        
        if (_t >= 1)
        {
            // Transition complete
            global.menu_transition_scale = 1;
            global.menu_transition_alpha = 1;
            global.menu_transition_phase = 0;
            
            // Ensure blur is fully set
            global.menu_blur_alpha = _target_blur;
        }
    }
    
    return true;
}

/// @desc Check if menu transition is active
function menu_transition_is_active()
{
    return global.menu_transition_phase != 0;
}

// Initialize global alpha and scale
global.menu_transition_alpha = 1;
global.menu_transition_scale = 1;
global.menu_blur_alpha = 0;
global.menu_capture_blur = false;
global.menu_blur_surface = [ -1, -1 ];
