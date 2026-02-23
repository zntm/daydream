/// @desc Virtual Machine for Proglang bytecode execution

enum PROGLANG_ERROR_TYPE
{
    RUNTIME,
    TYPE,
    INDEX,
    MEMBER,
    VARIABLE,
    DIVIDE_BY_ZERO,
    UNDEFINED_VALUE,
    NULL_REFERENCE,
    INVALID_ARGUMENT,
    NOT_CALLABLE,
    SYNTAX,
    IMPORT,
    /* stack errors */
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
    /* execution limits */
    RECURSION_LIMIT,
    INFINITE_LOOP,
    /* access control */
    ACCESS_DENIED,
    ABSTRACT_METHOD,
    /* file/path errors */
    FILE_NOT_FOUND,
    PATH_SECURITY,
    /* function errors */
    ARITY_MISMATCH,
    SUPER_ERROR
}

// ========== ARRAY-BASED VM STRUCTURE ==========

enum PROG_VM
{
    STACK,          /* array (unified data stack) */
    SP,             /* real (stack pointer) */
    IP,             /* real (instruction pointer) */
    BP,             /* real (base pointer for current frame) */
    SCOPE,          /* array [prog_scope] */
    CONTEXT,        /* struct (external context) */
    GLOBAL_REF,     /* struct (global scope) */
    TRY_STACK,      /* array */
    ACTIVE_MODULE,  /* struct (module info) */
    FRAME_IP,       /* array (real: return instruction pointer) */
    FRAME_BP,       /* array (real: saved base pointer) */
    FRAME_SCOPE,    /* array (array: saved scope) */
    FRAME_BYTECODE, /* array (struct: saved bytecode object) */
    FRAME_GREF,     /* array (struct: saved global reference) */
    FP,             /* real (frame pointer) */
    CURRENT_THIS,   /* any */
    ACTIVE_CLASS,   /* struct */
    CLASS_REGISTRY, /* struct */
    MEMO_CACHES,    /* struct (memo_id -> { hash -> value }) */
    MEMO_ARG_KEYS,  /* array (stack of argument hashes for current calls) */
    SIZE            /* total size */
}

enum PROG_SCOPE
{
    VARS,               /* the actual variables map */
    PARENT,             /* array [prog_scope] or undefined */
    TRACKED_RESOURCES,  /* array of resources to cleanup on scope exit (raii) */
    SIZE
}

#macro PROGLANG_MAX_STEP 1_000_000

// ========== CORE VM FUNCTIONS ==========

/// @desc Reset VM state for reuse
/// @param {Array<PROG_VM>} _vm The VM array
function proglang_vm_reset(_vm)
{
    _vm[@ PROG_VM.SP] = 0;
    _vm[@ PROG_VM.IP] = 0;
    _vm[@ PROG_VM.BP] = 0;
    _vm[@ PROG_VM.FP] = 0;
    
    if (array_length(_vm[PROG_VM.STACK]) < 10_000)
    {
        _vm[@ PROG_VM.STACK] = array_create(10_000);
    }
    
    if (array_length(_vm[PROG_VM.FRAME_IP]) < 1_000)
    {
        _vm[@ PROG_VM.FRAME_IP] = array_create(1_000);
    }
    
    if (array_length(_vm[PROG_VM.FRAME_BP]) < 1_000)
    {
        _vm[@ PROG_VM.FRAME_BP] = array_create(1_000);
    }
    
    if (array_length(_vm[PROG_VM.FRAME_SCOPE]) < 1_000)
    {
        _vm[@ PROG_VM.FRAME_SCOPE] = array_create(1_000);
    }
    
    if (array_length(_vm[PROG_VM.FRAME_BYTECODE]) < 1_000)
    {
        _vm[@ PROG_VM.FRAME_BYTECODE] = array_create(1_000);
    }
    
    if (array_length(_vm[PROG_VM.FRAME_GREF]) < 1_000)
    {
        _vm[@ PROG_VM.FRAME_GREF] = array_create(1_000);
    }

    var _scope = array_create(PROG_SCOPE.SIZE);
    
    _scope[@ PROG_SCOPE.VARS] = {}
    _scope[@ PROG_SCOPE.PARENT] = undefined;
    _scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];
    
    _vm[@ PROG_VM.SCOPE] = _scope;
    _vm[@ PROG_VM.CONTEXT] = undefined;
    _vm[@ PROG_VM.GLOBAL_REF] = {}
    _vm[@ PROG_VM.TRY_STACK] = [];
    _vm[@ PROG_VM.CURRENT_THIS] = undefined;
    _vm[@ PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[@ PROG_VM.ACTIVE_MODULE] = undefined;
    _vm[@ PROG_VM.MEMO_CACHES] = {}
    _vm[@ PROG_VM.MEMO_ARG_KEYS] = [];
}

