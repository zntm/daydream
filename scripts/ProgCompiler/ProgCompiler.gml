/// @desc VM Opcodes for Proglang bytecode
enum PROG_OP {
    // Stack operations
    PUSH_NULL, PUSH_TRUE, PUSH_FALSE, PUSH_CONST, PUSH_GLOBAL_REF,
    POP, DUP,
    
    // Arithmetic
    ADD, SUB, MUL, DIV, MOD, POW, NEG,
    
    // Comparison
    EQ, NE, LT, GT, LE, GE,
    
    // Logical/Bitwise
    NOT, AND, OR, BIT_AND, BIT_OR, BIT_XOR, SHL, SHR,
    
    // Variables
    LOAD, STORE, LOAD_GLOBAL, STORE_GLOBAL,
    
    // Structure access
    INDEX_GET, INDEX_SET, MEMBER_GET, MEMBER_SET,
    
    // Creation
    ARRAY_NEW, OBJECT_NEW,
    
    // Control flow
    JUMP, JUMP_IF_FALSE, JUMP_IF_NULL, JUMP_IF_NOT_NULL,
    
    // Functions
    CALL, RETURN, CALL_SPREAD, MAKE_CLOSURE,
    
    // Iteration
    ITER_INIT, ITER_NEXT,
    
    // Exceptions
    PUSH_TRY, POP_TRY, THROW,
    
    // Spread operations
    PUSH_ARRAY_EMPTY, ARRAY_PUSH, ARRAY_SPREAD
}

/// @desc Bytecode container
function ProgBytecode() constructor {
    code = [];
    code_size = 0;
    constants = [];
    lines = [];
}

