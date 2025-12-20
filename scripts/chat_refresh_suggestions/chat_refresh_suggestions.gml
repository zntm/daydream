function chat_refresh_suggestions()
{
    var _message = keyboard_string;
    
    // Only suggest if command
    if (string_length(_message) < 1) || (string_char_at(_message, 1) != "/") 
    {
        chat_hide_choices();
        global.chat_command_hint = undefined;
        return;
    }
    
    var _input = string_delete(_message, 1, 1);
    var _parts = string_split(_input, " ");
    
    // Handle trailing space indicating new argument
    if (string_length(_input) > 0) && (string_char_at(_input, string_length(_input)) == " ")
    {
        array_push(_parts, "");
    }
    
    var _part_count = array_length(_parts);
    var _current_text = _parts[_part_count - 1];
    var _suggestions = [];
    
    // Helper to rebuild string
    var _build_string = method({ parts: _parts, index: _part_count - 1 }, function(_choice)
    {
        // Extract just the choice name (before " - " description)
        var _dash_pos = string_pos(" - ", _choice);
        var _name = (_dash_pos > 0) ? string_copy(_choice, 1, _dash_pos - 1) : _choice;
        
        var _str = "/";
        for (var i = 0; i < index; ++i) _str += parts[i] + " ";
        _str += _name + " ";
        return _str;
    });
    
    // Root Command
    if (_part_count == 1)
    {
        var _names = global.command_data_names;
        var _len = array_length(_names);
        for (var i = 0; i < _len; ++i)
        {
            if (string_pos(_current_text, _names[i]) == 1)
            {
                var _cmd = global.command_data[$ _names[i]];
                var _desc = _cmd.get_description();
                if (_desc != undefined)
                {
                    array_push(_suggestions, $"{_names[i]} - {_desc}");
                }
                else
                {
                    array_push(_suggestions, _names[i]);
                }
            }
        }
        global.chat_command_hint = undefined;
    }
    else
    {
        // Drill down
        var _cmd_name = _parts[0];
        var _cmd_data = global.command_data[$ _cmd_name];
        
        if (_cmd_data != undefined)
        {
            var _pointer = _cmd_data;
            var _arg_start = 1;
            
            // Traverse subcommands
            for (var i = 1; i < _part_count - 1; ++i)
            {
                if (_pointer.get_type() == COMMAND_DATA_TYPE.SUBCOMMAND)
                {
                    var _sub = _pointer.get_subcommand(_parts[i]);
                    if (_sub != undefined)
                    {
                        _pointer = _sub;
                        _arg_start = i + 1;
                    }
                }
            }
            
            // Suggest Subcommand
            if (_pointer.get_type() == COMMAND_DATA_TYPE.SUBCOMMAND)
            {
                var _names = _pointer.get_subcommand_names();
                if (_names != undefined)
                {
                    var _len = array_length(_names);
                    for (var i = 0; i < _len; ++i)
                    {
                        if (string_pos(_current_text, _names[i]) == 1)
                        {
                            var _sub = _pointer.get_subcommand(_names[i]);
                            var _desc = _sub.get_description();
                            if (_desc != undefined)
                            {
                                array_push(_suggestions, $"{_names[i]} - {_desc}");
                            }
                            else
                            {
                                array_push(_suggestions, _names[i]);
                            }
                        }
                    }
                }
                global.chat_command_hint = undefined;
            }
            // Suggest Parameter Choice
            else
            {
                var _param_idx = (_part_count - 1) - _arg_start;
                
                // Build parameter hint array with colored entries
                // Format: [ { text: "...", color: c_xxx }, ... ]
                var _hint_parts = [];
                var _param_len = _pointer.get_parameter_length();
                
                for (var i = 0; i < _param_len; ++i)
                {
                    var _p = _pointer.get_parameter(i);
                    var _type_name = "";
                    var _param_type = _p.get_type();
                    
                    switch (_param_type)
                    {
                        case COMMAND_PARAMETER_TYPE.STRING:     _type_name = "string"; break;
                        case COMMAND_PARAMETER_TYPE.INTEGER:    _type_name = "int"; break;
                        case COMMAND_PARAMETER_TYPE.NUMBER:     _type_name = "number"; break;
                        case COMMAND_PARAMETER_TYPE.BOOLEAN:    _type_name = "bool"; break;
                        case COMMAND_PARAMETER_TYPE.USER:       _type_name = "user"; break;
                        case COMMAND_PARAMETER_TYPE.POSITION_X: _type_name = "x"; break;
                        case COMMAND_PARAMETER_TYPE.POSITION_Y: _type_name = "y"; break;
                        case COMMAND_PARAMETER_TYPE.POSITION_Z: _type_name = "z"; break;
                        default: _type_name = "?";
                    }
                    
                    var _hint_color = #555555; // Default gray
                    var _hint_text = "";
                    
                    if (i < _param_idx)
                    {
                        // Already filled in - show the value with validation color
                        var _value = _parts[_arg_start + i];
                        var _valid = chat_validate_parameter(_value, _param_type);
                        _hint_color = _valid ? #7ecfff : #ff6b6b; // Light blue if valid, red if invalid
                        _hint_text = $"[{_value}]";
                    }
                    else if (i == _param_idx)
                    {
                        // Currently typing - yellow
                        _hint_color = #ffd369;
                        _hint_text = $"<{_p.get_name()}: {_type_name}>";
                    }
                    else
                    {
                        // Not yet typed - gray
                        _hint_color = #666666;
                        _hint_text = $"<{_p.get_name()}: {_type_name}>";
                    }
                    
                    array_push(_hint_parts, { text: _hint_text, color: _hint_color });
                }
                
                global.chat_command_hint = _hint_parts;
                
                if (_param_idx < _param_len)
                {
                    var _param = _pointer.get_parameter(_param_idx);
                    var _choices = _param.get_choices();
                    
                    if (_choices != undefined)
                    {
                        var _len = array_length(_choices);
                        for (var i = 0; i < _len; ++i)
                        {
                             var _choice_str = string(_choices[i]);
                             if (string_pos(_current_text, _choice_str) == 1) array_push(_suggestions, _choice_str);
                        }
                    }
                }
            }
        }
        else
        {
            global.chat_command_hint = undefined;
        }
    }
    
    if (array_length(_suggestions) > 0)
    {
        chat_show_choices(_suggestions, method({ builder: _build_string }, function(_index, _text)
        {
            keyboard_string = builder(_text);
            obj_Game_Control.chat_message = keyboard_string;
            chat_refresh_suggestions();
        }));
    }
    else
    {
        chat_hide_choices();
    }
}