/// @desc Execute bytecode
/// @param {Array<PROG_VM>} _vm The VM array
/// @param {struct} _bytecode Compiled bytecode object
/// @returns {any} Execution result
function proglang_vm_run(_vm, _entry_bytecode)
{
    if (_entry_bytecode == undefined)
    {
        return undefined;
    }
    
    var _curr_bytecode = _entry_bytecode;
    var _code = _curr_bytecode.code;
    var _constants = _curr_bytecode.constants;
    var _length = array_length(_code);
    
    var _sp = _vm[PROG_VM.SP];
    var _fp = _vm[PROG_VM.FP];
    var _bp = _vm[PROG_VM.BP];
    var _ip = 0; 
    
    var _start_fp = _fp;
    
    var _stack = _vm[PROG_VM.STACK];
    var _f_ip = _vm[PROG_VM.FRAME_IP];
    var _f_bp = _vm[PROG_VM.FRAME_BP];
    var _f_scope = _vm[PROG_VM.FRAME_SCOPE];
    var _f_bytecode = _vm[PROG_VM.FRAME_BYTECODE];
    var _f_gref = _vm[PROG_VM.FRAME_GREF];
    
    var _scope = _vm[PROG_VM.SCOPE];
    var _gref = _vm[PROG_VM.GLOBAL_REF];
    
    var _a, _b, _val, _index, _name, _arr, _obj, _prop, _vm_thrown_error;
    var _steps = 0;
    
    for (;;)
    {
        try
        {
            while (_ip < _length)
            {
                if (++_steps > PROGLANG_MAX_STEP)
                {
                    show_debug_message("[ProgVM] Infinite loop protection triggered");
                    
                    return undefined;
                }
                
                var _op = _code[_ip++];
                var _arg = _code[_ip++];
                
                if (_sp < 0)
                {
                    show_debug_message($"[VM CRITICAL] SP UNDERFLOW BEFORE OP: {_sp}");
                }
                
                switch (_op)
                {
                    /* stack */
                    case PROG_OP.PUSH_NULL:
                        _stack[@ _sp++] = undefined;
                        break;
                    
                    case PROG_OP.PUSH_TRUE:
                        _stack[@ _sp++] = true;
                        break;
                    
                    case PROG_OP.PUSH_FALSE:
                        _stack[@ _sp++] = false;
                        break;
                    
                    case PROG_OP.PUSH_GLOBAL_REF:
                        _stack[@ _sp++] = _gref;
                        break;
                    
                    case PROG_OP.PUSH_CONST:
                        _stack[@ _sp++] = _constants[_arg];
                        break;
                    
                    case PROG_OP.POP:
                        --_sp;
                        break;
                    
                    case PROG_OP.DUP:
                        _stack[@ _sp] = _stack[_sp - 1];
                        
                        ++_sp;
                        break;
                    
                    case PROG_OP.DUP2:
                        _a = _stack[_sp - 1];
                        _b = _stack[_sp - 2];
                        
                        _stack[@ _sp++] = _b;
                        _stack[@ _sp++] = _a;
                        break;
                    
                    case PROG_OP.POP_AND_KEEP:
                        _a = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = _a;
                        break;
                    
                    /* optimization ops */
                    case PROG_OP.INC:
                        ++_stack[@ _sp - 1];
                        break;
                    
                    case PROG_OP.DEC:
                        --_stack[@ _sp - 1];
                        break;
                    
                    case PROG_OP.LOAD_LOCAL:
                        _stack[@ _sp++] = _stack[_bp + _arg];
                        break;
                    
                    case PROG_OP.STORE_LOCAL:
                        _stack[@ _bp + _arg] = _stack[_sp - 1];
                        break;
                    
                    case PROG_OP.INC_LOCAL:
                        ++_stack[@ _bp + _arg];
                        break;
                    
                    case PROG_OP.DEC_LOCAL:
                        --_stack[@ _bp + _arg];
                        break;
                    
                    case PROG_OP.ADD_CONST:
                        _stack[@ _sp - 1] += _constants[_arg];
                        break;
                    
                    /* arithmetic */
                    case PROG_OP.ADD:
                        _b = _stack[--_sp];
                        _a = _stack[_sp - 1];
                        
                        if (is_real(_a)) && (is_real(_b))
                        {
                            _stack[@ _sp - 1] = _a + _b;
                        }
                        else if (is_string(_a)) || (is_string(_b))
                        {
                            var _sa = is_string(_a)
                                ? _a
                                : ((is_bool(_a))
                                    ? ((_a) ? "true" : "false")
                                    : string(_a));
                            
                            var _sb = is_string(_b)
                                ? _b
                                : ((is_bool(_b))
                                    ? ((_b) ? "true" : "false")
                                    : string(_b));
                            
                            _stack[@ _sp - 1] = _sa + _sb;
                        }
                        else if (is_undefined(_a)) || (is_undefined(_b))
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.UNDEFINED_VALUE, "Undefined value in addition.");
                        }
                        else
                        {
                            _stack[@ _sp - 1] = _a + _b; 
                        }
                        break;
                    case PROG_OP.STRING_CONCAT:
                        _b = _stack[--_sp];
                        _a = _stack[_sp - 1];
                        
                        var _sa = is_string(_a)
                            ? _a
                            : ((is_bool(_a))
                                ? ((_a) ? "true" : "false")
                                : string(_a));
                        
                        var _sb = is_string(_b)
                            ? _b
                            : ((is_bool(_b))
                                ? ((_b) ? "true" : "false")
                                : string(_b));
                        
                        _stack[@ _sp - 1] = _sa + _sb;
                        break;  
                    case PROG_OP.SUB:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] -= _b;
                        break;
                    case PROG_OP.MUL:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] *= _b;
                        break;
                    case PROG_OP.DIV: 
                        _b = _stack[--_sp];
                        
                        if (_b == 0)
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.DIVIDE_BY_ZERO, "Division by zero.");
                            
                            break;
                        }
                        
                        _stack[@ _sp - 1] /= _b; 
                        break;
                    case PROG_OP.MOD:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] %= _b;
                        break;
                    
                    case PROG_OP.POW:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = power(_stack[_sp - 1], _b);
                        break;
                    
                    case PROG_OP.NEG:
                        _stack[@ _sp - 1] = -_stack[_sp - 1];
                        break;
                    
                    /* comparison */
                    case PROG_OP.EQ:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] == _b);
                        break;
                    
                    case PROG_OP.NE:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] != _b);
                        break;
                    
                    case PROG_OP.LT:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] < _b);
                        break;
                    
                    case PROG_OP.GT:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] > _b);
                        break;
                    
                    case PROG_OP.LE:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] <= _b);
                        break;
                    
                    case PROG_OP.GE:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] >= _b);
                        break;
                    
                    /* logical/bitwise */
                    case PROG_OP.NOT:
                        _stack[@ _sp - 1] = !_stack[_sp - 1];
                        break;
                    
                    case PROG_OP.AND:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] && _b);
                        break;
                    
                    case PROG_OP.OR:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = (_stack[_sp - 1] || _b);
                        break;
                    
                    case PROG_OP.BIT_AND:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = floor(_stack[_sp - 1]) & floor(_b);
                        break;
                    
                    case PROG_OP.BIT_OR:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = floor(_stack[_sp - 1]) | floor(_b);
                        break;
                    
                    case PROG_OP.BIT_XOR:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = floor(_stack[_sp - 1]) ^ floor(_b);
                        break;
                    
                    case PROG_OP.BIT_NOT:
                        _stack[_sp - 1] = ~floor(_stack[_sp - 1]);
                        break;
                    
                    case PROG_OP.SHL:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = floor(_stack[_sp - 1]) << floor(_b);
                        break;
                    
                    case PROG_OP.SHR:
                        _b = _stack[--_sp];
                        
                        _stack[@ _sp - 1] = floor(_stack[_sp - 1]) >> floor(_b);
                        break;
                    
                    case PROG_OP.LOAD:
                        _name = _constants[_arg];
                        
                        if (struct_exists(_scope[PROG_SCOPE.VARS], _name))
                        {
                            _stack[@ _sp++] = _scope[PROG_SCOPE.VARS][$ _name];
                            
                            break;
                        }
                        
                        var _s_load = _scope[PROG_SCOPE.PARENT];
                        var _found_load = false;
                        
                        while (_s_load != undefined)
                        {
                            if (struct_exists(_s_load[PROG_SCOPE.VARS], _name))
                            {
                                _stack[@ _sp++] = _s_load[PROG_SCOPE.VARS][$ _name];
                                _found_load = true;
                                
                                break;
                            }
                            
                            _s_load = _s_load[PROG_SCOPE.PARENT];
                        }
                        
                        if (_found_load) break;
                        
                        if (_vm[PROG_VM.CONTEXT] != undefined) && (struct_exists(_vm[PROG_VM.CONTEXT], _name))
                        {
                            _val = _vm[PROG_VM.CONTEXT][$ _name];
                            
                            _stack[@ _sp++] = is_method(_val) ? method_call(_val, []) : _val;
                        }
                        else if (struct_exists(global.proglang_macros, _name))
                        {
                            _val = global.proglang_macros[$ _name];
                            
                            _stack[@ _sp++] = is_method(_val) ? method_call(_val, []) : _val;
                        }
                        else if (struct_exists(_gref, _name))
                        {
                            _stack[@ _sp++] = _gref[$ _name];
                        }
                        else if (struct_exists(global.proglang_exports, _name))
                        {
                            _stack[@ _sp++] = global.proglang_exports[$ _name];
                        }
                        else if (struct_exists(global.proglang_scripts, _name))
                        {
                            _stack[@ _sp++] = global.proglang_scripts[$ _name];
                        }
                        else if (struct_exists(global.proglang_functions, _name))
                        {
                            _stack[@ _sp++] = global.proglang_functions[$ _name];
                        }
                        else if (_name == "global")
                        {
                            _stack[@ _sp++] = global;
                        }
                        else if (struct_exists(global, _name))
                        {
                            _stack[@ _sp++] = global[$ _name];
                        }
                        else
                        { 
                            runtime_error(PROGLANG_ERROR_TYPE.VARIABLE, $"Variable '{_name}' not found.");
                        }
                        break;
                        
                    case PROG_OP.STORE:
                        _val = _stack[_sp - 1];
                        _name = _constants[_arg];
                        
                        var _s_store = _scope;
                        var _target_s = undefined;
                        
                        while (_s_store != undefined)
                        {
                            if (struct_exists(_s_store[PROG_SCOPE.VARS], _name))
                            {
                                _target_s = _s_store;
                                
                                break;
                            }
                            
                            _s_store = _s_store[PROG_SCOPE.PARENT];
                        }
                        
                        if (_target_s != undefined)
                        {
                            _target_s[@ PROG_SCOPE.VARS][$ _name] = _val;
                        }
                        else if (_vm[PROG_VM.CONTEXT] != undefined) && (struct_exists(_vm[PROG_VM.CONTEXT], _name))
                        {
                            _vm[@ PROG_VM.CONTEXT][$ _name] = _val;
                        }
                        else if (struct_exists(_gref, _name))
                        {
                            _gref[$ _name] = _val;
                        }
                        else
                        {
                            _scope[@ PROG_SCOPE.VARS][$ _name] = _val;
                        }
                        break;
                        
                    case PROG_OP.DEFINE:
                        _val = _stack[_sp - 1];
                        _name = _constants[_arg];
                        
                        _vm[@ PROG_VM.SCOPE][@ PROG_SCOPE.VARS][$ _name] = _val;
                        break;
                        
                    case PROG_OP.LOAD_GLOBAL:
                        _stack[@ _sp++] = _gref[$ _constants[_arg]];
                        break;
                    
                    case PROG_OP.STORE_GLOBAL:
                        _gref[$ _constants[_arg]] = _stack[_sp - 1];
                        break;
                        
                    /* scope */
                    case PROG_OP.PUSH_SCOPE:
                        var _new_scope = array_create(PROG_SCOPE.SIZE);
                        
                        _new_scope[@ PROG_SCOPE.VARS] = {}
                        _new_scope[@ PROG_SCOPE.PARENT] = _vm[PROG_VM.SCOPE];
                        _new_scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];
                        
                        _vm[@ PROG_VM.SCOPE] = _new_scope;
                        _scope = _new_scope;
                        break;
                        
                    case PROG_OP.POP_SCOPE:
                        var _parent = _scope[PROG_SCOPE.PARENT];
                        
                        if (_parent != undefined)
                        {
                            proglang_scope_cleanup(_scope);
                            
                            _vm[@ PROG_VM.SCOPE] = _parent;
                            _scope = _parent;
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Scope underflow");
                        }
                        break;
                    
                    case PROG_OP.JUMP:
                        _ip = _arg;
                        break;
                        
                    case PROG_OP.JUMP_IF_FALSE:
                        _val = _stack[--_sp];
                        
                        if (!_val)
                        {
                            _ip = _arg;
                        }
                        break;
                        
                    case PROG_OP.JUMP_IF_TRUE:
                        _val = _stack[--_sp];
                        
                        if (_val)
                        {
                            _ip = _arg;
                        }
                        break;
                        
                    case PROG_OP.JUMP_IF_NULL:
                        if (is_undefined(_stack[_sp - 1]))
                        {
                            _ip = _arg;
                        }
                        break;
                        
                    case PROG_OP.JUMP_IF_NOT_NULL:
                        if (!is_undefined(_stack[_sp - 1]))
                        {
                            _ip = _arg;
                        }
                        break;
                    
                    case PROG_OP.CALL:
                    case PROG_OP.CALL_SPREAD:
                        var _param_count = 0;
                        var _callee_index = 0;
                        
                        if (_op == PROG_OP.CALL)
                        {
                            _param_count = _arg;
                            _callee_index = _sp - _param_count - 1;
                            _val = _stack[_callee_index];
                        }
                        else
                        {
                            var _args_arr = _stack[--_sp];
                            
                            _val = _stack[--_sp];
                            _param_count = array_length(_args_arr);
                            
                            _stack[@ _sp++] = _val;
                            
                            for (var i = 0; i < _param_count; ++i)
                            {
                                _stack[@ _sp++] = _args_arr[i];
                            }
                            
                            _callee_index = _sp - _param_count - 1;
                        }
                        
                        if (is_string(_val))
                        {
                            if (struct_exists(global.proglang_functions, _val))
                            {
                                _val = global.proglang_functions[$ _val];
                            }
                            else if (struct_exists(global.proglang_scripts, _val))
                            {
                                var _s = global.proglang_scripts[$ _val];
                                
                                _val = (is_array(_s)) && (array_length(_s) >= PROG_MODULE.SIZE)
                                    ? _s[PROG_MODULE.MAIN]
                                    : _s;
                            }
                            else if (_vm[PROG_VM.CONTEXT] != undefined) && (struct_exists(_vm[PROG_VM.CONTEXT], _val))
                            {
                                _val = _vm[PROG_VM.CONTEXT][$ _val];
                            }
                            else 
                            {
                                var _asset = asset_get_index(_val);
                                
                                if (_asset != -1) && (asset_get_type(_val) == asset_script)
                                {
                                    _val = _asset;
                                }
                            }
                        }
                        
                        if (is_array(_val)) && (array_length(_val) >= PROG_CLOSURE.SIZE) && (_val[PROG_CLOSURE.TYPE] == "closure")
                        {
                            var _expected_count = _val[PROG_CLOSURE.PARAM_COUNT];
                            
                            if (_param_count < _expected_count)
                            {
                                var _diff = _expected_count - _param_count;
                                
                                repeat(_diff)
                                {
                                    _stack[@ _sp++] = undefined;
                                }
                                
                                _param_count = _expected_count;
                            }
                            
                            _f_ip[@ _fp] = _ip;
                            _f_bp[@ _fp] = _bp;
                            _f_scope[@ _fp] = _scope;
                            _f_bytecode[@ _fp] = _curr_bytecode;
                            _f_gref[@ _fp] = _gref;
                            
                            ++_fp;
                            
                            _curr_bytecode = _val[PROG_CLOSURE.BYTECODE];
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _length = array_length(_code);
                            _ip = 0;
                            _bp = _sp - _param_count;
                            
                            var _closure_env = _val[PROG_CLOSURE.ENV];
                            var _new_scope = array_create(PROG_SCOPE.SIZE);
                            
                            _new_scope[@ PROG_SCOPE.VARS] = {}
                            _new_scope[@ PROG_SCOPE.PARENT] = _closure_env;
                            
                            _vm[@ PROG_VM.SCOPE] = _new_scope;
                            
                            _scope = _new_scope;
                            
                            _gref = _val[PROG_CLOSURE.GLOBAL_REF];
                            
                            _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                        }
                        else if (is_struct(_val)) && (struct_exists(_val, "function"))
                        {
                            var _args_subset = array_create(_param_count);
                            
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            
                            _sp -= _param_count + 1;
                            
                            var _res = _val[$ "function"](_args_subset, _vm);
                            
                            _stack[@ _sp++] = _res;
                        }
                        else if (is_real(_val)) && (script_exists(_val))
                        {
                            var _args_subset = array_create(_param_count);
                            
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            
                            _sp -= _param_count + 1;
                            
                            var _res = script_execute_ext(_val, _args_subset);
                            
                            _stack[@ _sp++] = _res;
                        }
                        else if (is_method(_val))
                        {
                            var _args_subset = array_create(_param_count);
                            
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            
                            _sp -= _param_count + 1;
                            
                            var _res = method_call(_val, _args_subset);
                            
                            _stack[@ _sp++] = _res;
                        }
                        else if (is_struct(_val)) && (struct_exists(_val, "code"))
                        {
                            _f_ip[@ _fp] = _ip;
                            _f_bp[@ _fp] = _bp;
                            _f_scope[@ _fp] = _scope;
                            _f_bytecode[@ _fp] = _curr_bytecode;
                            _f_gref[@ _fp] = _gref;
                            
                            ++_fp;
                            
                            _curr_bytecode = _val;
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _length = array_length(_code);
                            _ip = 0;
                            _bp = _sp - _param_count;
                            
                            var _new_scope = array_create(PROG_SCOPE.SIZE);
                            
                            _new_scope[@ PROG_SCOPE.VARS] = {}
                            _new_scope[@ PROG_SCOPE.PARENT] = undefined;
                            
                            _vm[@ PROG_VM.SCOPE] = _new_scope;
                            
                            _scope = _new_scope;
                        }
                        else
                        {
                            show_debug_message($"[ProgVM] Error: Call to non-callable value: {_val}");
                            
                            _sp -= (_param_count + 1);
                            
                            _stack[@ _sp++] = undefined;
                        }
                        break;
                        
                    case PROG_OP.RETURN:
                        var _val = _stack[--_sp];
                        
                        proglang_scope_cleanup(_scope);
                        
                        if (_curr_bytecode.is_constructor)
                        {
                            _val = _vm[PROG_VM.CURRENT_THIS];
                        }
                        
                        if (_fp == _start_fp)
                        {
                            _vm[@ PROG_VM.SP] = _sp;
                            _vm[@ PROG_VM.IP] = _ip;
                            _vm[@ PROG_VM.BP] = _bp;
                            _vm[@ PROG_VM.FP] = _fp;
                            
                            return _val;
                        }
                        
                        var _return_bp = _bp;
                        
                        --_fp;
                        
                        _gref = _f_gref[_fp];
                        _curr_bytecode = _f_bytecode[_fp];
                        _scope = _f_scope[_fp];
                        _bp = _f_bp[_fp];
                        _ip = _f_ip[_fp];
                        
                        _vm[@ PROG_VM.SCOPE] = _scope;
                        _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                        
                        _code = _curr_bytecode.code;
                        _constants = _curr_bytecode.constants;
                        _length = array_length(_code);
                        _sp = _return_bp - 1;
                        
                        _stack[@ _sp++] = _val;
                        break;
                        
                    /* try/catch */
                    case PROG_OP.PUSH_TRY:
                        array_push(_vm[PROG_VM.TRY_STACK], {
                            ip: _arg,
                            fp: _fp,
                            sp: _sp
                        });
                        break;
                    
                    case PROG_OP.POP_TRY:
                        array_pop(_vm[PROG_VM.TRY_STACK]);
                        break;
                    
                    case PROG_OP.THROW:
                        _val = _stack[--_sp];
                        
                        throw _val;
                        break;
                        
                    /* structure access */
                    case PROG_OP.INDEX_GET:
                        _index = _stack[--_sp];
                        _arr = _stack[--_sp];
                        
                        if (is_array(_index)) && (array_length(_index) >= 3) && (_index[0] == "range")
                        {
                            var _start = _index[1];
                            var _end = _index[2];
                            
                            if (is_array(_arr))
                            {
                                var _arr_len = array_length(_arr);
                                
                                if (_start < 0)
                                {
                                    _start = 0;
                                }
                                
                                if (_end >= _arr_len)
                                {
                                    _end = _arr_len - 1;
                                }
                                
                                var _slice_len = _end - _start + 1;
                                
                                if (_slice_len > 0)
                                {
                                    _val = array_create(_slice_len);
                                    
                                    array_copy(_val, 0, _arr, _start, _slice_len);
                                }
                                else
                                {
                                    _val = [];
                                }
                            }
                            else if (is_string(_arr))
                            {
                                var _str_len = string_length(_arr);
                                
                                if (_start < 0)
                                {
                                    _start = 0;
                                }
                                
                                if (_end >= _str_len)
                                {
                                    _end = _str_len - 1;
                                }
                                
                                var _slice_len = _end - _start + 1;
                                
                                if (_slice_len > 0)
                                {
                                    _val = string_copy(_arr, _start + 1, _slice_len);
                                }
                                else
                                {
                                    _val = "";
                                }
                            }
                            else
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.TYPE, "Range indexing only supported on arrays and strings.");
                            }
                        }
                        else
                        {
                            if (is_array(_arr))
                            {
                                _val = _arr[_index];
                            }
                            else if (is_struct(_arr))
                            {
                                _val = _arr[$ _index];
                            }
                            else if (is_string(_arr))
                            {
                                _val = string_char_at(_arr, _index + 1);
                            }
                            else
                            {
                                _val = undefined;
                            }
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.INDEX_SET:
                        _val = _stack[--_sp];
                        _index = _stack[--_sp];
                        _arr = _stack[--_sp];
                        
                        if (is_array(_arr))
                        {
                            _arr[@ _index] = _val;
                        }
                        else if (is_struct(_arr))
                        {
                            _arr[$ _index] = _val;
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.MEMBER_GET:
                        _prop = _constants[_arg];
                        _obj = _stack[--_sp];
                        _val = undefined;
                        
                        if (is_struct(_obj)) && (struct_exists(_obj, "__super__"))
                        {
                            var _super_class = _obj.__super__;
                            var _receiver = _obj.receiver;
                            var _curr = _super_class;
                            var _found = false;
                            
                            while (_curr != undefined)
                            {
                                if (struct_exists(_curr.methods, _prop))
                                {
                                    var _method_entry = _curr.methods[$ _prop];
                                    
                                    _val = array_create(PROG_CLOSURE.SIZE);
                                    
                                    _val[@ PROG_CLOSURE.TYPE] = "closure";
                                    _val[@ PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                    _val[@ PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE];
                                    _val[@ PROG_CLOSURE.NAME] = _prop;
                                    _val[@ PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                    _val[@ PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                    _val[@ PROG_CLOSURE.RECEIVER] = _receiver;
                                    _val[@ PROG_CLOSURE.GLOBAL_REF] = _gref;
                                    
                                    _found = true;
                                    
                                    break;
                                }
                                
                                _curr = _curr.super_class;
                            }
                            
                            if (!_found)
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Property '{_prop}' not found in super class.");
                            }
                        }
                        else if (is_struct(_obj)) || ((is_numeric(_obj)) && (instance_exists(_obj)))
                        {
                            if (is_struct(_obj))
                            {
                                if (struct_exists(_obj, _prop))
                                {
                                    _val = _obj[$ _prop];
                                }
                                else if (struct_exists(_obj, "__class__"))
                                {
                                    var _class = _obj.__class__;
                                    var _curr = _class;
                                    var _found = false;
                                    
                                    while (_curr != undefined)
                                    {
                                        if (struct_exists(_curr.methods, _prop))
                                        {
                                            var _method_entry = _curr.methods[$ _prop];
                                            
                                            _val = array_create(PROG_CLOSURE.SIZE);
                                            
                                            _val[@ PROG_CLOSURE.TYPE] = "closure";
                                            _val[@ PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                            _val[@ PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE]; 
                                            _val[@ PROG_CLOSURE.NAME] = _prop;
                                            _val[@ PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                            _val[@ PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                            _val[@ PROG_CLOSURE.RECEIVER] = _obj;
                                            _val[@ PROG_CLOSURE.GLOBAL_REF] = _gref;
                                            
                                            _found = true;
                                            
                                            break;
                                        }
                                        
                                        _curr = _curr.super_class;
                                    }
                                    
                                    if (!_found)
                                    {
                                        runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Property or method '{_prop}' not found.");
                                    }
                                }
                                else
                                {
                                    _val = undefined;
                                }
                            }
                            else
                            {
                                _val = (variable_instance_exists(_obj, _prop))
                                    ? variable_instance_get(_obj, _prop)
                                    : undefined;
                            }
                        }
                        else
                        {
                            if (is_string(_obj))
                            {
                                if (_prop == "length")
                                {
                                    _val = string_length(_obj);
                                }
                                else
                                {
                                    runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Unknown string property");
                                }
                            }
                            else if (is_array(_obj))
                            {
                                if (_prop == "length")
                                {
                                    _val = array_length(_obj);
                                }
                                else if (_prop == "push")
                                {
                                    _val = method(_obj, function(_val)
                                    {
                                        array_push(self, _val);
                                    });
                                }
                                else if (_prop == "pop")
                                {
                                    _val = method(_obj, function()
                                    {
                                        return array_pop(self);
                                    });
                                }
                                else
                                {
                                    runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Unknown array property");
                                }
                            }
                            else
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Cannot access property '{_prop}' of non-object (value is {string(_obj)}).");
                            }
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                        
                    case PROG_OP.MEMBER_SET:
                        _val = _stack[--_sp];
                        _prop = _constants[_arg];
                        _obj = _stack[--_sp];
                        
                        if (is_struct(_obj))
                        {
                            _obj[$ _prop] = _val;
                        }
                        else if (is_numeric(_obj)) && (instance_exists(_obj))
                        {
                            variable_instance_set(_obj, _prop, _val);
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Cannot set property of non-object.");
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                    
                    /* creation */
                    case PROG_OP.ARRAY_NEW:
                        var _sz = _arg;
                        var _arr = array_create(_sz);
                        
                        for (var i = _sz - 1; i >= 0; --i)
                        {
                            _arr[@ i] = _stack[--_sp];
                        }
                        
                        _stack[@ _sp++] = _arr;
                        break;
                        
                    case PROG_OP.OBJECT_NEW:
                        var _sz = _arg;
                        var _obj = {}
                        
                        for (var i = _sz - 1; i >= 0; --i)
                        {
                            var _v = _stack[--_sp];
                            var _k = _stack[--_sp];
                            
                            _obj[$ _k] = _v;
                        }
                        
                        _stack[@ _sp++] = _obj;
                        break;
                        
                    case PROG_OP.MAKE_REGEX:
                        var _flags = _stack[--_sp];
                        var _pattern = _stack[--_sp];
                        
                        _stack[@ _sp++] = new Regex(_pattern, _flags);
                        break;
                        
                    /* spread operations */
                    case PROG_OP.PUSH_ARRAY_EMPTY:
                        _stack[@ _sp++] = [];
                        break;
                    
                    case PROG_OP.ARRAY_PUSH:
                        var _val = _stack[--_sp];
                        var _arr = _stack[_sp - 1]; 
                        
                        array_push(_arr, _val);
                        break;
                    
                    case PROG_OP.ARRAY_SPREAD:
                        var _arr = _stack[--_sp]; 
                        var _target = _stack[_sp - 1]; 
                        
                        if (is_array(_arr))
                        {
                            var _arr_spread_len = array_length(_arr);
                            
                            for (var i = 0; i < _arr_spread_len; ++i)
                            {
                                array_push(_target, _arr[i]);
                            }
                        }
                        break;
                        
                    case PROG_OP.MAKE_CLOSURE:
                        var _func = _stack[--_sp];
                        
                        if (is_array(_func)) && (array_length(_func) >= PROG_FUNC.SIZE)
                        {
                            var _closure_arr = array_create(PROG_CLOSURE.SIZE);
                            
                            _closure_arr[@ PROG_CLOSURE.TYPE] = "closure";
                            _closure_arr[@ PROG_CLOSURE.BYTECODE] = _func[PROG_FUNC.BYTECODE];
                            _closure_arr[@ PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE];
                            _closure_arr[@ PROG_CLOSURE.NAME] = _func[PROG_FUNC.NAME];
                            _closure_arr[@ PROG_CLOSURE.PARAM_COUNT] = _func[PROG_FUNC.PARAM_COUNT];
                            _closure_arr[@ PROG_CLOSURE.GLOBAL_REF] = _gref;
                            
                            _stack[@ _sp++] = _closure_arr;
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.TYPE, "MAKE_CLOSURE expects a function constant");
                        }
                        break;
                    
                    case PROG_OP.NEW_INSTANCE:
                        var _arg_count = _arg;
                        var _class = _stack[--_sp];
                        
                        if (!is_struct(_class)) || (!struct_exists(_class, "__type__")) || (_class.__type__ != "class")
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.TYPE, "Target is not a class.");
                        }
                        
                        var _inst = {
                            __class__: _class,
                            __type__: "instance"
                        }
                        
                        if (struct_exists(_class, "fields"))
                        {
                            var _fields = _class.fields;
                            
                            for (var k = array_length(_fields) - 1; k >= 0; --k)
                            {
                                var _field = _fields[k];
                                
                                _inst[$ _field.name] = _field.value;
                            }
                        }
                        
                        if (struct_exists(_class, "constructor_code") && (_class.constructor_code != undefined))
                        {
                            _f_ip[@ _fp] = _ip;
                            _f_bp[@ _fp] = _bp;
                            _f_scope[@ _fp] = _scope;
                            _f_bytecode[@ _fp] = _curr_bytecode;
                            _f_gref[@ _fp] = _fp;
                            
                            ++_fp;
                            
                            _vm[@ PROG_VM.CURRENT_THIS] = _inst;
                            
                            _curr_bytecode = _class.constructor_code;
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _length = array_length(_code);
                            _ip = 0;
                            
                            var _c_scope = array_create(PROG_SCOPE.SIZE);
                            
                            _c_scope[@ PROG_SCOPE.VARS] = {}
                            _c_scope[@ PROG_SCOPE.PARENT] = undefined;
                            _c_scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];
                            
                            _scope = _c_scope;
                            _bp = _sp - _arg_count;
                        }
                        else
                        {
                            _sp -= _arg_count; 
                            _stack[@ _sp++] = _inst;
                        }
                        break;
                    
                    case PROG_OP.LOAD_SUPER:
                        if (_vm[PROG_VM.CURRENT_THIS] == undefined) || (!struct_exists(_vm[PROG_VM.CURRENT_THIS], "__class__"))
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "'super' used outside of class instance.");
                        }
                        
                        var _class_super = (_vm[PROG_VM.ACTIVE_CLASS] != undefined)
                            ? _vm[PROG_VM.ACTIVE_CLASS]
                            : _vm[PROG_VM.CURRENT_THIS].__class__;
                        
                        if (_class_super.super_class == undefined)
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Class has no super class.");
                        }
                        
                        _stack[@ _sp++] = {
                            __super__: _class_super.super_class,
                            receiver: _vm[PROG_VM.CURRENT_THIS]
                        }
                        break;
                        
                    /* iteration */
                    case PROG_OP.ITER_INIT:
                        var _coll = _stack[--_sp];
                        /*
                         * 0: default
                         * 1: key
                         * 2: value
                         * 3: pair
                         */
                        var _mode = _arg; 
                        var _iter = undefined;
                        
                        if (is_array(_coll))
                        {
                            _iter = (array_length(_coll) >= 3) && (_coll[0] == "range")
                                ? {
                                    type: "range_iter",
                                    current: _coll[1],
                                    range_end: _coll[2],
                                    done: false
                                }
                                : {
                                    type: "array_iter",
                                    val: _coll,
                                    idx: 0,
                                    len: array_length(_coll)
                                }
                        }
                        else if (is_struct(_coll))
                        {
                            if (_mode == 0)
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Iterating struct with 'in' requires explicit 'key' or 'value' modifier.");
                            }
                            
                            var _keys = struct_get_names(_coll);
                            
                            _iter = {
                                type: "struct_iter",
                                val: _coll,
                                keys: _keys,
                                idx: 0,
                                len: array_length(_keys)
                            }
                        }
                        else
                        {
                            _iter = {
                                type: "empty",
                                idx: 0,
                                len: 0
                            }
                        }
                        
                        _stack[@ _sp++] = _iter;
                        break;
                    
                    case PROG_OP.ITER_NEXT:
                        var _iter = _stack[_sp - 1];
                        
                        if (_iter.type == "range_iter")
                        {
                            if (!_iter.done && _iter.current <= _iter.range_end)
                            {
                                var _val = _iter.current;
                                
                                ++_iter.current;
                                
                                if (_iter.current > _iter.range_end)
                                {
                                    _iter.done = true;
                                }
                                
                                _stack[@ _sp++] = _val;
                                _stack[@ _sp++] = true;
                            }
                            else
                            {
                                _stack[@ _sp++] = false;
                            }
                        }
                        else if (_iter.idx < _iter.len)
                        {
                            var _key = undefined;
                            
                            if (_iter.type == "array_iter")
                            {
                                _key = _iter.idx;
                            }
                            else if (_iter.type == "struct_iter")
                            {
                                _key = _iter.keys[_iter.idx];
                            }
                            
                            ++_iter.idx;
                            
                            _stack[@ _sp++] = _key;
                            _stack[@ _sp++] = true;
                        }
                        else
                        {
                            _stack[@ _sp++] = false;
                        }
                        break;
                    
                    case PROG_OP.ITER_GET_VAL:
                        var _iter = _stack[_sp - 1];
                        var _val = undefined;
                        
                        if (_iter.type == "range_iter")
                        {
                            _val = _iter.current - 1;
                        }
                        else if (_iter.type == "array_iter")
                        {
                            _val = _iter.val[_iter.idx - 1];
                        }
                        else if (_iter.type == "struct_iter")
                        {
                            _val = _iter.val[$ _iter.keys[_iter.idx - 1]];
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.CLASS_DEF:
                        _stack[@ _sp++] = _constants[_arg];
                        break;
                        
                    case PROG_OP.LOAD_THIS:
                        _stack[@ _sp++] = _vm[PROG_VM.CURRENT_THIS];
                        break;
                    
                    /* modules */
                    case PROG_OP.IMPORT:
                        var _path = _constants[_arg];
                        var _cur_file = "";
                        var _s_import = _scope;
                        
                        while (_s_import != undefined)
                        {
                            var _filename = _s_import[PROG_SCOPE.VARS][$ "__filename"];
                            
                            if (_filename != undefined)
                            {
                                _cur_file = _filename;
                                
                                break;
                            }
                            
                            _s_import = _s_import[PROG_SCOPE.PARENT];
                        }
                        
                        var _exports = proglang_load_module(_path, _cur_file);
                        
                        _stack[@ _sp++] = _exports;
                        break;
                        
                    case PROG_OP.IMPORT_UI:
                        var _ui_path = _constants[_arg];
                        var _ui_def = ui_load(_ui_path);
                        
                        _stack[@ _sp++] = _ui_def;
                        break;
                        
                    case PROG_OP.EXPORT_SET:
                        var _name = _constants[_arg];
                        var _val = _stack[_sp - 1]; 
                        
                        if (_vm[PROG_VM.ACTIVE_MODULE] != undefined)
                        {
                            _vm[@ PROG_VM.ACTIVE_MODULE].exports[$ _name] = _val;
                        }
                        else if (variable_global_exists("proglang_exports"))
                        {
                            global.proglang_exports[$ _name] = _val;
                        }
                        break;
                        
                    /* new v2 ops */
                    case PROG_OP.IN_CHECK:
                        var _rhs = _stack[--_sp];
                        var _lhs = _stack[--_sp];
                        var _result = false;
                        
                        if (is_array(_rhs))
                        {
                            for (var i = array_length(_rhs) - 1; i >= 0; --i)
                            {
                                if (_rhs[i] != _lhs) continue;
                                
                                _result = true;
                                
                                break;
                            }
                        }
                        else if (is_string(_rhs))
                        {
                            _result = string_contains(string(_rhs), _lhs);
                        }
                        
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.IN_KEY:
                        _rhs = _stack[--_sp];
                        _lhs = _stack[--_sp];
                        _result = false;
                        
                        if (is_struct(_rhs))
                        {
                            _result = struct_exists(_rhs, _lhs);
                        }
                        
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.IN_VALUE:
                        _rhs = _stack[--_sp];
                        _lhs = _stack[--_sp];
                        _result = false;
                        
                        if (is_struct(_rhs))
                        {
                            var _names = struct_get_names(_rhs);
                            
                            for (var i = array_length(_names) - 1; i >= 0; --i)
                            {
                                if (_rhs[$ _names[i]] != _lhs) continue;
                                
                                _result = true;
                                
                                break;
                            }
                        }
                        
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.MAKE_RANGE:
                        var _end = _stack[--_sp];
                        var _start = _stack[--_sp];
                        var _range = ["range", _start, _end];
                        
                        _stack[@ _sp++] = _range;
                        break;
                    
                    case PROG_OP.MEMOIZE_CHECK:
                        var _memo_id = _arg;
                        var _p_count = _curr_bytecode.param_count;
                        var _args = array_create(_p_count);
                        
                        for (var i = _p_count - 1; i >= 0; --i)
                        {
                            _args[@ i] = _stack[_bp + i];
                        }
                        
                        var _hash = string(_args);
                        
                        array_push(_vm[PROG_VM.MEMO_ARG_KEYS], _hash);
                        
                        var _cache = _vm[PROG_VM.MEMO_CACHES][$ _memo_id];
                        
                        if (_cache != undefined && struct_exists(_cache, _hash))
                        {
                            var _val = _cache[$ _hash];
                            
                            array_pop(_vm[PROG_VM.MEMO_ARG_KEYS]);
                            
                            var _return_bp = _bp;
                            
                            --_fp;
                            
                            _gref = _f_gref[_fp];
                            _curr_bytecode = _f_bytecode[_fp];
                            _scope = _f_scope[_fp];
                            _bp = _f_bp[_fp];
                            _ip = _f_ip[_fp];
                            
                            _vm[@ PROG_VM.SCOPE] = _scope;
                            _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                            
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _length = array_length(_code);
                            _sp = _return_bp - 1;
                            
                            _stack[@ _sp++] = _val;
                        }
                        break;
                        
                    case PROG_OP.MEMOIZE_STORE:
                        var _memo_id = _arg;
                        var _val = _stack[_sp - 1];
                        var _hash = array_pop(_vm[PROG_VM.MEMO_ARG_KEYS]);
                        
                        if (!struct_exists(_vm[PROG_VM.MEMO_CACHES], _memo_id))
                        {
                            _vm[@ PROG_VM.MEMO_CACHES][$ _memo_id] = {}
                        }
                        
                        _vm[PROG_VM.MEMO_CACHES][$ _memo_id][$ _hash] = _val;
                        break;
                }
            }
        }
        catch (_vm_exception)
        {
            var _try_stack = _vm[PROG_VM.TRY_STACK];
            
            if (array_length(_try_stack) == 0)
            {
                throw _vm_exception;
            }
            
            var _handler = _try_stack[array_length(_try_stack) - 1];
            
            array_pop(_try_stack);
            
            while (_fp > _handler.fp)
            {
                --_fp;
                
                _gref = _f_gref[_fp];
                _curr_bytecode = _f_bytecode[_fp];
                _scope = _f_scope[_fp];
                _bp = _f_bp[_fp];
                _ip = _f_ip[_fp];
            }
            
            _vm[@ PROG_VM.SCOPE] = _scope;
            _vm[@ PROG_VM.GLOBAL_REF] = _gref;
            
            _code = _curr_bytecode.code;
            _constants = _curr_bytecode.constants;
            _length = array_length(_code);
            _ip = _handler.ip;
            
            _vm[@ PROG_VM.SCOPE] = _scope;
            
            _sp = _handler.sp;
            _stack[@ _sp++] = _vm_exception;
            
            continue;
        }
        
        if (_fp <= _start_fp)
        {
            return undefined;
        }
        
        _sp = _bp - 1;
        _stack[@ _sp++] = undefined;
        
        _gref = _frames[--_fp];
        _curr_bytecode = _frames[--_fp];
        _scope = _frames[--_fp];
        _bp = _frames[--_fp]; 
        _ip = _frames[--_fp];
        
        _vm[@ PROG_VM.SCOPE] = _scope;
        _vm[@ PROG_VM.GLOBAL_REF] = _gref;
        
        _code = _curr_bytecode.code;
        _constants = _curr_bytecode.constants;
        _length = array_length(_code);
    }
}


