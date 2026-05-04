/// Proglang AST — ported from ProgAST.gml

#[derive(Debug, Clone, PartialEq)]
pub enum BinOp
{
    Add, Sub, Mul, Div, Mod, Pow,
    Eq, Ne, Lt, Gt, Le, Ge,
    And, Or,
    BitAnd, BitOr, BitXor, Shl, Shr,
    NullCoalesce,
    StringConcat,
}

#[derive(Debug, Clone, PartialEq)]
pub enum UnOp
{
    Neg, Not, BitNot, Spread,
}

#[derive(Debug, Clone, PartialEq)]
pub enum AssignOp
{
    Assign,
    AddAssign, SubAssign, MulAssign, DivAssign, ModAssign, PowAssign,
    ShlAssign, ShrAssign, AndAssign, OrAssign, XorAssign,
}

#[derive(Debug, Clone, PartialEq)]
pub enum PrefixOp { Inc, Dec }

#[derive(Debug, Clone, PartialEq)]
pub enum PostfixOp { Inc, Dec }

#[derive(Debug, Clone, PartialEq)]
pub enum AccessModifier { Public, Private, Protected }

#[derive(Debug, Clone)]
pub struct Param
{
    pub name: String,
    pub default_value: Option<Box<Expr>>,
}

#[derive(Debug, Clone)]
pub struct SwitchCase
{
    pub value: Box<Expr>,
    pub body: Vec<Stmt>,
}

#[derive(Debug, Clone)]
pub struct ImportItem
{
    pub name: String,
    pub alias: String,
}

#[derive(Debug, Clone)]
pub struct Annotations
{
    pub is_inline: bool,
    pub is_memoize: bool,
}

impl Default for Annotations
{
    fn default() -> Self
    {
        Self { is_inline: false, is_memoize: false }
    }
}

#[derive(Debug, Clone)]
pub struct ClassMember
{
    pub is_method: bool,
    pub node: Box<Stmt>,
    pub access: AccessModifier,
    pub is_static: bool,
    pub is_abstract: bool,
}

/// Destructuring pattern (object or array).
#[derive(Debug, Clone)]
pub enum DestructPat
{
    Object(Vec<ObjField>),
    Array(Vec<ArrayElem>),
}

#[derive(Debug, Clone)]
pub struct ObjField
{
    pub key: String,
    pub target: DestructTarget,
}

#[derive(Debug, Clone)]
pub enum DestructTarget
{
    Name(String),
    Nested(Box<DestructPat>),
}

#[derive(Debug, Clone)]
pub enum ArrayElem
{
    Name(String),
    Nested(Box<DestructPat>),
}

// ─────────────────────────── Expr ───────────────────────────

#[derive(Debug, Clone)]
pub enum Expr
{
    Number(f64),
    Str(String),
    Bool(bool),
    Undefined,
    Regex { pattern: String, flags: String },

    Ident(String),
    Array(Vec<Expr>),
    Object(Vec<(String, Expr)>),

    Binary { op: BinOp, left: Box<Expr>, right: Box<Expr> },
    Unary  { op: UnOp,  right: Box<Expr> },
    Ternary { condition: Box<Expr>, then: Box<Expr>, else_: Box<Expr> },

    Call   { callee: Box<Expr>, args: Vec<Expr> },
    Index  { target: Box<Expr>, index: Box<Expr> },
    Member { target: Box<Expr>, property: String },
    OptMember { target: Box<Expr>, property: String },
    OptIndex  { target: Box<Expr>, index: Box<Expr> },

    Assign  { target: Box<Expr>, value: Box<Expr>, op: AssignOp },
    Prefix  { op: PrefixOp,  target: Box<Expr> },
    Postfix { op: PostfixOp, target: Box<Expr> },

    New { class_name: String, args: Vec<Expr> },
    This,
    Super,

    In    { left: Box<Expr>, right: Box<Expr>, modifier: Option<String> },
    Range { start: Box<Expr>, end: Box<Expr> },

    FuncExpr { name: Option<String>, params: Vec<Param>, body: Box<Stmt> },

    GlobalRef,
}

// ─────────────────────────── Stmt ───────────────────────────

#[derive(Debug, Clone)]
pub enum Stmt
{
    Expr(Box<Expr>),
    Block(Vec<Stmt>),
    Empty,

    VarDecl
    {
        name: String,
        initializer: Option<Box<Expr>>,
        is_global: bool,
    },
    Destruct
    {
        pattern: DestructPat,
        initializer: Box<Expr>,
    },

    If
    {
        condition: Box<Expr>,
        then: Box<Stmt>,
        else_: Option<Box<Stmt>>,
    },
    While
    {
        condition: Box<Expr>,
        body: Box<Stmt>,
    },
    For
    {
        init: Option<Box<Stmt>>,
        condition: Option<Box<Expr>>,
        increment: Option<Box<Expr>>,
        body: Box<Stmt>,
    },
    ForIn
    {
        var: String,
        value_var: Option<String>,
        collection: Box<Expr>,
        body: Box<Stmt>,
        modifier: Option<String>,
    },
    Repeat
    {
        count: Box<Expr>,
        body: Box<Stmt>,
    },

    Break(Option<Box<Expr>>),
    Continue,
    Return(Option<Box<Expr>>),
    Throw(Box<Expr>),

    Switch
    {
        expr: Box<Expr>,
        cases: Vec<SwitchCase>,
        default: Option<Vec<Stmt>>,
    },
    Try
    {
        try_block: Box<Stmt>,
        catch_var: String,
        catch_block: Box<Stmt>,
    },

    FuncDecl
    {
        name: String,
        params: Vec<Param>,
        body: Box<Stmt>,
        is_global: bool,
        annotations: Annotations,
    },
    ClassDecl
    {
        name: String,
        super_class: Option<String>,
        members: Vec<ClassMember>,
        constructor: Option<Box<Stmt>>,
        is_abstract: bool,
    },

    Import { items: Vec<ImportItem>, path: String },
    Export { decl: Box<Stmt>, is_default: bool },
}
