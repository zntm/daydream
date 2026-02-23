function hex_parse(_string, _throw = true)
{
    if (is_numeric(_string))
    {
        return clamp(_string, 0, 0xffffff);
    }
    
    if (!is_string(_string)) || (!string_starts_with(_string, "#")) || (string_length(_string) != 7)
    {
        if (!_throw)
        {
            return undefined;
        }
        
        throw $"'{_string}' is not a valid colour";
    }
    
    // Robust hex parsing that works on all platforms (avoiding real("0x...") inconsistency)
    static __hex_to_dec = function(_c)
    {
        var _v = ord(string_lower(_c));
        
        if (_v >= ord("0") && _v <= ord("9"))
        {
            return _v - ord("0");
        }

        if (_v >= ord("a") && _v <= ord("f"))
        {
            return 10 + (_v - ord("a"));
        }
        
        throw $"'{_string}' is not a valid colour";
    }

    var _r = (__hex_to_dec(string_char_at(_string, 2)) << 4) | __hex_to_dec(string_char_at(_string, 3));
    var _g = (__hex_to_dec(string_char_at(_string, 4)) << 4) | __hex_to_dec(string_char_at(_string, 5));
    var _b = (__hex_to_dec(string_char_at(_string, 6)) << 4) | __hex_to_dec(string_char_at(_string, 7));

    return make_colour_rgb(_r, _g, _b);
}
