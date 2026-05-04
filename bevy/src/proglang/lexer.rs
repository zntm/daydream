/// Proglang Lexer — ported from ProgLexer.gml

use std::collections::HashMap;

// ─────────────────────────── Token ───────────────────────────

#[derive(Debug, Clone, PartialEq)]
pub enum TokenKind
{
    Number(f64), Str(String),
    Regex { pattern: String, flags: String },
    True, False, Undefined,
    Ident(String),
    Var, Global, If, Else, For, In, While, Repeat,
    Break, Continue, Return, Try, Catch, Throw,
    And, Or, Not, Switch, Case, Default, Fn,
    Import, Export, From, As,
    Class, New, This, Extends, Super, Static,
    Public, Private, Protected, Abstract, Interface, Implements,
    Plus, Minus, Star, Slash, Percent, Power,
    PlusPlus, MinusMinus,
    EqEq, BangEq, Lt, Gt, Le, Ge,
    Amp, Pipe, Caret, Tilde, Lshift, Rshift,
    Eq, PlusEq, MinusEq, StarEq, SlashEq, PercentEq, PowerEq,
    LshiftEq, RshiftEq, AmpEq, PipeEq, CaretEq,
    NullCoalesce, Spread, DotDot, QuestionDot, Arrow,
    Lparen, Rparen, Lbrace, Rbrace, Lbracket, Rbracket,
    Comma, Dot, Semi, Colon, Question,
    AtInline, AtMemoize,
    Eof,
}

#[derive(Debug, Clone)]
pub struct Token
{
    pub kind: TokenKind,
    pub lexeme: String,
    pub line: u32,
}

impl Token
{
    fn new(kind: TokenKind, lexeme: impl Into<String>, line: u32) -> Self
    {
        Self { kind, lexeme: lexeme.into(), line }
    }
}

// ─────────────────────────── Lexer ───────────────────────────

pub struct Lexer
{
    source: Vec<char>,
    start: usize,
    current: usize,
    line: u32,
    tokens: Vec<Token>,
    had_error: bool,
    error: String,
    interp_stack: Vec<i32>,
}

fn keywords() -> HashMap<&'static str, TokenKind>
{
    use TokenKind::*;
    let mut m: HashMap<&'static str, TokenKind> = HashMap::new();
    for (k, v) in [
        ("var",Var),("global",Global),("if",If),("else",Else),("for",For),
        ("in",In),("while",While),("repeat",Repeat),("break",Break),
        ("continue",Continue),("return",Return),("true",True),("false",False),
        ("undefined",Undefined),("try",Try),("catch",Catch),("throw",Throw),
        ("and",And),("or",Or),("not",Not),("switch",Switch),("case",Case),
        ("default",Default),("fn",Fn),("import",Import),("export",Export),
        ("from",From),("as",As),("class",Class),("new",New),("this",This),
        ("extends",Extends),("super",Super),("static",Static),("public",Public),
        ("private",Private),("protected",Protected),("abstract",Abstract),
        ("interface",Interface),("implements",Implements),
    ] { m.insert(k, v); }
    m
}

impl Lexer
{
    pub fn new(source: &str) -> Self
    {
        Self
        {
            source: source.chars().collect(),
            start: 0, current: 0, line: 1,
            tokens: Vec::new(),
            had_error: false, error: String::new(),
            interp_stack: Vec::new(),
        }
    }

    pub fn had_error(&self) -> bool { self.had_error }
    pub fn error(&self)     -> &str { &self.error }

    pub fn tokenize(&mut self) -> Vec<Token>
    {
        self.tokens.clear();
        self.start = 0; self.current = 0; self.line = 1;
        self.had_error = false; self.interp_stack.clear();

        while !self.is_at_end()
        {
            self.start = self.current;
            if self.interp_stack.last() == Some(&-1)
            {
                self.scan_interpolation();
                continue;
            }
            self.scan_token();
        }

        self.push(TokenKind::Eof, "");
        std::mem::take(&mut self.tokens)
    }

    fn is_at_end(&self) -> bool { self.current >= self.source.len() }
    fn advance(&mut self) -> char { let c = self.source[self.current]; self.current += 1; c }
    fn peek(&self) -> char { if self.is_at_end() { '\0' } else { self.source[self.current] } }
    fn peek_next(&self) -> char { self.source.get(self.current + 1).copied().unwrap_or('\0') }

