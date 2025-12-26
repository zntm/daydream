
/// @desc VM Instructions
enum PROG_OP {
    PUSH_NULL,      // Push undefined
    PUSH_TRUE,      // Push true
    PUSH_FALSE,     // Push false
    PUSH_CONST,     // Push constant from pool (arg: index)
    PUSH_GLOBAL_REF,// Push global struct reference
    
    POP,            // Pop top
    DUP,            // Duplicate top
    
    // Arithmetic
    ADD, SUB, MUL, DIV, MOD, POW,
    NEG,            // Unary minus
    
    // Comparison
    EQ, NE, LT, GT, LE, GE,
    
    // Logical/Bitwise
    NOT,            // Logical NOT (!)
    AND, OR,        // Logical (short-circuiting logic handled by JUMP)
    BIT_AND, BIT_OR, BIT_XOR, 
    SHL, SHR,
    
    // Variable Access
    LOAD,           // Load var by name (arg: name string index)
    STORE,          // Store var by name (arg: name string index)
    LOAD_GLOBAL,    // Load global (arg: name string index)
    STORE_GLOBAL,   // Store global (arg: name string index)
    
    // Structure Access
    INDEX_GET,      // arr[i]
    INDEX_SET,      // arr[i] = val
    MEMBER_GET,     // obj.prop (arg: prop string index)
    MEMBER_SET,     // obj.prop = val (arg: prop string index)
    
    // Structures creation
    ARRAY_NEW,      // Create array (arg: count)
    OBJECT_NEW,     // Create struct (arg: count)
    
    // Control Flow
    JUMP,           // Unconditional jump (arg: offset)
    JUMP_IF_FALSE,  // Jump if top is falsey (arg: offset)
    
    // Functions
    CALL,           // Call function (arg: arg_count)
    RETURN,         // Return from script
    
    // New Features
    ITER_INIT,      // Initialize iterator (pop collection, push iterator)
    ITER_NEXT,      // Next iteration (peek iterator. push bool has_next. if true, push value)
    
    PUSH_TRY,       // Push try handler (arg: catch offset)
    POP_TRY,        // Pop try handler
    THROW,          // Throw exception (pop value)
    
    JUMP_IF_NULL,   // Jump if top is undefined/null (arg: offset)
    JUMP_IF_NOT_NULL,// Jump if top is NOT undefined/null (arg: offset)
    
    // Spread
    PUSH_ARRAY_EMPTY, // Push []
    ARRAY_PUSH,       // Pop val, append to top array
    ARRAY_SPREAD,     // Pop array, append all to top array
    CALL_SPREAD,      // Call (Arg is Stack-Top Array)
    MAKE_CLOSURE      // Pop func const, push closure (captures env)
}

/// @desc Bytecode Container
function ProgBytecode() constructor {
    code = [];          // Array of { op, arg } or simple op ints? 
                        // To verify: storing structs in array ok? 
                        // Packed array [op, arg, op, arg] is faster usually.
                        // Let's use packed array for performance.
                        // [op, arg(optional)]? Variable length instruction?
                        // Fixed length is easier: [op, arg]. Arg undefined if unused.
    code_size = 0;
    constants = [];     // Array of literal expressions
    lines = [];         // Map code index to source line
}

