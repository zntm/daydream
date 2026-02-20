/* ui line path element - multi-segment line path with optional sprites */
/* @param {real} _x x position offset */
/* @param {real} _y y position offset */
function UILinePath(_x, _y) : UIElement(_x, _y, 0, 0) constructor 
{
    points = [];       /* array of [x, y] pairs */
    
    thickness = 1;
    
    colour = c_white;
    
    
    /* sprite decorations */
    sprite_start = undefined;   /* sprite def struct or undefined */
    
    sprite_end = undefined;
    
    sprite_turn = undefined;
    
    
    /* joint rendering type: "none", "turn", "plus", "T" */
    joint_type = "turn";
    
    
    /* set points from a resolved array of tuples */
    static set_points = function(_value) 
    {
        if (is_array(_value)) 
        {
            points = _value;
            
            recalculate_bounds();
        }
    }
    
    
    /* recalculate width/height from all points */
    static recalculate_bounds = function() 
    {
        if (array_length(points) == 0) 
        {
            width = 0;
            
            height = 0;
            
            exit;
        }
        
        
        var _min_x = infinity;
        var _min_y = infinity;
        var _max_x = -infinity;
        var _max_y = -infinity;
        
        var _count = array_length(points);
        
        
        for (var i = _count - 1; i >= 0; --i) 
        {
            var _pt = points[i];
            
            
            if (is_array(_pt) && array_length(_pt) >= 2) 
            {
                _min_x = min(_min_x, _pt[0]);
                _min_y = min(_min_y, _pt[1]);
                _max_x = max(_max_x, _pt[0]);
                _max_y = max(_max_y, _pt[1]);
            }
        }
        
        width = (_max_x - _min_x);
        
        height = (_max_y - _min_y);
    }
    
    
    /* get the angle between two points in degrees */
    static get_segment_angle = function(_x1, _y1, _x2, _y2) 
    {
        return point_direction(_x1, _y1, _x2, _y2);
    }
    
    
    /* detect the joint shape at a turn point */
    static detect_joint_shape = function(_angle_in, _angle_out) 
    {
        var _diff = abs(angle_difference(_angle_in, _angle_out));
        
        
        if (_diff > 80 && _diff < 100) 
        {
            return joint_type;
        }
        
        return "turn";
    }
    
    
    /* draw a sprite at a point with rotation */
    static draw_sprite_at = function(_sprite_def, _px, _py, _angle, _base_scale) 
    {
        if (_sprite_def == undefined) exit;
        
        
        var _sprite_name = _sprite_def[$ "sprite_name"] ?? "";
        var _spr = asset_get_index(_sprite_name);
        
        
        if (_spr < 0) exit;
        
        
        draw_sprite_ext(_spr, 0, _px, _py, _base_scale.x, _base_scale.y, _angle, c_white, 1);
    }
    
    
    static draw_content = function() 
    {
        var _count = array_length(points);
        
        if (_count < 2) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _scaled_thickness = max(1, thickness * _base_scale.x);
        
        
        /* draw line segments */
        for (var i = 0; i < _count - 1; ++i) 
        {
            var _p1 = points[i];
            var _p2 = points[i + 1];
            
            
            if !(is_array(_p1)) || !(is_array(_p2)) continue;
            
            if (array_length(_p1) < 2) || (array_length(_p2) < 2) continue;
            
            
            var _sx = (_abs_x + _p1[0]) * _base_scale.x;
            var _sy = (_abs_y + _p1[1]) * _base_scale.y;
            
            var _ex = (_abs_x + _p2[0]) * _base_scale.x;
            var _ey = (_abs_y + _p2[1]) * _base_scale.y;
            
            
            draw_line_width_colour(_sx, _sy, _ex, _ey, _scaled_thickness, colour, colour);
        }
        
        
        /* draw start sprite */
        if (sprite_start != undefined && _count >= 1) 
        {
            var _p = points[0];
            var _p_next = points[1];
            var _angle = get_segment_angle(_p[0], _p[1], _p_next[0], _p_next[1]);
            
            var _px = (_abs_x + _p[0]) * _base_scale.x;
            var _py = (_abs_y + _p[1]) * _base_scale.y;
            
            
            draw_sprite_at(sprite_start, _px, _py, -_angle, _base_scale);
        }
        
        
        /* draw end sprite */
        if (sprite_end != undefined && _count >= 2) 
        {
            var _p = points[_count - 1];
            var _p_prev = points[_count - 2];
            var _angle = get_segment_angle(_p_prev[0], _p_prev[1], _p[0], _p[1]);
            
            var _px = (_abs_x + _p[0]) * _base_scale.x;
            var _py = (_abs_y + _p[1]) * _base_scale.y;
            
            
            draw_sprite_at(sprite_end, _px, _py, -_angle, _base_scale);
        }
        
        
        /* draw turn sprites at intermediate points */
        if (sprite_turn != undefined && _count >= 3) 
        {
            for (var i = 1; i < _count - 1; ++i) 
            {
                var _prev = points[i - 1];
                var _curr = points[i];
                var _next = points[i + 1];
                
                
                if !(is_array(_prev)) || !(is_array(_curr)) || !(is_array(_next)) continue;
                
                
                var _angle_in = get_segment_angle(_prev[0], _prev[1], _curr[0], _curr[1]);
                var _angle_out = get_segment_angle(_curr[0], _curr[1], _next[0], _next[1]);
                
                
                /* average angle for rotation, biased toward the bend */
                var _avg_angle = (_angle_in + _angle_out) / 2;
                
                var _px = (_abs_x + _curr[0]) * _base_scale.x;
                var _py = (_abs_y + _curr[1]) * _base_scale.y;
                
                
                draw_sprite_at(sprite_turn, _px, _py, -(_avg_angle), _base_scale);
            }
        }
    }
}