// ========== VM POOL MANAGEMENT (Global) ==========

/// @desc Initialize VM pool if needed
function proglang_vm_pool_init()
{
    if (!variable_global_exists("proglang_vm_pool"))
    {
        global.proglang_vm_pool = [];
        global.proglang_vm_pool_max = 32;
        global.proglang_vm_alloc_count = 0;
        global.proglang_vm_gc_threshold = 100;
    }
}

function proglang_vm_create_impl()
{
    var _vm = array_create(PROG_VM.SIZE);
    
    _vm[@ PROG_VM.STACK] = array_create(1024);
    _vm[@ PROG_VM.FRAME_IP] = array_create(256);
    _vm[@ PROG_VM.FRAME_BP] = array_create(256);
    _vm[@ PROG_VM.FRAME_SCOPE] = array_create(256);
    _vm[@ PROG_VM.FRAME_BYTECODE] = array_create(256);
    _vm[@ PROG_VM.FRAME_GREF] = array_create(256);
    
    _vm[@ PROG_VM.SP] = 0;
    _vm[@ PROG_VM.IP] = 0;
    _vm[@ PROG_VM.BP] = 0;
    _vm[@ PROG_VM.FP] = 0;
    
    var _scope = array_create(PROG_SCOPE.SIZE);
    
    _scope[@ PROG_SCOPE.VARS] = {}
    _scope[@ PROG_SCOPE.PARENT] = undefined;
    _scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];
    
    _vm[@ PROG_VM.SCOPE] = _scope;
    _vm[@ PROG_VM.CONTEXT] = undefined;
    _vm[@ PROG_VM.GLOBAL_REF] = {}
    _vm[@ PROG_VM.TRY_STACK] = [];
    _vm[@ PROG_VM.ACTIVE_MODULE] = undefined;
    _vm[@ PROG_VM.CURRENT_THIS] = undefined;
    _vm[@ PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[@ PROG_VM.CLASS_REGISTRY] = {}
    
    return _vm;
}