/// @desc Compiler for Proglang
function ProgCompiler() constructor {
    bytecode = new ProgBytecode();
    
    // ----------------------------------------------------------------------------
    // Emitters
    // ----------------------------------------------------------------------------
    
    static emit = function(_op, _arg = undefined, _line = 0) {
        array_push(bytecode.code, _op);
        array_push(bytecode.code, _arg);
        array_push(bytecode.lines, _line);
        bytecode.code_size += 2;
        return bytecode.code_size - 2; // Return address of instruction
    }
    
    static add_constant = function(_value) {
        // Dedup constants
        for (var i = 0; i < array_length(bytecode.constants); i++) {
            if (bytecode.constants[i] == _value) return i;
        }
        array_push(bytecode.constants, _value);
        return array_length(bytecode.constants) - 1;
    }
    
    static patch_jump = function(_addr, _target_addr) {
        // Jumps store relative usage? Or absolute?
        // Absolute index is easier for VM.
        bytecode.code[_addr + 1] = _target_addr;
    }
    
    // ----------------------------------------------------------------------------
    // Entry Point
    // ----------------------------------------------------------------------------
    
    static compile = function(_ast) {
        if (_ast.type == PROG_AST.BLOCK) {
            for (var i = 0; i < array_length(_ast.statements); i++) {
                compile_node(_ast.statements[i]);
            }
        } else {
            compile_node(_ast);
        }
        
        // Ensure explicit return at end if missing (return null)
        emit(PROG_OP.PUSH_NULL);
        emit(PROG_OP.RETURN);
        
        return bytecode;
    }
    
    static compile_node = function(_node) {
        switch (_node.type) {
            // Literals
            case PROG_AST.NUMBER_LITERAL:
            case PROG_AST.STRING_LITERAL:
                var _idx = add_constant(_node.value);
                emit(PROG_OP.PUSH_CONST, _idx, _node.line);
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
                        _has_spread = true;
                        break;
                    }
                }
                
                if (_has_spread) {
                    emit(PROG_OP.PUSH_ARRAY_EMPTY, undefined, _node.line);
                    for (var i = 0; i < array_length(_node.elements); i++) {
                        var _el = _node.elements[i];
                        if (_el.type == PROG_AST.UNARY_OP && _el.op == PROG_TOKEN.SPREAD) {
                            compile_node(_el.right); // Compile spread expression
                            emit(PROG_OP.ARRAY_SPREAD, undefined, _node.line);
                        } else {
                            compile_node(_el);
                            emit(PROG_OP.ARRAY_PUSH, undefined, _node.line);
                        }
                    }
                } else {
                    for (var i = 0; i < array_length(_node.elements); i++) {
                        compile_node(_node.elements[i]);
                    }
                    emit(PROG_OP.ARRAY_NEW, array_length(_node.elements), _node.line);
                }
                break;
            
            case PROG_AST.OBJECT_LITERAL:
                for (var i = 0; i < array_length(_node.pairs); i++) {
                    var _p = _node.pairs[i];
                    var _k_idx = add_constant(_p.key);
                    emit(PROG_OP.PUSH_CONST, _k_idx, _node.line); // Push key
                    compile_node(_p.value);              // Push val
                }
                emit(PROG_OP.OBJECT_NEW, array_length(_node.pairs), _node.line);
                break;
            
            
            // Expressions
            case PROG_AST.BINARY_OP:
                // Handling Short-Circuit Operators and Null Coalesce
                if (_node.op == PROG_TOKEN.NULL_COALESCE) {
                    compile_node(_node.left);
                    var _jump_not_null = emit(PROG_OP.JUMP_IF_NOT_NULL, 0, _node.line);
                    emit(PROG_OP.POP); // Pop null
                    compile_node(_node.right);
                    patch_jump(_jump_not_null, bytecode.code_size);
                    break;
                }
                
                compile_node(_node.left);
                compile_node(_node.right);
                var _op_code;
                switch (_node.op) {
                    case PROG_TOKEN.PLUS: _op_code = PROG_OP.ADD; break;
                    case PROG_TOKEN.MINUS:_op_code = PROG_OP.SUB; break;
                    case PROG_TOKEN.STAR: _op_code = PROG_OP.MUL; break;
                    case PROG_TOKEN.SLASH:_op_code = PROG_OP.DIV; break;
                    case PROG_TOKEN.PERCENT:_op_code = PROG_OP.MOD; break;
                    case PROG_TOKEN.POWER: _op_code = PROG_OP.POW; break;
                    case PROG_TOKEN.EQ:   _op_code = PROG_OP.EQ; break;
                    case PROG_TOKEN.NE:   _op_code = PROG_OP.NE; break;
                    case PROG_TOKEN.LT:   _op_code = PROG_OP.LT; break;
                    case PROG_TOKEN.GT:   _op_code = PROG_OP.GT; break;
                    case PROG_TOKEN.LE:   _op_code = PROG_OP.LE; break;
                    case PROG_TOKEN.GE:   _op_code = PROG_OP.GE; break;
                    
                    case PROG_TOKEN.AND:  _op_code = PROG_OP.AND; break;
                    case PROG_TOKEN.OR:   _op_code = PROG_OP.OR; break;
                    
                    case PROG_TOKEN.AMP:  _op_code = PROG_OP.BIT_AND; break;
                    case PROG_TOKEN.PIPE: _op_code = PROG_OP.BIT_OR; break;
                    case PROG_TOKEN.CARET:_op_code = PROG_OP.BIT_XOR; break;
                    case PROG_TOKEN.LSHIFT:_op_code = PROG_OP.SHL; break;
                    case PROG_TOKEN.RSHIFT:_op_code = PROG_OP.SHR; break;
                }
                emit(_op_code, undefined, _node.line);
                break;
            
            
            case PROG_AST.UNARY_OP:
                compile_node(_node.right);
                if (_node.op == PROG_TOKEN.MINUS) emit(PROG_OP.NEG, undefined, _node.line);
                else if (_node.op == PROG_TOKEN.NOT) emit(PROG_OP.NOT, undefined, _node.line);
                break;
            
            
            case PROG_AST.IDENTIFIER:
                var _idx = add_constant(_node.name);
                emit(PROG_OP.LOAD, _idx, _node.line);
                break;
            
            
            case PROG_AST.ASSIGNMENT:
                compile_assignment(_node);
                break;
            
            
            case PROG_AST.VAR_DECL:
                if (_node.initializer != undefined) {
                    compile_node(_node.initializer);
                } else {
                    emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                }
                var _idx = add_constant(_node.name);
                // Declaring local var? In GML `var x` makes it local.
                // My VM usually defaults to local for `STORE` if not `instance`.
                // But I need to mark it as "Local Declaration" so VM knows to put it in `locals` map even if instance has same name?
                // Actually `STORE` usually overwrites whatever scope it finds, or creates local if scope is strictly local?
                // VM Logic: `STORE` -> if in locals update, else if in instance update, else create in instance?
                // `VAR_DECL` implies "Force create in locals".
                // I need `STORE_LOCAL` opcode or `OP.STORE` flag?
                // Since I claim GML style, `var x` declares it local for the function.
                // `STORE` opcode usually follows scope chain.
                // I will add a `DECLARE_LOCAL` opcode logic?
                // Or simply `STORE` assumes local if used with `var` keyword logic?
                // But Bytecode doesn't know about `var`.
                // So I need `INIT_LOCAL` opcode.
                if (variable_struct_exists(_node, "is_global") && _node.is_global) {
                     emit(PROG_OP.STORE_GLOBAL, _idx, _node.line);
                } else {
                     emit(PROG_OP.STORE, _idx, _node.line); 
                }
                emit(PROG_OP.POP, undefined, _node.line); // Pop the value left by Store
                
                break;
            
            
            case PROG_AST.BLOCK:
                for (var i = 0; i < array_length(_node.statements); i++) {
                    compile_node(_node.statements[i]);
                }
                break;
            
            
            case PROG_AST.FUNC_DECL:
                // Save current bytecode state
                var _parent_bytecode = bytecode;
                
                // Create new bytecode for function body
                bytecode = new ProgBytecode();
                
                // Store parameters as locals at function start
                for (var i = 0; i < array_length(_node.params); i++) {
                    var _param_idx = add_constant(_node.params[i]);
                    // Load from context arg0, arg1, etc.
                    var _arg_name_idx = add_constant($"arg{i}");
                    emit(PROG_OP.LOAD, _arg_name_idx, _node.line);
                    emit(PROG_OP.STORE, _param_idx, _node.line);
                }
                
                // Compile function body
                compile_node(_node.body);
                
                // Ensure function returns
                emit(PROG_OP.PUSH_NULL);
                emit(PROG_OP.RETURN);
                
                var _func_bytecode = bytecode;
                
                // Restore parent bytecode
                bytecode = _parent_bytecode;
                
                // Store function in exports or local scope
                // This is handled at runtime by script loader based on is_global flag
                // Emit metadata instruction for runtime to pick up
                var _func_idx = add_constant({
                    type: "function",
                    name: _node.name,
                    bytecode: _func_bytecode,
                    is_global: _node.is_global
                });
                emit(PROG_OP.PUSH_CONST, _func_idx, _node.line);
                
                // Make it a closure (captures current scope environment)
                emit(PROG_OP.MAKE_CLOSURE, undefined, _node.line);
                
                // Store it to appropriate scope
                var _name_idx = add_constant(_node.name);
                if (_node.is_global) emit(PROG_OP.STORE_GLOBAL, _name_idx, _node.line);
                else emit(PROG_OP.STORE, _name_idx, _node.line);
                
                emit(PROG_OP.POP); // Consumes the result of Store (ref to closure)
                break;
            
            
            case PROG_AST.EXPRESSION_STMT:
                compile_node(_node.expression);
                emit(PROG_OP.POP, undefined, _node.line); // Statement result discarded
                break;
            
            
            case PROG_AST.IF_STMT:
                compile_node(_node.condition);
                // JUMP_IF_FALSE to Else
                var _jump_else_instr = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                compile_node(_node.then_branch);
                var _jump_end_instr = emit(PROG_OP.JUMP, 0, _node.line); // Jump over else
                
                // Patch False Jump
                patch_jump(_jump_else_instr, bytecode.code_size);
                
                if (_node.else_branch != undefined) {
                    compile_node(_node.else_branch);
                }
                
                // Patch End Jump
                patch_jump(_jump_end_instr, bytecode.code_size);
                break;
            
            
            case PROG_AST.WHILE_STMT:
                var _loop_start = bytecode.code_size;
                compile_node(_node.condition);
                
                var _jump_exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _loop_start, _node.line); // Loop back
                
                patch_jump(_jump_exit, bytecode.code_size);
                break;
            
            
            case PROG_AST.REPEAT_STMT:
                // Stack: [count]
                // We need a loop counter. 
                // Since simpler VM, we can't easily push hidden stack var.
                // Or we can simple use a decreasing count on stack?
                // But body execution must not consume it.
                // Implementation:
                // Evaluate Count.
                // JUMP check <= 0 -> Exit
                // LOOP:
                //   Body
                //   DEC count
                //   JUMP check > 0
                // This implies count is on stack.
                // But Body consumes things. We need count to stay DEEP on stack?
                // Complicated. 
                // Easiest: evaluate count, store to temp variable? (hidden local).
                // Or use `PROG_OP.REPEAT_START` opcode?
                // Let's stick to standard ops.
                // We can't easily implement REPEAT without a register or hidden local.
                // Compile as:
                // var __rep = count; while (__rep > 0) { body; __rep--; }
                
                // No AST transformation here easily.
                // Let's assume VM handles REPEAT? No.
                // Let's skip REPEAT optimization and do the `__repeat_X` local var strategy.
                // Use a unique name based on depth?
                var _rep_var = "@repeat_" + string(bytecode.code_size);
                var _idx = add_constant(_rep_var);
                
                compile_node(_node.count);
                emit(PROG_OP.STORE, _idx, _node.line);
                emit(PROG_OP.POP);
                
                var _loop_start = bytecode.code_size;
                
                // Check __rep > 0
                emit(PROG_OP.LOAD, _idx, _node.line);
                emit(PROG_OP.PUSH_CONST, add_constant(0));
                emit(PROG_OP.GT);
                var _jump_exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                compile_node(_node.body);
                
                // Decrement
                emit(PROG_OP.LOAD, _idx);
                emit(PROG_OP.PUSH_CONST, add_constant(1));
                emit(PROG_OP.SUB);
                emit(PROG_OP.STORE, _idx);
                emit(PROG_OP.POP);
                
                emit(PROG_OP.JUMP, _loop_start);
                patch_jump(_jump_exit, bytecode.code_size);
                
                break;
            
            
            case PROG_AST.FOR_STMT:
                 if (_node.initializer) {
                     if (_node.initializer.type == PROG_AST.VAR_DECL) compile_node(_node.initializer);
                     else { // ExpStmt
                         compile_node(_node.initializer); 
                         emit(PROG_OP.POP); // Discard result if just expr
                     }
                 }
                 
                 var _loop_start = bytecode.code_size;
                 
                 var _jump_exit = -1;
                 if (_node.condition) {
                     compile_node(_node.condition);
                     _jump_exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                 }
                 
                 compile_node(_node.body);
                 
                 if (_node.increment) {
                     compile_node(_node.increment);
                     emit(PROG_OP.POP); // Discard inc result
                 }
                 
                 emit(PROG_OP.JUMP, _loop_start, _node.line);
                 
                 if (_jump_exit != -1) patch_jump(_jump_exit, bytecode.code_size);
                 break;
            
            
            case PROG_AST.BREAK_STMT:
                 // TODO: Implement break with loop context stack
                 break;
            
            case PROG_AST.TERNARY:
                 compile_node(_node.condition);
                 var _jump_false = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                 compile_node(_node.true_branch);
                 var _jump_end = emit(PROG_OP.JUMP, 0, _node.line);
                 patch_jump(_jump_false, bytecode.code_size);
                 compile_node(_node.false_branch);
                 patch_jump(_jump_end, bytecode.code_size);
                 break;
            
            
            case PROG_AST.PREFIX_OP:
                 // ++i: Load, inc, dup (return new value), store
                 var _target = _node.target;
                 if (_target.type == PROG_AST.IDENTIFIER) {
                     var _idx = add_constant(_target.name);
                     emit(PROG_OP.LOAD, _idx, _node.line);
                     emit(PROG_OP.PUSH_CONST, add_constant(1));
                     if (_node.op == PROG_TOKEN.PLUS_PLUS) emit(PROG_OP.ADD); 
                     else emit(PROG_OP.SUB);
                     
                     // emit(PROG_OP.DUP); // STORE now peeks, so DUP is not needed
                     emit(PROG_OP.STORE, _idx, _node.line);
                 }
                 break;
            
            
            case PROG_AST.POSTFIX_OP:
                 // i++: Load, dup (return old), inc, store
                 var _target = _node.target;
                 if (_target.type == PROG_AST.IDENTIFIER) {
                     var _idx = add_constant(_target.name);
                     emit(PROG_OP.LOAD, _idx, _node.line);
                     emit(PROG_OP.DUP); // Keep old value for return
                     // Stack: [old, old]
                     emit(PROG_OP.PUSH_CONST, add_constant(1));
                     // Stack: [old, old, 1]
                     emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.ADD : PROG_OP.SUB);
                     // Stack: [old, new]
                     emit(PROG_OP.STORE, _idx, _node.line);
                     // Stack: [old, new] (STORE peeks now)
                     emit(PROG_OP.POP); 
                     // Stack: [old] -- Correct!
                 }
                 break;
            
            
            case PROG_AST.SWITCH_STMT:
                 // Compile as chained if-else
                 compile_node(_node.expr);
                 
                 var _jump_nexts = [];
                 var _jump_ends = [];
                 
                 // Compile each case
                 for (var i = 0; i < array_length(_node.cases); i++) {
                     var _case = _node.cases[i];
                     
                     emit(PROG_OP.DUP); // Duplicate switch value for comparison
                     compile_node(_case.value);
                     emit(PROG_OP.EQ);
                     var _jump_skip = emit(PROG_OP.JUMP_IF_FALSE, 0);
                     
                     emit(PROG_OP.POP); // Pop switch value before body
                     compile_node(_case.body);
                     array_push(_jump_ends, emit(PROG_OP.JUMP, 0)); // Jump to end after body
                     
                     patch_jump(_jump_skip, bytecode.code_size);
                 }
                 
                 // Default case
                 emit(PROG_OP.POP); // Pop remaining switch value
                 if (_node.default_case != undefined) {
                     compile_node(_node.default_case);
                 }
                 
                 // Patch all end jumps
                 for (var i = 0; i < array_length(_jump_ends); i++) {
                     patch_jump(_jump_ends[i], bytecode.code_size);
                 }
                 break;
            
                 
            case PROG_AST.CALL:
                var _has_spread = false;
                for (var i = 0; i < array_length(_node.args); i++) {
                    if (_node.args[i].type == PROG_AST.UNARY_OP && _node.args[i].op == PROG_TOKEN.SPREAD) {
                        _has_spread = true;
                        break;
                    }
                }
                
                if (_has_spread) {
                    // Build arg array first
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
                    
                    // Call Spread (Pushes Callee later? No, CALL expects Args on stack)
                    // Regular CALL: Pushed Args, then emitted CALL.
                    // My VM CALL implementation: `callee = pop()`. `args` are BELOW callee?
                    // Let's check VM CALL.
                    /*
                    case PROG_OP.CALL: {
                         var _argc = _arg;
                         var _callee = pop(); // Function to call
                         // Args are on stack [arg1, arg2...] (Top is argN)
                         // Wait, if Args are on stack, then Callee was popped LAST?
                         // Compiler:
                         // 1. compile args.
                         // 2. compile callee (if identifier -> PUSH string).
                         // 3. emit CALL.
                         // Stack: [arg1, arg2, ... argN, CALLEE]. 
                    */
                    
                    // So for CALL_SPREAD:
                    // 1. Build Argument Array. Stack: [args_array].
                    // 2. Compile Callee. Stack: [args_array, CALLEE].
                    // 3. Emit CALL_SPREAD.
                    
                    // Compile callee to get its value (could be closure, method, or name)
                    compile_node(_node.callee);
                    
                    emit(PROG_OP.CALL_SPREAD, undefined, _node.line);
                } else {
                    for (var i = 0; i < array_length(_node.args); i++) {
                        compile_node(_node.args[i]);
                    }
                    
                    // Compile callee to get its value (could be closure, method, or name)
                    compile_node(_node.callee);
                    
                    emit(PROG_OP.CALL, array_length(_node.args), _node.line);
                }
                break;
            
            
            case PROG_AST.MEMBER:
                 compile_node(_node.target);
                 var _idx = add_constant(_node.property);
                 emit(PROG_OP.MEMBER_GET, _idx, _node.line);
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
                 // compile collection
                 compile_node(_node.collection);
                 
                 emit(PROG_OP.ITER_INIT, undefined, _node.line);
                 
                 var _loop_start = bytecode.code_size;
                 
                 emit(PROG_OP.ITER_NEXT, undefined, _node.line);
                 // Stack: [iter, defined, value(if defined)]
                 // Actually safer: ITER_NEXT pushes [has_next]. If true, also pushes [value].
                 // Wait, JUMP_IF_FALSE pops.
                 // So:
                 // ITER_NEXT pushes [next_val, true] OR [false].
                 
                 var _jump_exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                 
                 // If true, we have [next_val] on stack (because JUMP_IF_FALSE popped the bool).
                 // Assign to variable
                 var _var_idx = add_constant(_node.variable);
                 emit(PROG_OP.STORE, _var_idx, _node.line);
                 emit(PROG_OP.POP); // Discard stored value
                 
                 compile_node(_node.body);
                 
                 emit(PROG_OP.JUMP, _loop_start, _node.line);
                 
                 patch_jump(_jump_exit, bytecode.code_size);
                 
                 emit(PROG_OP.POP); // Pop iterator
                 break;
            
            
            case PROG_AST.TRY_STMT:
                 var _jump_catch = emit(PROG_OP.PUSH_TRY, 0, _node.line);
                 
                 compile_node(_node.try_block);
                 
                 emit(PROG_OP.POP_TRY, undefined, _node.line);
                 var _jump_end = emit(PROG_OP.JUMP, 0, _node.line);
                 
                 patch_jump(_jump_catch, bytecode.code_size);
                 
                 // Catch handler start
                 // Stack has [exception]. 
                 if (_node.catch_var != undefined) {
                     var _var_idx = add_constant(_node.catch_var);
                     emit(PROG_OP.STORE, _var_idx, _node.line);
                     emit(PROG_OP.POP);
                 } else {
                     emit(PROG_OP.POP); // Discard exception if unnamed
                 }
                 
                 if (_node.catch_block != undefined) {
                     compile_node(_node.catch_block);
                 }
                 
                 patch_jump(_jump_end, bytecode.code_size);
                 break;
            
            
            case PROG_AST.DESTRUCTURING_DECL:
                 // Init
                 if (_node.initializer != undefined) compile_node(_node.initializer);
                 else emit(PROG_OP.PUSH_NULL); // Default null
                 
                 // Stack: [value]
                 var _elements = _node.elements;
                 
                 if (_node.pattern_type == "array") {
                     // Array Destructuring
                     for (var i = 0; i < array_length(_elements); i++) {
                         emit(PROG_OP.DUP); // Keep value for next
                         emit(PROG_OP.PUSH_CONST, add_constant(i));
                         emit(PROG_OP.INDEX_GET, undefined, _node.line);
                         
                         var _name_idx = add_constant(_elements[i]);
                         emit(PROG_OP.STORE, _name_idx, _node.line);
                         emit(PROG_OP.POP);
                     }
                 } else {
                     // Object Destructuring
                     for (var i = 0; i < array_length(_elements); i++) {
                         emit(PROG_OP.DUP);
                         var _prop_idx = add_constant(_elements[i].key);
                         emit(PROG_OP.MEMBER_GET, _prop_idx, _node.line);
                         
                         var _var_idx = add_constant(_elements[i].name);
                         emit(PROG_OP.STORE, _var_idx, _node.line);
                         emit(PROG_OP.POP);
                     }
                 }
                 emit(PROG_OP.POP); // Pop initial value
                 break;
            
        }
    }
    
    static compile_assignment = function(_node) {
         var _target = _node.target;
         var _line = _node.line;
         var _op = _node.op; // PROG_TOKEN.ASSIGN, PLUS, MINUS, etc.
         
         if (_target.type == PROG_AST.IDENTIFIER) {
             var _idx = add_constant(_target.name);
             
             // Compound assignment: load target, push value, apply op
             if (_op != PROG_TOKEN.ASSIGN) {
                 emit(PROG_OP.LOAD, _idx, _line); // Load current value
                 compile_node(_node.value);       // Push RHS
                 // Apply operator
                 switch (_op) {
                     case PROG_TOKEN.PLUS_ASSIGN: emit(PROG_OP.ADD); break;
                     case PROG_TOKEN.MINUS_ASSIGN: emit(PROG_OP.SUB); break;
                     case PROG_TOKEN.STAR_ASSIGN: emit(PROG_OP.MUL); break;
                     case PROG_TOKEN.SLASH_ASSIGN: emit(PROG_OP.DIV); break;
                 }
             } else {
                 compile_node(_node.value); // Simple assignment
             }
             
             // STORE now uses peek(), so value stays on stack after store
             emit(PROG_OP.STORE, _idx, _line);
         }
         else if (_target.type == PROG_AST.MEMBER) {
             // obj.prop = val
             compile_node(_target.target); // Push obj
             compile_node(_node.value);    // Push val
             // Stack: [obj, val]
             // We need to Member Set.
             // MEMBER_SET op: Pops val, Pops obj.
             // But we need to return val?
             // DUP val?
             // Stack: [obj, val] -> DUP -> [obj, val, val]
             // SWAP? (Need SWAP op?)
             // We need [obj, val] -> [obj, val, val] ... ?
             // MEMBER_SET usually expects [obj, val].
             // To leave val on stack: [obj, val] -> [obj, val, val] is wrong order for SET if SET takes (obj, val).
             // If SET takes (obj, val), and we want val left:
             // 1. Push obj.
             // 2. Push val.
             // 3. DUP_X1 (Dup top value and insert down 2 slots)?
             
             // Simplest: `MEMBER_SET` does NOT pop value, only pops Obj? 
             // "Peek value, Pop Obj, Set". 
             // That way value remains on stack.
             // Let's define MEMBER_SET behavior: Pops Obj. Peeks Value. Sets.
             // Wait, usually SET(obj, key, val).
             // My MEMBER_SET arg is `key` (constant).
             // So operands on stack: [obj, value].
             // If I want to keep value:
             // `emit(DUP_X1)`?
             
             // Alternative: `emit(PROG_OP.MEMBER_SET)` pops [obj, val] and pushes [val].
             // Yes, let's make `MEMBER_SET` push the value back (or pass it through).
             var _idx = add_constant(_target.property);
             emit(PROG_OP.MEMBER_SET, _idx, _line);
         }
         else if (_target.type == PROG_AST.INDEX) {
             // arr[i] = val
             compile_node(_target.target); // arr
             compile_node(_target.index);  // i
             compile_node(_node.value);    // val
             // Stack: [arr, i, val]
             // INDEX_SET needs to consume arr, i.
             // And pass-through val.
             emit(PROG_OP.INDEX_SET, undefined, _line);
         }
    }
}
