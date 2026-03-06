/* ui editor panels - file browser, element tree, and property panel */
/* drawn on top of the game via draw_gui, uses raw draw calls */


#macro UI_EDITOR_PANEL_BG        $1a1a2e
#macro UI_EDITOR_PANEL_BG_DARK   $12121f
#macro UI_EDITOR_PANEL_BORDER    $3a3a5a
#macro UI_EDITOR_PANEL_HIGHLIGHT $5a5aff
#macro UI_EDITOR_PANEL_TEXT      $e0e0e0
#macro UI_EDITOR_PANEL_TEXT_DIM  $8888aa
#macro UI_EDITOR_PANEL_HOVER     $2a2a4a
#macro UI_EDITOR_PANEL_SELECTED  $3a3a6a


/* =============================================================================
   file browser panel
   ============================================================================= */

/* build file list from resources/data/ui/ directory */
/* @returns {array<string>} list of .ui file paths */
function ui_editor_get_file_list()
{
    var _files = file_read_directory("resources/data/ui", true);
    var _ui_files = [];

    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _f = _files[i];

        if (string_ends_with(_f, ".ui"))
        {
            array_push(_ui_files, _f);
        }
    }

    array_sort(_ui_files, true);

    return _ui_files;
}


/* draw file browser panel */
/* @param {real} _x panel x */
/* @param {real} _y panel y */
/* @param {real} _w panel width */
/* @param {real} _h panel height */
function ui_editor_draw_file_browser(_x, _y, _w, _h)
{
    var _editor = global.ui_editor;
    var _files  = _editor.file_list;
    var _count  = array_length(_files);
    var _mx     = device_mouse_x_to_gui(0);
    var _my     = device_mouse_y_to_gui(0);

    /* panel background */
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, false);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, true);

    /* title */
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    render_text(_x + _w / 2, _y + 8, "Open UI File", 1, 1, 0, UI_EDITOR_PANEL_TEXT);

    draw_set_halign(fa_left);

    /* file list */
    var _line_h   = 20;
    var _list_y   = _y + 32;
    var _scroll   = _editor.file_scroll;
    var _vis_count = floor((_h - 40) / _line_h);

    for (var i = 0; i < _vis_count; ++i)
    {
        var _idx = i + _scroll;

        if (_idx >= _count) break;

        var _fy = _list_y + (i * _line_h);
        var _hovered = (_mx >= _x) && (_mx <= _x + _w) && (_my >= _fy) && (_my <= _fy + _line_h);

        /* highlight */
        if (_hovered)
        {
            draw_rectangle_colour(_x + 2, _fy, _x + _w - 2, _fy + _line_h, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, false);

            /* click to load */
            if (mouse_check_button_pressed(mb_left))
            {
                ui_editor_load($"ui/{_files[_idx]}");
            }
        }

        render_text(_x + 8, _fy + 2, _files[_idx], 1, 1, 0, UI_EDITOR_PANEL_TEXT);
    }

    /* scroll with mouse wheel */
    if (_mx >= _x) && (_mx <= _x + _w) && (_my >= _y) && (_my <= _y + _h)
    {
        var _wheel = mouse_wheel_down() - mouse_wheel_up();

        if (_wheel != 0)
        {
            _editor.file_scroll = clamp(_editor.file_scroll + _wheel, 0, max(0, _count - _vis_count));
        }
    }
}


/* =============================================================================
   element tree panel
   ============================================================================= */

