/// @desc UI Language Token Types
enum UI_TOKEN
{
    // Literals
    NUMBER,         // 123, 45.67
    STRING,         // "hello"
    PERCENTAGE,     // 50%
    HEX_COLOR,      // #fff, #ffffff
    TRUE,           // true
    FALSE,          // false
    UNDEFINED,      // undefined
    
    // Identifiers & Keywords
    IDENTIFIER,     // my_var, content
    VAR,            // var keyword
    
    // Element declaration
    AT,             // @ (element prefix)
    
    // Data binding
    ASTERISK,       // * (binding prefix)
    
    // Punctuation
    LPAREN,         // (
    RPAREN,         // )
    LBRACE,         // {
    RBRACE,         // }
    COMMA,          // ,
    EQUALS,         // =
    
    // Constants (resolved to identifiers but recognized)
    CONSTANT,       // LAYOUT_VERTICAL, ALIGN_CENTER, etc.
    
    // Special
    EOF,
    ERROR
}

/// @desc Lexer for UI Language - tokenizes .ui source code
/// @param {String} _source The source code to tokenize
function UILexer(_source) constructor
{
    source = _source;
    length = string_length(_source);
    start = 1;      // 1-indexed for GML strings
    current = 1;
    line = 1;
    tokens = [];
    had_error = false;
    error = "";
    
    /// @desc Known constants in UI language
    static constants = {
        // Layout modes
        "LAYOUT_VERTICAL": true,
        "LAYOUT_HORIZONTAL": true,
        "LAYOUT_GRID": true,
        "LAYOUT_BLOCK": true,
        
        // Alignment
        "ALIGN_START": true,
        "ALIGN_CENTER": true,
        "ALIGN_END": true,
        "ALIGN_LEFT": true,
        "ALIGN_RIGHT": true,
        "ALIGN_TOP": true,
        "ALIGN_BOTTOM": true,
        "ALIGN_SPACE_BETWEEN": true,
        "ALIGN_SPACE_AROUND": true,
        
        // Scale modes
        "FIT": true,
        "FILL": true,
        "STRETCH": true,
        "NONE": true,
        
        // Input modes
        "MODE_STRING": true,
        "MODE_INTEGER": true
    };
    
    /// @desc Keywords lookup
    static keywords = {
        "var": UI_TOKEN.VAR,
        "true": UI_TOKEN.TRUE,
        "false": UI_TOKEN.FALSE,
        "undefined": UI_TOKEN.UNDEFINED
    };
    
    /// @desc Tokenize the source code
    /// @returns {Array} Array of token structs
    static tokenize = function()
    {
        tokens = [];
        start = 1;
        current = 1;
        line = 1;
        had_error = false;
        
        while (!is_at_end())
        {
            start = current;
            scan_token();
            
            if (had_error) break;
        }
        
        array_push(tokens, { type: UI_TOKEN.EOF, lexeme: "", literal: undefined, line: line });
        
        return tokens;
    }
    
    // --- Helper Functions ---
    
    static is_at_end = function()
    {
        return current > length;
    }
    
    static advance = function()
    {
        var _char = string_char_at(source, current);
        current++;
        return _char;
    }
    
    static peek = function()
    {
        if (is_at_end()) return "";
        return string_char_at(source, current);
    }
    
    static peek_next = function()
    {
        if (current + 1 > length) return "";
        return string_char_at(source, current + 1);
    }
    
    static match = function(_expected)
    {
        if (is_at_end()) return false;
        if (string_char_at(source, current) != _expected) return false;
        current++;
        return true;
    }
    
    static add_token = function(_type, _literal = undefined)
    {
        var _text = (current >= start) ? string_copy(source, start, current - start) : "";
        array_push(tokens, { type: _type, lexeme: _text, literal: _literal, line: line });
    }
    
    static is_digit = function(_c)
    {
        return _c >= "0" && _c <= "9";
    }
    
    static is_alpha = function(_c)
    {
        return (_c >= "a" && _c <= "z") || 
               (_c >= "A" && _c <= "Z") || 
               _c == "_";
    }
    
    static is_alphanumeric = function(_c)
    {
        return is_alpha(_c) || is_digit(_c);
    }
    
    // --- Token Scanning ---
    
    static scan_token = function()
    {
        var _c = advance();
        
        switch (_c)
        {
            case "(": add_token(UI_TOKEN.LPAREN); break;
            case ")": add_token(UI_TOKEN.RPAREN); break;
            case "{": add_token(UI_TOKEN.LBRACE); break;
            case "}": add_token(UI_TOKEN.RBRACE); break;
            case ",": add_token(UI_TOKEN.COMMA); break;
            case "=": add_token(UI_TOKEN.EQUALS); break;
            case "@": add_token(UI_TOKEN.AT); break;
            case "*": add_token(UI_TOKEN.ASTERISK); break;
            case "#": scan_hex_color(); break;
            
            // Whitespace
            case " ":
            case "\r":
            case "\t":
                break;
            
            case "\n":
                line++;
                break;
            
            // Comments
            case "/":
                if (match("/"))
                {
                    // Line comment - consume until newline
                    while (peek() != "\n" && !is_at_end())
                    {
                        advance();
                    }
                }
                else if (match("*"))
                {
                    // Block comment
                    while (!is_at_end())
                    {
                        if (peek() == "*" && peek_next() == "/")
                        {
                            advance(); // *
                            advance(); // /
                            break;
                        }
                        if (peek() == "\n") line++;
                        advance();
                    }
                }
                else
                {
                    had_error = true;
                    error = $"Unexpected '/' at line {line}";
                }
                break;
            
            // Strings
            case "\"":
                scan_string();
                break;
            
            default:
                if (is_digit(_c))
                {
                    scan_number();
                }
                else if (is_alpha(_c))
                {
                    scan_identifier();
                }
                else
                {
                    had_error = true;
                    error = $"Unexpected '{_c}' at line {line}";
                }
                break;
        }
    }
    
    /// @desc Scan a string literal
    static scan_string = function()
    {
        var _value = "";
        
        while (peek() != "\"" && !is_at_end())
        {
            if (peek() == "\n") line++;
            
            // Handle escape sequences
            if (peek() == "\\")
            {
                advance(); // consume backslash
                var _escape = advance();
                switch (_escape)
                {
                    case "n": _value += "\n"; break;
                    case "r": _value += "\r"; break;
                    case "t": _value += "\t"; break;
                    case "\"": _value += "\""; break;
                    case "\\": _value += "\\"; break;
                    default:
                        _value += _escape;
                        break;
                }
            }
            else
            {
                _value += advance();
            }
        }
        
        if (is_at_end())
        {
            had_error = true;
            error = $"Unterminated string at line {line}";
            return;
        }
        
        // Closing quote
        advance();
        
        add_token(UI_TOKEN.STRING, _value);
    }
    
    /// @desc Scan a number (with optional percentage)
    static scan_number = function()
    {
        while (is_digit(peek()))
        {
            advance();
        }
        
        // Decimal
        if (peek() == "." && is_digit(peek_next()))
        {
            advance(); // consume the dot
            
            while (is_digit(peek()))
            {
                advance();
            }
        }
        
        var _text = string_copy(source, start, current - start);
        var _value = real(_text);
        
        // Check for percentage suffix
        if (peek() == "%")
        {
            advance();
            add_token(UI_TOKEN.PERCENTAGE, _value);
        }
        else
        {
            add_token(UI_TOKEN.NUMBER, _value);
        }
    }
    
    /// @desc Scan an identifier or keyword
    static scan_identifier = function()
    {
        while (is_alphanumeric(peek()))
        {
            advance();
        }
        
        var _text = string_copy(source, start, current - start);
        
        // Check if it's a keyword
        var _keyword_type = keywords[$ _text];
        if (_keyword_type != undefined)
        {
            add_token(_keyword_type);
            return;
        }
        
        // Check if it's a constant
        if (constants[$ _text] == true)
        {
            add_token(UI_TOKEN.CONSTANT, _text);
            return;
        }
        
        // Regular identifier
        add_token(UI_TOKEN.IDENTIFIER, _text);
    }
    
    /// @desc Check if character is a hex digit
    static is_hex_digit = function(_c)
    {
        return (_c >= "0" && _c <= "9") ||
               (_c >= "a" && _c <= "f") ||
               (_c >= "A" && _c <= "F");
    }
    
    /// @desc Parse a hex character to value (0-15)
    static hex_char_to_value = function(_c)
    {
        if (_c >= "0" && _c <= "9") return ord(_c) - ord("0");
        if (_c >= "a" && _c <= "f") return ord(_c) - ord("a") + 10;
        if (_c >= "A" && _c <= "F") return ord(_c) - ord("A") + 10;
        return 0;
    }
    
    /// @desc Scan a hex color literal (#fff or #ffffff)
    static scan_hex_color = function()
    {
        var _hex_start = current;
        
        // Collect hex digits
        while (is_hex_digit(peek()))
        {
            advance();
        }
        
        var _hex_length = current - _hex_start;
        
        // Must be 3 or 6 hex digits
        if (_hex_length != 3 && _hex_length != 6)
        {
            had_error = true;
            error = $"Invalid hex color at line {line}. Expected 3 or 6 hex digits.";
            return;
        }
        
        var _hex_str = string_copy(source, _hex_start, _hex_length);
        var _r, _g, _b;
        
        if (_hex_length == 3)
        {
            // Short form: #rgb -> #rrggbb
            var _r1 = hex_char_to_value(string_char_at(_hex_str, 1));
            var _g1 = hex_char_to_value(string_char_at(_hex_str, 2));
            var _b1 = hex_char_to_value(string_char_at(_hex_str, 3));
            _r = _r1 * 16 + _r1;
            _g = _g1 * 16 + _g1;
            _b = _b1 * 16 + _b1;
        }
        else
        {
            // Full form: #rrggbb
            var _r1 = hex_char_to_value(string_char_at(_hex_str, 1));
            var _r2 = hex_char_to_value(string_char_at(_hex_str, 2));
            var _g1 = hex_char_to_value(string_char_at(_hex_str, 3));
            var _g2 = hex_char_to_value(string_char_at(_hex_str, 4));
            var _b1 = hex_char_to_value(string_char_at(_hex_str, 5));
            var _b2 = hex_char_to_value(string_char_at(_hex_str, 6));
            _r = _r1 * 16 + _r2;
            _g = _g1 * 16 + _g2;
            _b = _b1 * 16 + _b2;
        }
        
        var _color = make_colour_rgb(_r, _g, _b);
        add_token(UI_TOKEN.HEX_COLOR, _color);
    }
}
