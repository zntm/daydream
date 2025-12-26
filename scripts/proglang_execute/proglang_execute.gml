
enum PROG_TOKEN {
    // Literals
    NUMBER, STRING, TRUE, FALSE, UNDEFINED,
    // Identifiers
    IDENTIFIER,
    // Keywords
    VAR, GLOBAL, IF, ELSE, FOR, IN, WHILE, REPEAT, BREAK, CONTINUE, RETURN,
    TRY, CATCH,
    AND, OR, NOT,
    SWITCH, CASE, DEFAULT,
    FN, FUNCTION,
    // Operators
    PLUS, MINUS, STAR, SLASH, PERCENT, POWER,
    PLUS_PLUS, MINUS_MINUS,
    EQ, NE, LT, GT, LE, GE,
    AMP, PIPE, CARET, LSHIFT, RSHIFT,
    ASSIGN, PLUS_ASSIGN, MINUS_ASSIGN, STAR_ASSIGN, SLASH_ASSIGN,
    NULL_COALESCE, SPREAD, ARROW,
    // Punctuation
    LPAREN, RPAREN, LBRACE, RBRACE, LBRACKET, RBRACKET,
    COMMA, DOT, SEMICOLON, COLON, QUESTION,
    // Special
    EOF, ERROR
}

/// @desc Lexer for Proglang
function ProgLexer(_source) constructor {
    source = _source;
    length = string_length(_source);
    start = 1;
    current = 1;
    line = 1;
    tokens = [];
    had_error = false;
    error = "";
    
    // String Interpolation Stack: Stores nesting depth of braces for interpolation
    // -1: In String Scan Mode
    // >= 0: In Expression Mode (counting braces)
    interp_stack = []; 
    
    static keywords = {
        "var": PROG_TOKEN.VAR,
        "global": PROG_TOKEN.GLOBAL,
        "if": PROG_TOKEN.IF,
        "else": PROG_TOKEN.ELSE,
        "for": PROG_TOKEN.FOR,
        "in": PROG_TOKEN.IN,
        "while": PROG_TOKEN.WHILE,
        "repeat": PROG_TOKEN.REPEAT,
        "break": PROG_TOKEN.BREAK,
        "continue": PROG_TOKEN.CONTINUE,
        "return": PROG_TOKEN.RETURN,
        "true": PROG_TOKEN.TRUE,
        "false": PROG_TOKEN.FALSE,
        "undefined": PROG_TOKEN.UNDEFINED,
        "try": PROG_TOKEN.TRY,
        "catch": PROG_TOKEN.CATCH,
        "and": PROG_TOKEN.AND,
        "or": PROG_TOKEN.OR,
        "not": PROG_TOKEN.NOT,
        "switch": PROG_TOKEN.SWITCH,
        "case": PROG_TOKEN.CASE,
        "default": PROG_TOKEN.DEFAULT,
        "fn": PROG_TOKEN.FN,
        "function": PROG_TOKEN.FUNCTION
    };
    
    static tokenize = function() {
        tokens = [];
        start = 1;
        current = 1;
        line = 1;
        had_error = false;
        interp_stack = [];
        
        while (!is_at_end()) {
            start = current;
            
            // Check if we are in string interpolation mode
            if (array_length(interp_stack) > 0 && interp_stack[array_length(interp_stack)-1] == -1) {
                string_interpolation_scan();
            } else {
                scan_token();
            }
        }
        
        array_push(tokens, { type: PROG_TOKEN.EOF, lexeme: "", literal: undefined, line: line });
        return tokens;
    }
    
    static is_at_end = function() {
        return current > length;
    }
    
    static advance = function() {
        return string_char_at(source, current++);
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
        var _text = "";
        if (current >= start) _text = string_copy(source, start, current - start);
        array_push(tokens, {
            type: _type,
            lexeme: _text,
            literal: _literal,
            line: line
        });
    }
    
    static scan_token = function() {
        var _c = advance();
        
        switch (_c) {
            case "(": add_token(PROG_TOKEN.LPAREN); break;
            case ")": add_token(PROG_TOKEN.RPAREN); break;
            case "{": 
                add_token(PROG_TOKEN.LBRACE); 
                // Track braces if inside interpolation expression
                if (array_length(interp_stack) > 0) {
                     interp_stack[@ array_length(interp_stack) - 1]++;
                }
                break;
            case "}": 
                if (array_length(interp_stack) > 0) {
                     var _depth = interp_stack[array_length(interp_stack) - 1];
                     if (_depth == 0) {
                         // End of interpolation expression -> Resume string
                         add_token(PROG_TOKEN.RPAREN); // Closes string(...)
                         add_token(PROG_TOKEN.PLUS);   // Concatenate next part
                         
                         // Switch back to String Mode
                         interp_stack[@ array_length(interp_stack) - 1] = -1;
                         return;
                     } else {
                         interp_stack[@ array_length(interp_stack) - 1]--;
                         add_token(PROG_TOKEN.RBRACE);
                     }
                } else {
                    add_token(PROG_TOKEN.RBRACE); 
                }
                break;
            case "[": add_token(PROG_TOKEN.LBRACKET); break;
            case "]": add_token(PROG_TOKEN.RBRACKET); break;
            case ",": add_token(PROG_TOKEN.COMMA); break;
            case ".": 
                if (match(".") && match(".")) add_token(PROG_TOKEN.SPREAD);
                else add_token(PROG_TOKEN.DOT); 
                break;
            case ";": add_token(PROG_TOKEN.SEMICOLON); break;
            case ":": add_token(PROG_TOKEN.COLON); break;
            
            case "+": 
                if (match("+")) add_token(PROG_TOKEN.PLUS_PLUS);
                else add_token(match("=") ? PROG_TOKEN.PLUS_ASSIGN : PROG_TOKEN.PLUS); 
                break;
            case "-": 
                if (match("-")) add_token(PROG_TOKEN.MINUS_MINUS);
                else if (match(">")) add_token(PROG_TOKEN.ARROW);
                else add_token(match("=") ? PROG_TOKEN.MINUS_ASSIGN : PROG_TOKEN.MINUS); 
                break;
            case "*": add_token(match("=") ? PROG_TOKEN.STAR_ASSIGN : (match("*") ? PROG_TOKEN.POWER : PROG_TOKEN.STAR)); break;
            case "/": 
                if (match("/")) {
                    while (peek() != "\n" && !is_at_end()) advance();
                } else if (match("*")) {
                    while (!is_at_end()) {
                        if (peek() == "*" && peek_next() == "/") {
                            advance(); advance();
                            break;
                        }
                        if (peek() == "\n") line++;
                        advance();
                    }
                } else {
                    add_token(match("=") ? PROG_TOKEN.SLASH_ASSIGN : PROG_TOKEN.SLASH);
                }
                break;
            case "%": add_token(PROG_TOKEN.PERCENT); break;
            
            case "!": add_token(match("=") ? PROG_TOKEN.NE : PROG_TOKEN.NOT); break;
            case "=": 
                if (match("=")) add_token(PROG_TOKEN.EQ);
                else if (match(">")) add_token(PROG_TOKEN.ARROW);
                else add_token(PROG_TOKEN.ASSIGN);
                break; 
            case "<": add_token(match("=") ? PROG_TOKEN.LE : (match("<") ? PROG_TOKEN.LSHIFT : PROG_TOKEN.LT)); break;
            case ">": add_token(match("=") ? PROG_TOKEN.GE : (match(">") ? PROG_TOKEN.RSHIFT : PROG_TOKEN.GT)); break;
            
            case "&": add_token(match("&") ? PROG_TOKEN.AND : PROG_TOKEN.AMP); break;
            case "|": add_token(match("|") ? PROG_TOKEN.OR : PROG_TOKEN.PIPE); break;
            case "^": add_token(PROG_TOKEN.CARET); break;
            case "?": add_token(match("?") ? PROG_TOKEN.NULL_COALESCE : PROG_TOKEN.QUESTION); break;
            
            case " ":
            case "\r":
            case "\t":
                break;
                
            case "\n":
                line++;
                break;
                
            case "\"": 
                string_scan(); 
                break;
                
            case "$":
                if (match("\"")) {
                    string_interpolation_start();
                } else {
                     had_error = true;
                     error = $"Unexpected character '$' at line {line}";
                }
                break;
            
            default:
                if (is_digit(_c)) {
                    number_scan();
                } else if (is_alpha(_c)) {
                    identifier_scan();
                } else {
                    had_error = true;
                    error = $"Unexpected character '{_c}' at line {line}";
                }
                break;
        }
    }
    
    static string_scan = function() {
        while (peek() != "\"" && !is_at_end()) {
            if (peek() == "\n") line++;
            advance();
        }
        
        if (is_at_end()) {
            had_error = true;
            error = $"Unterminated string at line {line}";
            return;
        }
        
        advance(); // Closing quote
        var _val = string_copy(source, start + 1, current - start - 2);
        add_token(PROG_TOKEN.STRING, _val);
    }
    
    // Start $"..."
    static string_interpolation_start = function() {
        // Emit: ( "string" +
        add_token(PROG_TOKEN.LPAREN);
        
        // Push State: -1 (In string scan)
        array_push(interp_stack, -1);
        
        // Start scanning content
        start = current;  
        string_interpolation_scan();
    }
    
    static string_interpolation_scan = function() {
        start = current;
        
        while (peek() != "\"" && peek() != "{" && !is_at_end()) {
            if (peek() == "\n") line++;
            advance();
        }
        
        if (is_at_end()) {
            had_error = true;
            error = $"Unterminated interpolated string at line {line}";
            return;
        }
        
        // Text part
        var _text_part = string_copy(source, start, current - start);
        add_token(PROG_TOKEN.STRING, _text_part);
        
        var _char = peek();
        if (_char == "\"") {
            advance(); // Quote
            add_token(PROG_TOKEN.RPAREN); // Close outer group
            array_pop(interp_stack);
        } else if (_char == "{") {
            advance(); // Consume {
            
            // ... + string( ...
            add_token(PROG_TOKEN.PLUS);
            
            // Inject helper `string(`
            array_push(tokens, { type: PROG_TOKEN.IDENTIFIER, lexeme: "string", literal: undefined, line: line });
            array_push(tokens, { type: PROG_TOKEN.LPAREN, lexeme: "(", literal: undefined, line: line });
            
            // Switch to Code Mode
            interp_stack[@ array_length(interp_stack) - 1] = 0;
        }
    }
    
    static check_keyword = function(_key) {
       return variable_struct_exists(keywords, _key) ? keywords[$ _key] : PROG_TOKEN.IDENTIFIER;
    }

    static identifier_scan = function() {
        while (is_alpha_numeric(peek())) advance();
        var _text = string_copy(source, start, current - start);
        add_token(check_keyword(_text));
    }
    
    static number_scan = function() {
        while (is_digit(peek())) advance();
        if (peek() == "." && is_digit(peek_next())) {
            advance();
            while (is_digit(peek())) advance();
        }
        var _val = real(string_copy(source, start, current - start));
        add_token(PROG_TOKEN.NUMBER, _val);
    }
    
    static is_digit = function(_c) {
        return (_c >= "0" && _c <= "9");
    }
    
    static is_alpha = function(_c) {
        return (_c >= "a" && _c <= "z") || (_c >= "A" && _c <= "Z") || _c == "_";
    }
    
    static is_alpha_numeric = function(_c) {
        return is_alpha(_c) || is_digit(_c);
    }
}
