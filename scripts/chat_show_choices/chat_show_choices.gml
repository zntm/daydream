/// @description Display choices from command data or parameters
/// @param {Array<String>} _choices Array of choice strings
/// @param {Function} _callback Callback function called with (index, choice_text)
function chat_show_choices(_choices, _callback)
{
    if (global.gui_panel_choices != undefined)
    {
        global.gui_panel_choices.set_choices(_choices, _callback);
    }
}

/// @description Display subcommand choices from CommandData
/// @param {Struct.CommandData} _command_data The command data with subcommands
/// @param {Function} _callback Callback function called with (index, subcommand_name)
function chat_show_subcommand_choices(_command_data, _callback)
{
    var _subcommand_names = _command_data.get_subcommand_names();
    
    if (_subcommand_names == undefined) || (array_length(_subcommand_names) == 0)
    {
        exit;
    }
    
    // Build choices with descriptions
    var _choices = [];
    var _length = array_length(_subcommand_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _subcommand_names[i];
        var _subcommand = _command_data.get_subcommand(_name);
        var _description = _subcommand.get_description();
        
        if (_description != undefined)
        {
            array_push(_choices, $"{_name} - {_description}");
        }
        else
        {
            array_push(_choices, _name);
        }
    }
    
    chat_show_choices(_choices, function(_index, _text)
    {
        // Extract just the command name (before " - ")
        var _dash_pos = string_pos(" - ", _text);
        var _choice = (_dash_pos > 0) ? string_copy(_text, 1, _dash_pos - 1) : _text;
        
        _callback(_index, _choice);
    });
}

/// @description Display parameter choices from CommandParameter
/// @param {Struct.CommandParameter} _parameter The parameter with choices
/// @param {Function} _callback Callback function called with (index, choice_value)
function chat_show_parameter_choices(_parameter, _callback)
{
    var _choices = _parameter.get_choices();
    
    if (_choices == undefined) || (array_length(_choices) == 0)
    {
        exit;
    }
    
    // Convert choices to strings for display
    var _choice_strings = [];
    var _length = array_length(_choices);
    
    for (var i = 0; i < _length; ++i)
    {
        array_push(_choice_strings, string(_choices[i]));
    }
    
    chat_show_choices(_choice_strings, function(_index, _text)
    {
        _callback(_index, _choices[_index]);
    });
}

/// @description Clear and hide the choice panel
function chat_hide_choices()
{
    if (global.gui_panel_choices != undefined)
    {
        global.gui_panel_choices.clear_choices();
    }
}

/// @description Show available commands as choices
function chat_show_command_choices()
{
    var _command_names = global.command_data_names;
    
    if (_command_names == undefined) || (array_length(_command_names) == 0)
    {
        exit;
    }
    
    var _choices = [];
    var _length = array_length(_command_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _command_names[i];
        var _data = global.command_data[$ _name];
        var _description = _data.get_description();
        
        if (_description != undefined)
        {
            array_push(_choices, $"/{_name} - {_description}");
        }
        else
        {
            array_push(_choices, $"/{_name}");
        }
    }
    
    chat_show_choices(_choices, function(_index, _text)
    {
        // Extract command name (between "/" and " - " or end)
        var _start = 2; // After "/"
        var _dash_pos = string_pos(" - ", _text);
        var _choice = (_dash_pos > 0) ? string_copy(_text, _start, _dash_pos - _start) : string_delete(_text, 1, 1);
        
        // Insert command into chat
        keyboard_string = _choice + " ";
        obj_Game_Control.chat_message = keyboard_string;
        obj_Game_Control.is_command = true;
    });
}
