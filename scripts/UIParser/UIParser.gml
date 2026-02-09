/// @desc Parser for UI Language - produces AST from tokens
/// @param {Array} _tokens Array of tokens from UILexer
function UIParser(_tokens) constructor {
    tokens = _tokens;
    length = array_length(_tokens);
    current = 0;
    had_error = false;
    error = "";
    
    // Variable scope for local vars (var _padding = 10)
    variables = {};
    
    // =============================================================================
    // Helpers
    // =============================================================================
    
    static is_at_end = function() {
        return peek().type == UI_TOKEN.EOF;
    }
    
    static peek = function() {
        return tokens[current];
    }
    
    static previous = function() {
        return tokens[current - 1];
    }
    
    static advance = function() {
        if (!is_at_end()) current++;
        return previous();
    }
    
    static check = function(_type) {
        if (is_at_end()) return false;
        return peek().type == _type;
    }
    
    static match = function(_type) {
        if (check(_type)) {
            advance();
            return true;
        }
        return false;
    }
    
    static consume = function(_type, _message) {
        if (check(_type)) return advance();
        
        error_at_current(_message);
        return { type: UI_TOKEN.ERROR, lexeme: "", literal: undefined, line: peek().line };
    }
    
    static error_at_current = function(_message) {
        if (had_error) return;
        
        had_error = true;
        var _token = peek();
        error = $"[Line {_token.line}] Error at '{_token.lexeme}': {_message}";
    }
    
    // =============================================================================
    // Parser Entry Point
    // =============================================================================
    
    /// @desc Parse all tokens into a UI document
    /// @returns {Struct.UIASTDocument} Document AST node
    static parse = function() {
        var _definitions = [];
        
        while (!is_at_end()) {
            var _def = parse_definition();
            if (_def != undefined) {
                array_push(_definitions, _def);
            }
        }
        
        return new UIASTDocument(_definitions);
    }
    
    // =============================================================================
    // Definition Parsing
    // =============================================================================
    
    static parse_definition = function() {
        // Variable declaration: var _name = value
        if (match(UI_TOKEN.VAR)) {
            return parse_var_declaration();
        }
        
        // Element declaration: @type(name) { ... }
        if (match(UI_TOKEN.AT)) {
            return parse_element();
        }
        
        // Skip unknown tokens
        advance();
        return undefined;
    }
    
    static parse_var_declaration = function() {
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected variable name after 'var'.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        
        consume(UI_TOKEN.EQUALS, "Expected '=' after variable name.");
        
        var _value = parse_value();
        
        // Store in variable scope for later reference
        variables[$ _name] = _value;
        
        return new UIASTVarDecl(_name, _value);
    }
    
    static parse_element = function() {
        // Element type (text, button, window, etc.)
        var _type_token = consume(UI_TOKEN.IDENTIFIER, "Expected element type after '@'.");
        var _element_type = _type_token.literal ?? _type_token.lexeme;
        
        // Element name in parentheses
        consume(UI_TOKEN.LPAREN, "Expected '(' after element type.");
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected element name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        consume(UI_TOKEN.RPAREN, "Expected ')' after element name.");
        
        // Element body
        consume(UI_TOKEN.LBRACE, "Expected '{' before element body.");
        
        var _properties = [];
        var _children = [];
        
        while (!check(UI_TOKEN.RBRACE) && !is_at_end()) {
            // Check for nested element
            if (check(UI_TOKEN.AT)) {
                advance();
                var _child = parse_element();
                if (_child != undefined) {
                    array_push(_children, _child);
                }
            } else if (check(UI_TOKEN.IDENTIFIER)) {
                // Property assignment
                var _prop = parse_property();
                if (_prop != undefined) {
                    array_push(_properties, _prop);
                }
            } else {
                // Skip unknown
                advance();
            }
        }
        
        consume(UI_TOKEN.RBRACE, "Expected '}' after element body.");
        
        return new UIASTElement(_element_type, _name, _properties, _children);
    }
    
    static parse_property = function() {
        var _key_token = consume(UI_TOKEN.IDENTIFIER, "Expected property name.");
        var _key = _key_token.literal ?? _key_token.lexeme;
        
        consume(UI_TOKEN.EQUALS, "Expected '=' after property name.");
        
        var _value = parse_value();
        
        return new UIASTProperty(_key, _value);
    }
    
    // =============================================================================
    // Value Parsing
    // =============================================================================
    
    static parse_value = function() {
        // Binding: *variable
        if (match(UI_TOKEN.STAR)) {
            var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected variable name after '*'.");
            return new UIASTBinding(_name_token.literal ?? _name_token.lexeme);
        }
        
        // Localization key: $"key" or $sprite/$surface(...) { ... }
        if (match(UI_TOKEN.DOLLAR)) {
            // Check for $sprite(...) or $surface(...)
            if (check(UI_TOKEN.IDENTIFIER)) {
                var _id = peek().lexeme;
                if (_id == "sprite") {
                    advance();
                    return parse_sprite_def();
                } else if (_id == "surface") {
                    advance();
                    return parse_surface_def();
                }
            }
            // Localization key: $"string"
            if (check(UI_TOKEN.STRING)) {
                var _key_token = advance();
                return new UIASTLocaKey(_key_token.literal);
            }
            error_at_current("Expected 'sprite', 'surface', or string after '$'.");
            return new UIASTString("");
        }
        
        // Script reference: @"script_id"
        if (match(UI_TOKEN.AT)) {
            if (check(UI_TOKEN.STRING)) {
                var _script_token = advance();
                return new UIASTScriptRef(_script_token.literal);
            }
            error_at_current("Expected string after '@' for script reference.");
            return new UIASTString("");
        }
        
        // Tuple: (x, y, ...)
        if (match(UI_TOKEN.LPAREN)) {
            return parse_tuple();
        }
        
        // Number or Color
        if (match(UI_TOKEN.NUMBER)) {
            var _lit = previous().literal;
            
            // Check if it's a color struct
            if (is_struct(_lit) && (_lit[$ "is_color"] == true)) {
                return new UIASTColor(_lit.color, _lit.alpha);
            }
            
            return new UIASTNumber(_lit);
        }
        
        // String
        if (match(UI_TOKEN.STRING)) {
            return new UIASTString(previous().literal);
        }
        
        // Boolean
        if (match(UI_TOKEN.TRUE)) {
            return new UIASTBool(true);
        }
        if (match(UI_TOKEN.FALSE)) {
            return new UIASTBool(false);
        }
        
        // Layout enums
        if (match(UI_TOKEN.LAYOUT_VERTICAL)) {
            return new UIASTEnum("LAYOUT_VERTICAL");
        }
        if (match(UI_TOKEN.LAYOUT_HORIZONTAL)) {
            return new UIASTEnum("LAYOUT_HORIZONTAL");
        }
        if (match(UI_TOKEN.LAYOUT_GRID)) {
            return new UIASTEnum("LAYOUT_GRID");
        }
        if (match(UI_TOKEN.LAYOUT_NONE)) {
            return new UIASTEnum("LAYOUT_NONE");
        }
        
        // Identifier (variable reference)
        if (match(UI_TOKEN.IDENTIFIER)) {
            return new UIASTIdentifier(previous().literal ?? previous().lexeme);
        }
        
        error_at_current("Expected value.");
        return new UIASTString("");
    }
    
    static parse_tuple = function() {
        var _values = [];
        
        if (!check(UI_TOKEN.RPAREN)) {
            do {
                array_push(_values, parse_value());
            } until (!match(UI_TOKEN.COMMA));
        }
        
        consume(UI_TOKEN.RPAREN, "Expected ')' after tuple values.");
        
        return new UIASTTuple(_values);
    }
    
    /// @desc Parse $sprite(name) { properties }
    static parse_sprite_def = function() {
        consume(UI_TOKEN.LPAREN, "Expected '(' after '$sprite'.");
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected sprite name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        consume(UI_TOKEN.RPAREN, "Expected ')' after sprite name.");
        
        var _properties = [];
        
        // Optional property block { ... }
        if (match(UI_TOKEN.LBRACE)) {
            while (!check(UI_TOKEN.RBRACE) && !is_at_end()) {
                if (check(UI_TOKEN.IDENTIFIER)) {
                    var _prop = parse_property();
                    if (_prop != undefined) {
                        array_push(_properties, _prop);
                    }
                } else {
                    advance(); // Skip unknown tokens
                }
            }
            consume(UI_TOKEN.RBRACE, "Expected '}' after sprite properties.");
        }
        
        return new UIASTSpriteDef(_name, _properties);
    }
    
    /// @desc Parse $surface(name) { properties }
    static parse_surface_def = function() {
        consume(UI_TOKEN.LPAREN, "Expected '(' after '$surface'.");
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected surface name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        consume(UI_TOKEN.RPAREN, "Expected ')' after surface name.");
        
        var _properties = [];
        
        if (match(UI_TOKEN.LBRACE)) {
            while (!check(UI_TOKEN.RBRACE) && !is_at_end()) {
                if (check(UI_TOKEN.IDENTIFIER)) {
                    var _prop = parse_property();
                    if (_prop != undefined) {
                        array_push(_properties, _prop);
                    }
                } else {
                    advance();
                }
            }
            consume(UI_TOKEN.RBRACE, "Expected '}' after surface properties.");
        }
        
        return new UIASTSurfaceDef(_name, _properties);
    }
}
