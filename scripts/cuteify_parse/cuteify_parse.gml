global.cuteify_data = {
    happy: spr_Null,
    sad: spr_Null
}

enum CUTEIFY_NODE {
    TEXT,
    COLOUR,
    SPRITE,
    FONT,
    OBSTRUCT,
    OBSTRUCT_END,
    UNDERLINE,
    UNDERLINE_END,
    SHAKE,
    SHAKE_END,
    WAVE,
    WAVE_END,
    BOLD,
    BOLD_END,
    ITALIC,
    ITALIC_END,
    STRIKETHROUGH,
    STRIKETHROUGH_END
}

/// @desc Parses a cuteify string into an AST with line width/height info
/// @param {String} _string Input string
/// @param {String} _asset_prefix Prefix for assets
/// @returns {Struct}
function cuteify_parse(_string, _asset_prefix = "")
{
    var _tokens = cuteify_lex(_string);
    var _token_count = array_length(_tokens);
    
    var _lines = [[]]; // Array of arrays of nodes
    var _curr_line = 0;
    
    var _bold = false;
    var _italic = false;
    var _strikethrough = false;
    var _underline = false;
    var _obstruct = false;
    
    var _push_node = function(_lines_arr, _line_idx, _node)
    {
        array_push(_lines_arr[_line_idx], _node);
    }
    
    var _i = 0;
    while (_i < _token_count)
    {
        var _tok = _tokens[_i];
        
        switch (_tok.type)
        {
            case CUTEIFY_TOKEN.TEXT:
                _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: _tok.value });
                break;
                
            case CUTEIFY_TOKEN.NEWLINE:
                _curr_line++;
                _lines[@ _curr_line] = [];
                break;
                
            case CUTEIFY_TOKEN.BOLD_DELIM:
                _bold = !_bold;
                _push_node(_lines, _curr_line, { type: _bold ? CUTEIFY_NODE.BOLD : CUTEIFY_NODE.BOLD_END, value: "**" });
                break;
                
            case CUTEIFY_TOKEN.ITALIC_DELIM:
                _italic = !_italic;
                _push_node(_lines, _curr_line, { type: _italic ? CUTEIFY_NODE.ITALIC : CUTEIFY_NODE.ITALIC_END, value: "*" });
                break;
                
            case CUTEIFY_TOKEN.UNDERLINE_DELIM:
                _underline = !_underline;
                _push_node(_lines, _curr_line, { type: _underline ? CUTEIFY_NODE.UNDERLINE : CUTEIFY_NODE.UNDERLINE_END, value: "__" });
                break;
                
            case CUTEIFY_TOKEN.STRIKETHROUGH_DELIM:
                _strikethrough = !_strikethrough;
                _push_node(_lines, _curr_line, { type: _strikethrough ? CUTEIFY_NODE.STRIKETHROUGH : CUTEIFY_NODE.STRIKETHROUGH_END, value: "~~" });
                break;
                
            case CUTEIFY_TOKEN.EMOTE:
                var _emote_name = _tok.value;
                var _emote = undefined;
                
                if (variable_global_exists("cuteify_data"))
                {
                    var _cuteify_data = global.cuteify_data;
                    
                    if (_cuteify_data != undefined)
                    {
                        _emote = _cuteify_data[$ $"{_asset_prefix}{_emote_name}"];
                    }
                }
                
                if (_emote == undefined) && (variable_global_exists("emote_data"))
                {
                    _emote = global.emote_data[$ $"{_asset_prefix}{_emote_name}"];
                }
                
                var _asset = asset_get_index($"{_asset_prefix}{_emote_name}");
                
                if (_emote != undefined)
                {
                    _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.SPRITE, value: _emote });
                }
                else if (sprite_exists(_asset))
                {
                    _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.SPRITE, value: _asset });
                }
                else
                {
                    _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: $":{_emote_name}:" });
                }
                break;
                
            case CUTEIFY_TOKEN.TAG_OPEN:
                if (_i + 2 < _token_count) && (_tokens[_i+1].type == CUTEIFY_TOKEN.TAG_CONTENT) && (_tokens[_i+2].type == CUTEIFY_TOKEN.TAG_CLOSE)
                {
                    var _tag_content = _tokens[_i+1].value;
                    var _processed = false;
                    
                    var _string_colour = hex_parse(_tag_content, false);
                    
                    if (_string_colour != undefined)
                    {
                        _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.COLOUR, value: _string_colour });
                        _processed = true;
                    }
                    else
                    {
                        var _emote = undefined;
                        
                        if (variable_global_exists("cuteify_data"))
                        {
                            var _cuteify_data = global.cuteify_data;
                            
                            if (_cuteify_data != undefined)
                            {
                                _emote = _cuteify_data[$ $"{_asset_prefix}{_tag_content}"];
                            }
                        }
                        
                        if (_emote == undefined) && (variable_global_exists("emote_data"))
                        {
                            _emote = global.emote_data[$ $"{_asset_prefix}{_tag_content}"];
                        }
                        
                        var _asset = asset_get_index($"{_asset_prefix}{_tag_content}");
                        
                        if (_emote != undefined)
                        {
                            _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.SPRITE, value: _emote });
                            _processed = true;
                        }
                        else if (font_exists(_asset))
                        {
                            _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.FONT, value: _asset });
                            _processed = true;
                        }
                        else if (_tag_content == "*o")
                        {
                            _obstruct = !_obstruct;
                            _push_node(_lines, _curr_line, { type: _obstruct ? CUTEIFY_NODE.OBSTRUCT : CUTEIFY_NODE.OBSTRUCT_END, value: "*o" });
                            _processed = true;
                        }
                        else if (_tag_content == "*u")
                        {
                            _underline = !_underline;
                            _push_node(_lines, _curr_line, { type: _underline ? CUTEIFY_NODE.UNDERLINE : CUTEIFY_NODE.UNDERLINE_END, value: "*u" });
                            _processed = true;
                        }
                        else if (string_starts_with(_tag_content, "*s:"))
                        {
                            var _param_str = string_delete(_tag_content, 1, 3);
                            _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.SHAKE, value: real(_param_str) });
                            _processed = true;
                        }
                        else if (string_starts_with(_tag_content, "*w:"))
                        {
                            var _param_str = string_delete(_tag_content, 1, 3);
                            _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.WAVE, value: real(_param_str) });
                            _processed = true;
                        }
                    }
                    
                    if (!_processed)
                    {
                        _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: "{" + _tag_content + "}" });
                    }
                    
                    _i += 2;
                }
                else if (_i + 1 < _token_count) && (_tokens[_i+1].type == CUTEIFY_TOKEN.TAG_CLOSE)
                {
                    _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: "{}" });
                    _i += 1;
                }
                else
                {
                    _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: "{" });
                }
                break;
                
            case CUTEIFY_TOKEN.TAG_CLOSE:
                _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: "}" });
                break;
                
            case CUTEIFY_TOKEN.TAG_CONTENT:
                _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.TEXT, value: _tok.value });
                break;
        }
        
        _i++;
    }
    
    /* calculate line metrics */
    var _string_width = [];
    var _string_height = [];
    var _line_count = array_length(_lines);
    var _current_font = draw_get_font();
    var _base_line_height = (_current_font == -1) ? 16 : string_height("I");
    
    for (var j = 0; j < _line_count; ++j)
    {
        var _line_nodes = _lines[j];
        var _node_count = array_length(_line_nodes);
        
        var _w = 0;
        var _max_h = _base_line_height;
        
        for (var k = 0; k < _node_count; ++k)
        {
            var _node = _line_nodes[k];
            
            if (_node.type == CUTEIFY_NODE.FONT)
            {
                draw_set_font(_node.value);
                _max_h = max(_max_h, string_height("I"));
            }
            else if (_node.type == CUTEIFY_NODE.TEXT)
            {
                _w += string_width(_node.value);
            }
            else if (_node.type == CUTEIFY_NODE.SPRITE)
            {
                var _norm = (string_height("I")) / sprite_get_height(_node.value);
                _w += sprite_get_width(_node.value) * _norm;
                _max_h = max(_max_h, string_height("I")); /* sprites fit the font height */
            }
        }
        
        _string_width[@ j] = _w;
        _string_height[@ j] = _max_h;
    }
    
    draw_set_font(_current_font);
    
    return {
        lines: _lines,
        widths: _string_width,
        heights: _string_height,
        line_count: _line_count - 1
    }
}
