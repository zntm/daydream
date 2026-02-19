/// @desc UI Line Element - draws a line from point A to point B
/// @param {Real} _x X position offset
/// @param {Real} _y Y position offset
function UILine(_x, _y) : UIElement(_x, _y, 0, 0) constructor {
    start_x = 0;
    start_y = 0;
    end_x = 0;
    end_y = 0;
    thickness = 1;
    colour = c_white;
    
    /// @desc Set start point from a tuple
    static set_start = function(_value) {
        if (is_array(_value) && array_length(_value) >= 2) {
            start_x = _value[0];
            start_y = _value[1];
            recalculate_bounds();
        }
    }
    
    /// @desc Set end point from a tuple
    static set_end = function(_value) {
        if (is_array(_value) && array_length(_value) >= 2) {
            end_x = _value[0];
            end_y = _value[1];
            recalculate_bounds();
        }
    }
    
    /// @desc Recalculate width/height from start/end points
    static recalculate_bounds = function() {
        width = abs(end_x - start_x);
        height = abs(end_y - start_y);
    }
    
    static draw_content = function() {
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _sx = (_abs_x + start_x) * _base_scale.x;
        var _sy = (_abs_y + start_y) * _base_scale.y;
        var _ex = (_abs_x + end_x) * _base_scale.x;
        var _ey = (_abs_y + end_y) * _base_scale.y;
        
        var _scaled_thickness = max(1, thickness * _base_scale.x);
        
        draw_line_width_colour(_sx, _sy, _ex, _ey, _scaled_thickness, colour, colour);
    }
}
