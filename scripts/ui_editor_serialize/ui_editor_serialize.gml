/* serializes a ui ast document back into .ui source text */
/* used by the in-game ui editor to save changes back to disk */


/* serialize an entire parsed ui document back to .ui source */
/* @param {struct} _document UIASTDocument node */
/* @param {struct} _variables variable scope from parser */
/* @returns {string} valid .ui source text */
function ui_editor_serialize(_document, _variables)
{
    var _output = "";
    var _defs   = _document.definitions;
    var _count  = array_length(_defs);

    /* serialize variable declarations first */
    if (is_struct(_variables))
    {
        var _var_names = struct_get_names(_variables);
        var _var_count = array_length(_var_names);

        for (var i = 0; i < _var_count; ++i)
        {
            var _name  = _var_names[i];
            var _value = _variables[$ _name];

            _output += $"var {_name} = {ui_editor_serialize_value_raw(_value)}\n";
        }

        if (_var_count > 0)
        {
            _output += "\n";
        }
    }

    /* serialize each top-level definition */
    for (var i = 0; i < _count; ++i)
    {
        var _def = _defs[i];

        if (_def == undefined) continue;

        if (is_struct(_def))
        {
            switch (_def.type)
            {
                case UI_AST.ELEMENT:
                    _output += ui_editor_serialize_element(_def, 0);
                    break;

                case UI_AST.VAR_DECL:
                    _output += $"var {_def.name} = {ui_editor_serialize_ast_value(_def.value)}\n";
                    break;

                case UI_AST.EXPORT_VAR:
                    _output += $"export var {_def.name} = {ui_editor_serialize_ast_value(_def.value)}\n";
                    break;

                case UI_AST.EXPORT_ELEMENT:
                    _output += "export ";
                    _output += ui_editor_serialize_element(_def.element, 0);
                    break;
            }
        }
    }

    return _output;
}


/* serialize a single element node recursively */
/* @param {struct} _node UIASTElement node */
/* @param {real} _depth indentation depth */
/* @returns {string} serialized element text */
function ui_editor_serialize_element(_node, _depth)
{
    var _indent  = string_repeat("    ", _depth);
    var _indent2 = string_repeat("    ", _depth + 1);
    var _output  = "";

    /* element declaration */
    _output += $"{_indent}@{_node.element_type}({_node.name})";

    /* repeat clause */
    if (_node.repeat_count != undefined)
    {
        _output += $" repeat({_node.repeat_count}, {_node.repeat_var})";
    }

    _output += " {\n";

    /* properties */
    var _prop_count = array_length(_node.properties);

    for (var i = 0; i < _prop_count; ++i)
    {
        var _prop  = _node.properties[i];
        var _key   = _prop.key;
        var _value = ui_editor_serialize_ast_value(_prop.value);

        _output += $"{_indent2}{_key} = {_value}\n";
    }

    /* children */
    var _child_count = array_length(_node.children);

    if (_child_count > 0) && (_prop_count > 0)
    {
        _output += "\n";
    }

    for (var i = 0; i < _child_count; ++i)
    {
        _output += ui_editor_serialize_element(_node.children[i], _depth + 1);

        if (i < _child_count - 1)
        {
            _output += "\n";
        }
    }

    _output += $"{_indent}" + "}\n";

    return _output;
}