/* draw element tree panel */
/* @param {real} _x panel x */
/* @param {real} _y panel y */
/* @param {real} _w panel width */
/* @param {real} _h panel height */
function ui_editor_draw_tree(_x, _y, _w, _h)
{
    var _editor = global.ui_editor;

    /* panel background */
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, false);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, true);

    /* title */
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    render_text(_x + _w / 2, _y + 8, "Tree", 1, 1, 0, UI_EDITOR_PANEL_TEXT);

    draw_set_halign(fa_left);

    /* build flat list from ast */
    if (_editor.ast_document == undefined) exit;

    var _flat = [];

    ui_editor_flatten_tree(_editor.ast_document.definitions, _flat, 0);

    var _line_h    = 18;
    var _list_y    = _y + 32;
    var _scroll    = _editor.tree_scroll;
    var _vis_count = floor((_h - 40) / _line_h);
    var _count     = array_length(_flat);
    var _mx        = device_mouse_x_to_gui(0);
    var _my        = device_mouse_y_to_gui(0);

    for (var i = 0; i < _vis_count; ++i)
    {
        var _idx = i + _scroll;

        if (_idx >= _count) break;

        var _entry  = _flat[_idx];
        var _fy     = _list_y + (i * _line_h);
        var _indent = _entry.depth * 12;
        var _is_sel = (_editor.selected_node == _entry.node);
        var _hovered = (_mx >= _x) && (_mx <= _x + _w) && (_my >= _fy) && (_my <= _fy + _line_h);

        /* selection/hover background */
        if (_is_sel)
        {
            draw_rectangle_colour(_x + 2, _fy, _x + _w - 2, _fy + _line_h, UI_EDITOR_PANEL_SELECTED, UI_EDITOR_PANEL_SELECTED, UI_EDITOR_PANEL_SELECTED, UI_EDITOR_PANEL_SELECTED, false);
        }
        else if (_hovered)
        {
            draw_rectangle_colour(_x + 2, _fy, _x + _w - 2, _fy + _line_h, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, false);
        }

        /* click to select */
        if (_hovered) && (mouse_check_button_pressed(mb_left))
        {
            _editor.selected_node    = _entry.node;
            _editor.selected_element = _editor.preview_instance.elements[$ _entry.node.name];
        }

        /* label */
        var _tree_col = _is_sel ? UI_EDITOR_PANEL_HIGHLIGHT : UI_EDITOR_PANEL_TEXT;

        render_text(_x + 8 + _indent, _fy + 1, $"@{_entry.node.element_type}({_entry.node.name})", 1, 1, 0, _tree_col);
    }

    /* scroll */
    if (_mx >= _x) && (_mx <= _x + _w) && (_my >= _y) && (_my <= _y + _h)
    {
        var _wheel = mouse_wheel_down() - mouse_wheel_up();

        if (_wheel != 0)
        {
            _editor.tree_scroll = clamp(_editor.tree_scroll + _wheel, 0, max(0, _count - _vis_count));
        }
    }
}


/* recursively flatten ast element tree into array of {node, depth} */
/* @param {array} _defs array of ast definitions */
/* @param {array} _out output array */
/* @param {real} _depth current depth */
function ui_editor_flatten_tree(_defs, _out, _depth)
{
    var _count = array_length(_defs);

    for (var i = 0; i < _count; ++i)
    {
        var _def = _defs[i];

        if (_def == undefined) continue;

        if (!is_struct(_def)) continue;

        if (_def.type == UI_AST.ELEMENT)
        {
            array_push(_out, { node: _def, depth: _depth });

            ui_editor_flatten_tree(_def.children, _out, _depth + 1);
        }
        else if (_def.type == UI_AST.EXPORT_ELEMENT)
        {
            if (is_struct(_def.element))
            {
                array_push(_out, { node: _def.element, depth: _depth });

                ui_editor_flatten_tree(_def.element.children, _out, _depth + 1);
            }
        }
    }
}


/* =============================================================================
   property panel
   ============================================================================= */

