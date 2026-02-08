/// @desc UI Language AST Node Types
enum UI_AST
{
    FILE,           // Root node containing all definitions
    VAR_DECL,       // Variable declaration
    ELEMENT,        // UI element (@type(name) { ... })
    PROPERTY,       // Property assignment
    BINDING,        // Data binding (*name)
    LOCALE,         // Localization string ($key)
    SCRIPT_REF,     // Script reference (@script)
    VALUE,          // Literal value (number, string, bool, etc.)
    TUPLE,          // Tuple value (x, y)
    PERCENTAGE,     // Percentage value
    CONSTANT,       // Enum constant
    TRANSITION,     // Transition function call
    HEX_COLOR       // Hex color literal (#fff, #ffffff)
}

/// @desc AST Node: Root file containing definitions
function UIASTFile() constructor
{
    type = UI_AST.FILE;
    variables = [];     // Array of UIASTVarDecl
    elements = [];      // Array of UIASTElement (top-level)
}

/// @desc AST Node: Variable declaration (var _name = value)
function UIASTVarDecl(_name, _value) constructor
{
    type = UI_AST.VAR_DECL;
    name = _name;       // Variable name
    value = _value;     // UIASTValue or similar
}

/// @desc AST Node: UI Element (@type(name) { properties, children })
function UIASTElement(_element_type, _name) constructor
{
    type = UI_AST.ELEMENT;
    element_type = _element_type;   // "window", "button", "text", etc.
    name = _name;                   // Element instance name
    properties = [];                // Array of UIASTProperty
    children = [];                  // Array of UIASTElement
}

/// @desc AST Node: Property assignment (key = value)
function UIASTProperty(_key, _value) constructor
{
    type = UI_AST.PROPERTY;
    key = _key;         // Property name
    value = _value;     // Value node (UIASTValue, UIASTBinding, etc.)
}

/// @desc AST Node: Data binding (*identifier)
function UIASTBinding(_name) constructor
{
    type = UI_AST.BINDING;
    name = _name;       // Binding key
}

/// @desc AST Node: Localization string ("$key")
function UIASTLocale(_key) constructor
{
    type = UI_AST.LOCALE;
    key = _key;         // Localization key (e.g., "phantasia:menu.title")
}

/// @desc AST Node: Script reference ("@script_id")
function UIASTScriptRef(_script_id) constructor
{
    type = UI_AST.SCRIPT_REF;
    script_id = _script_id;   // Script ID (e.g., "phantasia:menu/close")
}

/// @desc AST Node: Literal value
function UIASTValue(_value, _value_type) constructor
{
    type = UI_AST.VALUE;
    value = _value;             // The actual value
    value_type = _value_type;   // "number", "string", "bool", "undefined"
}

/// @desc AST Node: Tuple (x, y) or (t, r, b, l)
function UIASTTuple(_values) constructor
{
    type = UI_AST.TUPLE;
    values = _values;   // Array of value nodes
}

/// @desc AST Node: Percentage value (50%)
function UIASTPercentage(_value) constructor
{
    type = UI_AST.PERCENTAGE;
    value = _value;     // Number (0-100)
}

/// @desc AST Node: Enum constant
function UIASTConstant(_name) constructor
{
    type = UI_AST.CONSTANT;
    name = _name;       // e.g., "LAYOUT_VERTICAL"
}

/// @desc AST Node: Transition function (fade(0.3), scale(0.2), etc.)
function UIASTTransition(_transition_type, _duration) constructor
{
    type = UI_AST.TRANSITION;
    transition_type = _transition_type;   // "fade", "scale", "slide_left", etc.
    duration = _duration;                 // Duration in seconds
}

/// @desc AST Node: Hex color literal (#fff, #ffffff)
function UIASTHexColor(_color_value) constructor
{
    type = UI_AST.HEX_COLOR;
    color = _color_value;   // GML color value (make_colour_rgb result)
}

// ============================================================================
// Parser
// ============================================================================

