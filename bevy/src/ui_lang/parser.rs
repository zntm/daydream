use crate::ui_lang::ast::*;
use crate::ui_lang::lexer::{UiToken, UiTokenKind};

pub struct Parser {
    tokens: Vec<UiToken>,
    current: usize,
}

impl Parser {
    pub fn new(tokens: Vec<UiToken>) -> Self {
        Self { tokens, current: 0 }
    }

    pub fn parse(&mut self) -> Result<UiDocument, String> {
        let mut definitions = Vec::new();
        while !self.is_at_end() {
            definitions.push(self.parse_definition()?);
        }
        Ok(UiDocument { definitions })
    }

    fn is_at_end(&self) -> bool { self.peek().kind == UiTokenKind::Eof }
    fn peek(&self) -> &UiToken { &self.tokens[self.current] }
    fn previous(&self) -> &UiToken { &self.tokens[self.current - 1] }
    fn advance(&mut self) -> &UiToken { if !self.is_at_end() { self.current += 1; } self.previous() }
    fn check(&self, kind: UiTokenKind) -> bool {
        if self.is_at_end() { false } else {
            std::mem::discriminant(&self.peek().kind) == std::mem::discriminant(&kind)
        }
    }
    fn match_token(&mut self, kind: UiTokenKind) -> bool { if self.check(kind) { self.advance(); true } else { false } }
    fn consume(&mut self, kind: UiTokenKind, msg: &str) -> Result<&UiToken, String> {
        if self.check(kind) { Ok(self.advance()) } else { Err(msg.to_string()) }
    }

    fn parse_definition(&mut self) -> Result<UiDef, String> {
        if self.match_token(UiTokenKind::Var) {
            let name = self.consume(UiTokenKind::Ident(String::new()), "Expected variable name.")?.lexeme.clone();
            self.consume(UiTokenKind::Eq, "Expected '=' after variable name.")?;
            let value = self.parse_value()?;
            return Ok(UiDef::VarDecl { name, value });
        }
        if self.match_token(UiTokenKind::Export) {
            if self.match_token(UiTokenKind::Var) {
                let name = self.consume(UiTokenKind::Ident(String::new()), "Expected variable name.")?.lexeme.clone();
                self.consume(UiTokenKind::Eq, "Expected '=' after variable name.")?;
                let value = self.parse_value()?;
                return Ok(UiDef::ExportVar { name, value });
            }
            return Ok(UiDef::ExportElement(self.parse_element()?));
        }
        Ok(UiDef::Element(self.parse_element()?))
    }

    fn parse_element(&mut self) -> Result<UiElement, String> {
        self.consume(UiTokenKind::At, "Expected '@' before element type.")?;
        let element_type = self.consume(UiTokenKind::Ident(String::new()), "Expected element type.")?.lexeme.clone();
        let name = if self.match_token(UiTokenKind::Lparen) {
            let n = self.consume(UiTokenKind::Ident(String::new()), "Expected element name.")?.lexeme.clone();
            self.consume(UiTokenKind::Rparen, "Expected ')' after name.")?;
            n
        } else { "".to_string() };

        self.consume(UiTokenKind::Lbrace, "Expected '{' before element body.")?;
        let mut properties = Vec::new();
        let mut children = Vec::new();
        let mut repeat_count = None;
        let mut repeat_var = None;

        while !self.check(UiTokenKind::Rbrace) && !self.is_at_end() {
            if self.match_token(UiTokenKind::Repeat) {
                self.consume(UiTokenKind::Lparen, "Expected '(' after repeat.")?;
                repeat_count = Some(self.parse_value()?);
                if self.match_token(UiTokenKind::Comma) {
                    repeat_var = Some(self.consume(UiTokenKind::Ident(String::new()), "Expected repeat variable name.")?.lexeme.clone());
                }
                self.consume(UiTokenKind::Rparen, "Expected ')' after repeat args.")?;
                children.push(self.parse_element()?);
            } else if self.check(UiTokenKind::At) {
                children.push(self.parse_element()?);
            } else {
                let key = self.consume(UiTokenKind::Ident(String::new()), "Expected property key.")?.lexeme.clone();
                self.consume(UiTokenKind::Eq, "Expected '=' after property key.")?;
                let value = self.parse_value()?;
                properties.push(UiProperty { key, value });
            }
        }
        self.consume(UiTokenKind::Rbrace, "Expected '}' after element body.")?;

        Ok(UiElement { element_type, name, properties, children, repeat_count, repeat_var })
    }

    fn parse_value(&mut self) -> Result<UiValue, String> {
        if self.match_token(UiTokenKind::Star) {
            let name = self.consume(UiTokenKind::Ident(String::new()), "Expected binding name.")?.lexeme.clone();
            if self.match_token(UiTokenKind::Lbracket) {
                let index = self.parse_value()?;
                self.consume(UiTokenKind::Rbracket, "Expected ']' after index.")?;
                return Ok(UiValue::ArrayIndex(name, Box::new(index)));
            }
            return Ok(UiValue::Binding(name));
        }
        if self.match_token(UiTokenKind::Dollar) {
            let key = self.consume(UiTokenKind::Str(String::new()), "Expected localization key.")?.lexeme.clone();
            return Ok(UiValue::LocaKey(key));
        }
        if self.match_token(UiTokenKind::At) {
            let path = self.consume(UiTokenKind::Str(String::new()), "Expected script path.")?.lexeme.clone();
            return Ok(UiValue::ScriptRef(path));
        }
        match self.advance().kind.clone() {
            UiTokenKind::Number(n) => Ok(UiValue::Number(n)),
            UiTokenKind::Percentage(p) => Ok(UiValue::Percentage(p)),
            UiTokenKind::Color(c) => {
                let r = ((c >> 16) & 0xFF) as u8;
                let g = ((c >> 8) & 0xFF) as u8;
                let b = (c & 0xFF) as u8;
                Ok(UiValue::Color(UiColor { r, g, b, a: 1.0 }))
            },
            UiTokenKind::Str(s) => Ok(UiValue::Str(s)),
            UiTokenKind::Ident(s) => Ok(UiValue::Identifier(s)),
            _ => Err("Invalid value.".to_string()),
        }
    }
}
