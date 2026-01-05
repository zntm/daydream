/// @description Global UI Manager for input handling and focus management

function UIManager() constructor
{
    root = undefined;
    root_stack = []; // Stack for modal dialogs
    focused_element = undefined;
    hovered_element = undefined;
    
    // Navigation
    focusable_elements = [];
    focus_index = 0;
    
    // Input Repeat
    repeat_delay = 20; // Frames before repeating starts (0.33s at 60fps)
    repeat_rate = 5;   // Frames between repeats (0.08s)
    
    input_timer_h = 0; // Horizontal
    input_timer_v = 0; // Vertical
    input_timer_tab = 0; // Tab
    
    last_h = 0;
    last_v = 0;
    last_tab = 0;
    
    // Scaling (reference resolution)
    reference_width = 960;
    reference_height = 540;
    
    // Ensure globals exist
    if (!variable_global_exists("gui_width")) global.gui_width = display_get_gui_width();
    if (!variable_global_exists("gui_height")) global.gui_height = display_get_gui_height();
    if (!variable_global_exists("gui_mouse_x")) global.gui_mouse_x = device_mouse_x_to_gui(0);
    if (!variable_global_exists("gui_mouse_y")) global.gui_mouse_y = device_mouse_y_to_gui(0);

    
    // --- Root Management ---
    
    static set_root = function(_root)
    {
        root = _root;
        root_stack = []; // Clear modal stack when setting new root
        clear_focus();
        return self;
    }
    
    static get_root = function()
    {
        return root;
    }
    
    /// @desc Push a modal dialog on top of the current root
    /// @param {Struct.UIElement} _modal The modal element to push
    static push_root = function(_modal)
    {
        if (root != undefined)
        {
            array_push(root_stack, root);
        }
        root = _modal;
        clear_focus();
        layout();
        return self;
    }
    
    /// @desc Pop the current modal and restore the previous root
    /// @returns {Struct.UIElement} The popped modal element
    static pop_root = function()
    {
        var _popped = root;
        
        if (array_length(root_stack) > 0)
        {
            root = array_pop(root_stack);
        }
        else
        {
            root = undefined;
        }
        
        clear_focus();
        if (root != undefined) layout();
        return _popped;
    }
    
    /// @desc Get the current modal stack depth
    static get_modal_depth = function()
    {
        return array_length(root_stack);
    }

    
    // --- Focus Management ---
    
    static set_focus = function(_element)
    {
        if (focused_element == _element) return;
        
        if (focused_element != undefined && focused_element.on_blur != undefined)
        {
            focused_element.on_blur(focused_element);
        }
        
        focused_element = _element;
        
        if (focused_element != undefined)
        {
            focused_element.state = UI_STATE.FOCUSED;
            if (focused_element.on_focus != undefined)
            {
                focused_element.on_focus(focused_element);
            }
        }
        
        return self;
    }
    
    static clear_focus = function()
    {
        set_focus(undefined);
        return self;
    }
    
    // --- Navigation ---
    
    static build_focus_list = function(_element = root, _list = [])
    {
        if (_element == undefined || !_element.visible || !_element.enabled) return _list;
        
        if (_element.focusable)
        {
            array_push(_list, _element);
        }
        
        var _child_count = array_length(_element.children);
        for (var i = 0; i < _child_count; ++i)
        {
            build_focus_list(_element.children[i], _list);
        }
        
        return _list;
    }
    
    static focus_directional = function(_dx, _dy)
    {
        focusable_elements = build_focus_list();
        var _len = array_length(focusable_elements);
        if (_len == 0) return;
        
        // If nothing is focused, select the first one (or closest to top-left?)
        if (focused_element == undefined)
        {
            set_focus(focusable_elements[0]);
            sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
            return;
        }
        
        var _fx = focused_element.get_absolute_x() + focused_element._computed_width / 2;
        var _fy = focused_element.get_absolute_y() + focused_element._computed_height / 2;
        
        var _best_candidate = undefined;
        var _best_score = infinity;
        
        for (var i = 0; i < _len; ++i)
        {
            var _candidate = focusable_elements[i];
            if (_candidate == focused_element) continue;
            
            var _cx = _candidate.get_absolute_x() + _candidate._computed_width / 2;
            var _cy = _candidate.get_absolute_y() + _candidate._computed_height / 2;
            
            var _diff_x = _cx - _fx;
            var _diff_y = _cy - _fy;
            
            // Check direction
            var _dot = dot_product(_diff_x, _diff_y, _dx, _dy);
            if (_dot <= 0) continue; // Wrong direction
            
            // Calculate score (weighted distance)
            // Prioritize elements more aligned with the direction
            var _dist_sq = (_diff_x * _diff_x) + (_diff_y * _diff_y);
            
            // Angle penalty: projected distance vs actual distance
            // We want components that are "straight ahead" to be preferred over those far to the side
            var _projected = abs(_diff_x * _dx + _diff_y * _dy);
            var _perpendicular = abs(_diff_x * _dy - _diff_y * _dx);
            
            // Score: primarily distance, but heavily penalize perpendicular offset
            var _score = _projected + (_perpendicular * 2); 
            
            if (_score < _best_score)
            {
                _best_score = _score;
                _best_candidate = _candidate;
            }
        }
        
        if (_best_candidate != undefined)
        {
            set_focus(_best_candidate);
            sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
        }
    }
    
    static focus_next_linear = function()
    {
        focusable_elements = build_focus_list();
        var _len = array_length(focusable_elements);
        if (_len == 0) return;
        
        var _index = -1;
        if (focused_element != undefined)
        {
            _index = array_get_index(focusable_elements, focused_element);
        }
        
        var _next_index = (_index + 1) mod _len;
        set_focus(focusable_elements[_next_index]);
        sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
    }
    
    static focus_previous_linear = function()
    {
        focusable_elements = build_focus_list();
        var _len = array_length(focusable_elements);
        if (_len == 0) return;
        
        var _index = -1;
        if (focused_element != undefined)
        {
            _index = array_get_index(focusable_elements, focused_element);
        }
        
        var _prev_index = (_index - 1 + _len) mod _len;
        set_focus(focusable_elements[_prev_index]);
        sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
    }
    
    static activate_focused = function()
    {
        if (focused_element == undefined) return;
        if (focused_element.on_click != undefined)
        {
            focused_element.on_click(focused_element);
            sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
        }
    }
    
    // --- Input Processing ---
    
    static process_input = function()
    {
        if (root == undefined) return;
        
        // Block input during transitions
        if (variable_global_exists("menu_transition_phase") && global.menu_transition_phase != 0) return;
        
        // Get scaled mouse position
        var _scale_x = global.gui_width / reference_width;
        var _scale_y = global.gui_height / reference_height;
        var _mouse_x = global.gui_mouse_x / _scale_x;
        var _mouse_y = global.gui_mouse_y / _scale_y;
        
        var _pressed = mouse_check_button_pressed(mb_left);
        var _held = mouse_check_button(mb_left);
        var _released = mouse_check_button_released(mb_left);
        
        // Process mouse input
        var _new_hovered = root.handle_input(_mouse_x, _mouse_y, _pressed, _held, _released);
        
        if (_new_hovered != undefined && _new_hovered != hovered_element)
        {
            if (hovered_element == undefined)
            {
                sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
            }
            hovered_element = _new_hovered;
        }
        else if (_new_hovered == undefined)
        {
            hovered_element = undefined;
        }
        
        // If the focused element consumed the input (e.g. slider), stop navigation
        if (focused_element != undefined && focused_element.state == UI_STATE.FOCUSED)
        {
             // Input consumption check placeholder
        }
        
        // --- Gamepad & Keyboard Navigation (With Repeat) ---
        
        // 1. Get raw input state (Held)
        var _h_input = 0;
        var _v_input = 0;
        
        if (keyboard_check(vk_right) || gamepad_button_check(0, gp_padr)) _h_input = 1;
        if (keyboard_check(vk_left)  || gamepad_button_check(0, gp_padl)) _h_input = -1;
        
        if (keyboard_check(vk_down) || gamepad_button_check(0, gp_padd)) _v_input = 1;
        if (keyboard_check(vk_up)   || gamepad_button_check(0, gp_padu)) _v_input = -1;
        
        // 2. Process Horizontal Repeat
        var _nav_right = false;
        var _nav_left = false;
        
        if (_h_input != 0)
        {
            if (_h_input != last_h)
            {
                // New press
                last_h = _h_input;
                input_timer_h = repeat_delay;
                
                if (_h_input > 0) _nav_right = true;
                else              _nav_left = true;
            }
            else
            {
                // Holding
                if (input_timer_h > 0)
                {
                    input_timer_h--;
                }
                else
                {
                    // Trigger repeat
                    input_timer_h = repeat_rate;
                    if (_h_input > 0) _nav_right = true;
                    else              _nav_left = true;
                }
            }
        }
        else
        {
            last_h = 0;
            input_timer_h = 0;
        }
        
        // 3. Process Vertical Repeat
        var _nav_down = false;
        var _nav_up = false;
        
        if (_v_input != 0)
        {
            if (_v_input != last_v)
            {
                // New press
                last_v = _v_input;
                input_timer_v = repeat_delay;
                
                if (_v_input > 0) _nav_down = true;
                else              _nav_up = true;
            }
            else
            {
                // Holding
                if (input_timer_v > 0)
                {
                    input_timer_v--;
                }
                else
                {
                    // Trigger repeat
                    input_timer_v = repeat_rate;
                    if (_v_input > 0) _nav_down = true;
                    else              _nav_up = true;
                }
            }
        }
        else
        {
            last_v = 0;
            input_timer_v = 0;
        }
        
        // 4. Process Tab Repeat
        var _tab = false;
        var _tab_input = 0;
        if (keyboard_check(vk_tab) || gamepad_button_check(0, gp_select)) _tab_input = 1;
        
        if (_tab_input != 0)
        {
            if (_tab_input != last_tab)
            {
                // New press
                last_tab = _tab_input;
                input_timer_tab = repeat_delay;
                _tab = true;
            }
            else
            {
                // Holding
                if (input_timer_tab > 0)
                {
                    input_timer_tab--;
                }
                else
                {
                    // Trigger repeat
                    input_timer_tab = repeat_rate;
                    _tab = true;
                }
            }
        }
        else
        {
            last_tab = 0;
            input_timer_tab = 0;
        }

        var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
        var _cancel = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_face2);
        // _tab is now calculated above with repeat logic
        
        // SPECIAL: If a slider is focused, it might want left/right.
        var _is_slider = (focused_element != undefined && is_instanceof(focused_element, UISlider));
        
        if (_is_slider && (_nav_left || _nav_right))
        {
            var _slider = focused_element;
            var _step = _slider.step;
            var _mult = (keyboard_check(vk_shift) || gamepad_button_check(0, gp_face3)) ? 5 : 1;
            
            if (_nav_right) _slider.set_value(_slider.value + _step * _mult);
            if (_nav_left) _slider.set_value(_slider.value - _step * _mult);
            
            // Don't do navigation
            _nav_right = false;
            _nav_left = false;
        }

        if (_tab)
        {
            if (focusable_elements == undefined || array_length(focusable_elements) == 0)
            {
               focusable_elements = build_focus_list();
            }
            
            // If nothing focused, start at 0
            if (focused_element == undefined)
            {
                if (array_length(focusable_elements) > 0)
                {
                    set_focus(focusable_elements[0]);
                    sfx_play("phantasia:sfx/menu/button/hover", global.settings.audio_ui);
                }
            }
            else
            {
                if (keyboard_check(vk_shift))
                {
                    focus_previous_linear();
                }
                else
                {
                    focus_next_linear();
                }
            }
        }
        
        if (_nav_right) focus_directional(1, 0);
        if (_nav_left) focus_directional(-1, 0);
        if (_nav_down) focus_directional(0, 1);
        if (_nav_up) focus_directional(0, -1);
        
        if (_confirm) activate_focused();
        if (_cancel) clear_focus();
    }
    
    // --- Layout & Rendering ---
    
    static layout = function()
    {
        if (root == undefined) return;
        
        root._computed_x = 0;
        root._computed_y = 0;
        root.calculate_layout(reference_width, reference_height);
    }
    
    static update = function()
    {
        // Update globals if we are the primary controller
        global.gui_width = display_get_gui_width();
        global.gui_height = display_get_gui_height();
        global.gui_mouse_x = device_mouse_x_to_gui(0);
        global.gui_mouse_y = device_mouse_y_to_gui(0);
        
        process_input();
        
        if (root != undefined)
        {
            root.update();
        }
    }
    
    static draw = function()
    {
        if (root == undefined) return;
        
        // Apply scaling transform
        var _scale_x = global.gui_width / reference_width;
        var _scale_y = global.gui_height / reference_height;
        
        // Combine with transition scale
        var _trans_scale = 1;
        var _trans_alpha = 1;
        
        if (variable_global_exists("menu_transition_scale")) _trans_scale = global.menu_transition_scale;
        if (variable_global_exists("menu_transition_alpha")) _trans_alpha = global.menu_transition_alpha;
        
        _scale_x *= _trans_scale;
        _scale_y *= _trans_scale;
        
        // Center the scaling origin on screen center
        var _center_x = global.gui_width / 2;
        var _center_y = global.gui_height / 2;
        
        // Matrix: Translate to origin -> Scale -> Translate back
        // But since we are drawing in GUI space, 0,0 is top left.
        // We want the whole GUI to scale from center?
        // Old menu used manual offsets.
        // Let's try simple scaling from center.
        
        // Build matrix:
        // 1. Translate (-center)
        // 2. Scale
        // 3. Translate (+center) (but accounting for scale? No, matrix multiplication)
        
        // Actually, matrix_build handles this if we give it the position.
        // But our root is at 0,0 locally.
        // If we want to zoom the entire UI:
        // Translate to internal center (reference_width/2, reference_height/2) -> Scale -> Move to screen center.
        
        // Let's stick to simple Top-Left scaling combined with the transition scale, 
        // but maybe applied around the center if transition needs it?
        // The old transition had a "bulge" effect.
        // For simplicity, let's just scale everything globally from the center of the screen.
        
        var _matrix_scale_x = _scale_x;
        var _matrix_scale_y = _scale_y;
        
        // Calculate offset to keep it centered when scaling
        // Final Width = RefWidth * ScaleX
        // Screen Center X = ScreenWidth / 2
        // TopLeft Should be = ScreenCenterX - (FinalWidth / 2)
        
        var _final_w = reference_width * _matrix_scale_x;
        var _final_h = reference_height * _matrix_scale_y;
        
        var _pos_x = (global.gui_width - _final_w) / 2;
        var _pos_y = (global.gui_height - _final_h) / 2;
        
        // If transition scale is 1, _pos_x should be 0 (if gui_width matches ref * scale)
        // Wait, regular GUI scaling handles aspect ratio how?
        // Current logic: _scale_x = global.gui_width / reference_width.
        // So _final_w = reference_width * (gui_width / reference_width) = gui_width.
        // So _pos_x = 0. Correct.
        
        // If _transition_scale < 1, then _scale_x decreases, _final_w decreases.
        // _pos_x becomes positive. So it shrinks to center. Correct.
        
        var _matrix = matrix_build(_pos_x, _pos_y, 0, 0, 0, 0, _matrix_scale_x, _matrix_scale_y, 1);
        matrix_set(matrix_world, _matrix);
        
        var _old_alpha = draw_get_alpha();
        draw_set_alpha(_old_alpha * _trans_alpha);
        
        root.draw();
        
        // Reset scissor to ensure focus indicator is visible
        gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
        
        // Draw focus indicator
        if (focused_element != undefined && focused_element.visible)
        {
            var _abs_x = focused_element.get_absolute_x();
            var _abs_y = focused_element.get_absolute_y();
            var _w = focused_element._computed_width;
            var _h = focused_element._computed_height;
            
            draw_set_colour(c_white);
            draw_set_alpha(0.5 + 0.3 * sin(current_time / 200));
            draw_rectangle(_abs_x - 2, _abs_y - 2, _abs_x + _w + 2, _abs_y + _h + 2, true);
        }
        
        draw_set_alpha(_old_alpha);
        matrix_set(matrix_world, matrix_build_identity());
        
        // Draw Cursor (Always on top, unscaled/untransformed relative to screen, or scaled?)
        // The old menu likely drew it in GUI coordinates.
        // We should draw it after resetting the matrix.
        
        // Check for custom cursor sprite
        // Check for custom cursor sprite
        var _cursor_sprite = -1;
        
        // 1. Try "spr_Cursor_Mouse" (Asset name)
        var _asset_index = asset_get_index("spr_Cursor_Mouse");
        if (_asset_index > -1) _cursor_sprite = _asset_index;
        
        // 2. Try builtin cursor_sprite variable
        if (_cursor_sprite == -1 && cursor_sprite > -1) _cursor_sprite = cursor_sprite;
        
        // 3. Try "spr_Mouse" (Asset name) - Common fallback
        if (_cursor_sprite == -1)
        {
             var _fallback = asset_get_index("spr_Mouse");
             if (_fallback > -1) _cursor_sprite = _fallback;
        }

        if (_cursor_sprite > -1)
        {
            draw_sprite_ext(_cursor_sprite, 0, global.gui_mouse_x, global.gui_mouse_y, 1, 1, 0, c_white, 1);
        }
    }
}

// Global UI manager instance
global.ui_manager = new UIManager();
