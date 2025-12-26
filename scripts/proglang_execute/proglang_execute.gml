
enum PROG_TOKEN {
    // Literals
    NUMBER, STRING, TRUE, FALSE, UNDEFINED,
    // Identifiers
    IDENTIFIER,
    // Keywords
    VAR, GLOBAL, IF, ELSE, FOR, WHILE, REPEAT, BREAK, CONTINUE, RETURN,
    AND, OR, NOT,
    SWITCH, CASE, DEFAULT,
    FN, FUNCTION,
    // Operators
    PLUS, MINUS, STAR, SLASH, PERCENT, POWER,
    PLUS_PLUS, MINUS_MINUS,
    EQ, NE, LT, GT, LE, GE,
    AMP, PIPE, CARET, LSHIFT, RSHIFT,
    ASSIGN, PLUS_ASSIGN, MINUS_ASSIGN, STAR_ASSIGN, SLASH_ASSIGN,
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
    
    static keywords = {
        "var": PROG_TOKEN.VAR,
        "global": PROG_TOKEN.GLOBAL,
        "if": PROG_TOKEN.IF,
        "else": PROG_TOKEN.ELSE,
        "for": PROG_TOKEN.FOR,
        "while": PROG_TOKEN.WHILE,
        "repeat": PROG_TOKEN.REPEAT,
        "break": PROG_TOKEN.BREAK,
        "continue": PROG_TOKEN.CONTINUE,
        "return": PROG_TOKEN.RETURN,
        "true": PROG_TOKEN.TRUE,
        "false": PROG_TOKEN.FALSE,
        "undefined": PROG_TOKEN.UNDEFINED,
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
        
        while (!is_at_end()) {
            start = current;
            scan_token();
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
        var _text = string_copy(source, start, current - start);
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
            case "{": add_token(PROG_TOKEN.LBRACE); break;
            case "}": add_token(PROG_TOKEN.RBRACE); break;
            case "[": add_token(PROG_TOKEN.LBRACKET); break;
            case "]": add_token(PROG_TOKEN.RBRACKET); break;
            case ",": add_token(PROG_TOKEN.COMMA); break;
            case ".": add_token(PROG_TOKEN.DOT); break;
            case ";": add_token(PROG_TOKEN.SEMICOLON); break;
            case ":": add_token(PROG_TOKEN.COLON); break;
            
            case "+": 
                if (match("+")) add_token(PROG_TOKEN.PLUS_PLUS);
                else add_token(match("=") ? PROG_TOKEN.PLUS_ASSIGN : PROG_TOKEN.PLUS); 
                break;
            case "-": 
                if (match("-")) add_token(PROG_TOKEN.MINUS_MINUS);
                else add_token(match("=") ? PROG_TOKEN.MINUS_ASSIGN : PROG_TOKEN.MINUS); 
                break;
            case "*": add_token(match("=") ? PROG_TOKEN.STAR_ASSIGN : (match("*") ? PROG_TOKEN.POWER : PROG_TOKEN.STAR)); break;
            case "/": 
                if (match("/")) {
                    // Comment
                    while (peek() != "\n" && !is_at_end()) advance();
                } else if (match("*")) {
                    // Block comment
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
            case "=": add_token(match("=") ? PROG_TOKEN.EQ : PROG_TOKEN.ASSIGN); break; // == is EQ, = is ASSIGN
            case "<": add_token(match("=") ? PROG_TOKEN.LE : (match("<") ? PROG_TOKEN.LSHIFT : PROG_TOKEN.LT)); break;
            case ">": add_token(match("=") ? PROG_TOKEN.GE : (match(">") ? PROG_TOKEN.RSHIFT : PROG_TOKEN.GT)); break;
            
            case "&": add_token(match("&") ? PROG_TOKEN.AND : PROG_TOKEN.AMP); break;
            case "|": add_token(match("|") ? PROG_TOKEN.OR : PROG_TOKEN.PIPE); break;
            case "^": add_token(PROG_TOKEN.CARET); break;
            case "?": add_token(PROG_TOKEN.QUESTION); break;
            
            case " ":
            case "\r":
            case "\t":
                // Ignore whitespace
                break;
                
            case "\n":
                line++;
                break;
                
            case "\"": string_scan(); break;
            
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
        
        // Trim quotes
        var _val = string_copy(source, start + 1, current - start - 2);
        add_token(PROG_TOKEN.STRING, _val);
    }
    
    static check_keyword = function(_key) {
       return struct_exists(keywords, _key) ? keywords[$ _key] : PROG_TOKEN.IDENTIFIER;
    }

    static identifier_scan = function() {
        while (is_alpha_numeric(peek())) advance();
        
        var _text = string_copy(source, start, current - start);
        var _type = check_keyword(_text);
        
        add_token(_type);
    }
    
    static number_scan = function() {
        while (is_digit(peek())) advance();
        
        if (peek() == "." && is_digit(peek_next())) {
            advance(); // Consume dot
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