/// @desc Acquire a VM instance (from pool or new)
/// @returns {Array<PROG_VM>}
function proglang_vm_create()
{
    proglang_vm_pool_init();
    
    global.proglang_vm_alloc_count++;
    
    // Auto-GC check
    if (global.proglang_vm_alloc_count >= global.proglang_vm_gc_threshold)
    {
        // Clear excess pool entries
        while (array_length(global.proglang_vm_pool) > global.proglang_vm_pool_max / 2)
        {
            array_pop(global.proglang_vm_pool);
        }
        
        // Force GML garbage collection
        gc_collect();
        
        global.proglang_vm_alloc_count = 0;
    }
    
    if (array_length(global.proglang_vm_pool) > 0)
    {
        var _vm = array_pop(global.proglang_vm_pool);
        proglang_vm_reset(_vm);
        return _vm;
    }
    
    return proglang_vm_create_impl();
}

/// @desc Release a VM instance back to the pool
/// @param {Array<PROG_VM>} _vm
function proglang_vm_free(_vm)
{
    proglang_vm_pool_init();
    
    if (array_length(global.proglang_vm_pool) < global.proglang_vm_pool_max)
    {
        proglang_vm_reset(_vm);
        
        array_push(global.proglang_vm_pool, _vm);
    }
}

