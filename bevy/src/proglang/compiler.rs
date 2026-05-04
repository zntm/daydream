use crate::proglang::ast::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OpCode {
    PushNull, PushTrue, PushFalse, PushConst, PushGlobalRef,
    Pop, Dup, Dup2, PopAndKeep,
    Add, Sub, Mul, Div, Mod, Pow, Neg,
    Eq, Ne, Lt, Gt, Le, Ge,
    Not, And, Or, BitAnd, BitOr, BitXor, BitNot, Shl, Shr,
    Load, Store, Define, LoadGlobal, StoreGlobal,
    IndexGet, IndexSet, MemberGet, MemberSet,
    ArrayNew, ObjectNew, MakeRegex,
    Jump, JumpIfFalse, JumpIfTrue, JumpIfNull, JumpIfNotNull, BreakN,
    Call, Return, CallSpread, MakeClosure,
    IterInit, IterNext, IterGetVal,
    PushTry, PopTry, Throw,
    PushArrayEmpty, ArrayPush, ArraySpread,
    Import, ImportUi, ExportSet,
    Inc, Dec,
    ClassDef, NewInstance, LoadThis, LoadSuper, AccessCheck,
    PushScope, PopScope,
    DebugLine,
    InCheck, InKey, InValue, MakeRange,
    StringConcat,
    LoadLocal, StoreLocal, IncLocal, DecLocal, AddConst,
    MemoizeCheck, MemoizeStore,
}

#[derive(Debug, Clone)]
pub enum Constant {
    Number(f64),
    Str(String),
    Bool(bool),
    Undefined,
    Bytecode(Box<Bytecode>),
    Function(Box<FunctionData>),
    Regex { pattern: String, flags: String },
}

#[derive(Debug, Clone, Default)]
pub struct Bytecode {
    pub ops: Vec<(OpCode, Option<usize>)>,
    pub constants: Vec<Constant>,
    pub lines: Vec<u32>,
    pub param_count: usize,
    pub is_constructor: bool,
}

#[derive(Debug, Clone)]
pub struct FunctionData {
    pub name: String,
    pub bytecode: Bytecode,
    pub is_global: bool,
    pub param_count: usize,
    pub is_inline: bool,
}

pub struct Compiler {
    bytecode: Bytecode,
    had_error: bool,
    error: String,
}

impl Compiler {
    pub fn new() -> Self {
        Self {
            bytecode: Bytecode::default(),
            had_error: false,
            error: String::new(),
        }
    }

    pub fn compile(mut self, stmt: &Stmt) -> Result<Bytecode, String> {
        self.compile_stmt(stmt);
        self.emit(OpCode::PushNull, None, 0);
        self.emit(OpCode::Return, None, 0);
        if self.had_error { Err(self.error) } else { Ok(self.bytecode) }
    }

    fn emit(&mut self, op: OpCode, arg: Option<usize>, line: u32) -> usize {
        let pos = self.bytecode.ops.len();
        self.bytecode.ops.push((op, arg));
        self.bytecode.lines.push(line);
        pos
    }

    fn add_constant(&mut self, constant: Constant) -> usize {
        let pos = self.bytecode.constants.len();
        self.bytecode.constants.push(constant);
        pos
    }

    fn patch_jump(&mut self, pos: usize, target: usize) {
        if let Some((_, arg)) = self.bytecode.ops.get_mut(pos) {
            *arg = Some(target);
        }
    }

    fn compile_stmt(&mut self, stmt: &Stmt) {
        match stmt {
            Stmt::Expr(expr) => {
                self.compile_expr(expr);
                self.emit(OpCode::Pop, None, 0);
            }
            Stmt::Block(stmts) => {
                for s in stmts { self.compile_stmt(s); }
            }
            Stmt::VarDecl { name, initializer, .. } => {
                if let Some(init) = initializer {
                    self.compile_expr(init);
                } else {
                    self.emit(OpCode::PushNull, None, 0);
                }
                let name_idx = self.add_constant(Constant::Str(name.clone()));
                self.emit(OpCode::Define, Some(name_idx), 0);
                self.emit(OpCode::Pop, None, 0);
            }
            Stmt::If { condition, then, else_ } => {
                self.compile_expr(condition);
                let jump_pos = self.emit(OpCode::JumpIfFalse, None, 0);
                self.compile_stmt(then);
                if let Some(els) = else_ {
                    let else_jump = self.emit(OpCode::Jump, None, 0);
                    let then_end = self.bytecode.ops.len();
                    self.patch_jump(jump_pos, then_end);
                    self.compile_stmt(els);
                    let else_end = self.bytecode.ops.len();
                    self.patch_jump(else_jump, else_end);
                } else {
                    let then_end = self.bytecode.ops.len();
                    self.patch_jump(jump_pos, then_end);
                }
            }
            Stmt::While { condition, body } => {
                let start = self.bytecode.ops.len();
                self.compile_expr(condition);
                let exit_jump = self.emit(OpCode::JumpIfFalse, None, 0);
                self.compile_stmt(body);
                self.emit(OpCode::Jump, Some(start), 0);
                let end = self.bytecode.ops.len();
                self.patch_jump(exit_jump, end);
            }
            Stmt::For { init, condition, increment, body } => {
                if let Some(i) = init { self.compile_stmt(i); }
                let start = self.bytecode.ops.len();
                if let Some(cond) = condition {
                    self.compile_expr(cond);
                } else {
                    self.emit(OpCode::PushTrue, None, 0);
                }
                let exit_jump = self.emit(OpCode::JumpIfFalse, None, 0);
                self.compile_stmt(body);
                if let Some(inc) = increment {
                    self.compile_expr(inc);
                    self.emit(OpCode::Pop, None, 0);
                }
                self.emit(OpCode::Jump, Some(start), 0);
                let end = self.bytecode.ops.len();
                self.patch_jump(exit_jump, end);
            }
            Stmt::FuncDecl { name, params, body, .. } => {
                let mut sub_compiler = Compiler::new();
                let sub_bytecode = match sub_compiler.compile(body) {
                    Ok(b) => b,
                    Err(e) => {
                        self.had_error = true;
                        self.error = e;
                        return;
                    }
                };
                let func_data = FunctionData {
                    name: name.clone(),
                    bytecode: sub_bytecode,
                    is_global: true,
                    param_count: params.len(),
                    is_inline: false,
                };
                let func_idx = self.add_constant(Constant::Function(Box::new(func_data)));
                let name_idx = self.add_constant(Constant::Str(name.clone()));
                self.emit(OpCode::PushConst, Some(func_idx), 0);
                self.emit(OpCode::Store, Some(name_idx), 0);
                self.emit(OpCode::Pop, None, 0);
            }
            Stmt::Return(expr) => {
                if let Some(e) = expr {
                    self.compile_expr(e);
                } else {
                    self.emit(OpCode::PushNull, None, 0);
                }
                self.emit(OpCode::Return, None, 0);
            }
            _ => {}
        }
    }

