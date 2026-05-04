use crate::proglang::ast::*;
use crate::proglang::lexer::{Token, TokenKind};

pub struct Parser {
    tokens: Vec<Token>,
    current: usize,
    had_error: bool,
    error: String,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self {
            tokens,
            current: 0,
            had_error: false,
            error: String::new(),
        }
    }

    pub fn parse(&mut self) -> Result<Stmt, String> {
        let mut statements = Vec::new();
        while !self.is_at_end() {
            match self.parse_statement() {
                Ok(stmt) => statements.push(stmt),
                Err(err) => {
                    self.had_error = true;
                    self.error = err;
                    break;
                }
            }
        }

        if self.had_error {
            Err(self.error.clone())
        } else {
            Ok(Stmt::Block(statements))
        }
    }

    fn is_at_end(&self) -> bool {
        self.peek().kind == TokenKind::Eof
    }

    fn peek(&self) -> &Token {
        &self.tokens[self.current]
    }

    fn previous(&self) -> &Token {
        &self.tokens[self.current - 1]
    }

    fn advance(&mut self) -> &Token {
        if !self.is_at_end() {
            self.current += 1;
        }
        self.previous()
    }

    fn check(&self, kind: TokenKind) -> bool {
        if self.is_at_end() {
            false
        } else {
            // We only compare the variant for TokenKind here
            std::mem::discriminant(&self.peek().kind) == std::mem::discriminant(&kind)
        }
    }

    fn match_token(&mut self, kind: TokenKind) -> bool {
        if self.check(kind) {
            self.advance();
            true
        } else {
            false
        }
    }

    fn consume(&mut self, kind: TokenKind, message: &str) -> Result<&Token, String> {
        if self.check(kind) {
            Ok(self.advance())
        } else {
            Err(format!("[Line {}] Error at '{}': {}", self.peek().line, self.peek().lexeme, message))
        }
    }

    fn parse_statement(&mut self) -> Result<Stmt, String> {
        let mut annotations = Annotations::default();
        while self.check(TokenKind::AtInline) || self.check(TokenKind::AtMemoize) {
            if self.match_token(TokenKind::AtInline) {
                annotations.is_inline = true;
            } else if self.match_token(TokenKind::AtMemoize) {
                annotations.is_memoize = true;
            }
            if self.check(TokenKind::Lbrace) {
                return Err("Annotations must not be followed by braces ('{'). Use '@annotation declaration'.".to_string());
            }
        }

        let mut is_global = false;
        if self.match_token(TokenKind::Global) {
            if self.check(TokenKind::Fn) {
                is_global = true;
            } else if self.match_token(TokenKind::Var) {
                return self.parse_var_decl(true);
            } else if self.check(TokenKind::Dot) {
                self.current -= 1; // Backtrack
                return self.parse_expression_statement();
            } else {
                return Err("Expected 'var', 'fn', or '.' after 'global'.".to_string());
            }
        }

        if self.match_token(TokenKind::Fn) {
            return self.parse_function_decl(is_global, annotations);
        }

        if self.match_token(TokenKind::Class) {
            return self.parse_class_decl(annotations);
        }

        if self.match_token(TokenKind::Var) {
            return self.parse_var_decl(false);
        }

        if self.match_token(TokenKind::If) {
            return self.parse_if_stmt();
        }

        if self.match_token(TokenKind::While) {
            return self.parse_while_stmt();
        }

        if self.match_token(TokenKind::For) {
            return self.parse_for_stmt();
        }

        if self.match_token(TokenKind::Repeat) {
            return self.parse_repeat_stmt();
        }

        if self.match_token(TokenKind::Try) {
            return self.parse_try_stmt();
        }

        if self.match_token(TokenKind::Break) {
            let amount = if !self.check(TokenKind::Semi) && !self.check(TokenKind::Rbrace) {
                Some(Box::new(self.parse_expression()?))
            } else {
                None
            };
            self.match_token(TokenKind::Semi);
            return Ok(Stmt::Break(amount));
        }

        if self.match_token(TokenKind::Continue) {
            self.match_token(TokenKind::Semi);
            return Ok(Stmt::Continue);
        }

        if self.match_token(TokenKind::Return) {
            let value = if !self.check(TokenKind::Semi) && !self.check(TokenKind::Rbrace) {
                Some(Box::new(self.parse_expression()?))
            } else {
                None
            };
            self.match_token(TokenKind::Semi);
            return Ok(Stmt::Return(value));
        }

        if self.match_token(TokenKind::Lbrace) {
            return Ok(Stmt::Block(self.parse_block()?));
        }

        if self.match_token(TokenKind::Switch) {
            return self.parse_switch_stmt();
        }

        if self.match_token(TokenKind::Import) {
            return self.parse_import_stmt();
        }

        if self.match_token(TokenKind::Export) {
            return self.parse_export_stmt();
        }

        if self.match_token(TokenKind::Throw) {
            let expr = self.parse_expression()?;
            self.match_token(TokenKind::Semi);
            return Ok(Stmt::Throw(Box::new(expr)));
        }

        self.parse_expression_statement()
    }

    fn parse_var_decl(&mut self, is_global: bool) -> Result<Stmt, String> {
        if self.check(TokenKind::Lbrace) || self.check(TokenKind::Lbracket) {
            let pattern = self.parse_destructuring_pattern()?;
            self.consume(TokenKind::Eq, "Expected '=' in destructuring declaration.")?;
            let initializer = self.parse_expression()?;
            self.match_token(TokenKind::Semi);
            return Ok(Stmt::Destruct { pattern, initializer: Box::new(initializer) });
        }

        let name = self.consume(TokenKind::Ident(String::new()), "Expected variable name.")?.lexeme.clone();
        let mut initializer = None;
        if self.match_token(TokenKind::Eq) {
            initializer = Some(Box::new(self.parse_expression()?));
        }
        self.match_token(TokenKind::Semi);
        Ok(Stmt::VarDecl { name, initializer, is_global })
    }

    fn parse_destructuring_pattern(&mut self) -> Result<DestructPat, String> {
        if self.match_token(TokenKind::Lbrace) {
            let mut fields = Vec::new();
            loop {
                let key = self.consume(TokenKind::Ident(String::new()), "Expected key in destructuring.")?.lexeme.clone();
                let mut target = DestructTarget::Name(key.clone());
                if self.match_token(TokenKind::Colon) {
                    if self.check(TokenKind::Lbrace) || self.check(TokenKind::Lbracket) {
                        target = DestructTarget::Nested(Box::new(self.parse_destructuring_pattern()?));
                    } else {
                        target = DestructTarget::Name(self.consume(TokenKind::Ident(String::new()), "Expected variable name.")?.lexeme.clone());
                    }
                }
                fields.push(ObjField { key, target });
                if !self.match_token(TokenKind::Comma) { break; }
            }
            self.consume(TokenKind::Rbrace, "Expected '}' after object pattern.")?;
            Ok(DestructPat::Object(fields))
        } else if self.match_token(TokenKind::Lbracket) {
            let mut elements = Vec::new();
            loop {
                if self.check(TokenKind::Lbrace) || self.check(TokenKind::Lbracket) {
                    elements.push(ArrayElem::Nested(Box::new(self.parse_destructuring_pattern()?)));
                } else {
                    elements.push(ArrayElem::Name(self.consume(TokenKind::Ident(String::new()), "Expected variable name.")?.lexeme.clone()));
                }
                if !self.match_token(TokenKind::Comma) { break; }
            }
            self.consume(TokenKind::Rbracket, "Expected ']' after array pattern.")?;
            Ok(DestructPat::Array(elements))
        } else {
            Err("Invalid destructuring pattern start.".to_string())
        }
    }

    fn parse_function_decl(&mut self, is_global: bool, annotations: Annotations) -> Result<Stmt, String> {
        let name = self.consume(TokenKind::Ident(String::new()), "Expected function name.")?.lexeme.clone();
        let (params, body) = self.parse_function_body()?;
        Ok(Stmt::FuncDecl { name, params, body: Box::new(body), is_global, annotations })
    }

    fn parse_function_body(&mut self) -> Result<(Vec<Param>, Stmt), String> {
        self.consume(TokenKind::Lparen, "Expected '(' after function name.")?;
        let mut params = Vec::new();
        if !self.check(TokenKind::Rparen) {
            loop {
                let name = self.consume(TokenKind::Ident(String::new()), "Expected parameter name.")?.lexeme.clone();
                let mut default_value = None;
                if self.match_token(TokenKind::Eq) {
                    default_value = Some(Box::new(self.parse_expression()?));
                }
                params.push(Param { name, default_value });
                if !self.match_token(TokenKind::Comma) { break; }
            }
        }
        self.consume(TokenKind::Rparen, "Expected ')' after parameters.")?;
        self.consume(TokenKind::Lbrace, "Expected '{' before function body.")?;
        let body = Stmt::Block(self.parse_block()?);
        Ok((params, body))
    }

    fn parse_block(&mut self) -> Result<Vec<Stmt>, String> {
        let mut statements = Vec::new();
        while !self.check(TokenKind::Rbrace) && !self.is_at_end() {
            statements.push(self.parse_statement()?);
        }
        self.consume(TokenKind::Rbrace, "Expected '}' after block.")?;
        Ok(statements)
    }

    fn parse_if_stmt(&mut self) -> Result<Stmt, String> {
        let has_paren = self.match_token(TokenKind::Lparen);
        let condition = self.parse_expression()?;
        if has_paren { self.consume(TokenKind::Rparen, "Expected ')' after if condition.")?; }
        let then = self.parse_statement()?;
        let mut else_ = None;
        if self.match_token(TokenKind::Else) {
            else_ = Some(Box::new(self.parse_statement()?));
        }
        Ok(Stmt::If { condition: Box::new(condition), then: Box::new(then), else_ })
    }

    fn parse_while_stmt(&mut self) -> Result<Stmt, String> {
        let condition = self.parse_expression()?;
        let body = self.parse_statement()?;
        Ok(Stmt::While { condition: Box::new(condition), body: Box::new(body) })
    }

    fn parse_for_stmt(&mut self) -> Result<Stmt, String> {
        let _has_paren = self.match_token(TokenKind::Lparen);
        // Simplified for now, real implementation would check for 'in'
        let init = if self.match_token(TokenKind::Var) {
            Some(Box::new(self.parse_var_decl(false)?))
        } else if !self.check(TokenKind::Semi) {
            Some(Box::new(Stmt::Expr(Box::new(self.parse_expression()?))))
        } else {
            None
        };
        self.consume(TokenKind::Semi, "Expected ';' after for init.")?;
        let condition = if !self.check(TokenKind::Semi) {
            Some(Box::new(self.parse_expression()?))
        } else {
            None
        };
        self.consume(TokenKind::Semi, "Expected ';' after for condition.")?;
        let increment = if !self.check(TokenKind::Rparen) {
            Some(Box::new(self.parse_expression()?))
        } else {
            None
        };
        if _has_paren { self.consume(TokenKind::Rparen, "Expected ')' after for clauses.")?; }
        let body = self.parse_statement()?;
        Ok(Stmt::For { init, condition, increment, body: Box::new(body) })
    }

    fn parse_repeat_stmt(&mut self) -> Result<Stmt, String> {
        let count = self.parse_expression()?;
        let body = self.parse_statement()?;
        Ok(Stmt::Repeat { count: Box::new(count), body: Box::new(body) })
    }

    fn parse_try_stmt(&mut self) -> Result<Stmt, String> {
        let try_block = Stmt::Block(self.parse_block()?);
        self.consume(TokenKind::Catch, "Expected 'catch' after try block.")?;
        self.consume(TokenKind::Lparen, "Expected '(' after catch.")?;
        let catch_var = self.consume(TokenKind::Ident(String::new()), "Expected catch variable.")?.lexeme.clone();
        self.consume(TokenKind::Rparen, "Expected ')' after catch variable.")?;
        self.consume(TokenKind::Lbrace, "Expected '{' before catch block.")?;
        let catch_block = Stmt::Block(self.parse_block()?);
        Ok(Stmt::Try { try_block: Box::new(try_block), catch_var, catch_block: Box::new(catch_block) })
    }

    fn parse_switch_stmt(&mut self) -> Result<Stmt, String> {
        let expr = self.parse_expression()?;
        self.consume(TokenKind::Lbrace, "Expected '{' before switch body.")?;
        let mut cases = Vec::new();
        let mut default = None;
        while !self.check(TokenKind::Rbrace) && !self.is_at_end() {
            if self.match_token(TokenKind::Case) {
                let value = self.parse_expression()?;
                self.consume(TokenKind::Colon, "Expected ':' after case value.")?;
                let mut body = Vec::new();
                while !self.check(TokenKind::Case) && !self.check(TokenKind::Default) && !self.check(TokenKind::Rbrace) {
                    body.push(self.parse_statement()?);
                }
                cases.push(SwitchCase { value: Box::new(value), body });
            } else if self.match_token(TokenKind::Default) {
                self.consume(TokenKind::Colon, "Expected ':' after default.")?;
                let mut body = Vec::new();
                while !self.check(TokenKind::Case) && !self.check(TokenKind::Default) && !self.check(TokenKind::Rbrace) {
                    body.push(self.parse_statement()?);
                }
                default = Some(body);
            } else {
                return Err("Expected 'case' or 'default' in switch body.".to_string());
            }
        }
        self.consume(TokenKind::Rbrace, "Expected '}' after switch body.")?;
        Ok(Stmt::Switch { expr: Box::new(expr), cases, default })
    }

    fn parse_import_stmt(&mut self) -> Result<Stmt, String> {
        let mut items = Vec::new();
        let uses_braces = self.match_token(TokenKind::Lbrace);
        loop {
            let name = self.consume(TokenKind::Ident(String::new()), "Expected imported name.")?.lexeme.clone();
            let mut alias = name.clone();
            if self.match_token(TokenKind::As) {
                alias = self.consume(TokenKind::Ident(String::new()), "Expected alias name.")?.lexeme.clone();
            }
            items.push(ImportItem { name, alias });
            if !self.match_token(TokenKind::Comma) { break; }
        }
        if uses_braces { self.consume(TokenKind::Rbrace, "Expected '}' after imported names.")?; }
        self.consume(TokenKind::From, "Expected 'from' after imports.")?;
        let path = match self.consume(TokenKind::Str(String::new()), "Expected module path.")?.kind.clone() {
            TokenKind::Str(s) => s,
            _ => unreachable!(),
        };
        self.match_token(TokenKind::Semi);
        Ok(Stmt::Import { items, path })
    }

    fn parse_export_stmt(&mut self) -> Result<Stmt, String> {
        let is_default = self.match_token(TokenKind::Default);
        let decl = if is_default {
            Stmt::Expr(Box::new(self.parse_expression()?))
        } else {
            self.parse_statement()?
        };
        self.match_token(TokenKind::Semi);
        Ok(Stmt::Export { decl: Box::new(decl), is_default })
    }

    fn parse_class_decl(&mut self, _annotations: Annotations) -> Result<Stmt, String> {
        let name = self.consume(TokenKind::Ident(String::new()), "Expected class name.")?.lexeme.clone();
        let mut super_class = None;
        if self.match_token(TokenKind::Extends) {
            super_class = Some(self.consume(TokenKind::Ident(String::new()), "Expected superclass name.")?.lexeme.clone());
        }
        self.consume(TokenKind::Lbrace, "Expected '{' before class body.")?;
        let mut members = Vec::new();
        let mut constructor = None;
        while !self.check(TokenKind::Rbrace) && !self.is_at_end() {
            let mut access = AccessModifier::Public;
            if self.match_token(TokenKind::Public) { access = AccessModifier::Public; }
            else if self.match_token(TokenKind::Private) { access = AccessModifier::Private; }
            else if self.match_token(TokenKind::Protected) { access = AccessModifier::Protected; }

            let is_static = self.match_token(TokenKind::Static);
            let is_abstract = self.match_token(TokenKind::Abstract);

            if self.match_token(TokenKind::Fn) {
                let member_name = self.peek().lexeme.clone();
                let decl = self.parse_function_decl(false, Annotations::default())?;
                if member_name == "constructor" {
                    constructor = Some(Box::new(decl));
                } else {
                    members.push(ClassMember { is_method: true, node: Box::new(decl), access, is_static, is_abstract });
                }
            } else if self.match_token(TokenKind::Var) {
                let decl = self.parse_var_decl(false)?;
                members.push(ClassMember { is_method: false, node: Box::new(decl), access, is_static, is_abstract });
            } else {
                self.advance();
            }
        }
        self.consume(TokenKind::Rbrace, "Expected '}' after class body.")?;
        Ok(Stmt::ClassDecl { name, super_class, members, constructor, is_abstract: false })
    }

    fn parse_expression_statement(&mut self) -> Result<Stmt, String> {
        let expr = self.parse_expression()?;
        self.match_token(TokenKind::Semi);
        Ok(Stmt::Expr(Box::new(expr)))
    }

    fn parse_expression(&mut self) -> Result<Expr, String> {
        self.parse_assignment()
    }

    fn parse_assignment(&mut self) -> Result<Expr, String> {
        let expr = self.parse_logical_or()?;
        if self.match_token(TokenKind::Eq) || self.match_token(TokenKind::PlusEq) || self.match_token(TokenKind::MinusEq) || self.match_token(TokenKind::StarEq) || self.match_token(TokenKind::SlashEq) {
            let op = match self.previous().kind {
                TokenKind::Eq => AssignOp::Assign,
                TokenKind::PlusEq => AssignOp::AddAssign,
                TokenKind::MinusEq => AssignOp::SubAssign,
                TokenKind::StarEq => AssignOp::MulAssign,
                TokenKind::SlashEq => AssignOp::DivAssign,
                _ => unreachable!(),
            };
            let value = self.parse_assignment()?;
            return Ok(Expr::Assign { target: Box::new(expr), value: Box::new(value), op });
        }
        Ok(expr)
    }

    fn parse_logical_or(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_logical_and()?;
        while self.match_token(TokenKind::Or) {
            let right = self.parse_logical_and()?;
            expr = Expr::Binary { op: BinOp::Or, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_logical_and(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_equality()?;
        while self.match_token(TokenKind::And) {
            let right = self.parse_equality()?;
            expr = Expr::Binary { op: BinOp::And, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_equality(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_comparison()?;
        while self.match_token(TokenKind::EqEq) || self.match_token(TokenKind::BangEq) {
            let op = if self.previous().kind == TokenKind::EqEq { BinOp::Eq } else { BinOp::Ne };
            let right = self.parse_comparison()?;
            expr = Expr::Binary { op, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_comparison(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_term()?;
        while self.match_token(TokenKind::Lt) || self.match_token(TokenKind::Gt) || self.match_token(TokenKind::Le) || self.match_token(TokenKind::Ge) {
            let op = match self.previous().kind {
                TokenKind::Lt => BinOp::Lt,
                TokenKind::Gt => BinOp::Gt,
                TokenKind::Le => BinOp::Le,
                TokenKind::Ge => BinOp::Ge,
                _ => unreachable!(),
            };
            let right = self.parse_term()?;
            expr = Expr::Binary { op, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_term(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_factor()?;
        while self.match_token(TokenKind::Plus) || self.match_token(TokenKind::Minus) {
            let op = if self.previous().kind == TokenKind::Plus { BinOp::Add } else { BinOp::Sub };
            let right = self.parse_factor()?;
            expr = Expr::Binary { op, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_factor(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_unary()?;
        while self.match_token(TokenKind::Star) || self.match_token(TokenKind::Slash) || self.match_token(TokenKind::Percent) {
            let op = match self.previous().kind {
                TokenKind::Star => BinOp::Mul,
                TokenKind::Slash => BinOp::Div,
                TokenKind::Percent => BinOp::Mod,
                _ => unreachable!(),
            };
            let right = self.parse_unary()?;
            expr = Expr::Binary { op, left: Box::new(expr), right: Box::new(right) };
        }
        Ok(expr)
    }

    fn parse_unary(&mut self) -> Result<Expr, String> {
        if self.match_token(TokenKind::Not) || self.match_token(TokenKind::Minus) || self.match_token(TokenKind::Tilde) || self.match_token(TokenKind::Spread) {
            let op = match self.previous().kind {
                TokenKind::Not => UnOp::Not,
                TokenKind::Minus => UnOp::Neg,
                TokenKind::Tilde => UnOp::BitNot,
                TokenKind::Spread => UnOp::Spread,
                _ => unreachable!(),
            };
            let right = self.parse_unary()?;
            return Ok(Expr::Unary { op, right: Box::new(right) });
        }
        self.parse_call()
    }

    fn parse_call(&mut self) -> Result<Expr, String> {
        let mut expr = self.parse_primary()?;
        loop {
            if self.match_token(TokenKind::Lparen) {
                let mut args = Vec::new();
                if !self.check(TokenKind::Rparen) {
                    loop {
                        args.push(self.parse_expression()?);
                        if !self.match_token(TokenKind::Comma) { break; }
                    }
                }
                self.consume(TokenKind::Rparen, "Expected ')' after arguments.")?;
                expr = Expr::Call { callee: Box::new(expr), args };
            } else if self.match_token(TokenKind::Dot) {
                let property = self.consume(TokenKind::Ident(String::new()), "Expected property name.")?.lexeme.clone();
                expr = Expr::Member { target: Box::new(expr), property };
            } else if self.match_token(TokenKind::Lbracket) {
                let index = self.parse_expression()?;
                self.consume(TokenKind::Rbracket, "Expected ']' after index.")?;
                expr = Expr::Index { target: Box::new(expr), index: Box::new(index) };
            } else {
                break;
            }
        }
        Ok(expr)
    }

    fn parse_primary(&mut self) -> Result<Expr, String> {
        if self.match_token(TokenKind::False) { return Ok(Expr::Bool(false)); }
        if self.match_token(TokenKind::True) { return Ok(Expr::Bool(true)); }
        if self.match_token(TokenKind::Undefined) { return Ok(Expr::Undefined); }
        if self.match_token(TokenKind::Global) { return Ok(Expr::GlobalRef); }
        if self.match_token(TokenKind::This) { return Ok(Expr::This); }
        if self.match_token(TokenKind::Super) { return Ok(Expr::Super); }

        match self.peek().kind.clone() {
            TokenKind::Number(v) => { self.advance(); Ok(Expr::Number(v)) },
            TokenKind::Str(v) => { self.advance(); Ok(Expr::Str(v)) },
            TokenKind::Ident(v) => { self.advance(); Ok(Expr::Ident(v)) },
            TokenKind::Regex { pattern, flags } => { self.advance(); Ok(Expr::Regex { pattern, flags }) },
            TokenKind::Lparen => {
                self.advance();
                let expr = self.parse_expression()?;
                self.consume(TokenKind::Rparen, "Expected ')' after expression.")?;
                Ok(expr)
            },
            TokenKind::Lbracket => {
                self.advance();
                let mut elements = Vec::new();
                if !self.check(TokenKind::Rbracket) {
                    loop {
                        elements.push(self.parse_expression()?);
                        if !self.match_token(TokenKind::Comma) { break; }
                    }
                }
                self.consume(TokenKind::Rbracket, "Expected ']' after array.")?;
                Ok(Expr::Array(elements))
            },
            TokenKind::Lbrace => {
                self.advance();
                let mut pairs = Vec::new();
                if !self.check(TokenKind::Rbrace) {
                    loop {
                        let key = self.consume(TokenKind::Ident(String::new()), "Expected key.")?.lexeme.clone();
                        self.consume(TokenKind::Colon, "Expected ':' after key.")?;
                        let value = self.parse_expression()?;
                        pairs.push((key, value));
                        if !self.match_token(TokenKind::Comma) { break; }
                    }
                }
                self.consume(TokenKind::Rbrace, "Expected '}' after object.")?;
                Ok(Expr::Object(pairs))
            },
            _ => Err(format!("Unexpected token: {:?}", self.peek().kind)),
        }
    }
}
