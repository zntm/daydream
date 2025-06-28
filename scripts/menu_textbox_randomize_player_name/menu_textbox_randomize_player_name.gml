function menu_textbox_randomize_player_name()
{
    randomize();
    
    var _text = "";
    
    if (chance(0.42))
    {
        _text = choose("b", "c", "d", "g", "j", "m", "n", "s", "v", "z", "bl", "br", "cl", "cr", "dr", "fl", "fr", "gl", "gr", "pl", "pr", "sc", "sk", "sl", "sp", "st", "tr", "wr", "str", "shr");
    }
    
    var _last_vowel = "";
    var _last_consonant = "";
    
    var _repeat = (chance(0.76) ? 2 : irandom_range(3, 4));
    
    repeat (_repeat)
    {
        var _vowel = choose("a", "e", "i", "o", "u");
        
        if (chance(0.78))
        {
            while (_vowel == _last_vowel)
            {
                _vowel = choose("a", "e", "i", "o", "u");
            }
        }
        
        _last_vowel = _vowel;
        
        if (chance(0.14)) && (_text != "")
        {
            _text += _vowel;
            
            if (_vowel == "i")
            {
                _text += choose("a", "u");
            }
            else if (_vowel == "u")
            {
                _text += choose("a", "i");
            }
        }
        else
        {
            _text += _vowel;
        }
        
        var _consonant = choose("d", "l", "m", "n", "s", "p", "t", "c", "k", "sg", "sl", "ld", "mn", "pl", "st", "tr", "rr", "ck", "th", "nc", "nd", "ng", "nt", "mp", "lk", "rk", "ft", "sp", "ndr");
        
        if (chance(0.22))
        {
            while (_consonant == _last_consonant)
            {
                _consonant = choose("d", "l", "m", "n", "s", "p", "t", "c", "k", "sg", "sl", "ld", "mn", "pl", "st", "tr", "rr", "ck", "th", "nc", "nd", "ng", "nt", "mp", "lk", "rk", "ft", "sp", "ndr");
            }
        }
        
        _last_consonant = _consonant;
        
        _text += _consonant;
        
        if (chance(0.99)) && (string_length(_text) >= 8) break;
    }
    
    #region Cleanup
    
    static __bad_end = [ "r", "l", "p", "nc", "c", "sg" ];
    static __bad_end_length = array_length(__bad_end);
    
    for (var i = 0; i < __bad_end_length; ++i)
    {
        if (!string_ends_with(_text, __bad_end[i])) continue;
        
        _text += choose("a", "ia", "ie", "io", "y");
        
        break;
    }
    
    if (string_ends_with(_text, "ly"))
    {
        _text = string_delete(_text, string_length(_text) - 1, 2);
    }
    
    if (string_ends_with(_text, "mn"))
    {
        _text = string_delete(_text, string_length(_text) - choose(0, 1), 1);
    }
    
    if (string_contains(_text, "amam"))
    {
        _text = string_replace_all(_text, "ama", "a");
    }
    
    if (string_contains(_text, "rria"))
    {
        _text = string_replace_all(_text, "rria", "ria");
    }
    
    if (string_contains(_text, "rry"))
    {
        _text = string_replace_all(_text, "rry", "ry");
    }
    
    #endregion
    
    return string_upper(string_char_at(_text, 1)) + string_delete(_text, 1, 1);
}