/// @description Validate a parameter value against its type
/// @param {String} _value The value to validate
/// @param {Real} _type The COMMAND_PARAMETER_TYPE
function chat_validate_parameter(_value, _type)
{
    if (string_length(_value) == 0) return false;
    
    switch (_type)
    {
        case COMMAND_PARAMETER_TYPE.INTEGER:
            // Check if it's a valid integer (only digits, optionally prefixed with -)
            var _start = 1;
            if (string_char_at(_value, 1) == "-") _start = 2;
            for (var i = _start; i <= string_length(_value); ++i)
            {
                var _c = string_char_at(_value, i);
                if (_c < "0") || (_c > "9") return false;
            }
            return (string_length(_value) >= _start);
            
        case COMMAND_PARAMETER_TYPE.NUMBER:
        case COMMAND_PARAMETER_TYPE.POSITION_X:
        case COMMAND_PARAMETER_TYPE.POSITION_Y:
        case COMMAND_PARAMETER_TYPE.POSITION_Z:
            // Check if it's a valid number (digits, optional -, optional .)
            var _has_dot = false;
            var _start2 = 1;
            if (string_char_at(_value, 1) == "-") _start2 = 2;
            for (var j = _start2; j <= string_length(_value); ++j)
            {
                var _c2 = string_char_at(_value, j);
                if (_c2 == ".")
                {
                    if (_has_dot) return false;
                    _has_dot = true;
                }
                else if (_c2 < "0") || (_c2 > "9")
                {
                    return false;
                }
            }
            return (string_length(_value) >= _start2);
            
        case COMMAND_PARAMETER_TYPE.BOOLEAN:
            return (_value == "true") || (_value == "false") || (_value == "1") || (_value == "0");
            
        case COMMAND_PARAMETER_TYPE.USER:
        case COMMAND_PARAMETER_TYPE.STRING:
        default:
            return true; // Strings are always valid
    }
}
