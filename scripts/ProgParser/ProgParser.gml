
/// @desc Parser for Proglang
function ProgParser(_tokens) constructor {
    tokens = _tokens;
    length = array_length(_tokens);
    current = 0;
    had_error = false;
    error = "";
    
    // ----------------------------------------------------------------------------
    // Helpers
    // ----------------------------------------------------------------------------
    
    static is_at_end = function() {
        return peek().type == PROG_TOKEN.EOF;
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
        return new ProgASTNode(PROG_AST.UNDEFINED_LITERAL); // Return dummy to prevent crash
    }
    
    static error_at_current = function(_message) {
        if (had_error) return; // Suppress cascade
        had_error = true;
        var _token = peek();
        error = $"[Line {_token.line}] Error at '{_token.lexeme}': {_message}";
    }
    
    // ----------------------------------------------------------------------------
    // Entry Point
    // ----------------------------------------------------------------------------
    
    static parse = function() {
        var _statements = [];
        had_error = false;
        error = "";
        current = 0;
        
        while (!is_at_end()) {
            array_push(_statements, parse_statement());
        }
        
        return new ProgASTBlock(_statements);
    }
    
    // ----------------------------------------------------------------------------
    // Statements
    // ----------------------------------------------------------------------------
    
    static parse_statement = function() {
        // Check for global prefix
        var _is_global = false;
        if (match(PROG_TOKEN.GLOBAL)) {
            // Could be: global fn, global function, global var, or global.x
            if (check(PROG_TOKEN.FN) || check(PROG_TOKEN.FUNCTION)) {
                _is_global = true;
                // Fall through to fn/function handling below
            } else if (check(PROG_TOKEN.VAR)) {
                // global var x
                advance(); // consume VAR
                return parse_var_decl(true); // is_global = true
            } else if (check(PROG_TOKEN.IDENTIFIER)) {
                // global x = 10 (treat as implicit var decl)
                return parse_var_decl(true);
            } else {
                // global.x = expression (member access)
                current--; // Backtrack
                return parse_expression_statement();
            }
        }
        
        // Function declaration
        if (match(PROG_TOKEN.FN) || match(PROG_TOKEN.FUNCTION)) {
            return parse_function_decl(_is_global);
        }
        
        if (match(PROG_TOKEN.VAR)) return parse_var_decl(false);
        
        if (match(PROG_TOKEN.IF)) return parse_if_stmt();
        if (match(PROG_TOKEN.WHILE)) return parse_while_stmt();
        if (match(PROG_TOKEN.FOR)) return parse_for_stmt();
        if (match(PROG_TOKEN.REPEAT)) return parse_repeat_stmt();
        
        if (match(PROG_TOKEN.BREAK)) {
            match(PROG_TOKEN.SEMICOLON); // Optional
            return new ProgASTBreakStmt();
        }
        
        if (match(PROG_TOKEN.CONTINUE)) {
             match(PROG_TOKEN.SEMICOLON);
             return new ProgASTContinueStmt();
        }
        
        if (match(PROG_TOKEN.RETURN)) {
            var _value = undefined;
            if (!check(PROG_TOKEN.SEMICOLON) && !check(PROG_TOKEN.RBRACE)) {
                _value = parse_expression();
            }
            match(PROG_TOKEN.SEMICOLON); // Optional
            return new ProgASTReturnStmt(_value);
        }
        
        if (match(PROG_TOKEN.LBRACE)) {
            return new ProgASTBlock(parse_block());
        }
        
        if (match(PROG_TOKEN.SWITCH)) return parse_switch_stmt();
        
        return parse_expression_statement();
    }
    
    static parse_block = function() {
        var _statements = [];
        while (!check(PROG_TOKEN.RBRACE) && !is_at_end()) {
            array_push(_statements, parse_statement());
        }
        consume(PROG_TOKEN.RBRACE, "Expected '}' after block.");
        return _statements;
    }
    
    static parse_var_decl = function(_is_global = false) {
        var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected variable name.").lexeme;
        var _initializer = undefined;
        
        if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.EQ)) {
            _initializer = parse_expression();
        }
        
        match(PROG_TOKEN.SEMICOLON); // Optional
        
        var _node = new ProgASTVarDecl(_name, _initializer);
        _node.is_global = _is_global;
        return _node;
    }
    
    static parse_function_decl = function(_is_global = false) {
        var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected function name.").lexeme;
        consume(PROG_TOKEN.LPAREN, "Expected '(' after function name.");
        
        var _params = [];
        if (!check(PROG_TOKEN.RPAREN)) {
            do {
                var _param = consume(PROG_TOKEN.IDENTIFIER, "Expected parameter name.").lexeme;
                array_push(_params, _param);
            } until (!match(PROG_TOKEN.COMMA));
        }
        consume(PROG_TOKEN.RPAREN, "Expected ')' after parameters.");
        
        consume(PROG_TOKEN.LBRACE, "Expected '{' before function body.");
        var _body = new ProgASTBlock(parse_block());
        
        return new ProgASTFuncDecl(_name, _params, _body, _is_global);
    }
    
    static parse_if_stmt = function() {
        var _paren = match(PROG_TOKEN.LPAREN);
        
        var _condition = parse_expression();
        
        if (_paren) consume(PROG_TOKEN.RPAREN, "Expected ')' after if condition.");
        
        var _then = parse_statement();
        var _else = undefined;
        
        if (match(PROG_TOKEN.ELSE)) {
            _else = parse_statement();
        }
        
        return new ProgASTIfStmt(_condition, _then, _else);
    }
    
    static parse_while_stmt = function() {
        var _condition = parse_expression();
        var _body = parse_statement();
        return new ProgASTWhileStmt(_condition, _body);
    }
    
    static parse_repeat_stmt = function() {
        var _count = parse_expression();
        var _body = parse_statement();
        return new ProgASTRepeatStmt(_count, _body);
    }
    
    static parse_for_stmt = function() {
        // for (init; cond; inc) body
        // parens optional in GML if structured correctly, but usually needed for separator.
        // Let's enforce parens for simplicity of parsing 3 parts, OR semi-colons.
        // `for i = 0; i < 10; i++`
        
        // If parens used: `for (i=0; i<10; i++)`
        var _paren = match(PROG_TOKEN.LPAREN);
        
        var _init = undefined;
        if (!match(PROG_TOKEN.SEMICOLON)) {
            if (match(PROG_TOKEN.VAR)) {
                _init = parse_var_decl();
            } else {
                _init = parse_expression_statement(); // This consumes the semicolon usually?
            }
        }
        // Note: parse_var_decl/expression_stmt consumes trailing semicolon if present.
        // If not present, we should expect one?
        // `parse_expression_statement` consumes semicolon.
        
        var _cond = undefined;
        if (!check(PROG_TOKEN.SEMICOLON)) {
            _cond = parse_expression();
        }
        consume(PROG_TOKEN.SEMICOLON, "Expected ';' after loop condition.");
        
        var _inc = undefined;
        if (!check(PROG_TOKEN.RPAREN) && !check(PROG_TOKEN.LBRACE)) {
            // Increment is an expression statement usually (i += 1)
            // But w/o semicolon?
            // Special handling: parse expression, check for assignment conversion
            // We use `parse_expression` then convert to assignment just like `parse_expression_statement`.
            var _expr = parse_expression();
            _inc = _convert_to_assignment(_expr);
        }
        
        if (_paren) consume(PROG_TOKEN.RPAREN, "Expected ')' after for clauses.");
        
        var _body = parse_statement();
        
        return new ProgASTForStmt(_init, _cond, _inc, _body);
    }
    
    static parse_switch_stmt = function() {
        // switch (expr) { case val: body... default: body }
        var _paren = match(PROG_TOKEN.LPAREN);
        var _expr = parse_expression();
        if (_paren) consume(PROG_TOKEN.RPAREN, "Expected ')' after switch expression.");
        
        consume(PROG_TOKEN.LBRACE, "Expected '{' before switch cases.");
        
        var _cases = [];
        var _default_case = undefined;
        
        while (!check(PROG_TOKEN.RBRACE) && !is_at_end()) {
            if (match(PROG_TOKEN.CASE)) {
                var _case_val = parse_expression();
                consume(PROG_TOKEN.COLON, "Expected ':' after case value.");
                
                // Parse body statements until next case/default/rbrace
                var _stmts = [];
                while (!check(PROG_TOKEN.CASE) && !check(PROG_TOKEN.DEFAULT) && !check(PROG_TOKEN.RBRACE) && !is_at_end()) {
                    array_push(_stmts, parse_statement());
                }
                array_push(_cases, { value: _case_val, body: new ProgASTBlock(_stmts) });
            }
            else if (match(PROG_TOKEN.DEFAULT)) {
                consume(PROG_TOKEN.COLON, "Expected ':' after default.");
                var _stmts = [];
                while (!check(PROG_TOKEN.CASE) && !check(PROG_TOKEN.RBRACE) && !is_at_end()) {
                    array_push(_stmts, parse_statement());
                }
                _default_case = new ProgASTBlock(_stmts);
            }
            else {
                // Unexpected token
                error_at_current("Expected 'case' or 'default' in switch.");
                break;
            }
        }
        
        consume(PROG_TOKEN.RBRACE, "Expected '}' after switch cases.");
        return new ProgASTSwitchStmt(_expr, _cases, _default_case);
    }
    
    static parse_expression_statement = function() {
        var _expr = parse_expression();
        
        _expr = _convert_to_assignment(_expr);
        
        match(PROG_TOKEN.SEMICOLON);
        return new ProgASTExpressionStmt(_expr);
    }
    
    static _convert_to_assignment = function(_expr) {
        // Check for compound assignment tokens (+=, -=) that appear AFTER the expression
        // parse_expression() stops at them.
        
        if (match(PROG_TOKEN.PLUS_ASSIGN)) {
            var _rhs = parse_expression();
            return new ProgASTAssignment(_expr, _rhs, PROG_TOKEN.PLUS); // Op is logic to apply
        }
        if (match(PROG_TOKEN.MINUS_ASSIGN)) {
            var _rhs = parse_expression();
            return new ProgASTAssignment(_expr, _rhs, PROG_TOKEN.MINUS);
        }
        if (match(PROG_TOKEN.STAR_ASSIGN)) {
            var _rhs = parse_expression();
            return new ProgASTAssignment(_expr, _rhs, PROG_TOKEN.STAR);
        }
        if (match(PROG_TOKEN.SLASH_ASSIGN)) {
            var _rhs = parse_expression();
            return new ProgASTAssignment(_expr, _rhs, PROG_TOKEN.SLASH);
        }
        if (match(PROG_TOKEN.ASSIGN) || match(PROG_TOKEN.EQ)) {
             // Handle explicit `target = value` where parser stopped at `=` (if treating as simple expr)
             // But my parser treats `=` as operator, so it IS in `_expr` as BinaryOp
        }
        
        // Convert `BinaryOp(ASSIGN/EQ)` to `Assignment` if Top-Level
        if (_expr.type == PROG_AST.BINARY_OP) {
            if (_expr.op == PROG_TOKEN.ASSIGN || _expr.op == PROG_TOKEN.EQ) {
                // Determine implicit chaining? `a = b` -> Assignment.
                // Compiler will handle `ExpressionStmt(Assignment)` as STORE.
                // `BinaryOp(EQ)` here effectively becomes `Attribute = value`.
                // So we assume top-Level `=` is always Assignment.
                return new ProgASTAssignment(_expr.left, _expr.right, PROG_TOKEN.ASSIGN);
            }
        }
        
        return _expr;
    }
    
    // ----------------------------------------------------------------------------
    // Expressions
    // ----------------------------------------------------------------------------
    
    static parse_expression = function() {
        return parse_ternary();
    }
    
    static parse_ternary = function() {
        var _expr = parse_logic_or();
        
        if (match(PROG_TOKEN.QUESTION)) {
            var _true_branch = parse_expression();
            consume(PROG_TOKEN.COLON, "Expected ':' in ternary expression.");
            var _false_branch = parse_ternary();
            return new ProgASTTernary(_expr, _true_branch, _false_branch);
        }
        
        return _expr;
    }
    
    static parse_logic_or = function() {
        var _expr = parse_logic_and();
        while (match(PROG_TOKEN.OR)) {
            var _right = parse_logic_and();
            _expr = new ProgASTBinaryOp(PROG_TOKEN.OR, _expr, _right);
        }
        return _expr;
    }
    
    static parse_logic_and = function() {
        var _expr = parse_bitwise_or();
        while (match(PROG_TOKEN.AND)) {
            var _right = parse_bitwise_or();
            _expr = new ProgASTBinaryOp(PROG_TOKEN.AND, _expr, _right);
        }
        return _expr;
    }
    
    static parse_bitwise_or = function() {
         var _expr = parse_bitwise_xor();
         while (match(PROG_TOKEN.PIPE)) {
             _expr = new ProgASTBinaryOp(PROG_TOKEN.PIPE, _expr, parse_bitwise_xor());
         }
         return _expr;
    }
    
    static parse_bitwise_xor = function() {
         var _expr = parse_bitwise_and();
         while (match(PROG_TOKEN.CARET)) {
             _expr = new ProgASTBinaryOp(PROG_TOKEN.CARET, _expr, parse_bitwise_and());
         }
         return _expr;
    }
    
    static parse_bitwise_and = function() {
         var _expr = parse_equality();
         while (match(PROG_TOKEN.AMP)) {
             _expr = new ProgASTBinaryOp(PROG_TOKEN.AMP, _expr, parse_equality());
         }
         return _expr;
    }
    
    static parse_equality = function() {
        var _expr = parse_comparison();
        
        // Treat both == and = as equality in expressions
        while (check(PROG_TOKEN.EQ) || check(PROG_TOKEN.NE) || check(PROG_TOKEN.ASSIGN)) {
            var _op = advance().type;
            if (_op == PROG_TOKEN.ASSIGN) _op = PROG_TOKEN.EQ; // Normalize to EQ
            
            var _right = parse_comparison();
            _expr = new ProgASTBinaryOp(_op, _expr, _right);
        }
        
        return _expr;
    }
    
    static parse_comparison = function() {
        var _expr = parse_shift();
        while (check(PROG_TOKEN.GT) || check(PROG_TOKEN.GE) || check(PROG_TOKEN.LT) || check(PROG_TOKEN.LE)) {
             var _op = advance().type;
             var _right = parse_shift();
             _expr = new ProgASTBinaryOp(_op, _expr, _right);
        }
        return _expr;
    }
    
    static parse_shift = function() {
        var _expr = parse_term();
        while (check(PROG_TOKEN.LSHIFT) || check(PROG_TOKEN.RSHIFT)) {
             var _op = advance().type;
             var _right = parse_term();
             _expr = new ProgASTBinaryOp(_op, _expr, _right);
        }
        return _expr;
    }
    
    static parse_term = function() {
        var _expr = parse_factor();
        while (check(PROG_TOKEN.PLUS) || check(PROG_TOKEN.MINUS)) {
            var _op = advance().type;
            var _right = parse_factor();
            _expr = new ProgASTBinaryOp(_op, _expr, _right);
        }
        return _expr;
    }
    
    static parse_factor = function() {
        var _expr = parse_unary();
        while (check(PROG_TOKEN.STAR) || check(PROG_TOKEN.SLASH) || check(PROG_TOKEN.PERCENT)) {
            var _op = advance().type;
            var _right = parse_unary();
            _expr = new ProgASTBinaryOp(_op, _expr, _right);
        }
        return _expr;
    }
    
    static parse_unary = function() {
        // Prefix increment/decrement
        if (match(PROG_TOKEN.PLUS_PLUS) || match(PROG_TOKEN.MINUS_MINUS)) {
            var _op = previous().type;
            var _target = parse_unary();
            return new ProgASTPrefixOp(_op, _target);
        }
        
        if (check(PROG_TOKEN.NOT) || check(PROG_TOKEN.MINUS)) {
            var _op = advance().type;
            var _right = parse_unary();
            return new ProgASTUnaryOp(_op, _right);
        }
        return parse_power();
    }
    
    static parse_power = function() {
        var _expr = parse_call();
        // Right associative? 2^3^4 -> 2^(3^4)? 
        if (match(PROG_TOKEN.POWER)) {
            var _right = parse_unary(); // Recursion for right associativity
            _expr = new ProgASTBinaryOp(PROG_TOKEN.POWER, _expr, _right);
        }
        return _expr;
    }
    
    static parse_call = function() {
        var _expr = parse_primary();
        
        while (true) {
            if (match(PROG_TOKEN.LPAREN)) {
                _expr = finish_call(_expr);
            } else if (match(PROG_TOKEN.DOT)) {
                var _name = consume(PROG_TOKEN.IDENTIFIER, "Expected property name after '.'.");
                _expr = new ProgASTMember(_expr, _name.lexeme);
            } else if (match(PROG_TOKEN.LBRACKET)) {
                var _index = parse_expression();
                consume(PROG_TOKEN.RBRACKET, "Expected ']' after index.");
                _expr = new ProgASTIndex(_expr, _index);
            } else if (match(PROG_TOKEN.PLUS_PLUS) || match(PROG_TOKEN.MINUS_MINUS)) {
                // Postfix increment/decrement
                _expr = new ProgASTPostfixOp(previous().type, _expr);
            } else {
                break;
            }
        }
        return _expr;
    }
    
    static finish_call = function(_callee) {
        var _args = [];
        if (!check(PROG_TOKEN.RPAREN)) {
            do {
                array_push(_args, parse_expression());
            } until (!match(PROG_TOKEN.COMMA));
        }
        consume(PROG_TOKEN.RPAREN, "Expected ')' after arguments.");
        return new ProgASTCall(_callee, _args);
    }
    
    static parse_primary = function() {
        if (match(PROG_TOKEN.FALSE)) return new ProgASTLiteral(PROG_AST.BOOL_LITERAL, false);
        if (match(PROG_TOKEN.TRUE)) return new ProgASTLiteral(PROG_AST.BOOL_LITERAL, true);
        if (match(PROG_TOKEN.UNDEFINED)) return new ProgASTLiteral(PROG_AST.UNDEFINED_LITERAL, undefined);
        
        if (match(PROG_TOKEN.NUMBER)) return new ProgASTLiteral(PROG_AST.NUMBER_LITERAL, previous().literal);
        if (match(PROG_TOKEN.STRING)) return new ProgASTLiteral(PROG_AST.STRING_LITERAL, previous().literal);
        
        if (match(PROG_TOKEN.IDENTIFIER)) return new ProgASTIdentifier(previous().lexeme);
        if (match(PROG_TOKEN.GLOBAL)) return new ProgASTIdentifier("global"); // Allow `global` as identifier
        
        if (match(PROG_TOKEN.LPAREN)) {
            var _expr = parse_expression();
            consume(PROG_TOKEN.RPAREN, "Expect ')' after expression.");
            return _expr;
        }
        
        if (match(PROG_TOKEN.LBRACKET)) {
            var _elements = [];
            if (!check(PROG_TOKEN.RBRACKET)) {
                do {
                    array_push(_elements, parse_expression());
                } until (!match(PROG_TOKEN.COMMA));
            }
            consume(PROG_TOKEN.RBRACKET, "Expected ']' after array.");
            return new ProgASTArrayLiteral(_elements);
        }
        
        if (match(PROG_TOKEN.LBRACE)) {
             var _pairs = [];
             if (!check(PROG_TOKEN.RBRACE)) {
                 do {
                     var _key = consume(PROG_TOKEN.IDENTIFIER, "Expected key name.");
                     consume(PROG_TOKEN.COLON, "Expected ':' after key.");
                     var _val = parse_expression();
                     array_push(_pairs, { key: _key.lexeme, value: _val });
                 } until (!match(PROG_TOKEN.COMMA));
             }
             consume(PROG_TOKEN.RBRACE, "Expected '}' after object.");
             return new ProgASTObjectLiteral(_pairs);
        }
        
        error_at_current("Expect expression.");
        return new ProgASTLiteral(PROG_AST.UNDEFINED_LITERAL, undefined);
    }
}
