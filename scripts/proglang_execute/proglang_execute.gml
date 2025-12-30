/// @desc Execute Proglang source string
/// @param {string} _source Script source code
/// @param {struct} _context Execution context variables
/// @param {string} _filepath Optional file path for import/export resolution
/// @returns {any} Script result
function proglang_execute(_source, _context = {}, _filepath = "")
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
    
    var _vm = ProgVM_create();
    
    _vm[@ PROG_VM.CONTEXT] = _context;
    
    // Set directory context for import/export resolution
    if (_filepath != "")
    {
        var _dirname = proglang_get_directory(_filepath);
        
        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = _dirname;
        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _filepath;
    }
    
    // show_debug_message(_bytecode);
    
    var _result = ProgVM_run(_vm, _bytecode);
    
    proglang_run_pending();
    
    ProgVM_free(_vm);
    
    return _result;
}