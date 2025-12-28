
global.proglang_cache = {};

/// @desc Compile Proglang source to bytecode (cached)
/// @param {string} _source The script source code
/// @returns {struct} ProgBytecode or undefined on error
function proglang_compile(_source) {
    if (_source == undefined) return undefined;

    var _hash = md5_string_utf8(_source);
    
    if (struct_exists(global.proglang_cache, _hash)) {
        return global.proglang_cache[$ _hash];
    }
    
    // Lexing
    var _lexer = new ProgLexer(_source);
    var _tokens = _lexer.tokenize();
    
    if (_lexer.had_error)
    {
        if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Lexer Error: {_lexer.error}");
        return undefined;
    }
    
    // Parsing
    var _parser = new ProgParser(_tokens);
    var _ast = _parser.parse();
    
    if (_parser.had_error)
    {
        if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Parser Error: {_parser.error}");
        return undefined;
    }
    
    // Compiling
    var _compiler = new ProgCompiler();
    var _bytecode = _compiler.compile(_ast);
    
    // Cache
    global.proglang_cache[$ _hash] = _bytecode;
    return _bytecode;
}

/// @desc Clear compilation cache
function proglang_cache_clear() {
    global.proglang_cache = {};
}
