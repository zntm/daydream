function draw_text_cuteify(_x, _y, _string, _xscale = 1, _yscale = 1, _angle = 0, _colour = c_white, _alpha = 1, _asset_prefix = "")
{
    var _current_font = draw_get_font();
    
    var _ast = cuteify_get(_string, _asset_prefix);
    var _lines = _ast.lines;
    var _string_widths = _ast.widths;
    var _string_heights = _ast.heights;
    var _line_count = _ast.line_count;
    
    var _cos =  dcos(_angle);
    var _sin = -dsin(_angle);
    
    var _angle_90 = _angle - 90;
    var _cos_90 =  dcos(_angle_90);
    var _sin_90 = -dsin(_angle_90);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var _yoffset = 0;
    var _total_height = 0;
    
    for (var i = 0; i <= _line_count; ++i)
    {
        _total_height += _string_heights[i];
    }
    
    if (_valign == fa_middle)
    {
        _yoffset -= (_total_height * _yscale) / 2;
    }
    else if (_valign == fa_bottom)
    {
        _yoffset -= (_total_height * _yscale);
    }
    
    var _state_obstruct = false;
    var _state_underline = false;
    var _state_strikethrough = false;
    var _state_bold = false;
    // var _state_italic = false; /* italic not visually supported natively yet */
    
    var _shake_intensity = 0;
    var _wave_intensity = 0;
    var _char_counter = 0; /* For wave phase offset */
    
    for (var i = 0; i <= _line_count; ++i)
    {
        var _xoffset = 0;
        var _line_width = _string_widths[i] * _xscale;
        var _line_height = _string_heights[i] * _yscale;
        
        if (_halign == fa_middle)
        {
            _xoffset -= _line_width / 2;
        }
        else if (_halign == fa_right)
        {
            _xoffset -= _line_width;
        }
        
        var _line_nodes = _lines[i];
        var _node_count = array_length(_line_nodes);
        
        for (var j = 0; j < _node_count; ++j)
        {
            var _node = _line_nodes[j];
            var _type = _node.type;
            var _value = _node.value;
            
            if (_type == CUTEIFY_NODE.COLOUR)
            {
                _colour = _value;
                continue;
            }
            
            if (_type == CUTEIFY_NODE.FONT)
            {
                draw_set_font(_value);
                continue;
            }
            
            if (_type == CUTEIFY_NODE.OBSTRUCT) { _state_obstruct = true; continue; }
            if (_type == CUTEIFY_NODE.OBSTRUCT_END) { _state_obstruct = false; continue; }
            if (_type == CUTEIFY_NODE.UNDERLINE) { _state_underline = true; continue; }
            if (_type == CUTEIFY_NODE.UNDERLINE_END) { _state_underline = false; continue; }
            if (_type == CUTEIFY_NODE.STRIKETHROUGH) { _state_strikethrough = true; continue; }
            if (_type == CUTEIFY_NODE.STRIKETHROUGH_END) { _state_strikethrough = false; continue; }
            if (_type == CUTEIFY_NODE.BOLD) { _state_bold = true; continue; }
            if (_type == CUTEIFY_NODE.BOLD_END) { _state_bold = false; continue; }
            if (_type == CUTEIFY_NODE.ITALIC) { continue; }
            if (_type == CUTEIFY_NODE.ITALIC_END) { continue; }
            if (_type == CUTEIFY_NODE.SHAKE) { _shake_intensity = _value; continue; }
            if (_type == CUTEIFY_NODE.SHAKE_END) { _shake_intensity = 0; continue; }
            if (_type == CUTEIFY_NODE.WAVE) { _wave_intensity = _value; continue; }
            if (_type == CUTEIFY_NODE.WAVE_END) { _wave_intensity = 0; continue; }
            
            if (_type == CUTEIFY_NODE.SPRITE)
            {
                var _norm = (string_height("I")) / sprite_get_height(_value);
                
                var _draw_xscale = _xscale * _norm;
                var _draw_yscale = _yscale * _norm;

                var _y2 = (sprite_get_yoffset(_value) * _draw_yscale) + _yoffset;
                var _x2 = (sprite_get_xoffset(_value) * _draw_xscale) + _xoffset;
                
                var _sx = 0;
                var _sy = 0;
                
                if (_shake_intensity > 0)
                {
                    _sx = random_range(-_shake_intensity, _shake_intensity);
                    _sy = random_range(-_shake_intensity, _shake_intensity);
                }
                
                if (_wave_intensity > 0)
                {
                    _sy += sin((current_time / 100) + _char_counter * 0.5) * _wave_intensity;
                }
                
                draw_sprite_ext(
                    _value,
                    0,
                    _x + (_y2 * _cos_90) + (_x2 * _cos) + (_sx * _cos) - (_sy * _sin),
                    _y + (_y2 * _sin_90) + (_x2 * _sin) + (_sx * _sin) + (_sy * _cos),
                    _draw_xscale,
                    _draw_yscale,
                    _angle,
                    _colour,
                    _alpha
                );
                
                _xoffset += sprite_get_width(_value) * _draw_xscale;
                ++_char_counter;
                
                continue;
            }
            
            if (_type == CUTEIFY_NODE.TEXT)
            {
                var _text_length = string_length(_value);
                if (_text_length <= 0) continue;
                
                var _xstart = _x + (_yoffset * _cos_90);
                var _ystart = _y + (_yoffset * _sin_90);
                
                var _draw_text = ((global.settings.menu_profanity_filter) ? string_scunthorpe(_value) : _value);
                
                for (var l = 1; l <= _text_length; ++l)
                {
                    var _char = string_char_at(_draw_text, l);
                    var _char_width = string_width(_char) * _xscale;
                    
                    if (_state_obstruct) && (_char != " ")
                    {
                        _char = chr(irandom_range(32, 127));
                    }
                    
                    var _sx = 0;
                    var _sy = 0;
                    
                    if (_shake_intensity > 0)
                    {
                        _sx = random_range(-_shake_intensity, _shake_intensity);
                        _sy = random_range(-_shake_intensity, _shake_intensity);
                    }
                    
                    if (_wave_intensity > 0)
                    {
                        _sy += sin((current_time / 100) + _char_counter * 0.5) * _wave_intensity;
                    }
                    
                    var _draw_px = _xstart + (_xoffset * _cos) + (_sx * _cos) - (_sy * _sin);
                    var _draw_py = _ystart + (_xoffset * _sin) + (_sx * _sin) + (_sy * _cos);
                    
                    draw_text_transformed_colour(
                        _draw_px, _draw_py,
                        _char, _xscale, _yscale, _angle,
                        _colour, _colour, _colour, _colour, _alpha
                    );
                    
                    if (_state_bold)
                    {
                        /* Fake bold effect by drawing slightly offset */
                        draw_text_transformed_colour(
                            _draw_px + (1 * _xscale * _cos), _draw_py + (1 * _xscale * _sin),
                            _char, _xscale, _yscale, _angle,
                            _colour, _colour, _colour, _colour, _alpha
                        );
                    }
                    
                    var _line_y_offset = 0;
                    var _draw_line = false;
                    
                    if (_state_underline)
                    {
                        _draw_line = true;
                        _line_y_offset = _line_height * 0.9;
                    }
                    else if (_state_strikethrough)
                    {
                        _draw_line = true;
                        _line_y_offset = _line_height * 0.5;
                    }
                    
                    if (_draw_line)
                    {
                        var _lx1 = _draw_px + (_line_y_offset * _cos_90);
                        var _ly1 = _draw_py + (_line_y_offset * _sin_90);
                        var _lx2 = _lx1 + (_char_width * _cos);
                        var _ly2 = _ly1 + (_char_width * _sin);
                        
                        draw_line_colour(_lx1, _ly1, _lx2, _ly2, _colour, _colour);
                    }
                    
                    _xoffset += _char_width;
                    ++_char_counter;
                }
            }
        }
        
        _yoffset += _line_height;
    }
    
    draw_set_halign(_halign);
    draw_set_valign(_valign);
    
    draw_set_font(_current_font);
}