/// @desc Bytecode compiler for Proglang
function ProgCompiler() constructor {
    bytecode = new ProgBytecode();
    
    // Emit instruction
    static emit = function(_op, _arg = undefined, _line = 0) {
        array_push(bytecode.code, _op, _arg);
        array_push(bytecode.lines, _line);
        bytecode.code_size += 2;
        return bytecode.code_size - 2;
    }
    
    // Add constant with deduplication
    static add_constant = function(_value) {
        var _len = array_length(bytecode.constants);
        for (var i = 0; i < _len; i++) {
            if (bytecode.constants[i] == _value) return i;
        }
        array_push(bytecode.constants, _value);
        return _len;
    }
    
    // Patch jump address
    static patch_jump = function(_addr, _target) {
        bytecode.code[_addr + 1] = _target;
    }
    
    /// @desc Compile AST to bytecode
    static compile = function(_ast) {
        if (_ast.type == PROG_AST.BLOCK) {
            for (var i = 0; i < array_length(_ast.statements); i++) {
                compile_node(_ast.statements[i]);
            }
        } else {
            compile_node(_ast);
        }
        emit(PROG_OP.PUSH_NULL);
        emit(PROG_OP.RETURN);
        return bytecode;
    }
    
    /// @desc Try constant folding for binary operations
    static try_fold_binary = function(_node) {
        if (_node.left.type != PROG_AST.NUMBER_LITERAL || _node.right.type != PROG_AST.NUMBER_LITERAL) {
            return undefined;
        }
        var _a = _node.left.value;
        var _b = _node.right.value;
        switch (_node.op) {
            case PROG_TOKEN.PLUS: return _a + _b;
            case PROG_TOKEN.MINUS: return _a - _b;
            case PROG_TOKEN.STAR: return _a * _b;
            case PROG_TOKEN.SLASH: return _b != 0 ? _a / _b : undefined;
            case PROG_TOKEN.PERCENT: return _b != 0 ? _a % _b : undefined;
            case PROG_TOKEN.POWER: return power(_a, _b);
            default: return undefined;
        }
    }
    
    static compile_node = function(_node) {
        switch (_node.type) {
            // Literals
            case PROG_AST.NUMBER_LITERAL:
            case PROG_AST.STRING_LITERAL:
                emit(PROG_OP.PUSH_CONST, add_constant(_node.value), _node.line);
                break;
                
            case PROG_AST.BOOL_LITERAL:
                emit(_node.value ? PROG_OP.PUSH_TRUE : PROG_OP.PUSH_FALSE, undefined, _node.line);
                break;
                
            case PROG_AST.UNDEFINED_LITERAL:
                emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                break;
                
            case PROG_AST.ARRAY_LITERAL:
                var _has_spread = false;
                for (var i = 0; i < array_length(_node.elements); i++) {
                    if (_node.elements[i].type == PROG_AST.UNARY_OP && _node.elements[i].op == PROG_TOKEN.SPREAD) {
                        _has_spread = true; break;
                    }
                }
                if (_has_spread) {
                    emit(PROG_OP.PUSH_ARRAY_EMPTY, undefined, _node.line);
                    for (var i = 0; i < array_length(_node.elements); i++) {
                        var _el = _node.elements[i];
                        if (_el.type == PROG_AST.UNARY_OP && _el.op == PROG_TOKEN.SPREAD) {
                            compile_node(_el.right);
                            emit(PROG_OP.ARRAY_SPREAD, undefined, _node.line);
                        } else {
                            compile_node(_el);
                            emit(PROG_OP.ARRAY_PUSH, undefined, _node.line);
                        }
                    }
                } else {
                    for (var i = 0; i < array_length(_node.elements); i++) compile_node(_node.elements[i]);
                    emit(PROG_OP.ARRAY_NEW, array_length(_node.elements), _node.line);
                }
                break;
                
            case PROG_AST.OBJECT_LITERAL:
                for (var i = 0; i < array_length(_node.pairs); i++) {
                    emit(PROG_OP.PUSH_CONST, add_constant(_node.pairs[i].key), _node.line);
                    compile_node(_node.pairs[i].value);
                }
                emit(PROG_OP.OBJECT_NEW, array_length(_node.pairs), _node.line);
                break;
                
            // Expressions
            case PROG_AST.BINARY_OP:
                // Constant folding
                var _folded = try_fold_binary(_node);
                if (_folded != undefined) {
                    emit(PROG_OP.PUSH_CONST, add_constant(_folded), _node.line);
                    break;
                }
                
                // Null coalescing short-circuit
                if (_node.op == PROG_TOKEN.NULL_COALESCE) {
                    compile_node(_node.left);
                    var _jmp = emit(PROG_OP.JUMP_IF_NOT_NULL, 0, _node.line);
                    emit(PROG_OP.POP);
                    compile_node(_node.right);
                    patch_jump(_jmp, bytecode.code_size);
                    break;
                }
                
                compile_node(_node.left);
                compile_node(_node.right);
                
                var _opcode;
                switch (_node.op) {
                    case PROG_TOKEN.PLUS: _opcode = PROG_OP.ADD; break;
                    case PROG_TOKEN.MINUS: _opcode = PROG_OP.SUB; break;
                    case PROG_TOKEN.STAR: _opcode = PROG_OP.MUL; break;
                    case PROG_TOKEN.SLASH: _opcode = PROG_OP.DIV; break;
                    case PROG_TOKEN.PERCENT: _opcode = PROG_OP.MOD; break;
                    case PROG_TOKEN.POWER: _opcode = PROG_OP.POW; break;
                    case PROG_TOKEN.EQ: _opcode = PROG_OP.EQ; break;
                    case PROG_TOKEN.NE: _opcode = PROG_OP.NE; break;
                    case PROG_TOKEN.LT: _opcode = PROG_OP.LT; break;
                    case PROG_TOKEN.GT: _opcode = PROG_OP.GT; break;
                    case PROG_TOKEN.LE: _opcode = PROG_OP.LE; break;
                    case PROG_TOKEN.GE: _opcode = PROG_OP.GE; break;
                    case PROG_TOKEN.AND: _opcode = PROG_OP.AND; break;
                    case PROG_TOKEN.OR: _opcode = PROG_OP.OR; break;
                    case PROG_TOKEN.AMP: _opcode = PROG_OP.BIT_AND; break;
                    case PROG_TOKEN.PIPE: _opcode = PROG_OP.BIT_OR; break;
                    case PROG_TOKEN.CARET: _opcode = PROG_OP.BIT_XOR; break;
                    case PROG_TOKEN.LSHIFT: _opcode = PROG_OP.SHL; break;
                    case PROG_TOKEN.RSHIFT: _opcode = PROG_OP.SHR; break;
                }
                emit(_opcode, undefined, _node.line);
                break;
                
            case PROG_AST.UNARY_OP:
                compile_node(_node.right);
                if (_node.op == PROG_TOKEN.MINUS) emit(PROG_OP.NEG, undefined, _node.line);
                else if (_node.op == PROG_TOKEN.NOT) emit(PROG_OP.NOT, undefined, _node.line);
                break;
                
            case PROG_AST.IDENTIFIER:
                emit(PROG_OP.LOAD, add_constant(_node.name), _node.line);
                break;
                
            case PROG_AST.ASSIGNMENT:
                compile_assignment(_node);
                break;
                
            case PROG_AST.VAR_DECL:
                if (_node.initializer != undefined) compile_node(_node.initializer);
                else emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                var _idx = add_constant(_node.name);
                if (struct_exists(_node, "is_global") && _node.is_global) {
                    emit(PROG_OP.STORE_GLOBAL, _idx, _node.line);
                } else {
                    emit(PROG_OP.STORE, _idx, _node.line);
                }
                emit(PROG_OP.POP, undefined, _node.line);
                break;
                
            case PROG_AST.BLOCK:
                for (var i = 0; i < array_length(_node.statements); i++) {
                    compile_node(_node.statements[i]);
                }
                break;
                
            case PROG_AST.FUNC_DECL:
                var _parent = bytecode;
                bytecode = new ProgBytecode();
                
                // Map parameters to arg0, arg1, etc.
                for (var i = 0; i < array_length(_node.params); i++) {
                    emit(PROG_OP.LOAD, add_constant($"arg{i}"), _node.line);
                    emit(PROG_OP.STORE, add_constant(_node.params[i]), _node.line);
                }
                
                compile_node(_node.body);
                emit(PROG_OP.PUSH_NULL);
                emit(PROG_OP.RETURN);
                
                var _func_bc = bytecode;
                bytecode = _parent;
                
                var _func_idx = add_constant({
                    type: "function", name: _node.name,
                    bytecode: _func_bc, is_global: _node.is_global
                });
                emit(PROG_OP.PUSH_CONST, _func_idx, _node.line);
                emit(PROG_OP.MAKE_CLOSURE, undefined, _node.line);
                
                var _name_idx = add_constant(_node.name);
                emit(_node.is_global ? PROG_OP.STORE_GLOBAL : PROG_OP.STORE, _name_idx, _node.line);
                emit(PROG_OP.POP);
                break;
                
            case PROG_AST.EXPRESSION_STMT:
                compile_node(_node.expression);
                emit(PROG_OP.POP, undefined, _node.line);
                break;
                
            case PROG_AST.IF_STMT:
                compile_node(_node.condition);
                var _jmp_else = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.then_branch);
                var _jmp_end = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_jmp_else, bytecode.code_size);
                if (_node.else_branch != undefined) compile_node(_node.else_branch);
                patch_jump(_jmp_end, bytecode.code_size);
                break;
                
            case PROG_AST.WHILE_STMT:
                var _start = bytecode.code_size;
                compile_node(_node.condition);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _start, _node.line);
                patch_jump(_exit, bytecode.code_size);
                break;
                
            case PROG_AST.REPEAT_STMT:
                var _rep_var = "@rep_" + string(bytecode.code_size);
                var _idx = add_constant(_rep_var);
                compile_node(_node.count);
                emit(PROG_OP.STORE, _idx, _node.line);
                emit(PROG_OP.POP);
                
                var _start = bytecode.code_size;
                emit(PROG_OP.LOAD, _idx, _node.line);
                emit(PROG_OP.PUSH_CONST, add_constant(0));
                emit(PROG_OP.GT);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                compile_node(_node.body);
                
                emit(PROG_OP.LOAD, _idx);
                emit(PROG_OP.PUSH_CONST, add_constant(1));
                emit(PROG_OP.SUB);
                emit(PROG_OP.STORE, _idx);
                emit(PROG_OP.POP);
                emit(PROG_OP.JUMP, _start);
                patch_jump(_exit, bytecode.code_size);
                break;
                
            case PROG_AST.FOR_STMT:
                if (_node.initializer) {
                    if (_node.initializer.type == PROG_AST.VAR_DECL) compile_node(_node.initializer);
                    else { compile_node(_node.initializer); emit(PROG_OP.POP); }
                }
                var _start = bytecode.code_size;
                var _exit = -1;
                if (_node.condition) {
                    compile_node(_node.condition);
                    _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                }
                compile_node(_node.body);
                if (_node.increment) { compile_node(_node.increment); emit(PROG_OP.POP); }
                emit(PROG_OP.JUMP, _start, _node.line);
                if (_exit != -1) patch_jump(_exit, bytecode.code_size);
                break;
                
            case PROG_AST.BREAK_STMT:
                // TODO: Implement with loop context
                break;
                
            case PROG_AST.TERNARY:
                compile_node(_node.condition);
                var _jf = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.true_branch);
                var _je = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_jf, bytecode.code_size);
                compile_node(_node.false_branch);
                patch_jump(_je, bytecode.code_size);
                break;
                
            case PROG_AST.PREFIX_OP:
                if (_node.target.type == PROG_AST.IDENTIFIER) {
                    var _idx = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _idx, _node.line);
                    emit(PROG_OP.PUSH_CONST, add_constant(1));
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.ADD : PROG_OP.SUB);
                    emit(PROG_OP.STORE, _idx, _node.line);
                }
                break;
                
            case PROG_AST.POSTFIX_OP:
                if (_node.target.type == PROG_AST.IDENTIFIER) {
                    var _idx = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _idx, _node.line);
                    emit(PROG_OP.DUP);
                    emit(PROG_OP.PUSH_CONST, add_constant(1));
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.ADD : PROG_OP.SUB);
                    emit(PROG_OP.STORE, _idx, _node.line);
                    emit(PROG_OP.POP);
                }
                break;
                
            case PROG_AST.SWITCH_STMT:
                compile_node(_node.expr);
                var _ends = [];
                for (var i = 0; i < array_length(_node.cases); i++) {
                    var _case = _node.cases[i];
                    emit(PROG_OP.DUP);
                    compile_node(_case.value);
                    emit(PROG_OP.EQ);
                    var _skip = emit(PROG_OP.JUMP_IF_FALSE, 0);
                    emit(PROG_OP.POP);
                    compile_node(_case.body);
                    array_push(_ends, emit(PROG_OP.JUMP, 0));
                    patch_jump(_skip, bytecode.code_size);
                }
                emit(PROG_OP.POP);
                if (_node.default_case != undefined) compile_node(_node.default_case);
                for (var i = 0; i < array_length(_ends); i++) patch_jump(_ends[i], bytecode.code_size);
                break;
                
            case PROG_AST.CALL:
                var _has_spread = false;
                for (var i = 0; i < array_length(_node.args); i++) {
                    if (_node.args[i].type == PROG_AST.UNARY_OP && _node.args[i].op == PROG_TOKEN.SPREAD) {
                        _has_spread = true; break;
                    }
                }
                if (_has_spread) {
                    emit(PROG_OP.PUSH_ARRAY_EMPTY, undefined, _node.line);
                    for (var i = 0; i < array_length(_node.args); i++) {
                        var _arg = _node.args[i];
                        if (_arg.type == PROG_AST.UNARY_OP && _arg.op == PROG_TOKEN.SPREAD) {
                            compile_node(_arg.right);
                            emit(PROG_OP.ARRAY_SPREAD, undefined, _node.line);
                        } else {
                            compile_node(_arg);
                            emit(PROG_OP.ARRAY_PUSH, undefined, _node.line);
                        }
                    }
                    compile_node(_node.callee);
                    emit(PROG_OP.CALL_SPREAD, undefined, _node.line);
                } else {
                    for (var i = 0; i < array_length(_node.args); i++) compile_node(_node.args[i]);
                    compile_node(_node.callee);
                    emit(PROG_OP.CALL, array_length(_node.args), _node.line);
                }
                break;
                
            case PROG_AST.MEMBER:
                compile_node(_node.target);
                emit(PROG_OP.MEMBER_GET, add_constant(_node.property), _node.line);
                break;
                
            case PROG_AST.INDEX:
                compile_node(_node.target);
                compile_node(_node.index);
                emit(PROG_OP.INDEX_GET, undefined, _node.line);
                break;
                
            case PROG_AST.RETURN_STMT:
                if (_node.value) compile_node(_node.value);
                else emit(PROG_OP.PUSH_NULL);
                emit(PROG_OP.RETURN, undefined, _node.line);
                break;
                
            case PROG_AST.FOR_IN_STMT:
                compile_node(_node.collection);
                emit(PROG_OP.ITER_INIT, undefined, _node.line);
                var _start = bytecode.code_size;
                emit(PROG_OP.ITER_NEXT, undefined, _node.line);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                emit(PROG_OP.STORE, add_constant(_node.variable), _node.line);
                emit(PROG_OP.POP);
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _start, _node.line);
                patch_jump(_exit, bytecode.code_size);
                emit(PROG_OP.POP);
                break;
                
            case PROG_AST.TRY_STMT:
                var _catch_jmp = emit(PROG_OP.PUSH_TRY, 0, _node.line);
                compile_node(_node.try_block);
                emit(PROG_OP.POP_TRY, undefined, _node.line);
                var _end_jmp = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_catch_jmp, bytecode.code_size);
                if (_node.catch_var != undefined) {
                    emit(PROG_OP.STORE, add_constant(_node.catch_var), _node.line);
                    emit(PROG_OP.POP);
                } else {
                    emit(PROG_OP.POP);
                }
                if (_node.catch_block != undefined) compile_node(_node.catch_block);
                patch_jump(_end_jmp, bytecode.code_size);
                break;
                
            case PROG_AST.DESTRUCTURING_DECL:
                if (_node.initializer != undefined) compile_node(_node.initializer);
                else emit(PROG_OP.PUSH_NULL);
                
                if (_node.pattern_type == "array") {
                    for (var i = 0; i < array_length(_node.elements); i++) {
                        emit(PROG_OP.DUP);
                        emit(PROG_OP.PUSH_CONST, add_constant(i));
                        emit(PROG_OP.INDEX_GET, undefined, _node.line);
                        emit(PROG_OP.STORE, add_constant(_node.elements[i]), _node.line);
                        emit(PROG_OP.POP);
                    }
                } else {
                    for (var i = 0; i < array_length(_node.elements); i++) {
                        emit(PROG_OP.DUP);
                        emit(PROG_OP.MEMBER_GET, add_constant(_node.elements[i].key), _node.line);
                        emit(PROG_OP.STORE, add_constant(_node.elements[i].name), _node.line);
                        emit(PROG_OP.POP);
                    }
                }
                emit(PROG_OP.POP);
                break;
        }
    }
    
    static compile_assignment = function(_node) {
        var _target = _node.target;
        var _line = _node.line;
        var _op = _node.op;
        
        if (_target.type == PROG_AST.IDENTIFIER) {
            var _idx = add_constant(_target.name);
            if (_op != PROG_TOKEN.ASSIGN) {
                emit(PROG_OP.LOAD, _idx, _line);
                compile_node(_node.value);
                switch (_op) {
                    case PROG_TOKEN.PLUS_ASSIGN: emit(PROG_OP.ADD); break;
                    case PROG_TOKEN.MINUS_ASSIGN: emit(PROG_OP.SUB); break;
                    case PROG_TOKEN.STAR_ASSIGN: emit(PROG_OP.MUL); break;
                    case PROG_TOKEN.SLASH_ASSIGN: emit(PROG_OP.DIV); break;
                }
            } else {
                compile_node(_node.value);
            }
            emit(PROG_OP.STORE, _idx, _line);
        } else if (_target.type == PROG_AST.MEMBER) {
            compile_node(_target.target);
            compile_node(_node.value);
            emit(PROG_OP.MEMBER_SET, add_constant(_target.property), _line);
        } else if (_target.type == PROG_AST.INDEX) {
            compile_node(_target.target);
            compile_node(_target.index);
            compile_node(_node.value);
            emit(PROG_OP.INDEX_SET, undefined, _line);
        }
    }
}
