/* ui radio button element - exclusive selection option */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {string} _text label text */
function UIRadioButton(_x, _y, _text = "") : UIElement(_x, _y, 100, 20) constructor 
{
    text = _text;
    
    setting_name = undefined;
    
    value = ""; /* the value this button represents */
    
    group = ""; /* radio group name */
    
    selected = false;
    
    
    /* visual styling */
    circle_size = 8;
    
    circle_color = #3a3a4a;
    
    selected_color = #4a8aff;
    
    text_color = c_white;
    
    track_sprite = spr_Menu_Indent;
    
    handle_sprite = spr_Menu_Button_Main;
    
    handle_select_sprite = spr_Menu_Button_Select;
    
    handle_xscale = 1;
    
    handle_yscale = 2;
    
    
    /* hover state */
    is_hovered = false;
    
    
    static update = function() 
    {
        if !(visible) exit;
        
        
        var _abs_x = get_interaction_x();
        var _abs_y = get_interaction_y();
        
        
        var _mx = ui_get_mouse_x();
        var _my = ui_get_mouse_y();
        
        if (setting_name != undefined)
        {
            var _setting_value = global.settings[$ setting_name];
            
            if (_setting_value != undefined)
            {
                selected = (_setting_value == true);
            }
        }
        
        
        var _left = _abs_x;
        var _top = _abs_y;
        var _right = _left + get_width();
        var _bottom = _top + get_height();
        
        
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        var _p = parent;
        while (ui_element_is_valid_parent(_p))
        {
            if (instanceof(_p) == "UIScrollArea")
            {
                var _p_left = _p.get_absolute_x();
                var _p_top = _p.get_absolute_y();
                var _p_right = _p_left + ui_layout_resolve_scalar(_p.width, 0);
                var _p_bottom = _p_top + ui_layout_resolve_scalar(_p.height, 0);
                
                if (_mx < _p_left || _mx > _p_right || _my < _p_top || _my > _p_bottom)
                {
                    is_hovered = false;
                    
                    break;
                }
            }
            
            _p = _p.parent;
        }
        
        
        if (is_hovered) && !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left)) 
        {
            var _next_selected = !selected;

            if (group != "")
            {
                _next_selected = true;

                if (parent != undefined)
                {
                    var _child_count = array_length(parent.children);

                    for (var i = _child_count - 1; i >= 0; --i)
                    {
                        var _child = parent.children[i];

                        if (_child == self) continue;

                        if (instanceof(_child) != "UIRadioButton") continue;

                        if (_child.group == group)
                        {
                            _child.deselect();
                        }
                    }
                }
            }

            set_selected(_next_selected);

            global.ui_input_consumed = true;

            if (selected)
            {
                emit_event("on_select", { value: value, group: group, selected: selected });
            }
            else
            {
                emit_event("on_deselect", { value: value, group: group, selected: selected });
            }

            emit_event("on_change", { value: value, group: group, selected: selected });
            emit_event("on_select_release", { value: value, group: group, selected: selected });

            sfx_play("phantasia:sfx/menu/button/select");
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


        if (text == "")
        {
            var _x1 = _abs_x * _base_scale_x;
            var _y1 = _abs_y * _base_scale_y;
            var _radio_width = get_width();
            var _radio_height = get_height();
            var _x2 = _x1 + (_radio_width * _base_scale_x);
            var _cy = _y1 + (_radio_height * _base_scale_y * 0.5);
            var _track_mid_x = _x1 + ((_x2 - _x1) * 0.5);
            var _track_width = _radio_width * _base_scale_x;
            var _handle_x = selected ? _x2 : (_x2 - 32 * _base_scale_x);
            var _edge_sprite = asset_get_index(sprite_get_name(handle_sprite) + "_Edge");
            var _has_edge = sprite_exists(_edge_sprite);
            var _edge_offset = (_has_edge ? sprite_get_height(_edge_sprite) * handle_yscale * _base_scale_y : 0);
            var _is_active = false;
            var _handle_w = (sprite_get_width(handle_sprite) * handle_xscale * _base_scale_x) + 2;
            var _handle_h = (sprite_get_height(handle_sprite) * handle_yscale * _base_scale_y) + 2;
            var _draw_y = _cy + (_is_active ? _edge_offset : 0);

            draw_sprite_ext(track_sprite, 0, _track_mid_x, _cy, _track_width / 8, 16 / 8 * _base_scale_y, 0, c_white, 1);
            
            if (is_hovered)
            {
                draw_sprite_stretched_ext(handle_select_sprite, 0, _handle_x - (_handle_w / 2), _draw_y - (_handle_h / 2), _handle_w, _handle_h + _edge_offset, c_white, 1);
            }
            
            if (_has_edge)
            {
                draw_sprite_ext(_edge_sprite, 0, _handle_x, _cy + ((sprite_get_height(handle_sprite) * handle_yscale * _base_scale_y) / 2), handle_xscale * _base_scale_x, 1, 0, c_white, 1);
            }
            
            draw_sprite_ext(handle_sprite, 0, _handle_x, _draw_y, handle_xscale * _base_scale_x, handle_yscale * _base_scale_y, 0, c_white, 1);

            exit;
        }
        
        
        var _circle_x = (_abs_x + circle_size) * _base_scale_x;
        var _circle_y = (_abs_y + height / 2) * _base_scale_y;
        var _radius = min(circle_size * _base_scale_x, (height * _base_scale_y) * 0.5);
        
        
        /* draw outer circle */
        draw_circle_colour(_circle_x, _circle_y, _radius, circle_color, circle_color, false);
        
        
        /* draw selected indicator */
        if (selected) 
        {
            draw_circle_colour(_circle_x, _circle_y, _radius * 0.6, selected_color, selected_color, false);
        }
        
        
        /* draw text */
        var _text_x = (_abs_x + circle_size * 2 + 8) * _base_scale_x;
        var _text_y = _circle_y;

        var _prev_halign = draw_get_halign();
        var _prev_valign = draw_get_valign();

        draw_set_align(fa_left, fa_middle);


        draw_text_cuteify(
            _text_x, _text_y,
            text,
            _base_scale_x * 0.8,
            _base_scale_y * 0.8,
            0,
            text_color,
            1
        );


        draw_set_align(_prev_halign, _prev_valign);
    }
    
    
    /* deselect this radio button (called when another in group is selected) */
    static deselect = function() 
    {
        selected = false;

        return self;
    }


    static set_selected = function(_selected)
    {
        selected = (_selected == true);

        return self;
    }
}