    fn match_char(&mut self, e: char) -> bool
    {
        if self.is_at_end() || self.source[self.current] != e { return false; }
        self.current += 1; true
    }

    fn lexeme(&self) -> String { self.source[self.start..self.current].iter().collect() }
    fn push(&mut self, kind: TokenKind, lex: &str) { self.tokens.push(Token::new(kind, lex, self.line)); }
    fn add_token(&mut self, kind: TokenKind) { let l = self.lexeme(); self.push(kind, &l); }
    fn error_at(&mut self, msg: impl Into<String>) { if self.had_error { return; } self.had_error = true; self.error = msg.into(); }

    fn scan_token(&mut self)
    {
        let c = self.advance();
        match c
        {
            '(' => self.add_token(TokenKind::Lparen),
            ')' => self.add_token(TokenKind::Rparen),
            '[' => self.add_token(TokenKind::Lbracket),
            ']' => self.add_token(TokenKind::Rbracket),
            ',' => self.add_token(TokenKind::Comma),
            ';' => self.add_token(TokenKind::Semi),
            ':' => self.add_token(TokenKind::Colon),
            '~' => self.add_token(TokenKind::Tilde),
            '{' =>
            {
                if let Some(d) = self.interp_stack.last_mut() { *d += 1; }
                self.add_token(TokenKind::Lbrace);
            }
            '}' =>
            {
                let mut is_interp_end = false;
                if let Some(&d) = self.interp_stack.last()
                {
                    if d == 0 { is_interp_end = true; }
                }

                if is_interp_end
                {
                    *self.interp_stack.last_mut().unwrap() = -1;
                    self.push(TokenKind::Rparen, ")");
                    self.push(TokenKind::Plus,   "+");

                    return;
                }

                if let Some(d) = self.interp_stack.last_mut() { *d -= 1; }
                self.add_token(TokenKind::Rbrace);
            }
            '.' =>
            {
                if self.match_char('.')
                {
                    let k = if self.match_char('.') { TokenKind::Spread } else { TokenKind::DotDot };
                    self.add_token(k);
                }
                else { self.add_token(TokenKind::Dot); }
            }
            '+' =>
            {
                let k = if self.match_char('+') { TokenKind::PlusPlus }
                        else if self.match_char('=') { TokenKind::PlusEq }
                        else { TokenKind::Plus };
                self.add_token(k);
            }
            '-' =>
            {
                if self.match_char('>')      { self.add_token(TokenKind::Arrow); }
                else if self.match_char('-') { self.add_token(TokenKind::MinusMinus); }
                else if self.match_char('=') { self.add_token(TokenKind::MinusEq); }
                else                         { self.add_token(TokenKind::Minus); }
            }
            '*' =>
            {
                if self.match_char('*')
                {
                    let k = if self.match_char('=') { TokenKind::PowerEq } else { TokenKind::Power };
                    self.add_token(k);
                }
                else
                {
                    let k = if self.match_char('=') { TokenKind::StarEq } else { TokenKind::Star };
                    self.add_token(k);
                }
            }
            '%' => { let k = if self.match_char('=') { TokenKind::PercentEq } else { TokenKind::Percent }; self.add_token(k); }
            '!' => { let k = if self.match_char('=') { TokenKind::BangEq } else { TokenKind::Not }; self.add_token(k); }
            '=' => { let k = if self.match_char('=') { TokenKind::EqEq } else { TokenKind::Eq }; self.add_token(k); }
            '<' =>
            {
                if self.match_char('<') { let k = if self.match_char('=') { TokenKind::LshiftEq } else { TokenKind::Lshift }; self.add_token(k); }
                else { let k = if self.match_char('=') { TokenKind::Le } else { TokenKind::Lt }; self.add_token(k); }
            }
            '>' =>
            {
                if self.match_char('>') { let k = if self.match_char('=') { TokenKind::RshiftEq } else { TokenKind::Rshift }; self.add_token(k); }
                else { let k = if self.match_char('=') { TokenKind::Ge } else { TokenKind::Gt }; self.add_token(k); }
            }
            '&' => { let k = if self.match_char('&') { TokenKind::And } else if self.match_char('=') { TokenKind::AmpEq } else { TokenKind::Amp }; self.add_token(k); }
            '|' => { let k = if self.match_char('|') { TokenKind::Or } else if self.match_char('=') { TokenKind::PipeEq } else { TokenKind::Pipe }; self.add_token(k); }
            '^' => { let k = if self.match_char('=') { TokenKind::CaretEq } else { TokenKind::Caret }; self.add_token(k); }
            '?' =>
            {
                if self.match_char('?')      { self.add_token(TokenKind::NullCoalesce); }
                else if self.match_char('.') { self.add_token(TokenKind::QuestionDot); }
                else                         { self.add_token(TokenKind::Question); }
            }
            '/' =>
            {
                if self.match_char('/')
                {
                    while self.peek() != '\n' && !self.is_at_end() { self.advance(); }
                }
                else if self.match_char('*')
                {
                    while !self.is_at_end()
                    {
                        if self.peek() == '*' && self.peek_next() == '/' { self.advance(); self.advance(); break; }
                        if self.peek() == '\n' { self.line += 1; }
                        self.advance();
                    }
                }
                else
                {
                    let is_regex = self.last_is_regex_ctx();
                    if self.match_char('=')        { self.add_token(TokenKind::SlashEq); }
                    else if is_regex               { self.scan_regex(); }
                    else                           { self.add_token(TokenKind::Slash); }
                }
            }
            '"' => self.scan_string(),
            '$' =>
            {
                if self.match_char('"') { self.start_interpolation(); }
                else if self.peek().is_ascii_hexdigit() { self.scan_gml_hex(); }
                else { self.error_at(format!("Unexpected '$' at line {}", self.line)); }
            }
            '#' => self.scan_hex_color(),
            '@' => self.scan_annotation(),
            ' ' | '\r' | '\t' => {}
            '\n' => { self.line += 1; }
            c if c.is_ascii_digit() => self.scan_number(),
            c if c.is_alphabetic() || c == '_' => self.scan_identifier(),
            _ => self.error_at(format!("Unexpected '{}' at line {}", c, self.line)),
        }
    }

