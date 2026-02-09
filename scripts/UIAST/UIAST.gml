/// @desc UI AST Node Types for Declarative UI Language
/// Analogous to ProgAST for Proglang

enum UI_AST {
    // Root & Structure
    DOCUMENT,     // Root node containing all definitions
    ELEMENT,      // @type(name) { ... }
    
    // Properties & Values
    PROPERTY,     // key = value
    VAR_DECL,     // var _name = value
    
    // Value Types
    BINDING,      // *variable_name (data binding)
    LOCA_KEY,     // $"namespace:key" (localization)
    SCRIPT_REF,   // @"namespace:script/path" (event handler)
    NUMBER,       // numeric literal
    STRING,       // string literal
    BOOL,         // true/false
    TUPLE,        // (x, y) or (x, y, z, w)
    COLOR,        // #RRGGBB or #RRGGBBAA
    IDENTIFIER,   // variable reference (e.g. _padding)
    ENUM,         // LAYOUT_VERTICAL, etc.
    SPRITE_DEF,   // $sprite(name) { slices/margins }
    SURFACE_DEF   // $surface(name) { properties }
}

// =============================================================================
// AST Node Constructors
// =============================================================================

/// @desc Document node - root of UI file
/// @param {Array} _definitions Array of UIASTElement nodes
function UIASTDocument(_definitions) constructor {
    type = UI_AST.DOCUMENT;
    definitions = _definitions;
}

/// @desc Element node - represents @type(name) { ... }
/// @param {String} _element_type Type of element (text, button, window, etc.)
/// @param {String} _name Instance name
/// @param {Array} _properties Array of UIASTProperty nodes
/// @param {Array} _children Array of UIASTElement nodes
function UIASTElement(_element_type, _name, _properties, _children) constructor {
    type = UI_AST.ELEMENT;
    element_type = _element_type;
    name = _name;
    properties = _properties;
    children = _children;
}

/// @desc Property node - key = value
/// @param {String} _key Property name
/// @param {Struct} _value Value AST node
function UIASTProperty(_key, _value) constructor {
    type = UI_AST.PROPERTY;
    key = _key;
    value = _value;
}

/// @desc Variable declaration - var _name = value
/// @param {String} _name Variable name
/// @param {Struct} _value Initial value AST node
function UIASTVarDecl(_name, _value) constructor {
    type = UI_AST.VAR_DECL;
    name = _name;
    value = _value;
}

/// @desc Binding expression - *variable_name
/// @param {String} _name Variable name to bind to
function UIASTBinding(_name) constructor {
    type = UI_AST.BINDING;
    name = _name;
}

/// @desc Localization key - $"namespace:key"
/// @param {String} _key Localization key
function UIASTLocaKey(_key) constructor {
    type = UI_AST.LOCA_KEY;
    key = _key;
}

/// @desc Script reference - @"namespace:script/path"
/// @param {String} _script_id Script identifier
function UIASTScriptRef(_script_id) constructor {
    type = UI_AST.SCRIPT_REF;
    script_id = _script_id;
}

/// @desc Number literal
/// @param {Real} _value Numeric value
function UIASTNumber(_value) constructor {
    type = UI_AST.NUMBER;
    value = _value;
}

/// @desc String literal
/// @param {String} _value String value
function UIASTString(_value) constructor {
    type = UI_AST.STRING;
    value = _value;
}

/// @desc Boolean literal
/// @param {Bool} _value Boolean value
function UIASTBool(_value) constructor {
    type = UI_AST.BOOL;
    value = _value;
}

/// @desc Tuple literal - (x, y) or (x, y, z, w)
/// @param {Array} _values Array of value AST nodes
function UIASTTuple(_values) constructor {
    type = UI_AST.TUPLE;
    values = _values;
}

/// @desc Color literal - #RRGGBB or #RRGGBBAA
/// @param {Real} _color Color value (GML color format)
/// @param {Real} _alpha Alpha value (0-1)
function UIASTColor(_color, _alpha = 1) constructor {
    type = UI_AST.COLOR;
    color = _color;
    alpha = _alpha;
}

/// @desc Identifier reference (local variable)
/// @param {String} _name Variable name
function UIASTIdentifier(_name) constructor {
    type = UI_AST.IDENTIFIER;
    name = _name;
}

/// @desc Enum value (LAYOUT_VERTICAL, etc.)
/// @param {String} _name Enum name
function UIASTEnum(_name) constructor {
    type = UI_AST.ENUM;
    name = _name;
}

/// @desc Sprite definition - $sprite(name) { properties }
/// @param {String} _sprite_name Sprite asset name
/// @param {Array} _properties Array of property AST nodes (slice configs, etc.)
function UIASTSpriteDef(_sprite_name, _properties) constructor {
    type = UI_AST.SPRITE_DEF;
    sprite_name = _sprite_name;
    properties = _properties;
}

/// @desc Surface definition - $surface(name) { properties }
/// @param {String} _surface_name Surface variable/binding name
/// @param {Array} _properties Array of property AST nodes
function UIASTSurfaceDef(_surface_name, _properties) constructor {
    type = UI_AST.SURFACE_DEF;
    surface_name = _surface_name;
    properties = _properties;
}