/* draw property editor panel */
/* @param {real} _x panel x */
/* @param {real} _y panel y */
/* @param {real} _w panel width */
/* @param {real} _h panel height */
function ui_editor_draw_properties(_x, _y, _w, _h)
{
    var _editor = global.ui_editor;
    var _mx     = device_mouse_x_to_gui(0);
    var _my     = device_mouse_y_to_gui(0);

    /* panel background */
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, UI_EDITOR_PANEL_BG, false);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, true);

    /* title */
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    render_text(_x + _w / 2, _y + 8, "Properties", 1, 1, 0, UI_EDITOR_PANEL_TEXT);

    draw_set_halign(fa_left);

    if (_editor.selected_node == undefined) exit;

    var _node    = _editor.selected_node;
    var _element = _editor.selected_element;
    var _line_h  = 22;
    var _py      = _y + 32;

    /* element info header */
    render_text(_x + 8, _py, $"@{_node.element_type}({_node.name})", 1, 1, 0, UI_EDITOR_PANEL_HIGHLIGHT);

    _py += _line_h + 4;

    /* show live element properties (read-only) */
    if (_element != undefined)
    {
        ui_editor_draw_prop_row(_x, _py, _w, _line_h, "x",        string(round(_element.x)),       _mx, _my, undefined); _py += _line_h;
        ui_editor_draw_prop_row(_x, _py, _w, _line_h, "y",        string(round(_element.y)),       _mx, _my, undefined); _py += _line_h;
        ui_editor_draw_prop_row(_x, _py, _w, _line_h, "width",    string(round(_element.width)),   _mx, _my, undefined); _py += _line_h;
        ui_editor_draw_prop_row(_x, _py, _w, _line_h, "height",   string(round(_element.height)),  _mx, _my, undefined); _py += _line_h;
        ui_editor_draw_prop_row(_x, _py, _w, _line_h, "visible",  _element.visible ? "true" : "false", _mx, _my, undefined); _py += _line_h;

        if (struct_exists(_element, "text"))
        {
            ui_editor_draw_prop_row(_x, _py, _w, _line_h, "text", string(_element.text), _mx, _my, undefined);

            _py += _line_h;
        }

        if (struct_exists(_element, "layout"))
        {
            var _layout_str = "NONE";

            switch (_element.layout)
            {
                case UI_LAYOUT.VERTICAL:   _layout_str = "VERTICAL";   break;
                case UI_LAYOUT.HORIZONTAL: _layout_str = "HORIZONTAL"; break;
                case UI_LAYOUT.GRID:       _layout_str = "GRID";       break;
            }

            ui_editor_draw_prop_row(_x, _py, _w, _line_h, "layout", _layout_str, _mx, _my, undefined);

            _py += _line_h;
        }

        if (struct_exists(_element, "spacing")) && (_element.spacing != 0)
        {
            ui_editor_draw_prop_row(_x, _py, _w, _line_h, "spacing", string(_element.spacing), _mx, _my, undefined);

            _py += _line_h;
        }

        if (struct_exists(_element, "anchor_x")) && (_element.anchor_x != undefined)
        {
            ui_editor_draw_prop_row(_x, _py, _w, _line_h, "anchor", $"{_element.anchor_x}, {_element.anchor_y}", _mx, _my, undefined);

            _py += _line_h;
        }

        if (struct_exists(_element, "offset_x"))
        {
            ui_editor_draw_prop_row(_x, _py, _w, _line_h, "offset", $"{round(_element.offset_x)}, {round(_element.offset_y)}", _mx, _my, undefined);

            _py += _line_h;
        }
    }

    /* ast properties (editable) */
    _py += 8;

    render_text(_x + 8, _py, "--- ast properties ---", 1, 1, 0, UI_EDITOR_PANEL_TEXT_DIM);

    _py += _line_h;

    var _prop_count = array_length(_node.properties);

    for (var i = 0; i < _prop_count; ++i)
    {
        var _prop = _node.properties[i];
        var _val_text = ui_editor_serialize_ast_value(_prop.value);

        ui_editor_draw_prop_row(_x, _py, _w, _line_h, _prop.key, _val_text, _mx, _my, _prop);

        _py += _line_h;

        if (_py > _y + _h - _line_h) break;
    }
}