/* serialize an ast value node back to source text */
/* @param {struct} _node any ast value node */
/* @returns {string} serialized value */
function ui_editor_serialize_ast_value(_node)
{
    if (_node == undefined)
    {
        return "undefined";
    }

    switch (_node.type)
    {
        case UI_AST.NUMBER:
            return string(_node.value);

        case UI_AST.STRING:
            return $"\"{_node.value}\"";

        case UI_AST.BOOL:
            return _node.value ? "true" : "false";

        case UI_AST.COLOR:
            return ui_editor_color_to_hex(_node.color, _node.alpha);

        case UI_AST.TUPLE:
            var _parts = [];
            var _count = array_length(_node.values);

            for (var i = 0; i < _count; ++i)
            {
                array_push(_parts, ui_editor_serialize_ast_value(_node.values[i]));
            }

            return "(" + ui_editor_join(_parts, ", ") + ")";

        case UI_AST.IDENTIFIER:
            return _node.name;

        case UI_AST.ENUM:
            return _node.name;

        case UI_AST.BINDING:
            return $"*{_node.name}";

        case UI_AST.LOCA_KEY:
            return $"$\"{_node.key}\"";

        case UI_AST.SCRIPT_REF:
            return $"@\"{_node.script_id}\"";

        case UI_AST.PERCENTAGE:
            return $"{_node.value}%";

        case UI_AST.BINARY_OP:
            var _left  = ui_editor_serialize_ast_value(_node.left);
            var _right = ui_editor_serialize_ast_value(_node.right);

            return $"{_left} {_node.op} {_right}";

        case UI_AST.UNARY_OP:
            return $"{_node.op}{ui_editor_serialize_ast_value(_node.right)}";

        case UI_AST.FUNC_CALL:
            return $"{_node.func_name}({ui_editor_serialize_ast_value(_node.arg)})";

        case UI_AST.ARRAY_INDEX:
            return $"*{_node.name}[{ui_editor_serialize_ast_value(_node.index)}]";

        case UI_AST.SPRITE_DEF:
            var _out = $"$sprite({_node.sprite_name})";
            var _sp  = array_length(_node.properties);

            if (_sp > 0)
            {
                _out += " {\n";

                for (var i = 0; i < _sp; ++i)
                {
                    var _p = _node.properties[i];

                    _out += $"    {_p.key} = {ui_editor_serialize_ast_value(_p.value)}\n";
                }

                _out += "}";
            }

            return _out;

        case UI_AST.SURFACE_DEF:
            var _out = $"$surface({_node.surface_name})";
            var _sp  = array_length(_node.properties);

            if (_sp > 0)
            {
                _out += " {\n";

                for (var i = 0; i < _sp; ++i)
                {
                    var _p = _node.properties[i];

                    _out += $"    {_p.key} = {ui_editor_serialize_ast_value(_p.value)}\n";
                }

                _out += "}";
            }

            return _out;
    }

    return string(_node);
}


/* serialize a raw runtime value (not an ast node) back to source */
/* used for variable declarations where we only have resolved values */
/* @param {any} _value resolved runtime value */
/* @returns {string} serialized value */
function ui_editor_serialize_value_raw(_value)
{
    if (is_string(_value))
    {
        return $"\"{_value}\"";
    }

    if (is_bool(_value))
    {
        return _value ? "true" : "false";
    }

    if (is_real(_value))
    {
        return string(_value);
    }

    if (is_array(_value))
    {
        var _parts = [];
        var _count = array_length(_value);

        for (var i = 0; i < _count; ++i)
        {
            array_push(_parts, ui_editor_serialize_value_raw(_value[i]));
        }

        return "(" + ui_editor_join(_parts, ", ") + ")";
    }

    if (is_struct(_value))
    {
        if (_value[$ "is_sprite_def"] == true)
        {
            return $"$sprite({_value.sprite_name})";
        }

        if (_value[$ "color"] != undefined)
        {
            return ui_editor_color_to_hex(_value.color, _value[$ "alpha"] ?? 1);
        }
    }

    return string(_value);
}


/* convert a gml colour + alpha to #RRGGBB or #RRGGBBAA hex string */
/* @param {real} _color gml colour value */
/* @param {real} _alpha alpha (0-1) */
/* @returns {string} hex colour string */
function ui_editor_color_to_hex(_color, _alpha)
{
    var _r = colour_get_red(_color);
    var _g = colour_get_green(_color);
    var _b = colour_get_blue(_color);

    var _hex = "#"
        + ui_editor_byte_hex(_r)
        + ui_editor_byte_hex(_g)
        + ui_editor_byte_hex(_b);

    if (_alpha < 1)
    {
        _hex += ui_editor_byte_hex(round(_alpha * 255));
    }

    return _hex;
}


/* convert a byte (0-255) to a two-char hex string */
/* @param {real} _byte byte value */
/* @returns {string} two-char hex */
function ui_editor_byte_hex(_byte)
{
    var _hex_chars = "0123456789abcdef";
    var _hi = _byte div 16;
    var _lo = _byte mod 16;

    return string_char_at(_hex_chars, _hi + 1) + string_char_at(_hex_chars, _lo + 1);
}


/* join an array of strings with a separator */
/* @param {array<string>} _parts array of strings */
/* @param {string} _sep separator */
/* @returns {string} joined string */
function ui_editor_join(_parts, _sep)
{
    var _result = "";
    var _count  = array_length(_parts);

    for (var i = 0; i < _count; ++i)
    {
        if (i > 0)
        {
            _result += _sep;
        }

        _result += _parts[i];
    }

    return _result;
}