/// @desc Parser for UI Language
/// @param {Array} _tokens Array of tokens from UILexer
function UIParser(_tokens) constructor
{
    tokens = _tokens;
    length = array_length(_tokens);
    current = 0;
    had_error = false;
    error = "";
    
    // --- Helper Functions ---
    
    static is_at_end = function()
    {
        return peek().type == UI_TOKEN.EOF;
    }
    
    static peek = function()
    {
        return tokens[current];
    }
    
    static previous = function()
    {
        return tokens[max(0, current - 1)];
    }
    
    static advance = function()
    {
        if (!is_at_end()) current++;
        return previous();
    }
    
    static check = function(_type)
    {
        if (is_at_end()) return false;
        return peek().type == _type;
    }
    
    static match = function(_type)
    {
        if (check(_type))
        {
            advance();
            return true;
        }
        return false;
    }
    
    static consume = function(_type, _message)
    {
        if (check(_type)) return advance();
        
        error_at_current(_message);
        return { type: UI_TOKEN.EOF, lexeme: "", literal: undefined, line: peek().line };
    }
    
    static error_at_current = function(_message)
    {
        if (had_error) return;
        
        had_error = true;
        var _token = peek();
        error = $"[Line {_token.line}] Error at '{_token.lexeme}': {_message}";
    }
    
    // --- Parsing ---
    
    /// @desc Parse the token stream into an AST
    /// @returns {Struct.UIASTFile} Root AST node
    static parse = function()
    {
        var _file = new UIASTFile();
        
        while (!is_at_end())
        {
            if (had_error) break;
            
            if (match(UI_TOKEN.VAR))
            {
                var _var_decl = parse_var_decl();
                if (_var_decl != undefined)
                {
                    array_push(_file.variables, _var_decl);
                }
            }
            else if (check(UI_TOKEN.AT))
            {
                var _element = parse_element();
                if (_element != undefined)
                {
                    array_push(_file.elements, _element);
                }
            }
            else
            {
                error_at_current("Expected 'var' declaration or '@element' definition.");
                break;
            }
        }
        
        return _file;
    }
    
    /// @desc Parse variable declaration: var _name = value
    static parse_var_decl = function()
    {
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected variable name after 'var'.");
        if (had_error) return undefined;
        
        consume(UI_TOKEN.EQUALS, "Expected '=' after variable name.");
        if (had_error) return undefined;
        
        var _value = parse_value();
        if (had_error) return undefined;
        
        return new UIASTVarDecl(_name_token.lexeme, _value);
    }
    
    /// @desc Parse element: @type(name) { properties and children }
    static parse_element = function()
    {
        consume(UI_TOKEN.AT, "Expected '@' for element declaration.");
        if (had_error) return undefined;
        
        var _type_token = consume(UI_TOKEN.IDENTIFIER, "Expected element type after '@'.");
        if (had_error) return undefined;
        
        consume(UI_TOKEN.LPAREN, "Expected '(' after element type.");
        if (had_error) return undefined;
        
        var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected element name.");
        if (had_error) return undefined;
        
        consume(UI_TOKEN.RPAREN, "Expected ')' after element name.");
        if (had_error) return undefined;
        
        consume(UI_TOKEN.LBRACE, "Expected '{' to start element body.");
        if (had_error) return undefined;
        
        var _element = new UIASTElement(_type_token.lexeme, _name_token.lexeme);
        
        // Parse properties and children until closing brace
        while (!check(UI_TOKEN.RBRACE) && !is_at_end())
        {
            if (had_error) break;
            
            // Child element
            if (check(UI_TOKEN.AT))
            {
                var _child = parse_element();
                if (_child != undefined)
                {
                    array_push(_element.children, _child);
                }
            }
            // Property assignment
            else if (check(UI_TOKEN.IDENTIFIER))
            {
                var _property = parse_property();
                if (_property != undefined)
                {
                    array_push(_element.properties, _property);
                }
            }
            else
            {
                error_at_current("Expected property or child element.");
                break;
            }
        }
        
        consume(UI_TOKEN.RBRACE, "Expected '}' to close element body.");
        
        return _element;
    }
    
    /// @desc Parse property: key = value
    static parse_property = function()
    {
        var _key_token = consume(UI_TOKEN.IDENTIFIER, "Expected property name.");
        if (had_error) return undefined;
        
        consume(UI_TOKEN.EQUALS, "Expected '=' after property name.");
        if (had_error) return undefined;
        
        var _value = parse_value();
        if (had_error) return undefined;
        
        return new UIASTProperty(_key_token.lexeme, _value);
    }
    
    /// @desc Parse a value (number, string, tuple, binding, etc.)
    static parse_value = function()
    {
        // Data binding: *identifier
        if (match(UI_TOKEN.ASTERISK))
        {
            var _name_token = consume(UI_TOKEN.IDENTIFIER, "Expected binding name after '*'.");
            if (had_error) return undefined;
            return new UIASTBinding(_name_token.lexeme);
        }
        
        // Tuple: (value, value, ...)
        if (match(UI_TOKEN.LPAREN))
        {
            return parse_tuple();
        }
        
        // Number
        if (match(UI_TOKEN.NUMBER))
        {
            return new UIASTValue(previous().literal, "number");
        }
        
        // Percentage
        if (match(UI_TOKEN.PERCENTAGE))
        {
            return new UIASTPercentage(previous().literal);
        }
        
        // Hex color
        if (match(UI_TOKEN.HEX_COLOR))
        {
            return new UIASTHexColor(previous().literal);
        }
        
        // String (may contain $ or @ prefixes)
        if (match(UI_TOKEN.STRING))
        {
            var _str = previous().literal;
            
            // Check for localization prefix $
            if (string_char_at(_str, 1) == "$")
            {
                var _key = string_copy(_str, 2, string_length(_str) - 1);
                return new UIASTLocale(_key);
            }
            
            // Check for script reference prefix @
            if (string_char_at(_str, 1) == "@")
            {
                var _script_id = string_copy(_str, 2, string_length(_str) - 1);
                return new UIASTScriptRef(_script_id);
            }
            
            // Regular string
            return new UIASTValue(_str, "string");
        }
        
        // Boolean true/false
        if (match(UI_TOKEN.TRUE))
        {
            return new UIASTValue(true, "bool");
        }
        if (match(UI_TOKEN.FALSE))
        {
            return new UIASTValue(false, "bool");
        }
        
        // Undefined
        if (match(UI_TOKEN.UNDEFINED))
        {
            return new UIASTValue(undefined, "undefined");
        }
        
        // Constant (enum value)
        if (match(UI_TOKEN.CONSTANT))
        {
            return new UIASTConstant(previous().literal);
        }
        
        // Identifier - could be a variable reference or transition function
        if (match(UI_TOKEN.IDENTIFIER))
        {
            var _name = previous().lexeme;
            
            // Check if it's a transition function call
            if (check(UI_TOKEN.LPAREN))
            {
                return parse_transition(_name);
            }
            
            // Variable reference (will be resolved at compile time)
            return new UIASTValue(_name, "identifier");
        }
        
        error_at_current("Expected value.");
        return undefined;
    }
    
    /// @desc Parse tuple: (value, value, ...)
    static parse_tuple = function()
    {
        var _values = [];
        
        // First value
        var _val = parse_value();
        if (_val != undefined)
        {
            array_push(_values, _val);
        }
        
        // Additional values
        while (match(UI_TOKEN.COMMA))
        {
            _val = parse_value();
            if (_val != undefined)
            {
                array_push(_values, _val);
            }
            else
            {
                break;
            }
        }
        
        consume(UI_TOKEN.RPAREN, "Expected ')' after tuple values.");
        
        return new UIASTTuple(_values);
    }
    
    /// @desc Parse transition function: fade(0.3), scale(0.2), etc.
    static parse_transition = function(_type)
    {
        consume(UI_TOKEN.LPAREN, "Expected '(' after transition type.");
        if (had_error) return undefined;
        
        var _duration = 0.3; // Default duration
        
        if (match(UI_TOKEN.NUMBER))
        {
            _duration = previous().literal;
        }
        
        consume(UI_TOKEN.RPAREN, "Expected ')' after transition duration.");
        
        return new UIASTTransition(_type, _duration);
    }
}
