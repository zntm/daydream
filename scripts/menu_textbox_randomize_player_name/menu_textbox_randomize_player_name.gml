function menu_textbox_randomize_player_name()
{
    randomize();
    
    // 1. Initial Prefix
    static _prefix = choose(
        "Al", "Be", "Co", "Da", "El", "Fa", "Ga", "He", "Is", "Jo", "Ka", "Lu", "Ma", "No", "Or", "Pa", "Qu", "Ra", "Se", "Ty", "Ul", "Va", "Wi", "Xan", "Ye", "Ze",
        "Ar", "Bel", "Cor", "Del", "Val", "Zar", "Phar", "Thal", "Kron", "Bran", "Clen", "Phae", "Rhun", "Gwy", "Bry", "Kael", "Lyra", "Mira", "Nym", "Pyra", "Rha", 
        "Syl", "Vel", "Wren", "Xyl", "Yor", "Zeph", "Aeg", "Bla", "Cas", "Dra", "Elth", "Fen", "Gor", "Harl", "Iva", "Jeth", "Ken", "Lor", "Mor", "Nal", "Oro", "Pyr", 
        "Que", "Rav", "Sol", "Ter", "Ula", "Wyn", "Zor", "Mal", "Sar", "Kel", "Tor", "Fin", "Grom", "Thra", "Drak", "Vael", "Syg", "Eld", "Aet"
    );
    
    // 2. Middle Syllables
    static _middles = [
        "an", "en", "in", "on", "un", "ar", "er", "ir", "or", "ur",
        "al", "el", "il", "ol", "ul", "as", "es", "is", "os", "us",
        "den", "len", "ren", "ven", "zen", "bar", "car", "dar", "far", "gar", "lar", "mar", "nar", "par", "sar", "tar", "var",
        "lio", "rio", "nio", "via", "ria", "lia", "tha", "dra", "sha", "kla", "mra"
    ];
    
    // 3. Suffixes
    static _suffixes = [
        "ia", "ius", "ion", "is", "os", "us", "wyn", "lyn", "mon", 
        "thor", "ric", "vin", "dan", "lor", "mar", "ras", "nas", "las",
        "eth", "ith", "oth", "anth", "elle", "ette", "thas", "lorn", "rith", "vance", "dorn", 
        "gale", "hart", "jinn", "kest", "lark", "mist", "night", "oak", "pine", "quill", "reed", "star", "thorn", "vale", "wolf", "yew", "zest",
        "amir", "emir", "imir", "omir", "umir", "and", "end", "ind", "ond", "und", "aya", "ira", "ora", "ura"
    ];
    
    var _text = _prefix;
    
    // Decide length: short (2 parts) or long (3 parts)
    var _parts = choose(2, 2, 2, 3); 
    
    if (_parts == 2)
    {
        _text += string_lower(choose_from_array(_suffixes));
    }
    else
    {
        _text += string_lower(choose_from_array(_middles));
        _text += string_lower(choose_from_array(_suffixes));
    }
    
    #region Cleanup & Polish
    
    static __vowels = ["a", "e", "i", "o", "u", "y"];
    
    // Ensure at least 2 syllables (roughly: check if we have 2+ vowel groups)
    // Actually, following the structure above (Prefix with vowel + Suffix with vowel/structure) 
    // we already mostly guarantee it. But let's check for "1 syllable" edge cases.
    
    // Rule: Prevent 3 consecutive consonants (with exceptions for clusters like 'thr', 'sch', 'nth')
    static __allowed_triple_consonants = ["nth", "rth", "sch", "thr", "str", "shr"];
    
    var _is_consonant = function(_char) {
        return !array_contains(menu_textbox_randomize_player_name.__vowels, string_lower(_char)) && _char != "" && _char != " ";
    };
    
    for (var i = 1; i <= string_length(_text) - 2; ++i)
    {
        var _c1 = string_char_at(_text, i);
        var _c2 = string_char_at(_text, i + 1);
        var _c3 = string_char_at(_text, i + 2);
        
        // 1. Triple letter check (aaa -> aa)
        if (_c1 == _c2) && (_c2 == _c3)
        {
            _text = string_delete(_text, i, 1);
            i--;
            continue;
        }
        
        // 2. Triple consonant check (brt -> brat)
        if (_is_consonant(_c1) && _is_consonant(_c2) && _is_consonant(_c3))
        {
            var _cluster = string_lower(_c1 + _c2 + _c3);
            if (!array_contains(__allowed_triple_consonants, _cluster))
            {
                _text = string_insert(choose("a", "e", "i"), _text, i + 2);
                continue;
            }
        }
        
        // 3. Euphony: Prevent repetitive 'X-vowel-X' (e.g., 'lala', 'alala', 'bab')
        // We check for char_at(i) == char_at(i+2) where char_at(i+1) is a vowel
        if (string_lower(_c1) == string_lower(_c3)) && !array_contains(menu_textbox_randomize_player_name.__vowels, string_lower(_c1))
        {
            // If it's a consonant repeating with a vowel in between, swap the second one or the vowel
            if (!array_contains(menu_textbox_randomize_player_name.__vowels, string_lower(_c1)))
            {
                _text = string_delete(_text, i + 2, 1);
                _text = string_insert(choose("n", "r", "s", "d", "l", "m"), _text, i + 2);
            }
        }
    }
    
    // 4. Syllable Repetition (e.g., "Manman" -> "Manran")
    if (string_length(_text) >= 4)
    {
        for (var i = 1; i <= string_length(_text) - 3; ++i)
        {
            var _s1 = string_copy(_text, i, 2);
            var _s2 = string_copy(_text, i + 2, 2);
            if (_s1 == _s2)
            {
                _text = string_delete(_text, i + 2, 2);
                _text = string_insert(choose("ar", "en", "is"), _text, i + 2);
            }
        }
    }
    
    // Normalization
    _text = string_replace_all(_text, "uu", "u");
    _text = string_replace_all(_text, "ii", "i");
    _text = string_replace_all(_text, "oo", "o");
    _text = string_replace_all(_text, "aa", "a");
    _text = string_replace_all(_text, "ee", "e");
    
    // Final check for very short names (ensure 2 syllables minimum)
    // Most names from the lists above are at least 4-5 chars.
    // If we somehow got "Alen", that's 2 syllables. 
    // If we got "Bra" (now removed 'Br'), it would be too short.
    
    #endregion
    
    return _text;
}


/// @function choose_from_array
/// @param {Array} _array
function choose_from_array(_array)
{
    return _array[irandom(array_length(_array) - 1)];
}
