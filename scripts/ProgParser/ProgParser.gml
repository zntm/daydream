/* Parser for Proglang */
function ProgParser(_tokens) constructor
{
    tokens = _tokens;
    length = array_length(_tokens);
    current = 0;
    had_error = false;
    error = "";
    
    static is_at_end = function()
    {
        return (peek().type == PROG_TOKEN.EOF);
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
        if (!is_at_end())
        {
            ++current;
        }
        
        return previous();
    }
    
    static check = function(_type)
    {
        if (is_at_end())
        {
            return false;
        }
        
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
        if (check(_type))
        {
            return advance();
        }
        
        error_at_current(_message);
        
        return { type: PROG_TOKEN.EOF, lexeme: "", literal: undefined, line: peek().line } // Return dummy token
    }
    
    static error_at_current = function(_message)
    {
        if (had_error)
        {
             return; /* Suppress cascade */
        }
        
        had_error = true;
        
        var _token = peek();
        
        error = $"[Line {_token.line}] Error at '{_token.lexeme}': {_message}";
    }
    
    /* ----------------------------------------------------------------------------
       Entry Point
       ---------------------------------------------------------------------------- */
    
    static parse = function()
    {
        var _statements = [];
        had_error = false;
        error = "";
        current = 0;
        
        while (!is_at_end())
        {
            var _start = current;
            array_push(_statements, parse_statement());
            if (current == _start && !is_at_end())
            {
                 error_at_current("Parser stuck: Infinite loop detected. Forcing advance.");
                 advance();
            }
        }
        
        return new ProgASTBlock(_statements);
    }
    
    /* ----------------------------------------------------------------------------
       Statements
       ---------------------------------------------------------------------------- */
    
    static parse_statement = function()
    {
        /* Check for annotations */
        var _annotations = 
        {
            is_inline: false,
            is_memoize: false
        }
        
        while (check(PROG_TOKEN.AT_INLINE) || check(PROG_TOKEN.AT_MEMOIZE))
        {
            if (match(PROG_TOKEN.AT_INLINE))
            {
                _annotations.is_inline = true;
            }
            else if (match(PROG_TOKEN.AT_MEMOIZE))
            {
                _annotations.is_memoize = true;
            }
            
            /* STRICT CHECK: No braces allowed */
            if (check(PROG_TOKEN.LBRACE))
            {
                error_at_current("Annotations must not be followed by braces ('{'). Use '@annotation declaration'.");
            }
        }
        
        /* Check for global prefix */
        var _is_global = false;
        
        if (match(PROG_TOKEN.GLOBAL))
        {
            /* Could be: global fn, global function, global var, or global.x */
            if (check(PROG_TOKEN.FN))
            {
                _is_global = true;
                /* Fall through to fn/function handling below */
            }
            else if (check(PROG_TOKEN.VAR))
            {
                /* global var x */
                if (_annotations.is_inline || _annotations.is_memoize)
                {
                    error_at_current("Annotation can only be applied to functions.");
                }
                
                advance(); /* consume VAR */
                
                return parse_var_decl(true); /* is_global = true */
            }
            /* Backtrack to let parse_expression_statement handle 'global.x' */
            else if (check(PROG_TOKEN.DOT))
            {
                if (_annotations.is_inline || _annotations.is_memoize)
                {
                    error_at_current("Annotation can only be applied to functions.");
                }
                
                --current;
                
                return parse_expression_statement();
            }
            else
            {
                error_at_current("Expected 'var', 'fn', or '.' after 'global'.");
                
                return new ProgASTStatement();
            }
        }
        
        // Function declaration
        if (match(PROG_TOKEN.FN))
        {
            
            var _decl = parse_function_decl(_is_global, _annotations);
            return _decl;
        }
        
        /* Class Declaration */
        if (match(PROG_TOKEN.CLASS))
        {
            if (_annotations.is_inline || _annotations.is_memoize)
            {
                error_at_current("@inline/@memoize cannot be applied to classes.");
            }
            
            if (_is_global)
            {
                error_at_current("Global classes not supported.");
            }
            
            return parse_class_decl(_annotations);
        }
        
        /* Error if annotation was used without correct target */
        if (_annotations.is_inline || _annotations.is_memoize)
        {
            error_at_current("Annotations must be followed by a function declaration (fn).");
        }
        
        if (match(PROG_TOKEN.VAR))
        {
            return parse_var_decl(false);
        }
        
        if (match(PROG_TOKEN.IF))
        {
            return parse_if_stmt();
        }
        
        if (match(PROG_TOKEN.WHILE))
        {
            return parse_while_stmt();
        }
        
        if (match(PROG_TOKEN.FOR))
        {
            return parse_for_stmt();
        }
        
        if (match(PROG_TOKEN.REPEAT))
        {
            return parse_repeat_stmt();
        }
        
        if (match(PROG_TOKEN.TRY))
        {
            return parse_try_stmt();
        }
        
        if (match(PROG_TOKEN.BREAK))
        {
            var _brk_token = previous();
            
            /* Parse optional amount expression (for break 2, break n, etc.) */
            var _amount = undefined;
            
            if (!check(PROG_TOKEN.SEMICOLON) && !check(PROG_TOKEN.RBRACE) && (!is_at_end() && peek().line == _brk_token.line))
            {
                if (check(PROG_TOKEN.NUMBER))
                {
                    _amount = parse_expression();
                }
            }
            
            match(PROG_TOKEN.SEMICOLON); /* Optional */
            
            return new ProgASTBreakStmt(_amount);
        }
        
        if (match(PROG_TOKEN.CONTINUE))
        {
             var _con_token = previous();
             
             match(PROG_TOKEN.SEMICOLON);
             
             return new ProgASTContinueStmt();
        }
        
        if (match(PROG_TOKEN.RETURN))
        {
            var _value = undefined;
            var _ret_token = previous();
            
            if (!check(PROG_TOKEN.SEMICOLON) && !check(PROG_TOKEN.RBRACE) && (!is_at_end() && peek().line == _ret_token.line))
            {
                _value = parse_expression();
            }
            
            match(PROG_TOKEN.SEMICOLON); /* Optional */
            
            return new ProgASTReturnStmt(_value);
        }
        
        if (match(PROG_TOKEN.LBRACE))
        {
            return new ProgASTBlock(parse_block());
        }
        
        if (match(PROG_TOKEN.SWITCH)) return parse_switch_stmt();
        
        if (match(PROG_TOKEN.IMPORT)) return parse_import_stmt();
        if (match(PROG_TOKEN.EXPORT)) return parse_export_stmt();
        
        if (match(PROG_TOKEN.ABSTRACT))
        {
            if (match(PROG_TOKEN.CLASS))
            {
                var _decl = parse_class_decl();
                _decl.is_abstract = true;
                return _decl;
            }
            error_at_current("Expected 'class' after 'abstract'.");
            return new ProgASTLiteral(PROG_AST.UNDEFINED_LITERAL, undefined);
        }
        
        if (match(PROG_TOKEN.CLASS))
        {
            return parse_class_decl();
        }
        
        if (match(PROG_TOKEN.THROW))
        {
            var _expression = parse_expression();
            
            match(PROG_TOKEN.SEMICOLON);
            
            return new ProgASTThrowStmt(_expression);
        }
        
        return parse_expression_statement();
    }
    
    static parse_import_stmt = function()
    {
        var _imports = [];
        
        /* Simplified imports: import a, b from "path" */
        do
        {
            var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected imported name.").lexeme;
            var _alias = _name;
            
            if (match(PROG_TOKEN.AS))
            {
                _alias = consume(PROG_TOKEN.IDENTIFIER, "Expected alias name.").lexeme;
            }
            
            array_push(_imports, { name: _name, alias: _alias });
        }
        until (!match(PROG_TOKEN.COMMA));
        
        consume(PROG_TOKEN.FROM, "Expected 'from' after imports.");
        
        var _path = consume(PROG_TOKEN.STRING, "Expected module path.").literal;
        
        match(PROG_TOKEN.SEMICOLON); /* Optional semicolon */
        
        return new ProgASTImportStmt(_imports, _path);
    }
    
    static parse_export_stmt = function()
    {
        var _decl = undefined;
        var _is_default = false;
        
        if (match(PROG_TOKEN.DEFAULT))
        {
            _is_default = true;
            _decl = parse_expression();
            
            match(PROG_TOKEN.SEMICOLON); /* Optional */
        }
        else
        {
            var _is_global = match(PROG_TOKEN.GLOBAL);
            
            if (match(PROG_TOKEN.VAR))
            {
                _decl = parse_var_decl(_is_global);
            }
            else if (match(PROG_TOKEN.FN))
            {
                _decl = parse_function_decl(_is_global);
            }
            else if (match(PROG_TOKEN.CLASS))
            {
                if (_is_global) error_at_current("Global classes not supported (all classes are effectively global or module-scoped).");
                _decl = parse_class_decl();
            }
            else
            {
                error_at_current("Expected declaration after export.");
                
                return new ProgASTStatement();
            }
        }
        
        return new ProgASTExportStmt(_decl, _is_default);
    }
    
    static parse_class_decl = function(_annotations = {})
    {
        var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected class name.").lexeme;
        var _super = undefined;
        
        if (match(PROG_TOKEN.EXTENDS))
        {
            _super = consume(PROG_TOKEN.IDENTIFIER, "Expected superclass name.").lexeme;
        }
        
        consume(PROG_TOKEN.LBRACE, "Expected '{' before class body.");
        
        var _members = [];
        var _constructor = undefined;
        
        while (!check(PROG_TOKEN.RBRACE) && !is_at_end())
        {
            var _access = "public";
            
            if (match(PROG_TOKEN.PUBLIC))
            {
                _access = "public";
            }
            else if (match(PROG_TOKEN.PRIVATE))
            {
                _access = "private";
            }
            else if (match(PROG_TOKEN.PROTECTED))
            {
                _access = "protected";
            }
            
            var _is_static = match(PROG_TOKEN.STATIC);
            var _is_abstract_method = match(PROG_TOKEN.ABSTRACT);

            if (match(PROG_TOKEN.FN) || check(PROG_TOKEN.VAR) || check(PROG_TOKEN.IDENTIFIER))
            {
                
                var _is_method = false;
                var _decl = undefined;
                
                if (match(PROG_TOKEN.FN))
                {
                    if (_is_abstract_method)
                    {
                        _name = consume(PROG_TOKEN.IDENTIFIER, "Expected function name.").lexeme;
                        consume(PROG_TOKEN.LPAREN, "Expected '(' after function name.");
                        var _params = [];
                        if (!check(PROG_TOKEN.RPAREN))
                        {
                            do
                            {
                                var _p_name = consume(PROG_TOKEN.IDENTIFIER, "Expected parameter name.").lexeme;
                                
                                array_push(_params, { name: _p_name, default_value: undefined });
                            }
                            until (!match(PROG_TOKEN.COMMA));
                        }
                        
                        consume(PROG_TOKEN.RPAREN, "Expected ')' after parameters.");
                        
                        var _body = undefined;
                        
                        if (check(PROG_TOKEN.LBRACE))
                        {
                            consume(PROG_TOKEN.LBRACE, "Expected '{' before function body.");
                            
                            _body = new ProgASTBlock(parse_block());
                        }
                        
                        _decl = new ProgASTFuncDecl(_name, _params, _body, false);
                        _is_method = true;
                    }
                    else
                    {
                        _decl = parse_function_decl(false);
                        _is_method = true;
                    }
                }
                else if (match(PROG_TOKEN.VAR))
                {
                    _decl = parse_var_decl(false); // expects semicolon
                    _is_method = false;
                }
                else
                {
                    /* Maybe constructor or method without 'fn'? */
                    var _name_token = peek();
                    
                    if (_name_token.type == PROG_TOKEN.IDENTIFIER)
                    {
                        /* Check if next is LPAREN -> Method */
                        if (tokens[current + 1].type == PROG_TOKEN.LPAREN)
                        {
                            var _m_name = advance().lexeme;
                            var _data = parse_function_body();
                            
                            _decl = new ProgASTFuncDecl(_m_name, _data.params, _data.body, false);
                            _is_method = true;
                        }
                        else
                        {
                            /* Property without 'var'? "x = 10;" */
                            /* Let's enforce 'var' for properties for now to be safe or support it. */
                            /* Error for now. */
                            error_at_current("Expected 'fn' or 'var' in class body.");
                            
                            advance();
                            
                            continue;
                        }
                    }
                    else
                    {
                        advance(); // skip bad token
                        continue;
                    }
                }
                
                if (_decl != undefined)
                {
                    /* Attach metadata */
                    /* Since _decl is AST node, we wrap or modify it? */
                    /* Better to wrap in member struct */
                    if (_is_method && _decl.name == "constructor")
                    {
                        _constructor = _decl;
                    }
                    else
                    {
                        /* Store as plain struct or new AST? */
                        /* The VM will iterate this list. */
                        array_push(_members, { 
                            type: _is_method ? "method" : "field",
                            node: _decl, 
                            access: _access, 
                            is_static: _is_static 
                        });
                    }
                }
            }
            else
            {
                advance();
            }
        }
        
        consume(PROG_TOKEN.RBRACE, "Expected '}' after class body.");
        
        var _node = new ProgASTClassDecl(_name, _super, _members, _constructor);
        if (struct_exists(_annotations, "is_recyclable")) _node.is_recyclable = _annotations.is_recyclable;
        return _node;
    }
    
    static parse_new_expr = function()
    {
        var _class_name = consume(PROG_TOKEN.IDENTIFIER, "Expected class name.").lexeme;
        
        consume(PROG_TOKEN.LPAREN, "Expected '(' after class name.");
        
        var _args = [];
        
        if (!check(PROG_TOKEN.RPAREN))
        {
            do
            {
                array_push(_args, parse_assignment());
            } 
            until (!match(PROG_TOKEN.COMMA));
        }
        
        consume(PROG_TOKEN.RPAREN, "Expected ')' after arguments.");
        
        return new ProgASTNewExpr(_class_name, _args);
    }
    
    static parse_block = function()
    {
        var _statements = [];
        
        while (!check(PROG_TOKEN.RBRACE) && !is_at_end())
        {
            var _start = current;
            
            array_push(_statements, parse_statement());
            
            if (current == _start && !check(PROG_TOKEN.RBRACE) && !is_at_end())
            {
                error_at_current("Parser block stuck: Infinite loop detected. Forcing advance.");
                
                advance();
            }
        }
        
        consume(PROG_TOKEN.RBRACE, "Expected '}' after block.");
        
        return _statements;
    }
    
    static parse_var_decl = function(_is_global = false, _require_semi = true)
    {
        /* Destructuring: var {a, b} = ... OR var [a, b] = ... */
        if (check(PROG_TOKEN.LBRACE) || check(PROG_TOKEN.LBRACKET))
        {
            var _pattern = parse_destructuring_pattern();
            
            consume(PROG_TOKEN.ASSIGN, "Expected '=' in destructuring declaration.");
            
            var _initializer = parse_expression();
            
            if (_require_semi)
            {
                match(PROG_TOKEN.SEMICOLON);
            }
            
            /* Reuse existing AST Node but structurally richer */
            return new ProgASTDestructuringDecl(_pattern.type, _pattern.elements, _initializer);
        }
        
        /* Normal Declaration */
        var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected variable name.").lexeme;
        var _initializer = undefined;
        
        if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.EQ))
        {
            _initializer = parse_expression();
        }
        
        if (_require_semi)
        {
            match(PROG_TOKEN.SEMICOLON);
        }
        
        var _node = new ProgASTVarDecl(_name, _initializer);
        
        _node.is_global = _is_global;
        
        return _node;
    }
    
    static parse_destructuring_pattern = function()
    {
        if (match(PROG_TOKEN.LBRACE))
        {
            /* Object Pattern */
            var _elements = [];
            
            do
            {
                var _key = consume(PROG_TOKEN.IDENTIFIER, "Expected key in destructuring.").lexeme;
                var _target = _key; /* Default to var name same as key */
                
                if (match(PROG_TOKEN.COLON))
                {
                    if (check(PROG_TOKEN.LBRACE) || check(PROG_TOKEN.LBRACKET))
                    {
                        /* Nested pattern */
                        _target = parse_destructuring_pattern();
                    }
                    else
                    {
                        /* Alias variable */
                        _target = consume(PROG_TOKEN.IDENTIFIER, "Expected variable name.").lexeme;
                    }
                }
                
                array_push(_elements, { key: _key, target: _target });
            } 
            until (!match(PROG_TOKEN.COMMA));
            
            consume(PROG_TOKEN.RBRACE, "Expected '}' after object pattern.");
            
            return { type: "object", elements: _elements }
        } 
        else if (match(PROG_TOKEN.LBRACKET))
        {
            /* Array Pattern */
            var _elements = [];
            
            do
            {
                if (check(PROG_TOKEN.LBRACE) || check(PROG_TOKEN.LBRACKET))
                {
                    /* Nested pattern */
                    array_push(_elements, parse_destructuring_pattern());
                }
                else
                {
                    var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected variable name.").lexeme;
                    
                    array_push(_elements, _name);
                }
            } 
            until (!match(PROG_TOKEN.COMMA));
            
            consume(PROG_TOKEN.RBRACKET, "Expected ']' after array pattern.");
            
            return { type: "array", elements: _elements } 
        }
        
        error_at_current("Invalid destructuring pattern start.");
        return { type: "error", elements: [] }
    }
    
    static parse_function_decl = function(_is_global = false, _annotations = {})
    {
        var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected function name.").lexeme;
        var _data = parse_function_body();
        var _node = new ProgASTFuncDecl(_name, _data.params, _data.body, _is_global);
        
        if (struct_exists(_annotations, "is_inline")) _node.is_inline = _annotations.is_inline;
        if (struct_exists(_annotations, "is_memoize")) _node.is_memoize = _annotations.is_memoize;
        
        return _node;
    }

    static parse_function_expr = function()
    {
        var _name = undefined;
        
        if (check(PROG_TOKEN.IDENTIFIER))
        { 
            /* Optional name for recursion */
             _name = advance().lexeme;
        }
        
        var _data = parse_function_body();
        
        return new ProgASTFuncExpr(_name, _data.params, _data.body);
    }

    static parse_function_body = function()
    {
        consume(PROG_TOKEN.LPAREN, "Expected '(' after function name.");
        
        var _params = [];
        
        if (!check(PROG_TOKEN.RPAREN))
        {
            do
            {
                var _param_name = consume(PROG_TOKEN.IDENTIFIER, "Expected parameter name.").lexeme;
                var _default = undefined;
                
                if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.EQ))
                {
                    _default = parse_assignment();
                }
                
                array_push(_params, { name: _param_name, default_value: _default });
            } 
            until (!match(PROG_TOKEN.COMMA));
        }
        
        consume(PROG_TOKEN.RPAREN, "Expected ')' after parameters.");
        
        consume(PROG_TOKEN.LBRACE, "Expected '{' before function body.");
        
        var _body = new ProgASTBlock(parse_block());
        
        return { params: _params, body: _body }
    }
    
    static parse_if_stmt = function()
    {
        var _paren = match(PROG_TOKEN.LPAREN);
        
        var _condition = parse_expression();
        
        if (_paren) consume(PROG_TOKEN.RPAREN, "Expected ')' after if condition.");
        
        var _then = parse_statement();
        var _else = undefined;
        
        if (match(PROG_TOKEN.ELSE))
        {
            _else = parse_statement();
        }
        
        return new ProgASTIfStmt(_condition, _then, _else);
    }
    
    static parse_while_stmt = function()
    {
        var _condition = parse_expression();
        var _body = parse_statement();
        return new ProgASTWhileStmt(_condition, _body);
    }
    
    static parse_repeat_stmt = function()
    {
        var _count = parse_expression();
        var _body = parse_statement();
        return new ProgASTRepeatStmt(_count, _body);
    }
    
    static parse_for_stmt = function()
    {
        var _paren = match(PROG_TOKEN.LPAREN);
        
        // Check for "for (var x in y)" or "for (x in y)"
        // This is tricky because "var x" looks like init.
        // We peek? Or we parse var decl without semi, then check for IN?
        
        var _init = undefined;
        var _is_for_in = false;
        var _for_in_var = undefined;
        var _for_in_val_var = undefined; // Added
        var _for_in_modifier = undefined;
        
        if (match(PROG_TOKEN.VAR))
        {
            /* var decl */
            /* Must NOT consume semicolon yet to check for IN */
            _init = parse_var_decl(false, false); /* _require_semi = false */
            
            if (check(PROG_TOKEN.COMMA))
            { 
                /* Check for comma */
                advance(); /* consume comma */
                
                var _val_token = consume(PROG_TOKEN.IDENTIFIER, "Expected value variable name.");
                
                _for_in_val_var = _val_token.lexeme;
            }

            if (match(PROG_TOKEN.IN))
            { 
                /* CHANGED check to match */
                _is_for_in = true;
                
                /* Check for modifier (key/value) */
                if (check(PROG_TOKEN.IDENTIFIER))
                {
                    var _next = peek();
                    
                    if (_next.lexeme == "key" || _next.lexeme == "value")
                    {
                        _for_in_modifier = advance().lexeme;
                    }
                }
                
                _is_for_in = true;
                
                /* Extract variable name from decl */
                if (_init.type == PROG_AST.VAR_DECL)
                {
                    _for_in_var = _init.name;
                }
                else if (_init.type == PROG_AST.DESTRUCTURING_DECL)
                {
                    error_at_current("Destructuring in for-in not yet supported.");
                }
            }
            else
            {
                if (_for_in_val_var != undefined)
                {
                    error_at_current("Unexpected comma in variable declaration.");
                }
                
                match(PROG_TOKEN.SEMICOLON); /* Consume the semi we skipped */
            }
        } 
        else if (!match(PROG_TOKEN.SEMICOLON))
        {
            /* Expression init: "for (i in list)" or "for (i = 0; ...)" */
            /* Parse expression first, then check for IN keyword */
            var _expression = parse_assignment();
            
            /* Check if parsing consumed 'in' operator (e.g. "for (item in items)") */
            /* If so, error because we require 'var' */
            if (_expression.type == PROG_AST.IN_EXPR || check(PROG_TOKEN.COMMA) || check(PROG_TOKEN.IN))
            {
                 error_at_current("'for-in' loops require 'var' declaration (e.g. 'for (var i in list)').");
            }
            
            /* It's a normal for loop init. Convert to assignment if needed, then expect semicolon. */
            _expression = _convert_to_assignment(_expression);
            
            match(PROG_TOKEN.SEMICOLON);
            
            _init = new ProgASTExpressionStmt(_expression);
        }
        
        if (_is_for_in)
        {
            var _collection = undefined;
            
            if (_init != undefined && _init.type == PROG_AST.VAR_DECL) /* Var declaration case */
            {
                 _collection = parse_expression();
            }
            else if (_expression != undefined && _expression.type == PROG_AST.IN_EXPR) /* Binary IN expression case */
            {
                 _collection = _expression.right;
            }
            else /* Normal assignment case where IN was matched */
            {
                 _collection = parse_expression();
            }
            
            if (_paren)
            {
                consume(PROG_TOKEN.RPAREN, "Expected ')' after for-in.");
            }
            
            var _body = parse_statement();
            
            return new ProgASTForInStmt(_for_in_var, _collection, _body, _for_in_val_var, _for_in_modifier);
        }
        
        // Normal For Loop
        // _init is already set (Block or ExpressionStmt)
        
        var _cond = undefined;
        
        if (!check(PROG_TOKEN.SEMICOLON))
        {
            _cond = parse_expression();
        }
        
        consume(PROG_TOKEN.SEMICOLON, "Expected ';' after loop condition.");
        
        var _inc = undefined;
        
        if (!check(PROG_TOKEN.RPAREN) && !check(PROG_TOKEN.LBRACE))
        {
            var _expression = parse_expression();
            
            _inc = _convert_to_assignment(_expression);
        }
        
        if (_paren)
        {
            consume(PROG_TOKEN.RPAREN, "Expected ')' after for clauses.");
        }
        
        var _body = parse_statement();
        
        return new ProgASTForStmt(_init, _cond, _inc, _body);
    }
    
    static parse_try_stmt = function()
    {
        consume(PROG_TOKEN.LBRACE, "Expected '{' before try block.");
        
        var _try_block = new ProgASTBlock(parse_block());
        
        var _catch_var = undefined;
        var _catch_block = undefined;
        
        if (match(PROG_TOKEN.CATCH))
        {
            if (match(PROG_TOKEN.LPAREN))
            {
                _catch_var = consume(PROG_TOKEN.IDENTIFIER, "Expected catch variable name.").lexeme;
                
                consume(PROG_TOKEN.RPAREN, "Expected ')' after catch variable.");
            }
            
            consume(PROG_TOKEN.LBRACE, "Expected '{' before catch block.");
            
            _catch_block = new ProgASTBlock(parse_block());
        }
        
        return new ProgASTTryStmt(_try_block, _catch_var, _catch_block);
    }
    
    static parse_switch_stmt = function()
    {
        /* switch (expr) { case val: body... default: body } */
        var _paren = match(PROG_TOKEN.LPAREN);
        var _expression = parse_expression();
        
        if (_paren)
        {
            consume(PROG_TOKEN.RPAREN, "Expected ')' after switch expression.");
        }
        
        consume(PROG_TOKEN.LBRACE, "Expected '{' before switch cases.");
        
        var _cases = [];
        var _default_case = undefined;
        
        while (!check(PROG_TOKEN.RBRACE) && !is_at_end())
        {
            if (match(PROG_TOKEN.CASE))
            {
                var _case_val = parse_expression();
                
                consume(PROG_TOKEN.COLON, "Expected ':' after case value.");
                
                /* Parse body statements until next case/default/rbrace */
                var _stmts = [];
                
                while (!check(PROG_TOKEN.CASE) && !check(PROG_TOKEN.DEFAULT) && !check(PROG_TOKEN.RBRACE) && !is_at_end())
                {
                    array_push(_stmts, parse_statement());
                }
                
                array_push(_cases, { value: _case_val, body: new ProgASTBlock(_stmts) });
            }
            else if (match(PROG_TOKEN.DEFAULT))
            {
                consume(PROG_TOKEN.COLON, "Expected ':' after default.");
                
                var _stmts = [];
                
                while (!check(PROG_TOKEN.CASE) && !check(PROG_TOKEN.RBRACE) && !is_at_end())
                {
                    array_push(_stmts, parse_statement());
                }
                
                _default_case = new ProgASTBlock(_stmts);
            }
            else
            {
                /* Unexpected token */
                error_at_current("Expected 'case' or 'default' in switch.");
                
                break;
            }
        }
        
        consume(PROG_TOKEN.RBRACE, "Expected '}' after switch cases.");
        return new ProgASTSwitchStmt(_expression, _cases, _default_case);
    }
    
    static parse_expression_statement = function()
    {
        var _expression = parse_expression();
        
        _expression = _convert_to_assignment(_expression);
        
        match(PROG_TOKEN.SEMICOLON);
        
        return new ProgASTExpressionStmt(_expression);
    }
    
    static _convert_to_assignment = function(_expression)
    {
        /* Check for compound assignment tokens (+=, -=) that appear AFTER the expression */
        /* parse_expression() stops at them. */
        
        if (match(PROG_TOKEN.ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.ASSIGN);
        }
        
        if (match(PROG_TOKEN.PLUS_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.PLUS); /* Op is logic to apply */
        }
        
        if (match(PROG_TOKEN.MINUS_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.MINUS);
        }
        
        if (match(PROG_TOKEN.STAR_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.STAR);
        }
        
        if (match(PROG_TOKEN.SLASH_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.SLASH);
        }
        
        if (match(PROG_TOKEN.PERCENT_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.PERCENT);
        }
        
        if (match(PROG_TOKEN.POWER_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.POWER);
        }
        
        if (match(PROG_TOKEN.LSHIFT_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.LSHIFT);
        }
        
        if (match(PROG_TOKEN.RSHIFT_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.RSHIFT);
        }
        
        if (match(PROG_TOKEN.AMP_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.AMP);
        }
        
        if (match(PROG_TOKEN.PIPE_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.PIPE);
        }
        
        if (match(PROG_TOKEN.CARET_ASSIGN))
        {
            var _rhs = parse_expression();
            
            return new ProgASTAssignment(_expression, _rhs, PROG_TOKEN.CARET);
        }
        
        return _expression;
    }
    
    // ----------------------------------------------------------------------------
    // Expressions
    // ----------------------------------------------------------------------------
    
    static parse_expression = function()
    {
        var _expression = parse_assignment();
        
        while (match(PROG_TOKEN.COMMA))
        {
            var _right = parse_assignment();
            
            _expression = new ProgASTBinaryOp(PROG_TOKEN.COMMA, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_assignment = function()
    {
        var _expression = parse_ternary();
        
        if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.PLUS_ASSIGN) || match(PROG_TOKEN.MINUS_ASSIGN) ||
            match(PROG_TOKEN.STAR_ASSIGN) || match(PROG_TOKEN.SLASH_ASSIGN) || match(PROG_TOKEN.PERCENT_ASSIGN) || match(PROG_TOKEN.POWER_ASSIGN) ||
            match(PROG_TOKEN.LSHIFT_ASSIGN) || match(PROG_TOKEN.RSHIFT_ASSIGN) ||
            match(PROG_TOKEN.AMP_ASSIGN) || match(PROG_TOKEN.PIPE_ASSIGN) || match(PROG_TOKEN.CARET_ASSIGN))
        {
            var _op = tokens[current - 1].type;
            
            /* Right associative? usually parse_assignment() to allow a=b=c */
            /* parse_expression calls parse_assignment so it works. */
            var _value = parse_expression();
                                             
            if (_expression.type == PROG_AST.IDENTIFIER || _expression.type == PROG_AST.INDEX || _expression.type == PROG_AST.MEMBER)
            {
                return new ProgASTAssignment(_expression, _value, _op);
            }
            
            error_at_current("Invalid assignment target.");
        }
        
        return _expression;
    }
    
    static parse_ternary = function()
    {
        var _expression = parse_null_coalescing();
        
        if (match(PROG_TOKEN.QUESTION))
        {
            var _true_branch = parse_expression();
            
            consume(PROG_TOKEN.COLON, "Expected ':' in ternary expression.");
            
            var _false_branch = parse_ternary();
            
            return new ProgASTTernary(_expression, _true_branch, _false_branch);
        }
        
        return _expression;
    }
    
    static parse_null_coalescing = function()
    {
        var _expression = parse_logic_or();
        
        while (match(PROG_TOKEN.NULL_COALESCE))
        {
            var _right = parse_logic_or();
            
            _expression = new ProgASTBinaryOp(PROG_TOKEN.NULL_COALESCE, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_logic_or = function()
    {
        var _expression = parse_logic_and();
        
        while (match(PROG_TOKEN.OR))
        {
            var _right = parse_logic_and();
            
            _expression = new ProgASTBinaryOp(PROG_TOKEN.OR, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_logic_and = function()
    {
        var _expression = parse_bitwise_or();
        
        while (match(PROG_TOKEN.AND))
        {
            var _right = parse_bitwise_or();
            
            _expression = new ProgASTBinaryOp(PROG_TOKEN.AND, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_bitwise_or = function()
    {
        var _expression = parse_bitwise_xor();
        
        while (match(PROG_TOKEN.PIPE))
        {
            _expression = new ProgASTBinaryOp(PROG_TOKEN.PIPE, _expression, parse_bitwise_xor());
        }
        
        return _expression;
    }
    
    static parse_bitwise_xor = function()
    {
        var _expression = parse_bitwise_and();
        
        while (match(PROG_TOKEN.CARET))
        {
            _expression = new ProgASTBinaryOp(PROG_TOKEN.CARET, _expression, parse_bitwise_and());
        }
        
        return _expression;
    }
    
    static parse_bitwise_and = function()
    {
        var _expression = parse_equality();
        
        while (match(PROG_TOKEN.AMP))
        {
            _expression = new ProgASTBinaryOp(PROG_TOKEN.AMP, _expression, parse_equality());
        }
        
        return _expression;
    }
    
    static parse_equality = function()
    {
        var _expression = parse_comparison();
        
        /* Only handle == and != as equality operators */
        /* Strict assignment (=) is handled by parse_assignment/expression statement */
        while (check(PROG_TOKEN.EQ) || check(PROG_TOKEN.NE))
        {
            var _op = advance().type;
            var _right = parse_comparison();
            
            _expression = new ProgASTBinaryOp(_op, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_comparison = function()
    {
        var _expression = parse_shift();
        
        while (check(PROG_TOKEN.GT) || check(PROG_TOKEN.GE) || check(PROG_TOKEN.LT) || check(PROG_TOKEN.LE) || check(PROG_TOKEN.IN))
        {
            var _op = advance().type;
            
            /* Handle 'in' operator with optional key/value modifier */
            if (_op == PROG_TOKEN.IN)
            {
                var _modifier = undefined;
                
                /* Check for 'key' or 'value' modifier */
                if (check(PROG_TOKEN.IDENTIFIER))
                {
                    var _next = peek();
                    
                    if (_next.lexeme == "key" || _next.lexeme == "value")
                    {
                        _modifier = advance().lexeme;
                    }
                }
                
                var _right = parse_shift();
                
                _expression = new ProgASTInExpr(_expression, _right, _modifier);
            }
            else
            {
                var _right = parse_shift();
                
                _expression = new ProgASTBinaryOp(_op, _expression, _right);
            }
        }
        
        return _expression;
    }
    
    static parse_shift = function()
    {
        var _expression = parse_range();
        
        while (check(PROG_TOKEN.LSHIFT) || check(PROG_TOKEN.RSHIFT))
        {
            var _op = advance().type;
            var _right = parse_range();
             
            _expression = new ProgASTBinaryOp(_op, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_range = function()
    {
        var _expression = parse_term();
        
        // Handle .. range operator (inclusive)
        if (match(PROG_TOKEN.RANGE))
        {
            var _end = parse_term();
            _expression = new ProgASTRangeExpr(_expression, _end);
        }
        
        return _expression;
    }
    
    static parse_term = function()
    {
        var _expression = parse_factor();
        
        while (check(PROG_TOKEN.PLUS) || check(PROG_TOKEN.MINUS))
        {
            var _op = advance().type;
            var _right = parse_factor();
            
            _expression = new ProgASTBinaryOp(_op, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_factor = function()
    {
        var _expression = parse_unary();
        
        while (check(PROG_TOKEN.STAR) || check(PROG_TOKEN.SLASH) || check(PROG_TOKEN.PERCENT))
        {
            var _op = advance().type;
            var _right = parse_unary();
            
            _expression = new ProgASTBinaryOp(_op, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_unary = function()
    {
        /* Prefix increment/decrement */
        if (match(PROG_TOKEN.PLUS_PLUS) || match(PROG_TOKEN.MINUS_MINUS))
        {
            var _op = previous().type;
            var _target = parse_unary();
            
            return new ProgASTPrefixOp(_op, _target);
        }
        
        if (check(PROG_TOKEN.SPREAD) || check(PROG_TOKEN.NOT) || check(PROG_TOKEN.MINUS) || check(PROG_TOKEN.TILDE))
        {
            var _op = advance().type;
            var _right = parse_unary();
            
            return new ProgASTUnaryOp(_op, _right);
        }
        
        return parse_power();
    }
    
    static parse_power = function()
    {
        var _expression = parse_call();
        
        /* Right associative? 2**3**4 -> 2**(3**4)? */
        if (match(PROG_TOKEN.POWER))
        {
            var _right = parse_unary(); /* Recursion for right associativity */
            
            _expression = new ProgASTBinaryOp(PROG_TOKEN.POWER, _expression, _right);
        }
        
        return _expression;
    }
    
    static parse_call = function()
    {
        var _expression = parse_primary();
        
        for (;;)
        {
            if (match(PROG_TOKEN.LPAREN))
            {
                _expression = finish_call(_expression);
            }
            else if (match(PROG_TOKEN.DOT))
            {
                var _name_token = advance();
                // Allow identifiers and keywords as property names
                if (_name_token.type == PROG_TOKEN.EOF) error_at_current("Expected property name after '.'.");
                
                _expression = new ProgASTMember(_expression, _name_token.lexeme);
            }
            else if (match(PROG_TOKEN.QUESTION_DOT))
            {
                // Optional chaining: obj?.prop or obj?.[expr]
                if (match(PROG_TOKEN.LBRACKET))
                {
                    var _index = parse_expression();
                    consume(PROG_TOKEN.RBRACKET, "Expected ']' after optional index.");
                    _expression = new ProgASTOptionalIndex(_expression, _index);
                }
                else
                {
                    var _name_token = advance();
                    if (_name_token.type == PROG_TOKEN.EOF) error_at_current("Expected property name after '?.'.");
                    _expression = new ProgASTOptionalMember(_expression, _name_token.lexeme);
                }
            }
            else if (match(PROG_TOKEN.LBRACKET))
            {
                var _index = parse_expression();
                
                consume(PROG_TOKEN.RBRACKET, "Expected ']' after index.");
                
                _expression = new ProgASTIndex(_expression, _index);
            }
            else if (match(PROG_TOKEN.PLUS_PLUS) || match(PROG_TOKEN.MINUS_MINUS))
            {
                /* Postfix increment/decrement */
                _expression = new ProgASTPostfixOp(previous().type, _expression);
            }
            else break;
        }
        
        return _expression;
    }
    
    static finish_call = function(_callee)
    {
        var _args = [];
        
        if (!check(PROG_TOKEN.RPAREN))
        {
            do
            {
                array_push(_args, parse_assignment());
            } 
            until (!match(PROG_TOKEN.COMMA));
        }
        
        consume(PROG_TOKEN.RPAREN, "Expected ')' after arguments.");
        
        return new ProgASTCall(_callee, _args);
    }
    
    static parse_primary = function()
    {
        if (match(PROG_TOKEN.FALSE))
        {
            return new ProgASTLiteral(PROG_AST.BOOL_LITERAL, false);
        }
        
        if (match(PROG_TOKEN.TRUE))
        {
            return new ProgASTLiteral(PROG_AST.BOOL_LITERAL, true);
        }
        
        if (match(PROG_TOKEN.UNDEFINED))
        {
            return new ProgASTLiteral(PROG_AST.UNDEFINED_LITERAL, undefined);
        }
        
        if (match(PROG_TOKEN.REGEX))
        {
            var _token = previous();
            
            return new ProgASTRegexLiteral(_token.literal.pattern, _token.literal.flags);
        }
        
        if (match(PROG_TOKEN.FN))
        {
            return parse_function_expr();
        }
        
        if (match(PROG_TOKEN.NEW))
        {
            return parse_new_expr();
        }
        
        if (match(PROG_TOKEN.THIS))
        {
            return new ProgASTThisExpr();
        }
        
        if (match(PROG_TOKEN.SUPER))
        {
            /* Check for super(args) call vs super.method() */
            /* super() is usually in constructor call. */
            /* Parsing it as primitive allows it to be used in ParseCall. */
            /* ParseCall sees Primary(SUPER) then LPAREN -> Call(Super). */
            return new ProgASTSuperExpr();
        }
        
        if (match(PROG_TOKEN.NUMBER))
        {
            return new ProgASTLiteral(PROG_AST.NUMBER_LITERAL, previous().literal);
        }
        
        if (match(PROG_TOKEN.STRING))
        {
            return new ProgASTLiteral(PROG_AST.STRING_LITERAL, previous().literal);
        }
        
        if (match(PROG_TOKEN.IDENTIFIER))
        {
            return new ProgASTIdentifier(previous().lexeme);
        }
        
        if (match(PROG_TOKEN.GLOBAL))
        {
            return new ProgASTIdentifier("global"); /* Allow 'global' as identifier */
        }
        
        if (match(PROG_TOKEN.LPAREN))
        {
            // Check if this is a lambda: () -> expr  or  (a, b) -> expr
            // Use lookahead: save position, scan for matching RPAREN then ARROW
            var _saved = current;
            var _is_lambda = false;
            
            // Quick check: if we see RPAREN immediately, check for ->
            if (check(PROG_TOKEN.RPAREN))
            {
                advance(); // consume )
                if (check(PROG_TOKEN.ARROW))
                {
                    _is_lambda = true;
                }
                current = _saved; // restore either way
            }
            else
            {
                // Tentatively scan ahead: skip identifiers, commas, defaults
                // looking for matching RPAREN then ARROW
                var _depth = 1;
                while (!is_at_end() && _depth > 0)
                {
                    var _t = peek().type;
                    if (_t == PROG_TOKEN.LPAREN) _depth++;
                    else if (_t == PROG_TOKEN.RPAREN) _depth--;
                    
                    if (_depth > 0) advance();
                }
                
                if (_depth == 0)
                {
                    advance(); // consume the matching )
                    if (check(PROG_TOKEN.ARROW))
                    {
                        _is_lambda = true;
                    }
                }
                current = _saved; // restore
            }
            
            if (_is_lambda)
            {
                return parse_lambda();
            }
            
            // Normal grouped expression
            var _expression = parse_expression();
            consume(PROG_TOKEN.RPAREN, "Expect ')' after expression.");
            return _expression;
        }
        
        if (match(PROG_TOKEN.LBRACKET))
        {
            var _elements = [];
            
            if (!check(PROG_TOKEN.RBRACKET))
            {
                do
                {
                    if (check(PROG_TOKEN.RBRACKET))
                    {
                        break; /* Trailing comma */
                    }
                    
                    array_push(_elements, parse_assignment());
                } 
                until (!match(PROG_TOKEN.COMMA));
            }
            
            consume(PROG_TOKEN.RBRACKET, "Expected ']' after array.");
            
            return new ProgASTArrayLiteral(_elements);
        }
        
        if (match(PROG_TOKEN.LBRACE))
        {
            var _pairs = [];
            
            if (!check(PROG_TOKEN.RBRACE))
            {
                do
                {
                    if (check(PROG_TOKEN.RBRACE))
                    {
                        break; /* Trailing comma */
                    }
                    
                    var _key = consume(PROG_TOKEN.IDENTIFIER, "Expected key name.");
                    
                    consume(PROG_TOKEN.COLON, "Expected ':' after key.");
                    
                    var _val = parse_assignment();
                    
                    array_push(_pairs, { key: _key.lexeme, value: _val });
                } 
                until (!match(PROG_TOKEN.COMMA));
            }
            
            consume(PROG_TOKEN.RBRACE, "Expected '}' after object.");
            
            return new ProgASTObjectLiteral(_pairs);
        }
        
        error_at_current("Expect expression.");
        
        return new ProgASTLiteral(PROG_AST.UNDEFINED_LITERAL, undefined);
    }
    
    /* @desc Parse lambda expression: (params) -> body */
    /* At entry, current is positioned after the initial LPAREN was matched */
    static parse_lambda = function()
    {
        /* Parse parameter list (we're already past the LPAREN) */
        var _params = [];
        
        if (!check(PROG_TOKEN.RPAREN))
        {
            do
            {
                var _param_name = consume(PROG_TOKEN.IDENTIFIER, "Expected parameter name.").lexeme;
                var _default = undefined;
                
                if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.EQ))
                {
                    _default = parse_assignment();
                }
                
                array_push(_params, { name: _param_name, default_value: _default });
            } 
            until (!match(PROG_TOKEN.COMMA));
        }
        
        consume(PROG_TOKEN.RPAREN, "Expected ')' after lambda parameters.");
        
        /* Consume the -> */
        consume(PROG_TOKEN.ARROW, "Expected '->' after lambda parameters.");
        
        /* Parse body */
        var _body;
        
        if (check(PROG_TOKEN.LBRACE))
        {
            /* Block body: (x) -> { ... } */
            advance(); /* consume { */
            
            _body = new ProgASTBlock(parse_block());
        }
        else
        {
            /* Expression body: (x) -> x * 2  (implicit return) */
            var _expr = parse_assignment();
            
            _body = new ProgASTBlock([new ProgASTReturnStmt(_expr)]);
        }
        
        return new ProgASTFuncExpr(undefined, _params, _body);
    }
}