    fn scan_string(&mut self)
    {
        let mut result = String::new();
        loop
        {
            if self.is_at_end() { self.error_at(format!("Unterminated string at line {}", self.line)); return; }
            let c = self.peek();
            if c == '"' { self.advance(); break; }
            if c == '\n' { self.line += 1; }
            if c == '\\'
            {
                self.advance();
                if self.is_at_end() { break; }
                result.push(match self.advance()
                {
                    'n' => '\n', 'r' => '\r', 't' => '\t',
                    'b' => '\x08', 'f' => '\x0C',
                    '\\' => '\\', '"' => '"', c => c,
                });
            }
            else { result.push(self.advance()); }
        }
        let l = self.lexeme();
        let ln = self.line;
        self.tokens.push(Token::new(TokenKind::Str(result), l, ln));
    }

    fn start_interpolation(&mut self)
    {
        self.push(TokenKind::Lparen, "(");
        self.interp_stack.push(-1);
        self.start = self.current;
        self.scan_interpolation();
    }

    fn scan_interpolation(&mut self)
    {
        let mut result = String::new();
        self.start = self.current;
        loop
        {
            if self.is_at_end() { self.error_at(format!("Unterminated interpolated string at line {}", self.line)); return; }
            let c = self.peek();
            if c == '"' || c == '{' { break; }
            if c == '\n' { self.line += 1; }
            if c == '\\'
            {
                self.advance();
                if self.is_at_end() { break; }
                result.push(match self.advance() { 'n'=>'\n','r'=>'\r','t'=>'\t','{'=>'{','}'=>'}','\\'=>'\\','"'=>'"',c=>c });
            }
            else { result.push(self.advance()); }
        }
        let l = self.lexeme();
        self.tokens.push(Token::new(TokenKind::Str(result), l, self.line));
        let next = self.peek();
        if next == '"'
        {
            self.advance();
            self.push(TokenKind::Rparen, ")");
            self.interp_stack.pop();
        }
        else if next == '{'
        {
            self.advance();
            self.push(TokenKind::Plus,                         "+");
            self.push(TokenKind::Ident("string".to_owned()),  "string");
            self.push(TokenKind::Lparen,                       "(");
            *self.interp_stack.last_mut().unwrap() = 0;
        }
    }

