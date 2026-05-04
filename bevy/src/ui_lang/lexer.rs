/// UI Language Lexer — ported from UILexer.gml

#[derive(Debug, Clone, PartialEq)]
pub enum UiTokenKind {
    At, Lparen, Rparen, Lbrace, Rbrace, Lbracket, Rbracket, Eq, Comma, Star, Dollar, Hash,
    Plus, Minus, Slash, Percent, Power,
    Number(f64), Percentage(f64), Color(u32), Str(String), Ident(String),
    Var, Export, Repeat, Floor,
    Vertical, Horizontal, Grid, None,
    Eof,
}

#[derive(Debug, Clone)]
pub struct UiToken {
    pub kind: UiTokenKind,
    pub lexeme: String,
    pub line: u32,
}

pub struct Lexer {
    source: Vec<char>,
    start: usize,
    current: usize,
    line: u32,
}

impl Lexer {
    pub fn new(source: &str) -> Self {
        Self {
            source: source.chars().collect(),
            start: 0,
            current: 0,
            line: 1,
        }
    }

    pub fn tokenize(&mut self) -> Vec<UiToken> {
        let mut tokens = Vec::new();
        while !self.is_at_end() {
            self.start = self.current;
            if let Some(token) = self.scan_token() {
                tokens.push(token);
            }
        }
        tokens.push(UiToken { kind: UiTokenKind::Eof, lexeme: "".to_string(), line: self.line });
        tokens
    }

    fn is_at_end(&self) -> bool { self.current >= self.source.len() }

    fn advance(&mut self) -> char {
        let c = self.source[self.current];
        self.current += 1;
        c
    }

    fn peek(&self) -> char { if self.is_at_end() { '\0' } else { self.source[self.current] } }

    fn match_char(&mut self, expected: char) -> bool {
        if self.is_at_end() || self.source[self.current] != expected { return false; }
        self.current += 1;
        true
    }

    fn scan_token(&mut self) -> Option<UiToken> {
        let c = self.advance();
        match c {
            '@' => Some(self.make_token(UiTokenKind::At)),
            '(' => Some(self.make_token(UiTokenKind::Lparen)),
            ')' => Some(self.make_token(UiTokenKind::Rparen)),
            '{' => Some(self.make_token(UiTokenKind::Lbrace)),
            '}' => Some(self.make_token(UiTokenKind::Rbrace)),
            '[' => Some(self.make_token(UiTokenKind::Lbracket)),
            ']' => Some(self.make_token(UiTokenKind::Rbracket)),
            '=' => Some(self.make_token(UiTokenKind::Eq)),
            ',' => Some(self.make_token(UiTokenKind::Comma)),
            '*' => Some(self.make_token(UiTokenKind::Star)),
            '$' => Some(self.make_token(UiTokenKind::Dollar)),
            '#' => Some(self.scan_color()),
            '+' => Some(self.make_token(UiTokenKind::Plus)),
            '-' => Some(self.make_token(UiTokenKind::Minus)),
            '/' => Some(self.make_token(UiTokenKind::Slash)),
            '%' => Some(self.make_token(UiTokenKind::Percent)),
            ' ' | '\r' | '\t' => None,
            '\n' => { self.line += 1; None },
            '"' => Some(self.scan_string()),
            c if c.is_ascii_digit() => Some(self.scan_number()),
            c if c.is_alphabetic() || c == '_' => Some(self.scan_identifier()),
            _ => None,
        }
    }

    fn make_token(&self, kind: UiTokenKind) -> UiToken {
        UiToken {
            kind,
            lexeme: self.source[self.start..self.current].iter().collect(),
            line: self.line,
        }
    }

    fn scan_string(&mut self) -> UiToken {
        while self.peek() != '"' && !self.is_at_end() {
            if self.peek() == '\n' { self.line += 1; }
            self.advance();
        }
        self.advance(); // consume closing quote
        let val: String = self.source[self.start + 1..self.current - 1].iter().collect();
        self.make_token(UiTokenKind::Str(val))
    }

    fn scan_number(&mut self) -> UiToken {
        while self.peek().is_ascii_digit() { self.advance(); }
        if self.peek() == '.' {
            self.advance();
            while self.peek().is_ascii_digit() { self.advance(); }
        }
        if self.peek() == '%' {
            self.advance();
            let val: f64 = self.source[self.start..self.current - 1].iter().collect::<String>().parse().unwrap_or(0.0);
            return self.make_token(UiTokenKind::Percentage(val));
        }
        let val: f64 = self.source[self.start..self.current].iter().collect::<String>().parse().unwrap_or(0.0);
        self.make_token(UiTokenKind::Number(val))
    }

    fn scan_identifier(&mut self) -> UiToken {
        while self.peek().is_alphanumeric() || self.peek() == '_' { self.advance(); }
        let text: String = self.source[self.start..self.current].iter().collect();
        let kind = match text.as_str() {
            "var" => UiTokenKind::Var,
            "export" => UiTokenKind::Export,
            "repeat" => UiTokenKind::Repeat,
            "floor" => UiTokenKind::Floor,
            "LAYOUT_VERTICAL" => UiTokenKind::Vertical,
            "LAYOUT_HORIZONTAL" => UiTokenKind::Horizontal,
            "LAYOUT_GRID" => UiTokenKind::Grid,
            "LAYOUT_NONE" => UiTokenKind::None,
            _ => UiTokenKind::Ident(text),
        };
        self.make_token(kind)
    }

    fn scan_color(&mut self) -> UiToken {
        while self.peek().is_ascii_hexdigit() { self.advance(); }
        let hex: String = self.source[self.start + 1..self.current].iter().collect();
        let val = u32::from_str_radix(&hex, 16).unwrap_or(0);
        self.make_token(UiTokenKind::Color(val))
    }
}
