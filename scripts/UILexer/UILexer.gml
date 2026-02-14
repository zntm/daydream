/// @desc UI Token Types for Declarative UI Language
enum UI_TOKEN {
    // Element declaration
    AT,              // @
    LPAREN, RPAREN,  // ( )
    LBRACE, RBRACE,  // { }
    
    // Values
    NUMBER,
    STRING,
    TRUE, FALSE,
    UNDEFINED,
    IDENTIFIER,
    
    // Operators
    EQUALS,    // =
    COMMA,     // ,
    STAR,      // * (binding prefix OR multiplication depending on context)
    DOLLAR,    // $ (loca key prefix)
    HASH,      // # (color prefix)
    
    // Math operators
    PLUS,      // +
    MINUS,     // -
    SLASH,     // /
    PERCENT,   // % (modulo, standalone)
    POWER,     // **
    
    // Keywords
    VAR,
    EXPORT,
    MULTIPLE,    // multiple(count, var)
    
    // Built-in functions
    FLOOR,       // floor(expr)
    
    // Layout enums (treated as identifiers but reserved)
    LAYOUT_VERTICAL,
    LAYOUT_HORIZONTAL,
    LAYOUT_GRID,
    LAYOUT_NONE,
    
    // Special
    EOF,
    ERROR
}