    fn compile_expr(&mut self, expr: &Expr) {
        match expr {
            Expr::Number(n) => {
                let idx = self.add_constant(Constant::Number(*n));
                self.emit(OpCode::PushConst, Some(idx), 0);
            }
            Expr::Str(s) => {
                let idx = self.add_constant(Constant::Str(s.clone()));
                self.emit(OpCode::PushConst, Some(idx), 0);
            }
            Expr::Bool(b) => {
                self.emit(if *b { OpCode::PushTrue } else { OpCode::PushFalse }, None, 0);
            }
            Expr::Ident(name) => {
                let idx = self.add_constant(Constant::Str(name.clone()));
                self.emit(OpCode::Load, Some(idx), 0);
            }
            Expr::Unary { op, right } => {
                self.compile_expr(right);
                let opcode = match op {
                    UnOp::Neg => OpCode::Neg,
                    UnOp::Not => OpCode::Not,
                    UnOp::BitNot => OpCode::BitNot,
                    _ => OpCode::Neg,
                };
                self.emit(opcode, None, 0);
            }
            Expr::Binary { op, left, right } => {
                self.compile_expr(left);
                self.compile_expr(right);
                let opcode = match op {
                    BinOp::Add => OpCode::Add,
                    BinOp::Sub => OpCode::Sub,
                    BinOp::Mul => OpCode::Mul,
                    BinOp::Div => OpCode::Div,
                    BinOp::Mod => OpCode::Mod,
                    BinOp::Eq => OpCode::Eq,
                    BinOp::Ne => OpCode::Ne,
                    BinOp::Lt => OpCode::Lt,
                    BinOp::Gt => OpCode::Gt,
                    BinOp::Le => OpCode::Le,
                    BinOp::Ge => OpCode::Ge,
                    BinOp::And => OpCode::And,
                    BinOp::Or => OpCode::Or,
                    _ => OpCode::Add,
                };
                self.emit(opcode, None, 0);
            }
            Expr::Ternary { condition, then, else_ } => {
                self.compile_expr(condition);
                let else_jump = self.emit(OpCode::JumpIfFalse, None, 0);
                self.compile_expr(then);
                let end_jump = self.emit(OpCode::Jump, None, 0);
                let else_start = self.bytecode.ops.len();
                self.patch_jump(else_jump, else_start);
                self.compile_expr(else_);
                let end = self.bytecode.ops.len();
                self.patch_jump(end_jump, end);
            }
            Expr::Call { callee, args } => {
                for arg in args { self.compile_expr(arg); }
                self.compile_expr(callee);
                self.emit(OpCode::Call, Some(args.len()), 0);
            }
            Expr::Assign { target, value, .. } => {
                self.compile_expr(value);
                if let Expr::Ident(name) = &**target {
                    let name_idx = self.add_constant(Constant::Str(name.clone()));
                    self.emit(OpCode::Store, Some(name_idx), 0);
                }
            }
            Expr::Prefix { op, target } => {
                if let Expr::Ident(name) = &**target {
                    let name_idx = self.add_constant(Constant::Str(name.clone()));
                    self.emit(OpCode::Load, Some(name_idx), 0);
                    let one_idx = self.add_constant(Constant::Number(1.0));
                    self.emit(OpCode::PushConst, Some(one_idx), 0);
                    let opcode = match op {
                        PrefixOp::Inc => OpCode::Add,
                        PrefixOp::Dec => OpCode::Sub,
                    };
                    self.emit(opcode, None, 0);
                    self.emit(OpCode::Store, Some(name_idx), 0);
                }
            }
            Expr::Postfix { op, target } => {
                if let Expr::Ident(name) = &**target {
                    let name_idx = self.add_constant(Constant::Str(name.clone()));
                    self.emit(OpCode::Load, Some(name_idx), 0);
                    self.emit(OpCode::Dup, None, 0);
                    let one_idx = self.add_constant(Constant::Number(1.0));
                    self.emit(OpCode::PushConst, Some(one_idx), 0);
                    let opcode = match op {
                        PostfixOp::Inc => OpCode::Add,
                        PostfixOp::Dec => OpCode::Sub,
                    };
                    self.emit(opcode, None, 0);
                    self.emit(OpCode::Store, Some(name_idx), 0);
                    self.emit(OpCode::Pop, None, 0); // Remove result of store, leave original value
                }
            }
            _ => {}
        }
    }
}
