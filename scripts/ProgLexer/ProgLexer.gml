
/// @desc Execute Proglang source string
/// @param {string} _source Script source
/// @param {struct} _context Execution context variables
/// @returns {any} Script result
function proglang_execute(_source, _context = {}) {
    var _bytecode = proglang_compile(_source);
    
    var _vm = new ProgVM();
    
    // Extract functions from bytecode and register them
    if (struct_exists(_bytecode, "constants")) { // Function definitions are in constants
        for (var i = 0; i < array_length(_bytecode.constants); i++) {
            var _const = _bytecode.constants[i];
            if (is_struct(_const) && variable_struct_exists(_const, "type") && _const.type == "function") {
                if (_const.is_global) {
                     if (!variable_global_exists("proglang_exports")) global.proglang_exports = {};
                     global.proglang_exports[$ _const.name] = _const.bytecode;
                } else {
                     _context[$ _const.name] = _const.bytecode;
                }
            }
        }
    }

    _vm.context = _context;
    
    return _vm.run(_bytecode);
}

/// @desc Run pre-compiled bytecode
/// @param {struct} _bytecode Compiled ProgBytecode
/// @param {struct} _context Execution context variables
/// @returns {any} Script result
function proglang_run(_bytecode, _context = {}) {
    var _vm = new ProgVM();
    _vm.context = _context;
    
    return _vm.run(_bytecode);
}
