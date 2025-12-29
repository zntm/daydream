/// @desc Proglang Token Types
enum PROG_TOKEN
{
    // Literals
    NUMBER, STRING, REGEX, TRUE, FALSE, UNDEFINED,
    // Identifiers
    IDENTIFIER,
    // Keywords
    VAR, GLOBAL, IF, ELSE, FOR, IN, WHILE, REPEAT, BREAK, CONTINUE, RETURN,
    TRY, CATCH, THROW, AND, OR, NOT, SWITCH, CASE, DEFAULT, FN,
    IMPORT, EXPORT, FROM, AS,
    // Class keywords
    CLASS, NEW, THIS, EXTENDS, SUPER, STATIC,
    PUBLIC, PRIVATE, PROTECTED, ABSTRACT, INTERFACE, IMPLEMENTS,
    // Operators
    PLUS, MINUS, STAR, SLASH, PERCENT, POWER,
    PLUS_PLUS, MINUS_MINUS,
    EQ, NE, LT, GT, LE, GE,
    AMP, PIPE, CARET, TILDE, LSHIFT, RSHIFT,
    ASSIGN, PLUS_ASSIGN, MINUS_ASSIGN, STAR_ASSIGN, SLASH_ASSIGN,
    LSHIFT_ASSIGN, RSHIFT_ASSIGN, AMP_ASSIGN, PIPE_ASSIGN, CARET_ASSIGN,
    NULL_COALESCE, SPREAD, ARROW,
    // Punctuation
    LPAREN, RPAREN, LBRACE, RBRACE, LBRACKET, RBRACKET,
    COMMA, DOT, SEMICOLON, COLON, QUESTION,
    // Special
    EOF, ERROR
}

