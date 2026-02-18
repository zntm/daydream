/* Execute Proglang source string */
/* @param {string} _source Script source code */
/* @param {struct} _context Execution context variables */
/* @param {string} _filepath Optional file path for import/export resolution */
/* @returns {any} Script result */
function proglang_execute(_source, _context = {}, _filepath = "")
{
    proglang_reset_pending();
    
    /* Extract context keys to prevent redeclaration */
    var _context_keys = struct_get_names(_context);
    
    var _bytecode = proglang_compile(_source, _context_keys);
    
    if (_bytecode == undefined)
    {
        if (IS_DEVELOPER_MODE)
        {
            show_debug_message("[Daydream] Compilation failed.");
        }
        
        return undefined;
    }
    
    var _vm = proglang_vm_create();
    
    _vm[@ PROG_VM.CONTEXT] = _context;
    
    /* Set directory context for import/export resolution */
    if (_filepath != "")
    {
        var _dirname = proglang_get_directory(_filepath);
        
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = _dirname;
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _filepath;
    }

    /* Inject common context variables into root scope for reliable access in nested blocks */
    if (struct_exists(_context, "x"))
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "x"] = _context.x;
    }
    
    if (struct_exists(_context, "y"))
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "y"] = _context.y;
    }
    
    if (struct_exists(_context, "z"))
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "z"] = _context.z;
    }
    
    // show_debug_message(_bytecode);
    
    var _result = proglang_vm_run(_vm, _bytecode);
    
    proglang_run_pending();
    
    proglang_vm_free(_vm);
    
    return _result;
}