/* draw a single property label + value row */
/* @param {real} _x row x */
/* @param {real} _y row y */
/* @param {real} _w row total width */
/* @param {real} _line_h row height */
/* @param {string} _label property name */
/* @param {string} _value property value text */
/* @param {real} _mx mouse gui x */
/* @param {real} _my mouse gui y */
/* @param {struct|undefined} _prop ast property node (undefined = read-only) */
function ui_editor_draw_prop_row(_x, _y, _w, _line_h, _label, _value, _mx, _my, _prop)
{
    var _label_w = _w * 0.4;
    var _hovered = (_prop != undefined) && (_mx >= _x + _label_w) && (_mx <= _x + _w) && (_my >= _y) && (_my <= _y + _line_h);

    /* hover highlight on editable values */
    if (_hovered)
    {
        draw_rectangle_colour(_x + _label_w - 2, _y, _x + _w - 2, _y + _line_h, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, UI_EDITOR_PANEL_HOVER, false);
    }

    render_text(_x + 8, _y, _label, 1, 1, 0, UI_EDITOR_PANEL_TEXT_DIM);

    render_text(_x + _label_w, _y, _value, 1, 1, 0, _hovered ? UI_EDITOR_PANEL_HIGHLIGHT : UI_EDITOR_PANEL_TEXT);

    /* click to edit */
    if (_hovered) && (mouse_check_button_pressed(mb_left))
    {
        ui_editor_edit_property(_prop);
    }
}


/* prompt user to edit an ast property value and apply changes */
/* @param {struct} _prop ast property node with .key and .value */
function ui_editor_edit_property(_prop)
{
    var _current = ui_editor_serialize_ast_value(_prop.value);
    var _new_val = get_string($"Edit: {_prop.key}", _current);

    if (_new_val == _current) exit;

    if (_new_val == "") exit;

    /* parse the new value into an ast node */
    var _new_node = ui_editor_parse_value(_new_val);

    if (_new_node != undefined)
    {
        _prop.value = _new_node;

        global.ui_editor.dirty = true;

        /* re-spawn preview to apply changes */
        ui_editor_reload_preview();
    }
}


/* parse a raw string into an ast value node */
/* @param {string} _text user input */
/* @returns {struct|undefined} ast value node */
function ui_editor_parse_value(_text)
{
    /* try as number */
    var _num = real_try(_text);

    if (_num != undefined)
    {
        return { type: UI_AST.NUMBER, value: _num };
    }

    /* colour literal (starts with #) */
    if (string_char_at(_text, 1) == "#")
    {
        return { type: UI_AST.COLOR, value: _text };
    }

    /* boolean */
    if (_text == "true")
    {
        return { type: UI_AST.IDENTIFIER, name: "true" };
    }

    if (_text == "false")
    {
        return { type: UI_AST.IDENTIFIER, name: "false" };
    }

    /* treat as string (strip quotes if provided) */
    if (string_char_at(_text, 1) == "\"") && (string_char_at(_text, string_length(_text)) == "\"")
    {
        _text = string_copy(_text, 2, string_length(_text) - 2);
    }

    return { type: UI_AST.STRING, value: _text };
}


/* helper: try to parse string as real, returns undefined on failure */
function real_try(_text)
{
    try
    {
        var _val = real(_text);

        return _val;
    }
    catch (_e)
    {
        return undefined;
    }
}


