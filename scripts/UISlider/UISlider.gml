/* ui slider element - adjustable value slider */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width slider width */
/* @param {real} _min minimum value */
/* @param {real} _max maximum value */
/* @param {real} _value initial value */
function UISlider(_x, _y, _width, _min, _max, _value) : UIElement(_x, _y, _width, 16) constructor 
{
    setting_name = undefined;
    
    min_value = _min;
    
    max_value = _max;
    
    value = clamp(_value, _min, _max);
    
    step = 0; /* 0 = continuous */
    
    
    /* visual styling */
    track_sprite = spr_Menu_Indent;
    
    handle_sprite = spr_Menu_Button_Main;
    
    handle_select_sprite = spr_Menu_Button_Select;
    
    handle_xscale = 1;
    
    handle_yscale = 2;
    
    
    /* interaction state */
    is_dragging = false;
    
    is_hovered = false;
    
    
    static update = function() 
    {
        if !(visible) exit;
        
        
        var _abs_x = get_interaction_x();
        var _abs_y = get_interaction_y();
        
        
        var _mx = ui_get_mouse_x();
        var _my = ui_get_mouse_y();
        
        if (setting_name != undefined) && !(is_dragging)
        {
            if (global.settings[$ setting_name] != undefined)
            {
                value = clamp(global.settings[$ setting_name], min_value, max_value);
            }
        }
        
        
        var _left = _abs_x;
        var _hit_pad_x = max(0, (sprite_get_width(handle_sprite) * handle_xscale - width) * 0.5);
        var _hit_pad_y = max(0, ((sprite_get_height(handle_sprite) * handle_yscale) - height) * 0.5);
        var _top = _abs_y - _hit_pad_y;
        var _right = _left + width;
        var _bottom = _abs_y + height + _hit_pad_y;
        _left -= _hit_pad_x;
        _right += _hit_pad_x;
        
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        /* disable hover if the mouse is outside a parent scroll area clip */
        var _p = parent;
        while (_p != undefined)
        {
            if (instanceof(_p) == "UIScrollArea")
            {
                var _p_left = _p.get_absolute_x();
                var _p_top = _p.get_absolute_y();
                var _p_right = _p_left + _p.width;
                var _p_bottom = _p_top + _p.height;
                
                if (_mx < _p_left || _mx > _p_right || _my < _p_top || _my > _p_bottom)
                {
                    is_hovered = false;
                    
                    break;
                }
            }
            
            _p = _p.parent;
        }
        
        
        var _is_mouse_down = mouse_check_button(mb_left);
        
        if !(global.ui_input_consumed) && (_is_mouse_down)
        {
            if (is_hovered || is_dragging) 
            {
                if !(is_dragging)
                {
                    is_dragging = true;
                
                    sfx_play("phantasia:sfx/menu/button/select");
                }
                
                global.ui_input_consumed = true;
            }
        }
        
        
        if (!_is_mouse_down) 
        {
            if (is_dragging) 
            {
                is_dragging = false;
                
                emit_event("on_change", { value: value });
                emit_event("on_value_change", value);
            }
        }
        
        
        if (is_dragging) 
        {
            var _track_range = max(_right - _left, 0.0001);
            var _t = clamp((_mx - _left) / _track_range, 0, 1);
            var _new_value = lerp(min_value, max_value, _t);
            
            
            if (step > 0) 
            {
                _new_value = round(_new_value / step) * step;
            }
            
            
            value = clamp(_new_value, min_value, max_value);
            
            if (setting_name != undefined)
            {
                global.settings[$ setting_name] = value;
            }
            
            emit_event("on_drag", { value: value });
        }
        
        
        update_bindings();
    }
    
    
    static draw_content = function() 
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _cy = _y1 + (height * _base_scale_y / 2);
        
        var _range = max_value - min_value;
        var _t = (_range != 0) ? ((value - min_value) / _range) : 0;
        var _handle_x = lerp(_x1, _x2, _t);
        
        /* legacy slider track */
        draw_sprite_ext(track_sprite, 0, _x1 + ((_x2 - _x1) / 2), _cy, width / 8 * _base_scale_x, 16 / 8 * _base_scale_y, 0, c_white, 1);
        
        
        /* legacy slider handle */
        var _is_active = is_dragging;
        var _edge_sprite = asset_get_index(sprite_get_name(handle_sprite) + "_Edge");
        var _has_edge = sprite_exists(_edge_sprite);
        var _edge_offset = (_has_edge ? sprite_get_height(_edge_sprite) * handle_yscale * _base_scale_y : 0);
        var _handle_w = (sprite_get_width(handle_sprite) * handle_xscale * _base_scale_x) + 2;
        var _handle_h = (sprite_get_height(handle_sprite) * handle_yscale * _base_scale_y) + 2;
        var _draw_y = _cy + (_is_active ? _edge_offset : 0);
        
        if (is_hovered || _is_active)
        {
            draw_sprite_stretched_ext(handle_select_sprite, 0, _handle_x - (_handle_w / 2), _draw_y - (_handle_h / 2), _handle_w, _handle_h + (_is_active ? 0 : _edge_offset), c_white, 1);
        }
        
        if !(_is_active) && (_has_edge)
        {
            draw_sprite_ext(_edge_sprite, 0, _handle_x, _cy + ((sprite_get_height(handle_sprite) * handle_yscale * _base_scale_y) / 2), handle_xscale * _base_scale_x, 1, 0, c_white, 1);
        }
        
        draw_sprite_ext(handle_sprite, (_is_active ? 1 : 0), _handle_x, _draw_y, handle_xscale * _base_scale_x, handle_yscale * _base_scale_y, 0, c_white, 1);
    }


    static set_min = function(_min)
    {
        min_value = _min;
        value = clamp(value, min_value, max_value);

        return self;
    }


    static set_max = function(_max)
    {
        max_value = _max;
        value = clamp(value, min_value, max_value);

        return self;
    }


    static set_value = function(_value)
    {
        value = clamp(_value, min_value, max_value);

        return self;
    }
}