/// @desc Lexer for UI Language - tokenizes .ui source into tokens
/// @param {String} _source The source code to tokenize
function UILexer(_source) constructor {
    source = _source;
    length = string_length(_source);
    start = 1;
    current = 1;
    line = 1;
    tokens = [];
    had_error = false;
    error = "";
    
    /// @desc Keyword lookup table
    static keywords = {
        "var": UI_TOKEN.VAR,
        "export": UI_TOKEN.EXPORT,
        "multiple": UI_TOKEN.MULTIPLE,
        "true": UI_TOKEN.TRUE,
        "false": UI_TOKEN.FALSE,
        "undefined": UI_TOKEN.UNDEFINED,
        "floor": UI_TOKEN.FLOOR,
        "LAYOUT_VERTICAL": UI_TOKEN.LAYOUT_VERTICAL,
        "LAYOUT_HORIZONTAL": UI_TOKEN.LAYOUT_HORIZONTAL,
        "LAYOUT_GRID": UI_TOKEN.LAYOUT_GRID,
        "LAYOUT_NONE": UI_TOKEN.LAYOUT_NONE
    };
    
    /// @desc Tokenize the source code
    /// @returns {Array} Array of token structs
    static tokenize = function() {
        tokens = [];
        start = 1;
        current = 1;
        line = 1;
        had_error = false;
        
        while (!is_at_end()) {
            start = current;
            scan_token();
        }
        
        array_push(tokens, { type: UI_TOKEN.EOF, lexeme: "", literal: undefined, line: line });
        
        return tokens;
    }
    
    static is_at_end = function() {
        return current > length;
    }
    
    static advance = function() {
        var _c = string_char_at(source, current);
        current++;
        return _c;
    }
    
    static peek = function() {
        if (is_at_end()) return "";
        return string_char_at(source, current);
    }
    
    static peek_next = function() {
        if (current + 1 > length) return "";
        return string_char_at(source, current + 1);
    }
    
    static match = function(_expected) {
        if (is_at_end()) return false;
        if (string_char_at(source, current) != _expected) return false;
        current++;
        return true;
    }
    
    static add_token = function(_type, _literal = undefined) {
        var _text = (current >= start) ? string_copy(source, start, current - start) : "";
        array_push(tokens, { type: _type, lexeme: _text, literal: _literal, line: line });
    }
    
    static scan_token = function() {
        var _c = advance();
        
        switch (_c) {
            case "@":
                add_token(UI_TOKEN.AT);
                break;
            
            case "(":
                add_token(UI_TOKEN.LPAREN);
                break;
            
            case ")":
                add_token(UI_TOKEN.RPAREN);
                break;
            
            case "{":
                add_token(UI_TOKEN.LBRACE);
                break;
            
            case "}":
                add_token(UI_TOKEN.RBRACE);
                break;
            
            case "=":
                add_token(UI_TOKEN.EQUALS);
                break;
            
            case ",":
                add_token(UI_TOKEN.COMMA);
                break;
            
            case "*":
                if (match("*")) {
                    add_token(UI_TOKEN.POWER);
                } else {
                    add_token(UI_TOKEN.STAR);
                }
                break;
            
            case "$":
                add_token(UI_TOKEN.DOLLAR);
                break;
            
            case "+":
                add_token(UI_TOKEN.PLUS);
                break;
            
            case "-":
                if (is_digit(peek())) {
                    scan_number();
                } else {
                    add_token(UI_TOKEN.MINUS);
                }
                break;
            
            case "%":
                add_token(UI_TOKEN.PERCENT);
                break;
            
            case "#":
                scan_color();
                break;
            
            case "/":
                if (match("/")) {
                    // Line comment - skip to end of line
                    while (peek() != "\n" && !is_at_end()) {
                        advance();
                    }
                } else if (match("*")) {
                    // Block comment
                    while (!is_at_end()) {
                        if (peek() == "*" && peek_next() == "/") {
                            advance(); // consume *
                            advance(); // consume /
                            break;
                        }
                        if (peek() == "\n") line++;
                        advance();
                    }
                } else {
                    add_token(UI_TOKEN.SLASH);
                }
                break;
            
            case " ": case "\r": case "\t":
                // Ignore whitespace
                break;
            
            case "\n":
                line++;
                break;
            
            case "\"":
                scan_string();
                break;
            
            default:
                if (is_digit(_c)) {
                    scan_number();
                } else if (is_alpha(_c)) {
                    scan_identifier();
                } else {
                    had_error = true;
                    error = $"Unexpected character '{_c}' at line {line}";
                }
                break;
        }
    }
    
    static is_digit = function(_c) {
        return (_c >= "0" && _c <= "9");
    }
    
    static is_alpha = function(_c) {
        return (_c >= "a" && _c <= "z") ||
               (_c >= "A" && _c <= "Z") ||
               _c == "_";
    }
    
    static is_alphanumeric = function(_c) {
        return is_alpha(_c) || is_digit(_c);
    }
    
    static is_hex = function(_c) {
        return is_digit(_c) ||
               (_c >= "a" && _c <= "f") ||
               (_c >= "A" && _c <= "F");
    }
    
    static scan_string = function() {
        var _value = "";
        
        while (peek() != "\"" && !is_at_end()) {
            if (peek() == "\n") line++;
            if (peek() == "\\") {
                advance();
                var _escaped = advance();
                switch (_escaped) {
                    case "n": _value += "\n"; break;
                    case "t": _value += "\t"; break;
                    case "r": _value += "\r"; break;
                    case "\"": _value += "\""; break;
                    case "\\": _value += "\\"; break;
                    default: _value += _escaped; break;
                }
            } else {
                _value += advance();
            }
        }
        
        if (is_at_end()) {
            had_error = true;
            error = $"Unterminated string at line {line}";
            return;
        }
        
        advance(); // Closing "
        add_token(UI_TOKEN.STRING, _value);
    }
    
    static scan_number = function() {
        // Support underscores in numbers (e.g., 10_000)
        while (is_digit(peek()) || peek() == "_") advance();
        
        // Look for decimal
        if (peek() == "." && is_digit(peek_next())) {
            advance(); // consume .
            while (is_digit(peek()) || peek() == "_") advance();
        }
        
        // Remove underscores before parsing
        var _text = string_copy(source, start, current - start);
        _text = string_replace_all(_text, "_", "");
        var _value = real(_text);
        
        // Check for percentage suffix: 50% (no space before %)
        if (peek() == "%") {
            advance(); // consume %
            add_token(UI_TOKEN.NUMBER, { value: _value, is_percent: true });
        } else {
            add_token(UI_TOKEN.NUMBER, _value);
        }
    }
    
    static scan_color = function() {
        // Already consumed #
        var _hex = "";
        
        while (is_hex(peek())) {
            _hex += advance();
        }
        
        var _len = string_length(_hex);
        
        if (_len == 6 || _len == 8) {
            // Parse RGB or RGBA
            var _r = hex_parse_byte(string_copy(_hex, 1, 2));
            var _g = hex_parse_byte(string_copy(_hex, 3, 2));
            var _b = hex_parse_byte(string_copy(_hex, 5, 2));
            var _a = (_len == 8) ? hex_parse_byte(string_copy(_hex, 7, 2)) / 255 : 1;
            
            var _color = make_colour_rgb(_r, _g, _b);
            add_token(UI_TOKEN.NUMBER, { color: _color, alpha: _a, is_color: true });
        } else if (_len == 3) {
            // Short form #RGB
            var _r = hex_parse_byte(string_repeat(string_char_at(_hex, 1), 2));
            var _g = hex_parse_byte(string_repeat(string_char_at(_hex, 2), 2));
            var _b = hex_parse_byte(string_repeat(string_char_at(_hex, 3), 2));
            
            var _color = make_colour_rgb(_r, _g, _b);
            add_token(UI_TOKEN.NUMBER, { color: _color, alpha: 1, is_color: true });
        } else {
            had_error = true;
            error = $"Invalid color format '#{_hex}' at line {line}. Expected #RGB, #RRGGBB, or #RRGGBBAA";
        }
    }
    
    static hex_parse_byte = function(_hex) {
        var _result = 0;
        var _len = string_length(_hex);
        
        for (var i = 1; i <= _len; i++) {
            var _c = string_char_at(_hex, i);
            var _val = 0;
            
            if (_c >= "0" && _c <= "9") {
                _val = ord(_c) - ord("0");
            } else if (_c >= "a" && _c <= "f") {
                _val = ord(_c) - ord("a") + 10;
            } else if (_c >= "A" && _c <= "F") {
                _val = ord(_c) - ord("A") + 10;
            }
            
            _result = _result * 16 + _val;
        }
        
        return _result;
    }
    
    static scan_identifier = function() {
        while (is_alphanumeric(peek())) advance();
        
        var _text = string_copy(source, start, current - start);
        var _type = keywords[$ _text];
        
        if (_type == undefined) {
            _type = UI_TOKEN.IDENTIFIER;
        }
        
        add_token(_type, _text);
    }
}