    fn scan_number(&mut self)
    {
        if self.source.get(self.start) == Some(&'0') && self.peek().to_ascii_lowercase() == 'x'
        {
            self.advance();
            while self.peek().is_ascii_hexdigit() { self.advance(); }
            let hex: String = self.source[self.start + 2..self.current].iter().collect();
            let v = i64::from_str_radix(&hex, 16).unwrap_or(0) as f64;
            let l = self.lexeme(); let ln = self.line;
            self.tokens.push(Token::new(TokenKind::Number(v), l, ln));
            return;
        }
        while self.peek().is_ascii_digit() || self.peek() == '_' { self.advance(); }
        if self.peek() == '.' && self.peek_next().is_ascii_digit()
        {
            self.advance();
            while self.peek().is_ascii_digit() || self.peek() == '_' { self.advance(); }
        }
        let raw: String = self.source[self.start..self.current].iter().filter(|&&c| c != '_').collect();
        let v: f64 = raw.parse().unwrap_or(0.0);
        let l = self.lexeme(); let ln = self.line;
        self.tokens.push(Token::new(TokenKind::Number(v), l, ln));
    }

    fn scan_gml_hex(&mut self)
    {
        while self.peek().is_ascii_hexdigit() { self.advance(); }
        let hex: String = self.source[self.start + 1..self.current].iter().collect();
        let v = i64::from_str_radix(&hex, 16).unwrap_or(0) as f64;
        let l = self.lexeme(); let ln = self.line;
        self.tokens.push(Token::new(TokenKind::Number(v), l, ln));
    }

    fn scan_hex_color(&mut self)
    {
        let hs = self.current;
        while self.peek().is_ascii_hexdigit() { self.advance(); }
        let hex: String = self.source[hs..self.current].iter().collect();
        let v = Self::parse_color(&hex);
        let l = self.lexeme(); let ln = self.line;
        self.tokens.push(Token::new(TokenKind::Number(v), l, ln));
    }

    fn parse_color(hex: &str) -> f64
    {
        fn byte(h: &str, pos: usize) -> u8
        {
            u8::from_str_radix(&h[pos..pos + 2], 16).unwrap_or(0)
        }
        fn nibble(h: &str, pos: usize) -> u8
        {
            let v = u8::from_str_radix(&h[pos..pos + 1], 16).unwrap_or(0);
            v | (v << 4)
        }
        match hex.len()
        {
            3 => ((nibble(hex, 0) as u32) | ((nibble(hex, 1) as u32) << 8) | ((nibble(hex, 2) as u32) << 16)) as f64,
            6 | 8 => ((byte(hex, 0) as u32) | ((byte(hex, 2) as u32) << 8) | ((byte(hex, 4) as u32) << 16)) as f64,
            _ => 0.0,
        }
    }

    fn last_is_regex_ctx(&self) -> bool
    {
        use TokenKind::*;
        match self.tokens.last().map(|t| &t.kind)
        {
            None => true,
            Some(k) => matches!(k,
                Lparen|Comma|Eq|Colon|Semi|Lbrace|Lbracket|Return|Throw|Case
                |Plus|Minus|Star|Slash|Percent|Power|And|Or|Not
                |Amp|Pipe|Caret|EqEq|BangEq|Lt|Gt|Le|Ge|Question|NullCoalesce
            ),
        }
    }

    fn scan_regex(&mut self)
    {
        while !self.is_at_end()
        {
            let c = self.peek();
            if c == '\n' { self.error_at(format!("Unterminated regex at line {}", self.line)); return; }
            if c == '/' && self.current > self.start + 1 && self.source[self.current - 1] != '\\'
            {
                self.advance(); break;
            }
            self.advance();
        }
        let pattern: String = self.source[self.start + 1..self.current - 1].iter().collect();
        let mut flags = String::new();
        while self.peek().is_alphabetic() { flags.push(self.advance()); }
        let l = self.lexeme(); let ln = self.line;
        self.tokens.push(Token::new(TokenKind::Regex { pattern, flags }, l, ln));
    }

    fn scan_annotation(&mut self)
    {
        while self.peek().is_alphanumeric() || self.peek() == '_' { self.advance(); }
        let text = self.lexeme();
        let kind = match text.as_str()
        {
            "@inline"  => TokenKind::AtInline,
            "@memoize" => TokenKind::AtMemoize,
            _ => { self.error_at(format!("Unknown annotation '{}' at line {}", text, self.line)); return; }
        };
        self.tokens.push(Token::new(kind, text, self.line));
    }

    fn scan_identifier(&mut self)
    {
        while self.peek().is_alphanumeric() || self.peek() == '_' { self.advance(); }
        let text = self.lexeme();
        let kws = keywords();
        let kind = kws.get(text.as_str()).cloned().unwrap_or_else(|| TokenKind::Ident(text.clone()));
        self.tokens.push(Token::new(kind, text, self.line));
    }
}
