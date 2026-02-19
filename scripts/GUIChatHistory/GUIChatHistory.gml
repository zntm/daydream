/// @description GUI Chat History component - displays chat message history using cuteify rendering
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {Real} _width Component width
/// @param {Real} _height Component height
/// @param {Real} _max_messages Maximum number of messages to display

function GUIChatHistory(_x, _y, _width, _height, _max_messages = 8) : UIElement(_x, _y, _width, _height) constructor
{
    max_messages = _max_messages;
    line_height = 10;
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        var _scale_x = _base_scale_x * scale;
        var _scale_y = _base_scale_y * scale;
        
        var _chat_history = global.chat_history;
        var _length = min(array_length(_chat_history), max_messages);
        
        var _is_chat_open = (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.CHAT);
        
        for (var i = 0; i < _length; ++i)
        {
            var _chat = _chat_history[i];
            var _timer = _chat.get_timer();
            
            // Skip if timer expired (unless chat is open)
            if (_timer <= 0) && (!_is_chat_open) continue;
            
            var _name = _chat.get_name();
            var _message = _chat.get_message();
            var _colour = _chat.get_colour() ?? c_white;
            
            var _text = (_name != undefined) ? $"<{_name}> {_message}" : _message;
            var _y_pos = _abs_y + height - ((i + 1) * line_height);
            
            // Calculate alpha based on timer (fade out over last 2 seconds)
            var _alpha = clamp(_timer / (GAME_TICK * 2), 0, 1);
            if (_is_chat_open) _alpha = 1;
            
            draw_text_cuteify(
                _abs_x * _base_scale_x,
                _y_pos * _base_scale_y,
                _text,
                _scale_x * 0.2,
                _scale_y * 0.2,
                0,
                _colour,
                _alpha,
                "emote_"
            );
        }
        
        // Draw chat input box when chat is open
        if (_is_chat_open)
        {
            var _input_y = _abs_y + height;
            var _message = obj_Game_Control.chat_message;
            
            // Draw input background
            draw_set_alpha(0.5);
            draw_rectangle_colour(
                _abs_x * _base_scale_x,
                _input_y * _base_scale_y,
                (_abs_x + width) * _base_scale_x,
                (_input_y + line_height) * _base_scale_y,
                c_black, c_black, c_black, c_black,
                false
            );
            draw_set_alpha(1);
            
            // Draw input text
            var _display_text = keyboard_string + "_";
            
            draw_text_cuteify(
                (_abs_x + 4) * _base_scale_x,
                _input_y * _base_scale_y,
                _display_text,
                _scale_x * 0.2,
                _scale_y * 0.2,
                0,
                c_white,
                1
            );
            
            // Draw argument type hints (if available)
            var _hint = global.chat_command_hint;
            if (_hint != undefined) && (is_array(_hint))
            {
                // Calculate X offset after the input text
                var _input_width = string_width(_display_text) * _scale_x * 0.2;
                
                var _hint_x = (_abs_x + 4) * _base_scale_x + _input_width + (4 * _scale_x);
                var _hint_len = array_length(_hint);
                
                for (var i = 0; i < _hint_len; ++i)
                {
                    var _hint_part = _hint[i];
                    var _hint_text = _hint_part.text;
                    var _hint_colour = _hint_part.colour;
                    
                    draw_text_cuteify(
                        _hint_x,
                        _input_y * _base_scale_y,
                        _hint_text,
                        _scale_x * 0.2,
                        _scale_y * 0.2,
                        0,
                        _hint_colour,
                        0.8
                    );
                    
                    // Move X for next hint part
                    _hint_x += string_width(_hint_text + " ") * _scale_x * 0.2;
                }
            }
        }
    }
    
    static update = function()
    {
        if (!visible) return;
        
        // Update chat timers
        var _chat_history = global.chat_history;
        var _length = array_length(_chat_history);
        var _delta = global.delta_time;
        
        for (var i = 0; i < _length; ++i)
        {
            var _chat = _chat_history[i];
            _chat.add_timer(-_delta * GAME_TICK);
        }
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
        
        update_bindings();
    }
}
