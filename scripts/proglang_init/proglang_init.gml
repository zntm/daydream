/// @desc Initialize Proglang environment
function proglang_init() {
    // Global function registry
    if (!variable_global_exists("proglang_functions")) {
        global.proglang_functions = {};
    }
    
    // Global script registry
    if (!variable_global_exists("proglang_scripts")) {
        global.proglang_scripts = {};
    }
    
    // Global module registry
    if (!variable_global_exists("proglang_modules")) {
        global.proglang_modules = {};
    }
    
    // Global constants
    if (!variable_global_exists("proglang_constants")) {
        global.proglang_constants = {};
    }
    
    // Expose PROG_ERROR enum
    global.proglang_constants.PROG_ERROR = {
        NONE: PROG_ERROR.NONE,
        RUNTIME: PROG_ERROR.RUNTIME,
        TYPE: PROG_ERROR.TYPE,
        INDEX: PROG_ERROR.INDEX,
        MEMBER: PROG_ERROR.MEMBER,
        VARIABLE: PROG_ERROR.VARIABLE,
        DIVIDE_BY_ZERO: PROG_ERROR.DIVIDE_BY_ZERO,
        UNDEFINED_VALUE: PROG_ERROR.UNDEFINED_VALUE,
        NULL_REFERENCE: PROG_ERROR.NULL_REFERENCE,
        INVALID_ARGUMENT: PROG_ERROR.INVALID_ARGUMENT,
        NOT_CALLABLE: PROG_ERROR.NOT_CALLABLE,
        SYNTAX: PROG_ERROR.SYNTAX,
        IMPORT: PROG_ERROR.IMPORT
    };
}