/* reload the preview from current ast without re-reading disk */
function ui_editor_reload_preview()
{
    var _editor   = global.ui_editor;
    var _old_sel  = (_editor.selected_node != undefined) ? _editor.selected_node.name : "";

    /* destroy old preview */
    if (_editor.preview_instance != undefined)
    {
        ui_destroy(_editor.preview_instance);

        _editor.preview_instance = undefined;
        _editor.preview_root     = undefined;
    }

    /* ensure gui_root exists */
    if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
    {
        global.gui_root              = new UIElement(0, 0, 960, 540);
        global.gui_root.element_name = "gui_root";
    }

    /* re-spawn from cached ast */
    var _def = {
        document:  _editor.ast_document,
        variables: _editor.ast_variables
    }

    var _full_path = "resources/data/" + _editor.loaded_path;

    global.ui_definitions[$ _full_path] = _def;

    var _instance = ui_spawn(_def, {
        link:   {},
        parent: global.gui_root
    });

    _editor.preview_instance = _instance;
    _editor.preview_root     = (array_length(_instance.root_elements) > 0) ? _instance.root_elements[0] : undefined;

    /* restore selection by name */
    if (_old_sel != "")
    {
        _editor.selected_node    = ui_editor_find_ast_node(_editor.ast_document.definitions, _old_sel);
        _editor.selected_element = (_editor.selected_node != undefined) ? _instance.elements[$ _old_sel] : undefined;
    }
    else
    {
        _editor.selected_node    = undefined;
        _editor.selected_element = undefined;
    }
}


/* =============================================================================
   toolbar
   ============================================================================= */

/* draw editor toolbar */
/* @param {real} _x toolbar x */
/* @param {real} _y toolbar y */
/* @param {real} _w toolbar width */
/* @param {real} _h toolbar height */
function ui_editor_draw_toolbar(_x, _y, _w, _h)
{
    var _editor = global.ui_editor;
    var _mx     = device_mouse_x_to_gui(0);
    var _my     = device_mouse_y_to_gui(0);

    /* background */
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BG_DARK, UI_EDITOR_PANEL_BG_DARK, UI_EDITOR_PANEL_BG_DARK, UI_EDITOR_PANEL_BG_DARK, false);

    /* buttons */
    var _btn_w = 80;
    var _btn_h = _h - 8;
    var _btn_y = _y + 4;
    var _bx    = _x + 8;

    /* save button */
    if (_editor.loaded_path != "")
    {
        _bx = ui_editor_draw_toolbar_btn(_bx, _btn_y, _btn_w, _btn_h, "Save", _mx, _my, function()
        {
            ui_editor_save();
        });

        _bx += 4;
    }

    /* close button */
    _bx = ui_editor_draw_toolbar_btn(_bx, _btn_y, _btn_w, _btn_h, "Close", _mx, _my, function()
    {
        ui_editor_close();
    });

    _bx += 4;

    /* reload button */
    if (_editor.loaded_path != "")
    {
        _bx = ui_editor_draw_toolbar_btn(_bx, _btn_y, _btn_w, _btn_h, "Reload", _mx, _my, function()
        {
            var _path = global.ui_editor.loaded_path;

            ui_editor_close();
            ui_editor_load(_path);
        });

        _bx += 4;
    }

    /* file browser button */
    _bx = ui_editor_draw_toolbar_btn(_bx, _btn_y, _btn_w, _btn_h, "Browse", _mx, _my, function()
    {
        global.ui_editor.show_file_browser = !(global.ui_editor.show_file_browser);
    });

    /* show loaded file path on the right */
    if (_editor.loaded_path != "")
    {
        draw_set_halign(fa_right);

        render_text(_x + _w - 8, _btn_y + 4, _editor.loaded_path, 1, 1, 0, UI_EDITOR_PANEL_TEXT_DIM);

        draw_set_halign(fa_left);
    }
}


/* draw a toolbar button and return the next x position */
/* @returns {real} next x after this button */
function ui_editor_draw_toolbar_btn(_x, _y, _w, _h, _text, _mx, _my, _callback)
{
    var _hovered = (_mx >= _x) && (_mx <= _x + _w) && (_my >= _y) && (_my <= _y + _h);
    var _col     = _hovered ? UI_EDITOR_PANEL_HOVER : UI_EDITOR_PANEL_BG;

    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _col, _col, _col, _col, false);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, UI_EDITOR_PANEL_BORDER, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    render_text(_x + _w / 2, _y + _h / 2, _text, 1, 1, 0, UI_EDITOR_PANEL_TEXT);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    if (_hovered) && (mouse_check_button_pressed(mb_left))
    {
        _callback();
    }

    return _x + _w;
}
