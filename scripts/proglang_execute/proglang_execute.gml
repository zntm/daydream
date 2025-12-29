/// @desc Execute Proglang source string
/// @param {string} _source Script source code
/// @param {struct} _context Execution context variables
/// @returns {any} Script result
function proglang_execute(_source, _context = {})
{
    proglang_reset_pending();
    
    var _bytecode = proglang_compile(_source);
    
    if (_bytecode == undefined)
    {
        if (IS_DEVELOPER_MODE)
        {
            show_debug_message("[Daydream] Compilation failed.");
        }
        
        return undefined;
    }
    
    var _vm = new ProgVM();
    
    _vm.context = _context;
    
    var _result = _vm.run(_bytecode);
    
    proglang_run_pending();
    
    return _result;
}