function proglang_scope_cleanup(_scope)
{
    var _resources = _scope[PROG_SCOPE.TRACKED_RESOURCES];
    
    if (_resources == undefined) exit;
    
    for (var i = array_length(_resources) - 1; i >= 0; --i)
    {
        var _resource = _resources[i];
        
        if (!is_array(_resource) || array_length(_resource) < 2) continue;
        
        var _value = _resource[1];
        
        switch (_resource[0])
        {
            case "__buffer__":
                if (buffer_exists(_value))
                {
                    buffer_delete(_value);
                }
                break;
                
            case "__surface__":
                if (surface_exists(_value))
                {
                    surface_free(_value);
                }
                break;
                
            case "__ds_list__":
                if (ds_exists(_value, ds_type_list))
                {
                    ds_list_destroy(_value);
                }
                break;
                
            case "__ds_map__":
                if (ds_exists(_value, ds_type_map))
                {
                    ds_map_destroy(_value);
                }
                break;
                
            case "__ds_grid__":
                if (ds_exists(_value, ds_type_grid))
                {
                    ds_grid_destroy(_value);
                }
                break;
        }
    }
    
    _scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];
}

function proglang_scope_track_resource(_scope, _type, _handle)
{
    var _resources = _scope[PROG_SCOPE.TRACKED_RESOURCES];
    
    if (_resources == undefined)
    {
        _resources = [];
        
        _scope[@ PROG_SCOPE.TRACKED_RESOURCES] = _resources;
    }
    
    array_push(_resources, [_type, _handle]);
}

function runtime_error(_type, _msg)
{
    throw { type: _type, message: _msg, stacktrace: debug_get_callstack() }
}

function proglang_vm_find_var_scope(_vm, _name)
{
    var _scope = _vm[PROG_VM.SCOPE];
    
    while (_scope != undefined)
    {
        if (struct_exists(_scope[PROG_SCOPE.VARS], _name))
        {
            return _scope;
        }
        
        _scope = _scope[PROG_SCOPE.PARENT];
    }
    
    return undefined;
}

