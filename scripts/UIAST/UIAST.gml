/* ui ast node types for declarative ui language */
/* analogous to ProgAST for Proglang */


enum UI_AST 
{
    /* root & structure */
    DOCUMENT,     /* root node containing all definitions */
    ELEMENT,      /* @type(name) { ... } */
    
    
    /* properties & values */
    PROPERTY,     /* key = value */
    VAR_DECL,     /* var _name = value */
    
    
    /* value types */
    BINDING,      /* *variable_name (data binding) */
    LOCA_KEY,     /* $"namespace:key" (localization) */
    SCRIPT_REF,   /* @"namespace:script/path" (event handler) */
    NUMBER,       /* numeric literal */
    STRING,       /* string literal */
    BOOL,         /* true/false */
    UNDEFINED,    /* undefined literal */
    TUPLE,        /* (x, y) or (x, y, z, w) */
    COLOR,        /* #RRGGBB or #RRGGBBAA */
    IDENTIFIER,   /* variable reference (e.g. _padding) */
    ENUM,         /* LAYOUT_VERTICAL, etc. */
    SPRITE_DEF,   /* $sprite(name) { slices/margins } */
    SURFACE_DEF,  /* $surface(name) { properties } */
    
    
    /* math expressions */
    BINARY_OP,    /* left op right (e.g. ORIGIN_CENTER + (10, 20)) */
    UNARY_OP,     /* -expr (negation) */
    PERCENTAGE,   /* 50% (percentage value) */
    
    
    /* export declarations */
    EXPORT_VAR,     /* export var name = value */
    EXPORT_ELEMENT, /* export @type(name) { ... } */
    
    
    /* function calls */
    FUNC_CALL,      /* floor(expr), etc. */
    
    
    /* array indexing */
    ARRAY_INDEX     /* *name[index] */
}


/* =============================================================================
   ast node constructors
   ============================================================================= */

/* document node - root of ui file */
/* @param {array} _definitions array of UIASTElement nodes */
function UIASTDocument(_definitions) constructor 
{
    type = UI_AST.DOCUMENT;
    
    definitions = _definitions;
}


/* element node - represents @type(name) { ... } */
/* @param {string} _element_type type of element (text, button, window, etc.) */
/* @param {string} _name instance name */
/* @param {array} _properties array of UIASTProperty nodes */
/* @param {array} _children array of UIASTElement nodes */
function UIASTElement(_element_type, _name, _properties, _children) constructor 
{
    type = UI_AST.ELEMENT;
    
    element_type = _element_type;
    
    name = _name;
    
    properties = _properties;
    
    children = _children;
    
    
    repeat_count = undefined;  /* number of copies to create */
    
    repeat_var = undefined;    /* loop variable name */
}


/* property node - key = value */
/* @param {string} _key property name */
/* @param {struct} _value value ast node */
function UIASTProperty(_key, _value) constructor 
{
    type = UI_AST.PROPERTY;
    
    key = _key;
    
    value = _value;
}


/* variable declaration - var _name = value */
/* @param {string} _name variable name */
/* @param {struct} _value initial value ast node */
function UIASTVarDecl(_name, _value) constructor 
{
    type = UI_AST.VAR_DECL;
    
    name = _name;
    
    value = _value;
}


/* binding expression - *variable_name */
/* @param {string} _name variable name to bind to */
function UIASTBinding(_name) constructor 
{
    type = UI_AST.BINDING;
    
    name = _name;
}


/* localization key - $"namespace:key" */
/* @param {string} _key localization key */
function UIASTLocaKey(_key) constructor 
{
    type = UI_AST.LOCA_KEY;
    
    key = _key;
}


/* script reference - @"namespace:script/path" */
/* @param {string} _script_id script identifier */
function UIASTScriptRef(_script_id) constructor 
{
    type = UI_AST.SCRIPT_REF;
    
    script_id = _script_id;
}


/* number literal */
/* @param {real} _value numeric value */
function UIASTNumber(_value) constructor 
{
    type = UI_AST.NUMBER;
    
    value = _value;
}


