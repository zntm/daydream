/// @desc GML Regex Engine with capture groups
/// @param {string} _pattern The regex pattern
/// @param {string} _flags The flags (i, g)
function GMLRegex(_pattern, _flags = "") constructor {
    pattern = _pattern;
    flags = _flags;
    
    is_global = string_pos("g", _flags) > 0;
    ignore_case = string_pos("i", _flags) > 0;
    
    // Capture group tracking
    group_count = 0;
    last_captures = []; // Populated after match
    
    static parse_pattern = function(_p) {
        var _res = [];
        var _len = string_length(_p);
        var _i = 1;
        
        while (_i <= _len) {
            var _c = string_char_at(_p, _i);
            
            if (_c == "\\") {
                _i++;
                if (_i > _len) break;
                var _next = string_char_at(_p, _i);
                if (_next == "d") array_push(_res, { type: "digit" });
                else if (_next == "w") array_push(_res, { type: "word" });
                else if (_next == "s") array_push(_res, { type: "space" });
                else array_push(_res, { type: "char", char: _next });
            }
            else if (_c == "(") {
                // Capture group - parse until matching )
                var _group_start = _i + 1;
                var _depth = 1;
                _i++;
                while (_i <= _len && _depth > 0) {
                    var _gc = string_char_at(_p, _i);
                    if (_gc == "(") _depth++;
                    else if (_gc == ")") _depth--;
                    if (_depth > 0) _i++;
                }
                var _group_content = string_copy(_p, _group_start, _i - _group_start);
                group_count++;
                var _group_nodes = parse_pattern(_group_content);
                array_push(_res, { type: "group", nodes: _group_nodes, index: group_count });
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
                    var _ch = string_char_at(_p, _i);
                    if (_i + 2 <= _len && string_char_at(_p, _i + 1) == "-" && string_char_at(_p, _i + 2) != "]") {
                        var _start_char = ord(_ch);
                        var _end_char = ord(string_char_at(_p, _i + 2));
                        for (var _r = _start_char; _r <= _end_char; _r++) {
                            _chars += chr(_r);
                        }
                        _i += 3;
                    } else {
                        _chars += _ch;
                        _i++;
                    }
                }
                array_push(_res, { type: "set", chars: _chars, negate: _negate });
            }
            else if (_c == "*" || _c == "+" || _c == "?") {
                if (array_length(_res) > 0) {
                    var _prev = _res[array_length(_res)-1];
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
    
    nodes = parse_pattern(_pattern);
    
    static test = function(_str) {
        var _len = string_length(_str);
        var _anchored = (array_length(nodes) > 0 && nodes[0].type == "start");
        
        for (var i = 1; i <= _len + 1; i++) {
            last_captures = array_create(group_count + 1, "");
            var _result = match_at(_str, i, 0, last_captures);
            if (_result != -1) return true;
            if (_anchored) break;
            if (i > _len) break;
        }
        return false;
    }
    
    static match = function(_str) {
        var _matches = [];
        var _len = string_length(_str);
        var _i = 1;
        var _anchored = (array_length(nodes) > 0 && nodes[0].type == "start");
        
        while (_i <= _len + 1) {
            last_captures = array_create(group_count + 1, "");
            var _res = match_at(_str, _i, 0, last_captures);
            if (_res != -1) {
                var _m_str = string_copy(_str, _i, _res);
                last_captures[0] = _m_str;
                
                if (!is_global) {
                    // Return array: [full match, group1, group2, ...]
                    return last_captures;
                }
                array_push(_matches, _m_str);
                _i += (_res > 0) ? _res : 1;
            } else {
                _i++;
            }
            if (_anchored) break;
            if (_i > _len + 1) break;
        }
        
        if (array_length(_matches) == 0 && !is_global) return undefined;
        return _matches;
    }
    
    static match_at = function(_str, _str_idx, _node_idx, _captures) {
        if (_node_idx >= array_length(nodes)) return 0;
        
        var _node = nodes[_node_idx];
        
        // Handle capture groups
        if (_node.type == "group") {
            var _group_start = _str_idx;
            var _total_len = 0;
            var _curr_idx = _str_idx;
            
            // Match all nodes in the group
            for (var g = 0; g < array_length(_node.nodes); g++) {
                var _sub_len = match_single_node(_str, _curr_idx, _node.nodes[g], _captures);
                if (_sub_len == -1) return -1;
                _total_len += _sub_len;
                _curr_idx += _sub_len;
            }
            
            // Store capture
            _captures[@ _node.index] = string_copy(_str, _group_start, _total_len);
            
            // Continue with rest of pattern
            var _rest = match_at(_str, _str_idx + _total_len, _node_idx + 1, _captures);
            if (_rest != -1) return _total_len + _rest;
            return -1;
        }
        
        // Quantifiers
        if (_node.type == "quantifier") {
            var _sub = _node.node;
            if (_node.op == "?") {
                var _len1 = match_single_node(_str, _str_idx, _sub, _captures);
                if (_len1 != -1) {
                    var _rest = match_at(_str, _str_idx + _len1, _node_idx + 1, _captures);
                    if (_rest != -1) return _len1 + _rest;
                }
                var _rest0 = match_at(_str, _str_idx, _node_idx + 1, _captures);
                if (_rest0 != -1) return _rest0;
                return -1;
            }
            else if (_node.op == "*") {
                return match_star(_str, _str_idx, _node_idx, _sub, _captures);
            }
            else if (_node.op == "+") {
                var _len1 = match_single_node(_str, _str_idx, _sub, _captures);
                if (_len1 == -1) return -1;
                var _rest_star = match_star(_str, _str_idx + _len1, _node_idx, _sub, _captures);
                if (_rest_star != -1) return _len1 + _rest_star;
                return -1;
            }
        }
        
        if (_node.type == "end") {
            if (_str_idx > string_length(_str)) return 0;
            return -1;
        }
        
        if (_node.type == "start") {
            if (_node_idx == 0) {
                return match_at(_str, _str_idx, _node_idx + 1, _captures);
            }
            return -1; 
        }
        
        var _len = match_single(_str, _str_idx, _node);
        if (_len != -1) {
            var _rest = match_at(_str, _str_idx + _len, _node_idx + 1, _captures);
            if (_rest != -1) return _len + _rest;
        }
        
        return -1;
    }
    
    static match_single_node = function(_str, _idx, _node, _captures) {
        if (_node.type == "group") {
            var _total = 0;
            var _curr = _idx;
            for (var g = 0; g < array_length(_node.nodes); g++) {
                var _sub_len = match_single_node(_str, _curr, _node.nodes[g], _captures);
                if (_sub_len == -1) return -1;
                _total += _sub_len;
                _curr += _sub_len;
            }
            _captures[@ _node.index] = string_copy(_str, _idx, _total);
            return _total;
        }
        if (_node.type == "quantifier") {
            // For single node matching, handle quantifiers
            if (_node.op == "?") {
                var _len1 = match_single_node(_str, _idx, _node.node, _captures);
                return _len1 != -1 ? _len1 : 0;
            }
            return match_single(_str, _idx, _node.node);
        }
        return match_single(_str, _idx, _node);
    }
    
    static match_star = function(_str, _str_idx, _node_idx, _sub_node, _captures) {
        var _offsets = [];
        var _curr = _str_idx;
        var _total_match_len = 0;
        
        array_push(_offsets, 0);
        
        while (true) {
            var _len = match_single(_str, _curr, _sub_node);
            if (_len == -1) break;
            if (_len == 0) break;
            _curr += _len;
            _total_match_len += _len;
            array_push(_offsets, _total_match_len);
        }
        
        for (var i = array_length(_offsets) - 1; i >= 0; i--) {
            var _match_amount = _offsets[i];
            var _rest = match_at(_str, _str_idx + _match_amount, _node_idx + 1, _captures);
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
                var _o = ord(_c);
                if ((_o >= 48 && _o <= 57) || (_o >= 65 && _o <= 90) || (_o >= 97 && _o <= 122) || _o == 95) return 1;
                return -1;
            case "space":
                return (_c == " " || _c == "\t" || _c == "\n" || _c == "\r") ? 1 : -1;
            case "set":
                var _found = string_pos(_c, _node.chars) > 0;
                if (_node.negate) return (!_found) ? 1 : -1;
                return _found ? 1 : -1;
        }
        return -1;
    }
    
    static replace = function(_str, _replacement) {
        var _res = "";
        var _len = string_length(_str);
        var _i = 1;
        
        while (_i <= _len) {
            last_captures = array_create(group_count + 1, "");
            var _match_len = match_at(_str, _i, 0, last_captures);
            if (_match_len != -1) {
                var _matched_text = string_copy(_str, _i, _match_len);
                last_captures[0] = _matched_text;
                
                // Replace $0, $1, $2, etc.
                var _repl_text = _replacement;
                for (var g = 0; g <= group_count; g++) {
                    _repl_text = string_replace_all(_repl_text, $"${g}", last_captures[g]);
                }
                _res += _repl_text;
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
        var _split_count = 0;
        
        while (_i <= _len) {
            last_captures = array_create(group_count + 1, "");
            var _match_len = match_at(_str, _i, 0, last_captures);
            if (_match_len != -1 && _match_len > 0) {
                array_push(_res, string_copy(_str, _last_end, _i - _last_end));
                _i += _match_len;
                _last_end = _i;
                _split_count++;
                // If not global, only split once
                if (!is_global) {
                    break;
                }
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
            last_captures = array_create(group_count + 1, "");
            var _res = match_at(_str, _i, 0, last_captures);
            if (_res != -1) {
                array_push(_indices, _i - 1);
                if (!is_global) return _indices[0];
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
