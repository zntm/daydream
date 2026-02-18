
global.proglang_cache = {}

/* Compile Proglang source to bytecode (cached) */
/* @param {string} _source The script source code */
/* @param {array} _context_keys Optional array of context variable names */
/* @returns {Any} ProgBytecode or undefined on error */
function proglang_compile(_source, _context_keys = [])
{
    if (_source == undefined)
    {
        return undefined;
    }
    
    var _hash = md5_string_utf8(_source + json_stringify(_context_keys));
    
    var _cache = global.proglang_cache[$ _hash];
    
    if (_cache != undefined)
    {
        return _cache;
    }
    
    var _lexer = new ProgLexer(_source);
    var _tokens = _lexer.tokenize();
    
    if (_lexer.had_error)
    {
        if (IS_DEVELOPER_MODE)
        {
            show_debug_message($"[Daydream] Lexer Error: {_lexer.error}");
        }
        
        return undefined;
    }
    
    var _parser = new ProgParser(_tokens);
    var _ast = _parser.parse();
    
    if (_parser.had_error)
    {
        if (IS_DEVELOPER_MODE)
        {
            show_debug_message($"[Daydream] Parser Error: {_parser.error}");
        }
        
        return undefined;
    }
    
    var _compiler = new ProgCompiler(_context_keys);
    var _bytecode = _compiler.compile(_ast);
    
    global.proglang_cache[$ _hash] = _bytecode;
    
    return _bytecode;
}