/// @desc Lexer for Proglang - tokenizes source code into tokens
/// @param {string} _source The source code to tokenize
function ProgLexer(_source) constructor
{
    source = _source;
    length = string_length(_source);
    start = 1;
    current = 1;
    line = 1;
    tokens = [];
    had_error = false;
    error = "";
    interp_stack = []; // String interpolation state tracking
    
    /// @desc Keyword lookup table
    static keywords = {
        "var": PROG_TOKEN.VAR, "global": PROG_TOKEN.GLOBAL,
        "if": PROG_TOKEN.IF, "else": PROG_TOKEN.ELSE,
        "for": PROG_TOKEN.FOR, "in": PROG_TOKEN.IN,
        "while": PROG_TOKEN.WHILE, "repeat": PROG_TOKEN.REPEAT,
        "break": PROG_TOKEN.BREAK, "continue": PROG_TOKEN.CONTINUE,
        "return": PROG_TOKEN.RETURN,
        "true": PROG_TOKEN.TRUE, "false": PROG_TOKEN.FALSE, "undefined": PROG_TOKEN.UNDEFINED,
        "try": PROG_TOKEN.TRY, "catch": PROG_TOKEN.CATCH, "throw": PROG_TOKEN.THROW,
        "and": PROG_TOKEN.AND, "or": PROG_TOKEN.OR, "not": PROG_TOKEN.NOT,
        "switch": PROG_TOKEN.SWITCH, "case": PROG_TOKEN.CASE, "default": PROG_TOKEN.DEFAULT,
        "fn": PROG_TOKEN.FN,
        "import": PROG_TOKEN.IMPORT, "export": PROG_TOKEN.EXPORT, "from": PROG_TOKEN.FROM, "as": PROG_TOKEN.AS,
        // Class keywords
        "class": PROG_TOKEN.CLASS, "new": PROG_TOKEN.NEW, "this": PROG_TOKEN.THIS,
        "extends": PROG_TOKEN.EXTENDS, "super": PROG_TOKEN.SUPER, "static": PROG_TOKEN.STATIC,
        "public": PROG_TOKEN.PUBLIC, "private": PROG_TOKEN.PRIVATE, "protected": PROG_TOKEN.PROTECTED,
        "abstract": PROG_TOKEN.ABSTRACT, "interface": PROG_TOKEN.INTERFACE, "implements": PROG_TOKEN.IMPLEMENTS
    }
    
    /// @desc Tokenize the source code
    /// @returns {array} Array of token structs
    static tokenize = function()
    {
        tokens = [];
        start = 1;
        current = 1;
        line = 1;
        had_error = false;
        interp_stack = [];
        
        while (!is_at_end())
        {
            start = current;
            if (array_length(interp_stack) > 0 && interp_stack[array_length(interp_stack)-1] == -1)
            {
                scan_interpolation();
            }
            else
            {
                scan_token();
            }
        }
        
        array_push(tokens, { type: PROG_TOKEN.EOF, lexeme: "", literal: undefined, line: line });
        return tokens;
    }
    
    static is_at_end = function() { return current > length; }
    static advance = function() { return string_char_at(source, current++); }
    static peek = function() { return is_at_end() ? "" : string_char_at(source, current); }
    static peek_next = function() { return (current + 1 > length) ? "" : string_char_at(source, current + 1); }
    
    static match = function(_expected)
    {
        if (is_at_end() || string_char_at(source, current) != _expected) return false;
        current++;
        return true;
    }
    
    static add_token = function(_type, _literal = undefined)
    {
        var _text = (current >= start) ? string_copy(source, start, current - start) : "";
        array_push(tokens, { type: _type, lexeme: _text, literal: _literal, line: line });
    }
    
    static scan_token = function()
    {
        var _c = advance();
        
        switch (_c)
        {
            case "(": add_token(PROG_TOKEN.LPAREN); break;
            case ")": add_token(PROG_TOKEN.RPAREN); break;
            case "{": 
                add_token(PROG_TOKEN.LBRACE); 
                if (array_length(interp_stack) > 0) interp_stack[@ array_length(interp_stack) - 1]++;
                break;
            case "}": 
                if (array_length(interp_stack) > 0)
                {
                    var _depth = interp_stack[array_length(interp_stack) - 1];
                    if (_depth == 0)
                    {
                        add_token(PROG_TOKEN.RPAREN);
                        add_token(PROG_TOKEN.PLUS);
                        interp_stack[@ array_length(interp_stack) - 1] = -1;
                        return;
                    }
                    interp_stack[@ array_length(interp_stack) - 1]--;
                }
                add_token(PROG_TOKEN.RBRACE); 
                break;
            case "[": add_token(PROG_TOKEN.LBRACKET); break;
            case "]": add_token(PROG_TOKEN.RBRACKET); break;
            case ",": add_token(PROG_TOKEN.COMMA); break;
            case ".": add_token((match(".") && match(".")) ? PROG_TOKEN.SPREAD : PROG_TOKEN.DOT); break;
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
                if (match("/")) { while (peek() != "\n" && !is_at_end()) advance(); }
                else if (match("*"))
                {
                    while (!is_at_end())
                    {
                        if (peek() == "*" && peek_next() == "/") { advance(); advance(); break; }
                        if (peek() == "\n") line++;
                        advance();
                    }
                }
                else
                { 
                    // Regex vs Division check
                    var _is_regex = false;
                    if (array_length(tokens) == 0) _is_regex = true;
                    else
                    {
                        var _last = tokens[array_length(tokens) - 1].type;
                        if (_last == PROG_TOKEN.LPAREN || _last == PROG_TOKEN.COMMA || 
                            _last == PROG_TOKEN.ASSIGN || _last == PROG_TOKEN.COLON ||
                            _last == PROG_TOKEN.SEMICOLON || _last == PROG_TOKEN.LBRACE ||
                            _last == PROG_TOKEN.LBRACKET || _last == PROG_TOKEN.RETURN ||
                            _last == PROG_TOKEN.THROW || _last == PROG_TOKEN.CASE ||
                            _last == PROG_TOKEN.PLUS || _last == PROG_TOKEN.MINUS ||
                            _last == PROG_TOKEN.STAR || _last == PROG_TOKEN.SLASH ||
                            _last == PROG_TOKEN.PERCENT || _last == PROG_TOKEN.POWER ||
                            _last == PROG_TOKEN.AND || _last == PROG_TOKEN.OR || 
                            _last == PROG_TOKEN.NOT || _last == PROG_TOKEN.AMP || 
                            _last == PROG_TOKEN.PIPE || _last == PROG_TOKEN.CARET ||
                            _last == PROG_TOKEN.EQ || _last == PROG_TOKEN.NE ||
                            _last == PROG_TOKEN.LT || _last == PROG_TOKEN.GT ||
                            _last == PROG_TOKEN.LE || _last == PROG_TOKEN.GE ||
                            _last == PROG_TOKEN.QUESTION || _last == PROG_TOKEN.NULL_COALESCE)
                        {
                            _is_regex = true;
                        }
                    }
                    
                    if (match("=")) add_token(PROG_TOKEN.SLASH_ASSIGN);
                    else if (_is_regex) scan_regex();
                    else add_token(PROG_TOKEN.SLASH);
                }
                break;
            case "%": add_token(PROG_TOKEN.PERCENT); break;
            
            case "!": add_token(match("=") ? PROG_TOKEN.NE : PROG_TOKEN.NOT); break;
            case "=": 
                if (match("=")) add_token(PROG_TOKEN.EQ);
                else if (match(">")) add_token(PROG_TOKEN.ARROW);
                else add_token(PROG_TOKEN.ASSIGN);
                break; 
            case "<": 
                if (match("<")) add_token(match("=") ? PROG_TOKEN.LSHIFT_ASSIGN : PROG_TOKEN.LSHIFT);
                else add_token(match("=") ? PROG_TOKEN.LE : PROG_TOKEN.LT);
                break;
            case ">": 
                if (match(">")) add_token(match("=") ? PROG_TOKEN.RSHIFT_ASSIGN : PROG_TOKEN.RSHIFT);
                else add_token(match("=") ? PROG_TOKEN.GE : PROG_TOKEN.GT);
                break;
            
            case "&": add_token(match("&") ? PROG_TOKEN.AND : (match("=") ? PROG_TOKEN.AMP_ASSIGN : PROG_TOKEN.AMP)); break;
            case "|": add_token(match("|") ? PROG_TOKEN.OR : (match("=") ? PROG_TOKEN.PIPE_ASSIGN : PROG_TOKEN.PIPE)); break;
            case "^": add_token(match("=") ? PROG_TOKEN.CARET_ASSIGN : PROG_TOKEN.CARET); break;
            case "~": add_token(PROG_TOKEN.TILDE); break;
            case "?": add_token(match("?") ? PROG_TOKEN.NULL_COALESCE : PROG_TOKEN.QUESTION); break;
            
            case " ": case "\r": case "\t": break;
            case "\n": line++; break;
            case "\"": scan_string("\""); break;
            case "'": scan_string("'"); break; // Single quote support
            case "$": 
                if (match("\"")) { start_interpolation(); }
                else { had_error = true; error = $"Unexpected '$' at line {line}"; }
                break;
            
            default:
                if (is_digit(_c)) scan_number();
                else if (is_alpha(_c)) scan_identifier();
                else { had_error = true; error = $"Unexpected '{_c}' at line {line}"; }
                break;
        }
    }
    
    static scan_string = function(_quote = "\"")
    {
        while (peek() != _quote && !is_at_end())
        {
            if (peek() == "\n") line++;
            advance();
        }
        if (is_at_end()) { had_error = true; error = $"Unterminated string at line {line}"; return; }
        advance();
        add_token(PROG_TOKEN.STRING, string_copy(source, start + 1, current - start - 2));
    }
    
    static start_interpolation = function()
    {
        add_token(PROG_TOKEN.LPAREN);
        array_push(interp_stack, -1);
        start = current;
        scan_interpolation();
    }
    
    static scan_interpolation = function()
    {
        start = current;
        while (peek() != "\"" && peek() != "{" && !is_at_end())
        {
            if (peek() == "\n") line++;
            advance();
        }
        if (is_at_end()) { had_error = true; error = $"Unterminated interpolated string at line {line}"; return; }
        
        add_token(PROG_TOKEN.STRING, string_copy(source, start, current - start));
        
        var _char = peek();
        if (_char == "\"")
        {
            advance();
            add_token(PROG_TOKEN.RPAREN);
            array_pop(interp_stack);
        }
        else if (_char == "{")
        {
            advance();
            add_token(PROG_TOKEN.PLUS);
            array_push(tokens, { type: PROG_TOKEN.IDENTIFIER, lexeme: "string", literal: undefined, line: line });
            array_push(tokens, { type: PROG_TOKEN.LPAREN, lexeme: "(", literal: undefined, line: line });
            interp_stack[@ array_length(interp_stack) - 1] = 0;
        }
    }
    
    static scan_identifier = function()
    {
        while (is_alpha_numeric(peek())) advance();
        var _text = string_copy(source, start, current - start);
        add_token(struct_exists(keywords, _text) ? keywords[$ _text] : PROG_TOKEN.IDENTIFIER);
    }
    
    static scan_number = function()
    {
        // Support underscores in numbers (e.g., 10_000)
        while (is_digit(peek()) || peek() == "_") advance();
        if (peek() == "." && is_digit(peek_next()))
        {
            advance();
            while (is_digit(peek()) || peek() == "_") advance();
        }
        // Remove underscores before parsing
        var _num_str = string_copy(source, start, current - start);
        _num_str = string_replace_all(_num_str, "_", "");
        add_token(PROG_TOKEN.NUMBER, real(_num_str));
    }
    
    static scan_regex = function()
    {
        while (!is_at_end())
        {
            var _c = peek();
            if (_c == "\n")
            {
                 had_error = true; error = $"Unterminated regex at line {line}"; return;
            }
            if (_c == "/")
            {
                // Check if escaped?
                if (string_char_at(source, current - 1) == "\\")
                {
                    // It is escaped, continue
                }
                else
                {
                    // End of regex
                    advance(); // Consume /
                    break;
                }
            }
            advance();
        }
        
        var _pattern = string_copy(source, start + 1, current - start - 2);
        var _flags = "";
        
        // Scan flags
        while (is_alpha(peek()))
        {
            _flags += advance();
        }
        
        add_token(PROG_TOKEN.REGEX, { pattern: _pattern, flags: _flags });
    }

    static is_digit = function(_c) { return (_c >= "0" && _c <= "9"); }
    static is_alpha = function(_c) { return (_c >= "a" && _c <= "z") || (_c >= "A" && _c <= "Z") || _c == "_"; }
    static is_alpha_numeric = function(_c) { return is_alpha(_c) || is_digit(_c); }
}
