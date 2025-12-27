/// @desc Simple GML Regex Engine for Proglang
/// @param {string} _pattern The regex pattern
/// @param {string} _flags The flags (i, g)
function GMLRegex(_pattern, _flags = "") constructor {
    pattern = _pattern;
    flags = _flags;
    
    is_global = string_pos("g", _flags) > 0;
    ignore_case = string_pos("i", _flags) > 0;
    
    // Parse pattern into simple tokens/nodes
    // Supported: . (dot), \w, \d, \s, [chars], *, +, ?, ^, $
    nodes = parse_pattern(_pattern);
    
    static parse_pattern = function(_p) {
        var _res = [];
        var _len = string_length(_p);
        var _i = 1;
        
        while (_i <= _len) {
            var _c = string_char_at(_p, _i);
            
            if (_c == "\\") {
                _i++;
                if (_i > _len) break; // Trailing backslash
                var _next = string_char_at(_p, _i);
                if (_next == "d") array_push(_res, { type: "digit" });
                else if (_next == "w") array_push(_res, { type: "word" });
                else if (_next == "s") array_push(_res, { type: "space" });
                else array_push(_res, { type: "char", char: _next }); // Escaped char
            }
            else if (_c == ".") {
                array_push(_res, { type: "any" });
            }
            else if (_c == "^") {
                array_push(_res, { type: "start" });
            }
            else if (_c == "$") {
                array_push(_res, { type: "end" });
            }
            else if (_c == "[") {
                _i++;
                var _chars = "";
                var _negate = false;
                if (string_char_at(_p, _i) == "^") {
                    _negate = true;
                    _i++;
                }
                while (_i <= _len && string_char_at(_p, _i) != "]") {
                    // TODO: Ranges a-z
                    _chars += string_char_at(_p, _i);
                    _i++;
                }
                array_push(_res, { type: "set", chars: _chars, negate: _negate });
            }
            else if (_c == "*" || _c == "+" || _c == "?") {
                if (array_length(_res) > 0) {
                    var _prev = _res[array_length(_res)-1];
                    // Wrap previous in quantifier
                    // But if prev was already quantifier?
                     _res[array_length(_res)-1] = { type: "quantifier", node: _prev, op: _c };
                }
            }
            else {
                array_push(_res, { type: "char", char: _c });
            }
            _i++;
        }
        return _res;
    }
    
    static test = function(_str) {
        // Find first match
        var _len = string_length(_str);
        // Optimization: if ^ is first, only check at index 1
        var _start_index = 1;
        var _anchored = (array_length(nodes) > 0 && nodes[0].type == "start");
        
        for (var i = 1; i <= _len + 1; i++) {
            if (match_at(_str, i, 0)) return true;
            if (_anchored) break;
            if (i > _len) break; // Empty string support?
        }
        return false;
    }
    
    static match = function(_str) {
        var _matches = [];
        var _len = string_length(_str);
        var _i = 1;
        var _anchored = (array_length(nodes) > 0 && nodes[0].type == "start");
        
        while (_i <= _len + 1) { // +1 for empty match at end
             var _res = match_at(_str, _i, 0); // Returns length of match or -1
             if (_res != -1) {
                 var _m_str = string_copy(_str, _i, _res);
                 array_push(_matches, _m_str);
                 
                 if (!is_global) return _matches; // Return first match as single-element array if not global? 
                 // JS behavior: match(regex) returns array with captures or null.
                 // match(regex_g) returns array of all matches.
                 
                 _i += (_res > 0) ? _res : 1;
             } else {
                 _i++;
             }
             if (_anchored) break;
             if (_i > _len + 1) break;
        }
        
        if (array_length(_matches) == 0 && !is_global) return undefined; // JS returns null
        return _matches;
    }
    
    // Returns length of match from str_idx, or -1 if no match
    static match_at = function(_str, _str_idx, _node_idx) {
        if (_node_idx >= array_length(nodes)) return 0; // End of pattern, success (match length 0 so far from this recursive step?)
        // Wait, need to return TOTAL length matched from this point
        
        var _node = nodes[_node_idx];
        
        // Handling Quantifiers
        if (_node.type == "quantifier") {
            var _sub = _node.node;
            if (_node.op == "?") {
                // Try 1, then 0
                var _len1 = match_single(_str, _str_idx, _sub);
                if (_len1 != -1) {
                    var _rest = match_at(_str, _str_idx + _len1, _node_idx + 1);
                    if (_rest != -1) return _len1 + _rest;
                }
                var _rest0 = match_at(_str, _str_idx, _node_idx + 1);
                if (_rest0 != -1) return _rest0;
                return -1;
            }
            else if (_node.op == "*") {
                return match_star(_str, _str_idx, _node_idx, _sub);
            }
            else if (_node.op == "+") {
                var _len1 = match_single(_str, _str_idx, _sub);
                if (_len1 == -1) return -1;
                var _rest_star = match_star(_str, _str_idx + _len1, _node_idx, _sub);
                if (_rest_star != -1) return _len1 + _rest_star;
                return -1;
            }
        }
        
        if (_node.type == "end") {
            if (_str_idx > string_length(_str)) return 0;
            return -1;
        }
        
        if (_node.type == "start") {
             // Already checked at top level if anchored, but internal ^ usually invalid unless multiline
             // Treated as 0-length assertion allowed only at start
             if (_node_idx == 0) {
                 return match_at(_str, _str_idx, _node_idx + 1);
             }
             return -1; 
        }
        
        var _len = match_single(_str, _str_idx, _node);
        if (_len != -1) {
            var _rest = match_at(_str, _str_idx + _len, _node_idx + 1);
            if (_rest != -1) return _len + _rest;
        }
        
        return -1;
    }
    
    static match_star = function(_str, _str_idx, _node_idx, _sub_node) {
        // Greedily match as many as possible
        // Then backtrack
        var _offsets = [];
        var _curr = _str_idx;
        var _total_match_len = 0;
        
        array_push(_offsets, 0); // 0 matches
        
        while (true) {
            var _len = match_single(_str, _curr, _sub_node);
            if (_len == -1) break;
            if (_len == 0) break; // Prevent infinite loop on empty match
            _curr += _len;
            _total_match_len += _len;
            array_push(_offsets, _total_match_len);
        }
        
        // Try from longest to shortest
        for (var i = array_length(_offsets) - 1; i >= 0; i--) {
            var _match_amount = _offsets[i];
            var _rest = match_at(_str, _str_idx + _match_amount, _node_idx + 1);
            if (_rest != -1) {
                return _match_amount + _rest;
            }
        }
        return -1;
    }
    
    static match_single = function(_str, _idx, _node) {
        if (_idx > string_length(_str)) return -1;
        var _c = string_char_at(_str, _idx);
        
        if (ignore_case) _c = string_lower(_c);
        
        switch (_node.type) {
            case "char": 
                var _target = ignore_case ? string_lower(_node.char) : _node.char;
                return (_c == _target) ? 1 : -1;
            case "any": return 1;
            case "digit": return (string_digits(_c) == _c) ? 1 : -1;
            case "word": 
                // Alphanumeric + _
                var _o = ord(_c);
                if ((_o >= 48 && _o <= 57) || (_o >= 65 && _o <= 90) || (_o >= 97 && _o <= 122) || _o == 95) return 1;
                return -1;
            case "space":
                return (_c == " " || _c == "\t" || _c == "\n" || _c == "\r") ? 1 : -1;
            case "set":
                var _found = string_pos(_c, _node.chars) > 0;
                if (ignore_case && !_found) {
                     // Check lower/upper in set? Simplified: just check if c in chars
                     // If set contains 'A', and ignore_case, it should match 'a'.
                     // My parse puts literal characters in set.
                     // Ideally parse should lower-case them if flag is set?
                     // Or just check lower(_c) in chars.
                     // But chars might be mixed.
                }
                if (_node.negate) return (!_found) ? 1 : -1;
                return _found ? 1 : -1;
        }
        return -1;
    }
    
    static replace = function(_str, _replacement) {
         // Basic replace
         // TODO: $1, $2 support
         var _res = "";
         var _len = string_length(_str);
         var _i = 1;
         
         while (_i <= _len) {
             var _match_len = match_at(_str, _i, 0);
             if (_match_len != -1) {
                 _res += _replacement;
                 _i += (_match_len > 0) ? _match_len : 1;
                 if (!is_global) {
                     _res += string_copy(_str, _i, _len - _i + 1);
                     break;
                 }
             } else {
                 _res += string_char_at(_str, _i);
                 _i++;
             }
         }
         return _res;
    }

    static split = function(_str) {
        var _res = [];
        var _len = string_length(_str);
        var _last_end = 1;
        var _i = 1;
        
        show_debug_message($"[RegexSplit] Str: '{_str}', Pattern: '{pattern}'");
        
        while (_i <= _len) {
            var _match_len = match_at(_str, _i, 0);
            show_debug_message($"[RegexSplit] i: {_i}, match_len: {_match_len}");
            if (_match_len != -1 && _match_len > 0) {
                 array_push(_res, string_copy(_str, _last_end, _i - _last_end));
                 _i += _match_len;
                 _last_end = _i;
            } else {
                 _i++;
            }
        }
        array_push(_res, string_copy(_str, _last_end, _len - _last_end + 1));
        return _res;
    }

    static match_index = function(_str) {
        var _indices = [];
        var _len = string_length(_str);
        var _i = 1;
        
        while (_i <= _len + 1) {
             var _res = match_at(_str, _i, 0);
             if (_res != -1) {
                 array_push(_indices, _i - 1); // 0-indexed return
                 
                 if (!is_global) return _indices[0]; // Return single index if not global
                 
                 _i += (_res > 0) ? _res : 1;
             } else {
                 _i++;
             }
             if (_i > _len + 1) break;
        }
        
        if (array_length(_indices) == 0 && !is_global) return -1;
        return _indices;
    }
}
