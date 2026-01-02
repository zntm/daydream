/// @desc Evaluate a spline at a given position using interpolation with optional easing
/// @param {Array} _spline Spline points array [{position, value, easing?}, ...]
/// @param {Real} _x Input position to evaluate
/// @returns {Real} Interpolated value at the given position
function spline_evaluate(_spline, _x)
{
    var _length = array_length(_spline);
    
    // Handle edge cases
    if (_length == 0) return 0;
    if (_length == 1) return _spline[0].value;
    
    // Below first point
    if (_x <= _spline[0].position)
    {
        return _spline[0].value;
    }
    
    // Above last point
    if (_x >= _spline[_length - 1].position)
    {
        return _spline[_length - 1].value;
    }
    
    // Find the two points to interpolate between
    for (var i = 0; i < _length - 1; ++i)
    {
        var _p0 = _spline[i];
        var _p1 = _spline[i + 1];
        
        if (_x >= _p0.position && _x < _p1.position)
        {
            // Calculate normalized t value (0-1) between points
            var _t = (_x - _p0.position) / (_p1.position - _p0.position);
            
            // Apply easing to t based on the starting point's easing type
            var _easing = _p0[$ "easing"] ?? "linear";
            _t = spline_apply_easing(_t, _easing);
            
            // Interpolate between values
            return lerp(_p0.value, _p1.value, _t);
        }
    }
    
    // Fallback (shouldn't reach here)
    return _spline[_length - 1].value;
}

/// @desc Apply an easing function to a normalized t value
/// @param {Real} _t Normalized value between 0 and 1
/// @param {String} _easing Easing type name
/// @returns {Real} Eased t value
function spline_apply_easing(_t, _easing)
{
    switch (_easing)
    {
        case "linear":
            return _t;
            
        case "ease_in":
            // Quadratic ease in: slow start
            return _t * _t;
            
        case "ease_out":
            // Quadratic ease out: slow end
            return 1 - (1 - _t) * (1 - _t);
            
        case "ease_in_out":
            // Smoothstep: slow start and end
            return _t * _t * (3 - 2 * _t);
            
        case "ease_in_cubic":
            // Cubic ease in
            return _t * _t * _t;
            
        case "ease_out_cubic":
            // Cubic ease out
            var _inv = 1 - _t;
            return 1 - _inv * _inv * _inv;
            
        case "ease_in_out_cubic":
            // Cubic ease in-out
            if (_t < 0.5)
            {
                return 4 * _t * _t * _t;
            }
            else
            {
                var _f = 2 * _t - 2;
                return 0.5 * _f * _f * _f + 1;
            }
            
        case "step":
            // Instant jump at the end
            return (_t >= 1) ? 1 : 0;
            
        default:
            return _t;
    }
}
