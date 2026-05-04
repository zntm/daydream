use crate::proglang::compiler::{OpCode, Bytecode, Constant};
use std::collections::HashMap;
use std::sync::Arc;

#[derive(Clone)]
pub enum Value {
    Number(f64),
    Str(String),
    Bool(bool),
    Undefined,
    Object(HashMap<String, Value>),
    Array(Vec<Value>),
    Closure(ClosureData),
    NativeFunction(Arc<dyn Fn(Vec<Value>) -> Value + Send + Sync>),
}

impl std::fmt::Debug for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Value::Number(n) => write!(f, "Number({})", n),
            Value::Str(s) => write!(f, "Str({})", s),
            Value::Bool(b) => write!(f, "Bool({})", b),
            Value::Undefined => write!(f, "Undefined"),
            Value::Object(o) => write!(f, "Object({:?})", o),
            Value::Array(a) => write!(f, "Array({:?})", a),
            Value::Closure(_) => write!(f, "Closure"),
            Value::NativeFunction(_) => write!(f, "NativeFunction"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct ClosureData {
    pub bytecode: Bytecode,
    pub env: Option<Box<Scope>>,
}

#[derive(Debug, Clone, Default)]
pub struct Scope {
    pub vars: HashMap<String, Value>,
    pub parent: Option<Box<Scope>>,
}

pub struct VM {
    stack: Vec<Value>,
    ip: usize,
    bytecode: Bytecode,
    scope: Scope,
    pub globals: HashMap<String, Value>,
}

impl VM {
    pub fn new(bytecode: Bytecode) -> Self {
        Self {
            stack: Vec::new(),
            ip: 0,
            bytecode,
            scope: Scope::default(),
            globals: HashMap::new(),
        }
    }

    pub fn set_global(&mut self, name: &str, value: Value) {
        self.globals.insert(name.to_string(), value);
    }

    pub fn call_function(&mut self, name: &str, args: Vec<Value>) -> Result<Value, String> {
        let callee = self.globals.get(name).cloned().ok_or_else(|| format!("Function not found: {}", name))?;
        
        match callee {
            Value::Closure(data) => {
                let mut sub_vm = VM::new(data.bytecode.clone());
                sub_vm.globals = self.globals.clone();
                for (i, arg_val) in args.into_iter().enumerate() {
                    sub_vm.scope.vars.insert(format!("param_{}", i), arg_val);
                }
                sub_vm.run()
            }
            Value::NativeFunction(f) => Ok(f(args)),
            _ => Err("Not a function".to_string()),
        }
    }

    pub fn run(&mut self) -> Result<Value, String> {
        while self.ip < self.bytecode.ops.len() {
            let (op, arg) = &self.bytecode.ops[self.ip];
            self.ip += 1;

            match op {
                OpCode::PushNull => self.stack.push(Value::Undefined),
                OpCode::PushTrue => self.stack.push(Value::Bool(true)),
                OpCode::PushFalse => self.stack.push(Value::Bool(false)),
                OpCode::PushConst => {
                    let idx = (*arg).ok_or("Missing constant index")?;
                    let constant = &self.bytecode.constants[idx];
                    match constant {
                        Constant::Number(n) => self.stack.push(Value::Number(*n)),
                        Constant::Str(s) => self.stack.push(Value::Str(s.clone())),
                        Constant::Function(f) => {
                            let closure = ClosureData {
                                bytecode: f.bytecode.clone(),
                                env: None,
                            };
                            self.stack.push(Value::Closure(closure));
                        }
                        _ => return Err(format!("Unsupported constant type: {:?}", constant)),
                    }
                }
                OpCode::Pop => { self.stack.pop(); }
                OpCode::Add => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Number(va + vb)),
                        (Value::Str(sa), Value::Str(sb)) => self.stack.push(Value::Str(sa + &sb)),
                        _ => return Err("Invalid operands for addition".to_string()),
                    }
                }
                OpCode::Sub => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Number(va - vb)),
                        _ => return Err("Invalid operands for subtraction".to_string()),
                    }
                }
                OpCode::Div => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Number(va / vb)),
                        _ => return Err("Invalid operands for division".to_string()),
                    }
                }
                OpCode::Mod => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Number(va % vb)),
                        _ => return Err("Invalid operands for modulo".to_string()),
                    }
                }
                OpCode::Dup => {
                    let val = self.stack.last().ok_or("Stack underflow")?.clone();
                    self.stack.push(val);
                }
                OpCode::Neg => {
                    let val = self.stack.pop().ok_or("Stack underflow")?;
                    match val {
                        Value::Number(n) => self.stack.push(Value::Number(-n)),
                        _ => return Err("Invalid operand for negation".to_string()),
                    }
                }
                OpCode::Not => {
                    let val = self.stack.pop().ok_or("Stack underflow")?;
                    match val {
                        Value::Bool(b) => self.stack.push(Value::Bool(!b)),
                        Value::Undefined => self.stack.push(Value::Bool(true)),
                        _ => self.stack.push(Value::Bool(false)),
                    }
                }
                OpCode::Mul => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Number(va * vb)),
                        _ => return Err("Invalid operands for multiplication".to_string()),
                    }
                }
                OpCode::Eq => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    self.stack.push(Value::Bool(format!("{:?}", a) == format!("{:?}", b)));
                }
                OpCode::Lt => {
                    let b = self.stack.pop().ok_or("Stack underflow")?;
                    let a = self.stack.pop().ok_or("Stack underflow")?;
                    match (a, b) {
                        (Value::Number(va), Value::Number(vb)) => self.stack.push(Value::Bool(va < vb)),
                        _ => return Err("Invalid operands for comparison".to_string()),
                    }
                }
                OpCode::Load => {
                    let idx = (*arg).ok_or("Missing identifier index")?;
                    let name = match &self.bytecode.constants[idx] {
                        Constant::Str(s) => s,
                        _ => return Err("Expected identifier name as string".to_string()),
                    };
                    let val = self.scope.vars.get(name)
                        .or_else(|| self.globals.get(name))
                        .cloned()
                        .unwrap_or(Value::Undefined);
                    self.stack.push(val);
                }
                OpCode::Define => {
                    let idx = (*arg).ok_or("Missing identifier index")?;
                    let name = match &self.bytecode.constants[idx] {
                        Constant::Str(s) => s,
                        _ => return Err("Expected identifier name as string".to_string()),
                    };
                    let val = self.stack.last().ok_or("Stack underflow")?.clone();
                    self.scope.vars.insert(name.clone(), val);
                }
                OpCode::Store => {
                    let idx = (*arg).ok_or("Missing identifier index")?;
                    let name = match &self.bytecode.constants[idx] {
                        Constant::Str(s) => s,
                        _ => return Err("Expected identifier name as string".to_string()),
                    };
                    let val = self.stack.last().ok_or("Stack underflow")?.clone();
                    self.globals.insert(name.clone(), val);
                }
                OpCode::Call => {
                    let arg_count = (*arg).ok_or("Missing arg count")?;
                    let mut args = Vec::new();
                    for _ in 0..arg_count {
                        args.push(self.stack.pop().ok_or("Stack underflow")?);
                    }
                    args.reverse();
                    let callee = self.stack.pop().ok_or("Stack underflow")?;
                    match callee {
                        Value::NativeFunction(f) => {
                            let result = f(args);
                            self.stack.push(result);
                        }
                        Value::Closure(data) => {
                            let mut sub_vm = VM::new(data.bytecode.clone());
                            sub_vm.globals = self.globals.clone();
                            for (i, arg_val) in args.into_iter().enumerate() {
                                sub_vm.scope.vars.insert(format!("param_{}", i), arg_val);
                            }
                            let res = sub_vm.run()?;
                            self.stack.push(res);
                        }
                        _ => return Err(format!("Callee is not a function: {:?}", callee)),
                    }
                }
                OpCode::Return => {
                    return Ok(self.stack.pop().unwrap_or(Value::Undefined));
                }
                OpCode::Jump => {
                    let target = (*arg).ok_or("Missing jump target")?;
                    self.ip = target;
                }
                OpCode::JumpIfFalse => {
                    let target = (*arg).ok_or("Missing jump target")?;
                    let cond = self.stack.pop().ok_or("Stack underflow")?;
                    let is_false = match cond {
                        Value::Bool(b) => !b,
                        Value::Undefined => true,
                        _ => false,
                    };
                    if is_false {
                        self.ip = target;
                    }
                }
                _ => { /* implement more as needed */ }
            }
        }
        Ok(Value::Undefined)
    }
}

unsafe impl Send for VM {}
unsafe impl Sync for VM {}
