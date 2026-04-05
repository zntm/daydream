global.cuteify_data = {
    happy: spr_Null,
    sad: spr_Null
}

enum CUTEIFY_NODE {
    TEXT,
    COLOUR,
    COLOUR_POP,
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

function cuteify_format_relative_time(_unix)
{
    var _delta = round(_unix - datetime_to_unix());
    var _future = (_delta > 0);
    var _value = abs(_delta);
    var _unit = "second";

    if (_value >= 31_536_000)
    {
        _value = floor(_value / 31_536_000);
        _unit = "year";
    }
    else if (_value >= 2_592_000)
    {
        _value = floor(_value / 2_592_000);
        _unit = "month";
    }
    else if (_value >= 604_800)
    {
        _value = floor(_value / 604_800);
        _unit = "week";
    }
    else if (_value >= 86_400)
    {
        _value = floor(_value / 86_400);
        _unit = "day";
    }
    else if (_value >= 3_600)
    {
        _value = floor(_value / 3_600);
        _unit = "hour";
    }
    else if (_value >= 60)
    {
        _value = floor(_value / 60);
        _unit = "minute";
    }

    if (_value != 1)
    {
        _unit += "s";
    }

    var _text = $"{_value} {_unit}";
    return _future ? $"in {_text}" : $"{_text} ago";
}

function cuteify_format_discord_timestamp(_tag_content)
{
    var _unix_str = _tag_content;
    var _style = "f";
    var _colon = string_pos(":", _tag_content);

    if (_colon > 0)
    {
        _unix_str = string_copy(_tag_content, 1, _colon - 1);
        _style = string_delete(_tag_content, 1, _colon);

        if (_style == "")
        {
            _style = "f";
        }
    }

    if (_unix_str == "")
    {
        return $"<t:{_tag_content}>";
    }

    var _unix = real(_unix_str);
    var _datetime = unix_to_datetime(_unix);

    switch (_style)
    {
        case "t":
        case "T":
            return date_time_string(_datetime);

        case "d":
        case "D":
            return date_date_string(_datetime);

        case "R":
            return cuteify_format_relative_time(_unix);

        case "f":
        case "F":
        default:
            return date_datetime_string(_datetime);
    }
}

function cuteify_markdown_preprocess_inline(_string)
{
    var _result = "";
    var _len = string_length(_string);
    var _pos = 1;

    while (_pos <= _len)
    {
        var _char = string_char_at(_string, _pos);

        if (_char == "\\")
        {
            if (_pos < _len)
            {
                var _escaped = string_char_at(_string, _pos + 1);
                _result += _escaped;
                _pos += 2;
                continue;
            }
        }

        if ((_char == "|") && (_pos < _len) && (string_char_at(_string, _pos + 1) == "|"))
        {
            var _spoiler_end = 0;
            for (var _j = _pos + 2; _j < _len; ++_j)
            {
                if ((string_char_at(_string, _j) == "|") && (string_char_at(_string, _j + 1) == "|"))
                {
                    _spoiler_end = _j;
                    break;
                }
            }

            if (_spoiler_end > 0)
            {
                var _spoiler_text = string_copy(_string, _pos + 2, _spoiler_end - _pos - 2);
                _result += "{*o}" + _spoiler_text + "{*o}";
                _pos = _spoiler_end + 2;
                continue;
            }
        }

        if (_char == "<")
        {
            if ((_pos + 3 <= _len) && (string_copy(_string, _pos, 3) == "</c"))
            {
                var _close_colour_end = string_pos(">", string_delete(_string, 1, _pos + 2));
                if (_close_colour_end > 0)
                {
                    _result += "{#}";
                    _pos += _close_colour_end + 3;
                    continue;
                }
            }
            else if ((_pos + 3 <= _len) && (string_copy(_string, _pos, 3) == "<c:"))
            {
                var _colour_end = string_pos(">", string_delete(_string, 1, _pos + 2));
                if (_colour_end > 0)
                {
                    var _absolute_colour_end = _pos + 2 + _colour_end;
                    var _colour_content = string_copy(_string, _pos + 3, _absolute_colour_end - _pos - 3);
                    if (string_starts_with(_colour_content, "#"))
                    {
                        _colour_content = string_delete(_colour_content, 1, 1);
                    }
                    _result += "{#" + _colour_content + "}";
                    _pos = _absolute_colour_end + 1;
                    continue;
                }
            }

            if ((_pos + 2 <= _len) && (string_copy(_string, _pos, 3) == "<o:"))
            {
                var _obstruct_end = string_pos(">", string_delete(_string, 1, _pos + 2));
                if (_obstruct_end > 0)
                {
                    var _absolute_end = _pos + 2 + _obstruct_end;
                    var _obstruct_text = string_copy(_string, _pos + 3, _absolute_end - _pos - 3);
                    _result += "{*o}" + _obstruct_text + "{*o}";
                    _pos = _absolute_end + 1;
                    continue;
                }
            }
            else if ((_pos + 2 <= _len) && (string_copy(_string, _pos, 3) == "<t:"))
            {
                var _timestamp_end = string_pos(">", string_delete(_string, 1, _pos + 2));
                if (_timestamp_end > 0)
                {
                    var _absolute_timestamp_end = _pos + 2 + _timestamp_end;
                    var _timestamp_content = string_copy(_string, _pos + 3, _absolute_timestamp_end - _pos - 3);
                    _result += cuteify_format_discord_timestamp(_timestamp_content);
                    _pos = _absolute_timestamp_end + 1;
                    continue;
                }
            }
        }

        if (_char == "[")
        {
            var _label_close = 0;
            for (var _j = _pos + 1; _j <= _len; ++_j)
            {
                var _label_char = string_char_at(_string, _j);
                if (_label_char == "]")
                {
                    _label_close = _j;
                    break;
                }
                if (_label_char == "\n") break;
            }

            if ((_label_close > 0) && (_label_close + 1 < _len) && (string_char_at(_string, _label_close + 1) == "("))
            {
                var _url_close = 0;
                for (var _j = _label_close + 2; _j <= _len; ++_j)
                {
                    var _url_char = string_char_at(_string, _j);
                    if (_url_char == ")")
                    {
                        _url_close = _j;
                        break;
                    }
                    if (_url_char == "\n") break;
                }

                if (_url_close > 0)
                {
                    var _label = string_copy(_string, _pos + 1, _label_close - _pos - 1);
                    var _url = string_copy(_string, _label_close + 2, _url_close - _label_close - 2);

                    if (_url != "")
                    {
                        _result += "{#6FA8FF}__" + _label + "__{#}";
                        _pos = _url_close + 1;
                        continue;
                    }
                }
            }
        }

        _result += _char;
        ++_pos;
    }

    return _result;
}

function cuteify_markdown_preprocess(_string)
{
    var _result = "";
    var _len = string_length(_string);
    var _pos = 1;
    var _quote_block = false;

    while (_pos <= _len)
    {
        var _line_end = _pos;
        while (_line_end <= _len) && (string_char_at(_string, _line_end) != "\n")
        {
            ++_line_end;
        }

        var _line = string_copy(_string, _pos, _line_end - _pos);
        var _line_len = string_length(_line);
        var _line_cursor = 1;

        while (_line_cursor <= _line_len)
        {
            var _indent_char = string_char_at(_line, _line_cursor);
            if (_indent_char != " ") && (_indent_char != chr(9)) break;
            ++_line_cursor;
        }

        var _indent = string_copy(_line, 1, _line_cursor - 1);
        var _content = string_delete(_line, 1, _line_cursor - 1);
        var _content_len = string_length(_content);
        var _line_prefix = _indent;

        if (_quote_block) && (_content == "")
        {
            _quote_block = false;
        }

        if (_quote_block)
        {
            _line_prefix += "{#9AA3B2}*";
            _content = cuteify_markdown_preprocess_inline(_content) + "*{#}";
        }
        else if (string_copy(_content, 1, 4) == ">>> ")
        {
            _quote_block = true;
            _line_prefix += "{#9AA3B2}*";
            _content = cuteify_markdown_preprocess_inline(string_delete(_content, 1, 4)) + "*{#}";
        }
        else if (string_copy(_content, 1, 2) == "> ")
        {
            _line_prefix += "{#9AA3B2}*";
            _content = cuteify_markdown_preprocess_inline(string_delete(_content, 1, 2)) + "*{#}";
        }
        else
        {
            var _handled_line = false;
            var _header_level = 0;

            while ((_header_level < _content_len) && (_header_level < 6) && (string_char_at(_content, _header_level + 1) == "#"))
            {
                ++_header_level;
            }

            if ((_header_level > 0) && (_header_level < _content_len) && (string_char_at(_content, _header_level + 1) == " "))
            {
                var _header_text = cuteify_markdown_preprocess_inline(string_delete(_content, 1, _header_level + 1));

                switch (_header_level)
                {
                    case 1:
                        _content = "{#F4E7B2}__**" + _header_text + "**__{#}";
                        break;

                    case 2:
                        _content = "{#F4D7A1}**" + _header_text + "**{#}";
                        break;

                    case 3:
                        _content = "{#C9D4FF}**" + _header_text + "**{#}";
                        break;

                    default:
                        _content = "{#C9D4FF}*" + _header_text + "*{#}";
                        break;
                }

                _handled_line = true;
            }

            if (!_handled_line)
            {
                var _list_char = string_char_at(_content, 1);
                if ((_list_char == "*") || (_list_char == "+") || (_list_char == "-"))
                {
                    if ((_content_len >= 2) && (string_char_at(_content, 2) == " "))
                    {
                        _content = "- " + cuteify_markdown_preprocess_inline(string_delete(_content, 1, 2));
                        _handled_line = true;
                    }
                }
                else
                {
                    var _number_end = 1;
                    while ((_number_end <= _content_len) && (string_char_at(_content, _number_end) >= "0") && (string_char_at(_content, _number_end) <= "9"))
                    {
                        ++_number_end;
                    }

                    if ((_number_end > 1) && (_number_end + 1 <= _content_len) && (string_char_at(_content, _number_end) == ".") && (string_char_at(_content, _number_end + 1) == " "))
                    {
                        _content = string_copy(_content, 1, _number_end) + " " + cuteify_markdown_preprocess_inline(string_delete(_content, 1, _number_end + 1));
                        _handled_line = true;
                    }
                }
            }

            if (!_handled_line)
            {
                _content = cuteify_markdown_preprocess_inline(_content);
            }
        }

        _result += _line_prefix + _content;

        if (_line_end <= _len)
        {
            _result += "\n";
            _pos = _line_end + 1;
        }
        else
        {
            _pos = _line_end + 1;
        }
    }

    return _result;
}

/// @desc Parses a cuteify string into an AST with line width/height info
/// @param {String} _string Input string
/// @param {String} _asset_prefix Prefix for assets
/// @returns {Struct}
function cuteify_parse(_string, _asset_prefix = "")
{
    _string = cuteify_markdown_preprocess(_string);
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
                    else if (_tag_content == "#")
                    {
                        _push_node(_lines, _curr_line, { type: CUTEIFY_NODE.COLOUR_POP, value: _tag_content });
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
