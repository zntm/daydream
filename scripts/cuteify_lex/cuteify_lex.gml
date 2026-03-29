enum CUTEIFY_TOKEN {
    TEXT,
    BOLD_DELIM,
    ITALIC_DELIM,
    UNDERLINE_DELIM,
    STRIKETHROUGH_DELIM,
    EMOTE,
    TAG_OPEN,
    TAG_CLOSE,
    TAG_CONTENT,
    NEWLINE
}

/// @desc Tokenizes a cuteify-formatted string into a flat array of token structs.
/// @param {String} _string The raw input string.
/// @returns {Array<Struct>} Array of { type, value, pos } token structs.
function cuteify_lex(_string)
{
    var _tokens = [];
    var _len    = string_length(_string);
    var _pos    = 1;
    var _buf    = "";
    var _buf_start = 1;

    while (_pos <= _len)
    {
        var _char = string_char_at(_string, _pos);

        /* newline */
        if (_char == "\n")
        {
            if (string_length(_buf) > 0)
            {
                array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                _buf = "";
            }

            array_push(_tokens, { type: CUTEIFY_TOKEN.NEWLINE, value: "\n", pos: _pos });

            ++_pos;
            _buf_start = _pos;

            continue;
        }

        /* ** bold delimiter (must check before single *) */
        if (_char == "*") && (_pos + 1 <= _len) && (string_char_at(_string, _pos + 1) == "*")
        {
            if (string_length(_buf) > 0)
            {
                array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                _buf = "";
            }

            array_push(_tokens, { type: CUTEIFY_TOKEN.BOLD_DELIM, value: "**", pos: _pos });

            _pos += 2;
            _buf_start = _pos;

            continue;
        }

        /* * italic delimiter */
        if (_char == "*")
        {
            if (string_length(_buf) > 0)
            {
                array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                _buf = "";
            }

            array_push(_tokens, { type: CUTEIFY_TOKEN.ITALIC_DELIM, value: "*", pos: _pos });

            ++_pos;
            _buf_start = _pos;

            continue;
        }

        /* __ underline delimiter */
        if (_char == "_") && (_pos + 1 <= _len) && (string_char_at(_string, _pos + 1) == "_")
        {
            if (string_length(_buf) > 0)
            {
                array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                _buf = "";
            }

            array_push(_tokens, { type: CUTEIFY_TOKEN.UNDERLINE_DELIM, value: "__", pos: _pos });

            _pos += 2;
            _buf_start = _pos;

            continue;
        }

        /* ~~ strikethrough delimiter */
        if (_char == "~") && (_pos + 1 <= _len) && (string_char_at(_string, _pos + 1) == "~")
        {
            if (string_length(_buf) > 0)
            {
                array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                _buf = "";
            }

            array_push(_tokens, { type: CUTEIFY_TOKEN.STRIKETHROUGH_DELIM, value: "~~", pos: _pos });

            _pos += 2;
            _buf_start = _pos;

            continue;
        }

        /* :emote: — scan for closing colon */
        if (_char == ":")
        {
            var _found_end = 0;

            for (var _j = _pos + 1; _j <= _len; ++_j)
            {
                var _c = string_char_at(_string, _j);

                if (_c == ":") { _found_end = _j; break; }
                if (_c == " ") || (_c == "\n") || (_c == "{") || (_c == "}") break;
            }

            if (_found_end > _pos + 1)
            {
                if (string_length(_buf) > 0)
                {
                    array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                    _buf = "";
                }

                var _emote_name = string_copy(_string, _pos + 1, _found_end - _pos - 1);

                array_push(_tokens, { type: CUTEIFY_TOKEN.EMOTE, value: _emote_name, pos: _pos });

                _pos = _found_end + 1;
                _buf_start = _pos;

                continue;
            }
        }

        /* { tag open */
        if (_char == "{")
        {
            /* scan ahead and emit the tag content + close as separate tokens */
            var _tag_start = _pos + 1;
            var _close_pos = 0;

            for (var _j = _tag_start; _j <= _len; ++_j)
            {
                if (string_char_at(_string, _j) == "}")
                {
                    _close_pos = _j;

                    break;
                }

                if (string_char_at(_string, _j) == "\n") break;
            }

            if (_close_pos > 0)
            {
                if (string_length(_buf) > 0)
                {
                    array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });

                    _buf = "";
                }

                array_push(_tokens, { type: CUTEIFY_TOKEN.TAG_OPEN, value: "{", pos: _pos });

                if (_close_pos > _tag_start)
                {
                    var _content = string_copy(_string, _tag_start, _close_pos - _tag_start);

                    array_push(_tokens, { type: CUTEIFY_TOKEN.TAG_CONTENT, value: _content, pos: _tag_start });
                }

                array_push(_tokens, { type: CUTEIFY_TOKEN.TAG_CLOSE, value: "}", pos: _close_pos });

                _pos = _close_pos + 1;
            }
            else
            {
                /* no closing brace found — treat { as plain text */
                if (string_length(_buf) == 0)
                {
                    _buf_start = _pos;
                }
                
                _buf += _char;
                ++_pos;
            }

            _buf_start = _pos;

            continue;
        }

        /* plain character — accumulate into buffer */
        if (string_length(_buf) == 0)
        {
            _buf_start = _pos;
        }

        _buf += _char;
        ++_pos;
    }

    /* flush remaining buffer */
    if (string_length(_buf) > 0)
    {
        array_push(_tokens, { type: CUTEIFY_TOKEN.TEXT, value: _buf, pos: _buf_start });
    }

    return _tokens;
}
