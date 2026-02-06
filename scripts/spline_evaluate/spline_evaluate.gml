function spline_evaluate(_spline, _x)
{
    var _length = array_length(_spline);
    
    if (_length == 0) return 0;
    if (_length == 1) return _spline[0].value;
    if (_x <= _spline[0].position) return _spline[0].value;
    
    var _last = _length - 1;
    if (_x >= _spline[_last].position) return _spline[_last].value;
    
    var _lo = 0;
    var _hi = _last;
    
    while (_hi - _lo > 1)
    {
        var _mid = (_lo + _hi) >> 1;
        if (_spline[_mid].position <= _x)
            _lo = _mid;
        else
            _hi = _mid;
    }
    
    var _p0 = _spline[_lo];
    var _p1 = _spline[_hi];
    
    var _t = (_x - _p0.position) / (_p1.position - _p0.position);
    
    var _easing = _p0[$ "easing"];
    if (_easing != undefined)
    {
        if (_easing == "ease_in_out")
            _t = _t * _t * (3 - 2 * _t);
        else if (_easing == "ease_out")
            _t = 1 - (1 - _t) * (1 - _t);
        else if (_easing == "ease_in")
            _t = _t * _t;
        else if (_easing == "ease_in_cubic")
            _t = _t * _t * _t;
        else if (_easing == "ease_out_cubic")
        {
            var _inv = 1 - _t;
            _t = 1 - _inv * _inv * _inv;
        }
        else if (_easing == "ease_in_out_cubic")
        {
            if (_t < 0.5)
                _t = 4 * _t * _t * _t;
            else
            {
                var _f = 2 * _t - 2;
                _t = 0.5 * _f * _f * _f + 1;
            }
        }
        else if (_easing == "step")
            _t = (_t >= 1) ? 1 : 0;
    }
    
    return lerp(_p0.value, _p1.value, _t);
}

function spline_apply_easing(_t, _easing)
{
    switch (_easing)
    {
        case "linear":
            return _t;
        case "ease_in":
            return _t * _t;
        case "ease_out":
            return 1 - (1 - _t) * (1 - _t);
        case "ease_in_out":
            return _t * _t * (3 - 2 * _t);
        case "ease_in_cubic":
            return _t * _t * _t;
        case "ease_out_cubic":
            var _inv = 1 - _t;
            return 1 - _inv * _inv * _inv;
        case "ease_in_out_cubic":
            if (_t < 0.5)
                return 4 * _t * _t * _t;
            var _f = 2 * _t - 2;
            return 0.5 * _f * _f * _f + 1;
        case "step":
            return (_t >= 1) ? 1 : 0;
        default:
            return _t;
    }
}