/* string literal */
/* @param {string} _value string value */
function UIASTString(_value) constructor 
{
    type = UI_AST.STRING;
    
    value = _value;
}


/* boolean literal */
/* @param {bool} _value boolean value */
function UIASTBool(_value) constructor 
{
    type = UI_AST.BOOL;
    
    value = _value;
}


/* undefined literal */
function UIASTUndefined() constructor
{
    type = UI_AST.UNDEFINED;
}


/* tuple literal - (x, y) or (x, y, z, w) */
/* @param {array} _values array of value ast nodes */
function UIASTTuple(_values) constructor 
{
    type = UI_AST.TUPLE;
    
    values = _values;
}


/* color literal - #RRGGBB or #RRGGBBAA */
/* @param {real} _color color value (GML color format) */
/* @param {real} _alpha alpha value (0-1) */
function UIASTColor(_color, _alpha = 1) constructor 
{
    type = UI_AST.COLOR;
    
    color = _color;
    
    alpha = _alpha;
}


/* identifier reference (local variable) */
/* @param {string} _name variable name */
function UIASTIdentifier(_name) constructor 
{
    type = UI_AST.IDENTIFIER;
    
    name = _name;
}


/* enum value (LAYOUT_VERTICAL, etc.) */
/* @param {string} _name enum name */
function UIASTEnum(_name) constructor 
{
    type = UI_AST.ENUM;
    
    name = _name;
}


/* sprite definition - $sprite(name) { properties } */
/* @param {string} _sprite_name sprite asset name */
/* @param {array} _properties array of property ast nodes (slice configs, etc.) */
function UIASTSpriteDef(_sprite_name, _properties) constructor 
{
    type = UI_AST.SPRITE_DEF;
    
    sprite_name = _sprite_name;
    
    properties = _properties;
}


/* surface definition - $surface(name) { properties } */
/* @param {string} _surface_name surface variable/binding name */
/* @param {array} _properties array of property ast nodes */
function UIASTSurfaceDef(_surface_name, _properties) constructor 
{
    type = UI_AST.SURFACE_DEF;
    
    surface_name = _surface_name;
    
    properties = _properties;
}


/* binary operation node - left op right */
/* @param {string} _op operator string ("+", "-", "*", "/", "%", "**") */
/* @param {struct} _left left operand ast node */
/* @param {struct} _right right operand ast node */
function UIASTBinaryOp(_op, _left, _right) constructor 
{
    type = UI_AST.BINARY_OP;
    
    op = _op;
    
    left = _left;
    
    right = _right;
}


/* unary operation node - op right */
/* @param {string} _op operator string ("-") */
/* @param {struct} _right operand ast node */
function UIASTUnaryOp(_op, _right) constructor 
{
    type = UI_AST.UNARY_OP;
    
    op = _op;
    
    right = _right;
}


/* percentage literal - 50% */
/* @param {real} _value raw numeric value (e.g. 50 for 50%) */
function UIASTPercentage(_value) constructor 
{
    type = UI_AST.PERCENTAGE;
    
    value = _value;
}


/* exported variable declaration - export var name = value */
/* @param {string} _name variable name */
/* @param {struct} _value value ast node */
function UIASTExportVar(_name, _value) constructor 
{
    type = UI_AST.EXPORT_VAR;
    
    name = _name;
    
    value = _value;
}


/* exported element - export @type(name) { ... } */
/* @param {struct} _element UIASTElement node */
function UIASTExportElement(_element) constructor 
{
    type = UI_AST.EXPORT_ELEMENT;
    
    element = _element;
}


/* function call - floor(expr) */
/* @param {string} _func_name function name */
/* @param {struct} _arg argument ast node */
function UIASTFuncCall(_func_name, _arg) constructor 
{
    type = UI_AST.FUNC_CALL;
    
    func_name = _func_name;
    
    arg = _arg;
}


/* array index binding - *name[index] */
/* @param {string} _name binding name in link context */
/* @param {struct} _index index ast node */
function UIASTArrayIndex(_name, _index) constructor 
{
    type = UI_AST.ARRAY_INDEX;
    
    name = _name;
    
    index = _index;
}
