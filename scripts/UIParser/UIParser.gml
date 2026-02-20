/* parser for ui language - produces ast from tokens */
/* @param {array} _tokens array of tokens from UILexer */
function UIParser(_tokens) constructor 
{
    tokens = _tokens;
    
    length = array_length(_tokens);
    
    current = 0;
    
    had_error = false;
    
    error = "";
    
    
    /* variable scope for local vars (var _padding = 10) */
    variables = {};
    
    
    /* =============================================================================
       helpers
       ============================================================================= */
    
    static is_at_end = function() 
    {
        return (peek().type == UI_TOKEN.EOF);
    }
    
    
    static peek = function() 
    {
        return tokens[current];
    }
    
    
    static previous = function() 
    {
        return tokens[current - 1];
    }
    
    
    static advance = function() 
    {
        if !(is_at_end())
        {
            ++current;
        }
        
        return previous();
    }
    
    
    static check = function(_type) 
    {
        if (is_at_end()) return false;
        
        return (peek().type == _type);
    }
    
    
    static match = function(_type) 
    {
        if (check(_type)) 
        {
            advance();
            
            return true;
        }
        
        return false;
    }
    
    
    static consume = function(_type, _message) 
    {
        if (check(_type)) return advance();
        
        
        error_at_current(_message);
        
        return { type: UI_TOKEN.ERROR, lexeme: "", literal: undefined, line: peek().line };
    }
    
    
    static error_at_current = function(_message) 
    {
        if (had_error) exit;
        
        
        had_error = true;
        
        var _token = peek();
        
        error = $"[Line {_token.line}] error at '{_token.lexeme}': {_message}";
    }
    
    
    /* =============================================================================
       parser entry point
       ============================================================================= */
    
    /* parse all tokens into a ui document */
    /* @returns {struct.UIASTDocument} document ast node */
    static parse = function() 
    {
        var _definitions = [];
        
        
        while !(is_at_end()) 
        {
            var _def = parse_definition();
            
            
            if (_def != undefined) 
            {
                array_push(_definitions, _def);
            }
        }
        
        
        return new UIASTDocument(_definitions);
    }
    
    
    /* =============================================================================
       definition parsing
       ============================================================================= */
    
    static parse_definition = function() 
    {
        /* export declaration: export var ... or export @element ... */
        if (match(UI_TOKEN.EXPORT)) 
        {
            if (match(UI_TOKEN.VAR)) 
            {
                var _decl = parse_var_declaration();
                
                return new UIASTExportVar(_decl.name, _decl.value);
            }
            
            
            if (match(UI_TOKEN.AT)) 
            {
                var _element = parse_element();
                
                return new UIASTExportElement(_element);
            }
            
            
            error_at_current("expected 'var' or '@' after 'export'.");
            
            return undefined;
        }
        
        
        /* variable declaration: var _name = value */
        if (match(UI_TOKEN.VAR)) 
        {
            return parse_var_declaration();
        }
        
        
        /* element declaration: @type(name) { ... } */
        if (match(UI_TOKEN.AT)) 
        {
            return parse_element();
        }
        
        
        /* skip unknown tokens */
        advance();
        
        return undefined;
    }
    
    
    static parse_var_declaration = function() 
    {
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "expected variable name after 'var'.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        
        
        consume(UI_TOKEN.EQUALS, "expected '=' after variable name.");
        
        
        var _value = parse_value();
        
        
        /* store in variable scope for later reference */
        variables[$ _name] = _value;
        
        
        return new UIASTVarDecl(_name, _value);
    }
    
    
    static parse_element = function() 
    {
        /* element type (text, button, window, etc.) */
        var _type_token = consume(UI_TOKEN.IDENTIFIER, "expected element type after '@'.");
        var _element_type = _type_token.literal ?? _type_token.lexeme;
        
        
        show_debug_message($"[UI Parser] parsing element: @{_element_type}...");
        
        
        /* element name in parentheses */
        consume(UI_TOKEN.LPAREN, "expected '(' after element type.");
        
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "expected element name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        
        consume(UI_TOKEN.RPAREN, "expected ')' after element name.");
        
        
        /* optional repeat(count, var) modifier */
        var _repeat_count = undefined;
        var _repeat_var = undefined;
        
        
        if (match(UI_TOKEN.REPEAT)) 
        {
            consume(UI_TOKEN.LPAREN, "expected '(' after 'repeat'.");
            
            var _count_token = consume(UI_TOKEN.NUMBER, "expected count in repeat().");
            _repeat_count = _count_token.literal;
            
            consume(UI_TOKEN.COMMA, "expected ',' after count in repeat().");
            
            var _var_token = consume(UI_TOKEN.IDENTIFIER, "expected variable name in repeat().");
            _repeat_var = _var_token.literal ?? _var_token.lexeme;
            
            consume(UI_TOKEN.RPAREN, "expected ')' after repeat arguments.");
        }
        
        
        /* element body */
        consume(UI_TOKEN.LBRACE, "expected '{' before element body.");
        
        
        var _properties = [];
        var _children = [];
        
        
        while !(check(UI_TOKEN.RBRACE)) && !(is_at_end()) 
        {
            /* check for nested element */
            if (check(UI_TOKEN.AT)) 
            {
                advance();
                
                var _child = parse_element();
                
                
                if (_child != undefined) 
                {
                    array_push(_children, _child);
                }
            } 
            else if (check(UI_TOKEN.IDENTIFIER)) 
            {
                /* property assignment */
                var _prop = parse_property();
                
                
                if (_prop != undefined) 
                {
                    array_push(_properties, _prop);
                }
            } 
            else 
            {
                /* skip unknown */
                advance();
            }
        }
        
        
        consume(UI_TOKEN.RBRACE, "expected '}' after element body.");
        
        
        var _element = new UIASTElement(_element_type, _name, _properties, _children);
        
        _element.repeat_count = _repeat_count;
        _element.repeat_var = _repeat_var;
        
        return _element;
    }
    
    
    static parse_property = function() 
    {
        var _key_token = consume(UI_TOKEN.IDENTIFIER, "expected property name.");
        var _key = _key_token.literal ?? _key_token.lexeme;
        
        
        show_debug_message($"[UI Parser]   property: {_key}...");
        
        
        consume(UI_TOKEN.EQUALS, "expected '=' after property name.");
        
        
        var _value = parse_value();
        
        
        return new UIASTProperty(_key, _value);
    }
    
    
    /* =============================================================================
       expression parsing (PEMDAS precedence)
       ============================================================================= */
    /* 
       precedence chain (lowest to highest):
         parse_value -> parse_addition -> parse_multiplication -> parse_unary -> parse_power -> parse_primary
      
       this allows expressions like:
         ORIGIN_BOTTOM_CENTER + (0, -10)
         (100 * 2, 50%)
         ORIGIN_CENTER + (-25%, 0)
    */
    
    static parse_value = function() 
    {
        return parse_addition();
    }
    
    
    /* parse addition/subtraction level: + - */
    static parse_addition = function() 
    {
        var _left = parse_multiplication();
        
        
        while (check(UI_TOKEN.PLUS) || check(UI_TOKEN.MINUS)) 
        {
            var _op_token = advance();
            var _op = (_op_token.type == UI_TOKEN.PLUS) ? "+" : "-";
            
            var _right = parse_multiplication();
            
            _left = new UIASTBinaryOp(_op, _left, _right);
        }
        
        return _left;
    }
    
    
    /* parse multiplication/division/modulo level: * / % */
    static parse_multiplication = function() 
    {
        var _left = parse_unary();
        
        
        while (check(UI_TOKEN.STAR) || check(UI_TOKEN.SLASH) || check(UI_TOKEN.PERCENT)) 
        {
            var _op_token = advance();
            
            show_debug_message($"[UI Parser]       binary op: {_op_token.lexeme}");
            
            var _op;
            
            
            switch (_op_token.type) 
            {
                case UI_TOKEN.STAR:    _op = "*"; break;
                case UI_TOKEN.SLASH:   _op = "/"; break;
                case UI_TOKEN.PERCENT: _op = "%"; break;
            }
            
            
            var _right = parse_unary();
            
            _left = new UIASTBinaryOp(_op, _left, _right);
        }
        
        return _left;
    }
    
    
    /* parse unary prefix: - (negation) */
    static parse_unary = function() 
    {
        if (match(UI_TOKEN.MINUS)) 
        {
            var _right = parse_unary();
            
            return new UIASTUnaryOp("-", _right);
        }
        
        return parse_power();
    }
    
    
    /* parse exponentiation: ** (right-associative) */
    static parse_power = function() 
    {
        var _left = parse_primary();
        
        
        if (match(UI_TOKEN.POWER)) 
        {
            var _right = parse_unary(); /* right-associative: recurse through unary */
            
            _left = new UIASTBinaryOp("**", _left, _right);
        }
        
        return _left;
    }
    
    
    /* =============================================================================
       primary value parsing
       ============================================================================= */
    
    static parse_primary = function() 
    {
        /* binding: *variable or *variable[index] */
        if (match(UI_TOKEN.STAR)) 
        {
            var _name_token = consume(UI_TOKEN.IDENTIFIER, "expected variable name after '*'.");
            var _name = _name_token.literal ?? _name_token.lexeme;
            
            
            if (match(UI_TOKEN.LBRACKET)) 
            {
                var _index = parse_value();
                
                consume(UI_TOKEN.RBRACKET, "expected ']' after array index.");
                
                return new UIASTArrayIndex(_name, _index);
            }
            
            return new UIASTBinding(_name);
        }
        
        
        /* localization key: $"key" or $sprite/$surface(...) { ... } */
        if (match(UI_TOKEN.DOLLAR)) 
        {
            /* check for $sprite(...) or $surface(...) */
            if (check(UI_TOKEN.IDENTIFIER)) 
            {
                var _id = peek().lexeme;
                
                
                if (_id == "sprite") 
                {
                    advance();
                    
                    return parse_sprite_def();
                } 
                else if (_id == "surface") 
                {
                    advance();
                    
                    return parse_surface_def();
                }
            }
            
            
            /* localization key: $"string" */
            if (check(UI_TOKEN.STRING)) 
            {
                var _key_token = advance();
                
                return new UIASTLocaKey(_key_token.literal);
            }
            
            
            error_at_current("expected 'sprite', 'surface', or string after '$'.");
            
            return new UIASTString("");
        }
        
        
        /* script reference: @"script_id" */
        if (match(UI_TOKEN.AT)) 
        {
            if (check(UI_TOKEN.STRING)) 
            {
                var _script_token = advance();
                
                return new UIASTScriptRef(_script_token.literal);
            }
            
            
            error_at_current("expected string after '@' for script reference.");
            
            return new UIASTString("");
        }
        
        
        /* tuple: (x, y, ...) */
        if (match(UI_TOKEN.LPAREN)) 
        {
            return parse_tuple();
        }
        
        
        /* number or color or percentage */
        if (match(UI_TOKEN.NUMBER)) 
        {
            var _lit = previous().literal;
            
            
            /* check if it's a percentage struct { value, is_percent: true } */
            if (is_struct(_lit) && (_lit[$ "is_percent"] == true)) 
            {
                return new UIASTPercentage(_lit.value);
            }
            
            
            /* check if it's a color struct */
            if (is_struct(_lit) && (_lit[$ "is_color"] == true)) 
            {
                return new UIASTColor(_lit.color, _lit.alpha);
            }
            
            return new UIASTNumber(_lit);
        }
        
        
        /* string */
        if (match(UI_TOKEN.STRING)) 
        {
            return new UIASTString(previous().literal);
        }
        
        
        /* boolean */
        if (match(UI_TOKEN.TRUE)) 
        {
            return new UIASTBool(true);
        }
        
        
        if (match(UI_TOKEN.FALSE)) 
        {
            return new UIASTBool(false);
        }
        
        
        /* layout enums */
        if (match(UI_TOKEN.LAYOUT_VERTICAL)) 
        {
            return new UIASTEnum("LAYOUT_VERTICAL");
        }
        
        
        if (match(UI_TOKEN.LAYOUT_HORIZONTAL)) 
        {
            return new UIASTEnum("LAYOUT_HORIZONTAL");
        }
        
        
        if (match(UI_TOKEN.LAYOUT_GRID)) 
        {
            return new UIASTEnum("LAYOUT_GRID");
        }
        
        
        if (match(UI_TOKEN.LAYOUT_NONE)) 
        {
            return new UIASTEnum("LAYOUT_NONE");
        }
        
        
        /* identifier (variable reference, including ORIGIN_* macros) */
        if (match(UI_TOKEN.IDENTIFIER)) 
        {
            return new UIASTIdentifier(previous().literal ?? previous().lexeme);
        }
        
        
        /* built-in functions: floor(expr) */
        if (match(UI_TOKEN.FLOOR)) 
        {
            consume(UI_TOKEN.LPAREN, "expected '(' after 'floor'.");
            
            var _func_arg = parse_value();
            
            consume(UI_TOKEN.RPAREN, "expected ')' after floor argument.");
            
            return new UIASTFuncCall("floor", _func_arg);
        }
        
        
        error_at_current("expected value.");
        
        return new UIASTString("");
    }
    
    
    static parse_tuple = function() 
    {
        var _values = [];
        
        
        if !(check(UI_TOKEN.RPAREN)) 
        {
            do 
            {
                array_push(_values, parse_value());
            } 
            until !(match(UI_TOKEN.COMMA));
        }
        
        
        consume(UI_TOKEN.RPAREN, "expected ')' after tuple values.");
        
        return new UIASTTuple(_values);
    }
    
    
    /* parse $sprite(name) { properties } */
    static parse_sprite_def = function() 
    {
        consume(UI_TOKEN.LPAREN, "expected '(' after '$sprite'.");
        
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "expected sprite name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        
        consume(UI_TOKEN.RPAREN, "expected ')' after sprite name.");
        
        
        var _properties = [];
        
        
        /* optional property block { ... } */
        if (match(UI_TOKEN.LBRACE)) 
        {
            while !(check(UI_TOKEN.RBRACE)) && !(is_at_end()) 
            {
                if (check(UI_TOKEN.IDENTIFIER)) 
                {
                    var _prop = parse_property();
                    
                    
                    if (_prop != undefined) 
                    {
                        array_push(_properties, _prop);
                    }
                } 
                else 
                {
                    advance(); /* skip unknown tokens */
                }
            }
            
            consume(UI_TOKEN.RBRACE, "expected '}' after sprite properties.");
        }
        
        return new UIASTSpriteDef(_name, _properties);
    }
    
    
    /* parse $surface(name) { properties } */
    static parse_surface_def = function() 
    {
        consume(UI_TOKEN.LPAREN, "expected '(' after '$surface'.");
        
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "expected surface name.");
        var _name = _name_token.literal ?? _name_token.lexeme;
        
        consume(UI_TOKEN.RPAREN, "expected ')' after surface name.");
        
        
        var _properties = [];
        
        
        if (match(UI_TOKEN.LBRACE)) 
        {
            while !(check(UI_TOKEN.RBRACE)) && !(is_at_end()) 
            {
                if (check(UI_TOKEN.IDENTIFIER)) 
                {
                    var _prop = parse_property();
                    
                    
                    if (_prop != undefined) 
                    {
                        array_push(_properties, _prop);
                    }
                } 
                else 
                {
                    advance();
                }
            }
            
            consume(UI_TOKEN.RBRACE, "expected '}' after surface properties.");
        }
        
        return new UIASTSurfaceDef(_name, _properties);
    }
}
