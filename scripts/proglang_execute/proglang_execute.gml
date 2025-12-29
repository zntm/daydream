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
    
    var _vm = new ProgVM();
    
    _vm.context = _context;
    
    // Set directory context for import/export resolution
    if (_filepath != "")
    {
        var _dirname = proglang_get_directory(_filepath);
        _vm.current_scope.vars[$ "__dirname"] = _dirname;
        _vm.current_scope.vars[$ "__filename"] = _filepath;
    }
    
    var _result = _vm.run(_bytecode);
    
    proglang_run_pending();
    
    return _result;
}