/* in-game ui editor — dev tool for visually editing .ui files */
/* toggled with f4, guarded by IS_DEVELOPER_MODE */


#macro UI_EDITOR_HANDLE_SIZE 8
#macro UI_EDITOR_HANDLE_HALF 4
#macro UI_EDITOR_SNAP_SIZE   10

enum UI_EDITOR_DRAG {
    NONE,
    MOVE,
    RESIZE_TL,
    RESIZE_T,
    RESIZE_TR,
    RESIZE_R,
    RESIZE_BR,
    RESIZE_B,
    RESIZE_BL,
    RESIZE_L
}


/* initialize the global editor state */
function ui_editor_init()
{
    if (!IS_DEVELOPER_MODE) exit;

    global.ui_editor = {
        active:            false,
        loaded_path:       "",
        ast_document:      undefined,
        ast_variables:     undefined,
        preview_instance:  undefined,
        preview_root:      undefined,
        selected_node:     undefined,
        selected_element:  undefined,
        hovered_element:   undefined,
        show_file_browser: true,
        file_list:         [],
        file_scroll:       0,
        tree_scroll:       0,
        dirty:             false,
        drag_mode:     UI_EDITOR_DRAG.NONE,
        drag_start_mx: 0,
        drag_start_my: 0,
        drag_start_x:  0,
        drag_start_y:  0,
        drag_start_w:  0,
        drag_start_h:  0
    }
}


/* toggle the editor on/off */
function ui_editor_toggle()
{
    if (!IS_DEVELOPER_MODE) exit;

    if (global.ui_editor == undefined)
    {
        ui_editor_init();
    }

    if (global.ui_editor.active)
    {
        ui_editor_close();
    }
    else
    {
        ui_editor_open();
    }
}


/* open the editor — auto-loads current menu's .ui file if in a menu room */
function ui_editor_open()
{
    var _editor = global.ui_editor;

    _editor.active            = true;
    _editor.show_file_browser = false;
    _editor.file_list         = ui_editor_get_file_list();
    _editor.file_scroll       = 0;

    /* try to auto-detect .ui file from current room */
    var _auto_path = ui_editor_resolve_room_ui();

    if (_auto_path != "")
    {
        ui_editor_load(_auto_path);

        PRINT($"[UI Editor] auto-loaded: {_auto_path}");
    }
    else
    {
        /* no match — show file browser */
        _editor.show_file_browser = true;

        PRINT("[UI Editor] opened (file browser)");
    }
}


/* resolve current room name to a .ui file path */
/* @returns {string} path like "ui/menu/title.ui" or "" if no match */
function ui_editor_resolve_room_ui()
{
    var _room_name = room_get_name(room);

    /* menu rooms: rm_Menu_Title → ui/menu/title.ui */
    if (string_starts_with(_room_name, "rm_Menu_"))
    {
        var _suffix = string_delete(_room_name, 1, 8);

        _suffix = string_lower(_suffix);

        var _path = $"ui/menu/{_suffix}.ui";

        if (file_exists($"resources/data/{_path}"))
        {
            return _path;
        }
    }

    return "";
}


/* load a .ui file into the editor */
/* @param {string} _path path relative to resources/data/ (e.g. "ui/menu/pause.ui") */
function ui_editor_load(_path)
{
    var _editor = global.ui_editor;

    /* destroy previous preview if any */
    if (_editor.preview_instance != undefined)
    {
        ui_destroy(_editor.preview_instance);

        _editor.preview_instance = undefined;
        _editor.preview_root     = undefined;
    }

    /* clear definition cache so we get a fresh parse */
    var _full_path = "resources/data/" + _path;

    if (struct_exists(global.ui_definitions, _full_path))
    {
        struct_remove(global.ui_definitions, _full_path);
    }

    /* parse the file using existing lexer/parser */
    var _source = undefined;

    if (file_exists(_full_path))
    {
        var _buf = buffer_load(_full_path);

        _source = buffer_read(_buf, buffer_text);

        buffer_delete(_buf);
    }
    else if (file_exists(_path))
    {
        var _buf = buffer_load(_path);

        _source = buffer_read(_buf, buffer_text);

        buffer_delete(_buf);
    }

    if (_source == undefined)
    {
        PRINT($"[UI Editor] ERROR: could not read file: {_path}");

        exit;
    }

    /* tokenize */
    var _lexer  = new UILexer(_source);
    var _tokens = _lexer.tokenize();

    if (_lexer.had_error)
    {
        PRINT($"[UI Editor] lexer error: {_lexer.error}");

        exit;
    }

    /* parse */
    var _parser   = new UIParser(_tokens);
    var _document = _parser.parse();

    if (_parser.had_error)
    {
        PRINT($"[UI Editor] parser error: {_parser.error}");

        exit;
    }

    _editor.ast_document  = _document;
    _editor.ast_variables = _parser.variables;
    _editor.loaded_path   = _path;

    /* ensure gui_root exists */
    if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
    {
        global.gui_root              = new UIElement(0, 0, 960, 540);
        global.gui_root.element_name = "gui_root";
    }

    /* spawn a preview instance */
    var _def = {
        document:  _document,
        variables: _parser.variables
    }

    /* cache it so ui_load works */
    global.ui_definitions[$ _full_path] = _def;

    var _instance = ui_spawn(_def, {
        link:   {},
        parent: global.gui_root
    });

    _editor.preview_instance  = _instance;
    _editor.preview_root      = (array_length(_instance.root_elements) > 0) ? _instance.root_elements[0] : undefined;
    _editor.selected_node     = undefined;
    _editor.selected_element  = undefined;
    _editor.show_file_browser = false;
    _editor.tree_scroll       = 0;
    _editor.dirty             = false;
    _editor.drag_mode         = UI_EDITOR_DRAG.NONE;

    PRINT($"[UI Editor] loaded: {_path} ({array_length(_document.definitions)} definitions)");
}


/* close the editor and clean up */
function ui_editor_close()
{
    var _editor = global.ui_editor;

    if (_editor.preview_instance != undefined)
    {
        ui_destroy(_editor.preview_instance);

        _editor.preview_instance = undefined;
        _editor.preview_root     = undefined;
    }

    _editor.active           = false;
    _editor.ast_document     = undefined;
    _editor.ast_variables    = undefined;
    _editor.selected_node    = undefined;
    _editor.selected_element = undefined;
    _editor.loaded_path      = "";
    _editor.drag_mode        = UI_EDITOR_DRAG.NONE;

    PRINT("[UI Editor] closed");
}


/* save the current ast back to disk as .ui source */
function ui_editor_save()
{
    var _editor = global.ui_editor;

    if (_editor.ast_document == undefined) || (_editor.loaded_path == "") exit;

    var _source    = ui_editor_serialize(_editor.ast_document, _editor.ast_variables);
    var _full_path = "resources/data/" + _editor.loaded_path;

    /* write to file */
    var _file = file_text_open_write(_full_path);

    file_text_write_string(_file, _source);
    file_text_close(_file);

    _editor.dirty = false;

    PRINT($"[UI Editor] saved: {_full_path}");
}


/* =============================================================================
   per-frame step — drag, selection, input
   ============================================================================= */

function ui_editor_step()
{
    if (!IS_DEVELOPER_MODE) exit;

    if (global.ui_editor == undefined) exit;

    if (!(global.ui_editor.active)) exit;

    var _editor = global.ui_editor;
    var _mx     = device_mouse_x_to_gui(0);
    var _my     = device_mouse_y_to_gui(0);

    /* handle active drag */
    if (_editor.drag_mode != UI_EDITOR_DRAG.NONE)
    {
        ui_editor_drag_update(_editor, _mx, _my);

        if (mouse_check_button_released(mb_left))
        {
            ui_editor_drag_end(_editor);
        }

        /* don't process other input while dragging */
        exit;
    }

    /* mouse press — check handles, then body, then hit test */
    if (_editor.preview_instance != undefined) && (mouse_check_button_pressed(mb_left))
    {
        var _gui_w     = global.gui_width;
        var _tree_w    = 200;
        var _prop_w    = 220;
        var _toolbar_h = 32;

        /* only interact within the canvas area */
        if (_mx > _tree_w) && (_mx < _gui_w - _prop_w) && (_my > _toolbar_h)
        {
            /* 1. check resize handles on selected element */
            if (_editor.selected_element != undefined)
            {
                var _handle = ui_editor_hit_handle(_editor.selected_element, _mx, _my);

                if (_handle != UI_EDITOR_DRAG.NONE)
                {
                    ui_editor_drag_begin(_editor, _handle, _mx, _my);

                    exit;
                }
            }

            /* 2. hit test for element selection or move */
            var _hit = ui_editor_hit_test(_editor.preview_root, _mx, _my);

            if (_hit != undefined)
            {
                if (_hit == _editor.selected_element)
                {
                    /* clicked on already-selected element → start move */
                    ui_editor_drag_begin(_editor, UI_EDITOR_DRAG.MOVE, _mx, _my);
                }
                else
                {
                    /* select a different element */
                    _editor.selected_element = _hit;
                    _editor.selected_node    = ui_editor_find_ast_node(_editor.ast_document.definitions, _hit.element_name);
                }
            }
        }
    }

    /* hover detection */
    if (_editor.preview_instance != undefined)
    {
        _editor.hovered_element = ui_editor_hit_test(_editor.preview_root, _mx, _my);
    }

    /* keyboard shortcuts */
    if (keyboard_check_pressed(vk_escape))
    {
        if (_editor.show_file_browser)
        {
            _editor.show_file_browser = false;
        }
        else
        {
            _editor.selected_node    = undefined;
            _editor.selected_element = undefined;
        }
    }

    /* ctrl+s to save */
    if (keyboard_check(vk_control)) && (keyboard_check_pressed(ord("S")))
    {
        if (_editor.loaded_path != "")
        {
            ui_editor_save();
        }
    }
}


/* =============================================================================
   drag system — move and resize
   ============================================================================= */

/* begin a drag operation on the selected element */
function ui_editor_drag_begin(_editor, _mode, _mx, _my)
{
    var _element = _editor.selected_element;

    _editor.drag_mode     = _mode;
    _editor.drag_start_mx = _mx;
    _editor.drag_start_my = _my;
    _editor.drag_start_x  = _element.x;
    _editor.drag_start_y  = _element.y;
    _editor.drag_start_w  = _element.width;
    _editor.drag_start_h  = _element.height;
}


/* update element x/y/width/height directly for instant visual feedback */
function ui_editor_drag_update(_editor, _mx, _my)
{
    var _element    = _editor.selected_element;
    var _base_scale = ui_get_base_scale();

    if (_element == undefined) exit;

    /* compute delta in element space */
    var _dx = (_mx - _editor.drag_start_mx) / _base_scale.x;
    var _dy = (_my - _editor.drag_start_my) / _base_scale.y;

    /* shift = snap to grid */
    if (keyboard_check(vk_shift))
    {
        _dx = round(_dx / UI_EDITOR_SNAP_SIZE) * UI_EDITOR_SNAP_SIZE;
        _dy = round(_dy / UI_EDITOR_SNAP_SIZE) * UI_EDITOR_SNAP_SIZE;
    }

    switch (_editor.drag_mode)
    {
        case UI_EDITOR_DRAG.MOVE:
            _element.x = _editor.drag_start_x + _dx;
            _element.y = _editor.drag_start_y + _dy;
            break;

        case UI_EDITOR_DRAG.RESIZE_BR:
            _element.width  = max(1, _editor.drag_start_w + _dx);
            _element.height = max(1, _editor.drag_start_h + _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_R:
            _element.width = max(1, _editor.drag_start_w + _dx);
            break;

        case UI_EDITOR_DRAG.RESIZE_B:
            _element.height = max(1, _editor.drag_start_h + _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_TL:
            _element.x      = _editor.drag_start_x + _dx;
            _element.y      = _editor.drag_start_y + _dy;
            _element.width  = max(1, _editor.drag_start_w - _dx);
            _element.height = max(1, _editor.drag_start_h - _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_TR:
            _element.y      = _editor.drag_start_y + _dy;
            _element.width  = max(1, _editor.drag_start_w + _dx);
            _element.height = max(1, _editor.drag_start_h - _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_BL:
            _element.x      = _editor.drag_start_x + _dx;
            _element.width  = max(1, _editor.drag_start_w - _dx);
            _element.height = max(1, _editor.drag_start_h + _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_T:
            _element.y      = _editor.drag_start_y + _dy;
            _element.height = max(1, _editor.drag_start_h - _dy);
            break;

        case UI_EDITOR_DRAG.RESIZE_L:
            _element.x     = _editor.drag_start_x + _dx;
            _element.width = max(1, _editor.drag_start_w - _dx);
            break;
    }
}


/* finalize a drag — compute deltas and write to ast */
function ui_editor_drag_end(_editor)
{
    var _element = _editor.selected_element;
    var _node    = _editor.selected_node;

    if (_node == undefined) || (_element == undefined)
    {
        _editor.drag_mode = UI_EDITOR_DRAG.NONE;

        exit;
    }

    /* compute net position delta from drag */
    var _moved_x = round(_element.x - _editor.drag_start_x);
    var _moved_y = round(_element.y - _editor.drag_start_y);

    /* update offset in ast if position changed */
    if (_moved_x != 0) || (_moved_y != 0)
    {
        /* read current ast offset to add delta on top */
        var _cur_offset_x = 0;
        var _cur_offset_y = 0;

        var _existing = ui_editor_ast_get_property(_node, "offset");

        if (_existing != undefined) && (_existing.type == UI_AST.TUPLE) && (array_length(_existing.values) >= 2)
        {
            _cur_offset_x = _existing.values[0].value;
            _cur_offset_y = _existing.values[1].value;
        }

        ui_editor_ast_set_property(_node, "offset", new UIASTTuple([
            new UIASTNumber(round(_cur_offset_x + _moved_x)),
            new UIASTNumber(round(_cur_offset_y + _moved_y))
        ]));
    }

    /* update size in ast if it changed */
    var _new_w = round(_element.width);
    var _new_h = round(_element.height);

    if (_new_w != round(_editor.drag_start_w))
    {
        ui_editor_ast_set_property(_node, "width", new UIASTNumber(_new_w));
    }

    if (_new_h != round(_editor.drag_start_h))
    {
        ui_editor_ast_set_property(_node, "height", new UIASTNumber(_new_h));
    }

    _editor.drag_mode = UI_EDITOR_DRAG.NONE;
    _editor.dirty     = true;

    PRINT($"[UI Editor] drag applied (dx:{_moved_x} dy:{_moved_y} w:{_new_w} h:{_new_h})");
}


/* =============================================================================
   handle hit-testing
   ============================================================================= */

/* test if mouse is on a resize handle of the selected element */
/* @returns {enum} UI_EDITOR_DRAG mode or NONE */
function ui_editor_hit_handle(_element, _mx, _my)
{
    var _base_scale = ui_get_base_scale();
    var _abs_x      = _element.get_absolute_x();
    var _abs_y      = _element.get_absolute_y();

    var _x1 = _abs_x * _base_scale.x;
    var _y1 = _abs_y * _base_scale.y;
    var _x2 = _x1 + (_element.width  * _base_scale.x);
    var _y2 = _y1 + (_element.height * _base_scale.y);

    var _cx = (_x1 + _x2) * 0.5;
    var _cy = (_y1 + _y2) * 0.5;
    var _hs = UI_EDITOR_HANDLE_HALF;

    /* corners first (higher priority) */
    if (point_in_rectangle(_mx, _my, _x1 - _hs, _y1 - _hs, _x1 + _hs, _y1 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_TL;
    }

    if (point_in_rectangle(_mx, _my, _x2 - _hs, _y1 - _hs, _x2 + _hs, _y1 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_TR;
    }

    if (point_in_rectangle(_mx, _my, _x1 - _hs, _y2 - _hs, _x1 + _hs, _y2 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_BL;
    }

    if (point_in_rectangle(_mx, _my, _x2 - _hs, _y2 - _hs, _x2 + _hs, _y2 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_BR;
    }

    /* edge midpoints */
    if (point_in_rectangle(_mx, _my, _cx - _hs, _y1 - _hs, _cx + _hs, _y1 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_T;
    }

    if (point_in_rectangle(_mx, _my, _cx - _hs, _y2 - _hs, _cx + _hs, _y2 + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_B;
    }

    if (point_in_rectangle(_mx, _my, _x1 - _hs, _cy - _hs, _x1 + _hs, _cy + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_L;
    }

    if (point_in_rectangle(_mx, _my, _x2 - _hs, _cy - _hs, _x2 + _hs, _cy + _hs))
    {
        return UI_EDITOR_DRAG.RESIZE_R;
    }

    return UI_EDITOR_DRAG.NONE;
}


/* =============================================================================
   drawing — overlays, handles, outlines
   ============================================================================= */

/* draw the editor overlay */
function ui_editor_draw()
{
    if (!IS_DEVELOPER_MODE) exit;

    if (global.ui_editor == undefined) exit;

    if (!(global.ui_editor.active)) exit;

    var _editor = global.ui_editor;
    var _gui_w  = global.gui_width;
    var _gui_h  = global.gui_height;

    var _tree_w    = 200;
    var _prop_w    = 220;
    var _toolbar_h = 32;

    /* draw toolbar at top */
    ui_editor_draw_toolbar(0, 0, _gui_w, _toolbar_h);

    /* draw element tree on left */
    if (_editor.preview_instance != undefined)
    {
        ui_editor_draw_tree(0, _toolbar_h, _tree_w, _gui_h - _toolbar_h);
    }

    /* draw properties panel on right */
    if (_editor.preview_instance != undefined)
    {
        ui_editor_draw_properties(_gui_w - _prop_w, _toolbar_h, _prop_w, _gui_h - _toolbar_h);
    }

    /* draw file browser if showing */
    if (_editor.show_file_browser)
    {
        var _fb_w = 320;
        var _fb_h = 400;

        ui_editor_draw_file_browser((_gui_w - _fb_w) / 2, (_gui_h - _fb_h) / 2, _fb_w, _fb_h);
    }

    /* draw selection/hover overlays + handles on canvas */
    ui_editor_draw_overlays();
}


/* draw selection outlines, hover outlines, and resize handles */
function ui_editor_draw_overlays()
{
    var _editor = global.ui_editor;

    if (_editor.preview_instance == undefined) exit;

    var _base_scale = ui_get_base_scale();

    /* hover outline */
    if (_editor.hovered_element != undefined) && (_editor.hovered_element != _editor.selected_element)
    {
        ui_editor_draw_element_outline(_editor.hovered_element, _base_scale, #4444ff, 0.3);
    }

    /* selection outline + handles */
    if (_editor.selected_element != undefined)
    {
        ui_editor_draw_element_outline(_editor.selected_element, _base_scale, UI_EDITOR_PANEL_HIGHLIGHT, 0.8);
        ui_editor_draw_handles(_editor.selected_element, _base_scale);
    }
}


/* draw a coloured outline around an element */
function ui_editor_draw_element_outline(_element, _base_scale, _color, _alpha)
{
    var _abs_x = _element.get_absolute_x();
    var _abs_y = _element.get_absolute_y();

    var _x1 = _abs_x * _base_scale.x;
    var _y1 = _abs_y * _base_scale.y;
    var _x2 = _x1 + (_element.width * _base_scale.x);
    var _y2 = _y1 + (_element.height * _base_scale.y);

    draw_set_alpha(_alpha);

    draw_rectangle_colour(_x1, _y1, _x2, _y2, _color, _color, _color, _color, true);

    /* draw a second outline 1px outside for visibility */
    draw_rectangle_colour(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, _color, _color, _color, _color, true);

    draw_set_alpha(1);
}


/* draw 8 resize handles around the selected element */
function ui_editor_draw_handles(_element, _base_scale)
{
    var _abs_x = _element.get_absolute_x();
    var _abs_y = _element.get_absolute_y();

    var _x1 = _abs_x * _base_scale.x;
    var _y1 = _abs_y * _base_scale.y;
    var _x2 = _x1 + (_element.width  * _base_scale.x);
    var _y2 = _y1 + (_element.height * _base_scale.y);

    var _cx = (_x1 + _x2) * 0.5;
    var _cy = (_y1 + _y2) * 0.5;

    /* 4 corners */
    ui_editor_draw_handle_square(_x1, _y1);
    ui_editor_draw_handle_square(_x2, _y1);
    ui_editor_draw_handle_square(_x2, _y2);
    ui_editor_draw_handle_square(_x1, _y2);

    /* 4 edge midpoints */
    ui_editor_draw_handle_square(_cx, _y1);
    ui_editor_draw_handle_square(_x2, _cy);
    ui_editor_draw_handle_square(_cx, _y2);
    ui_editor_draw_handle_square(_x1, _cy);
}


/* draw a single handle square */
function ui_editor_draw_handle_square(_cx, _cy)
{
    var _hs   = UI_EDITOR_HANDLE_HALF;
    var _fill = UI_EDITOR_PANEL_BG_DARK;
    var _bord = UI_EDITOR_PANEL_HIGHLIGHT;

    draw_rectangle_colour(_cx - _hs, _cy - _hs, _cx + _hs, _cy + _hs, _fill, _fill, _fill, _fill, false);
    draw_rectangle_colour(_cx - _hs, _cy - _hs, _cx + _hs, _cy + _hs, _bord, _bord, _bord, _bord, true);
}


/* =============================================================================
   ast helpers
   ============================================================================= */

/* set or create a property on an ast element node */
/* @param {struct} _node ast element node */
/* @param {string} _key property key */
/* @param {struct} _ast_value ast value node */
function ui_editor_ast_set_property(_node, _key, _ast_value)
{
    for (var i = array_length(_node.properties) - 1; i >= 0; --i)
    {
        if (_node.properties[i].key == _key)
        {
            _node.properties[i].value = _ast_value;

            return;
        }
    }

    /* not found — add new property */
    array_push(_node.properties, new UIASTProperty(_key, _ast_value));
}


/* get the value of an ast property by key, or undefined if not found */
/* @param {struct} _node ast element node */
/* @param {string} _key property key */
/* @returns {struct|undefined} ast value node */
function ui_editor_ast_get_property(_node, _key)
{
    for (var i = array_length(_node.properties) - 1; i >= 0; --i)
    {
        if (_node.properties[i].key == _key)
        {
            return _node.properties[i].value;
        }
    }

    return undefined;
}


/* =============================================================================
   element hit-testing
   ============================================================================= */

/* recursively hit test to find the deepest element under a gui coordinate */
/* @param {struct} _element root element */
/* @param {real} _mx mouse gui x */
/* @param {real} _my mouse gui y */
/* @returns {struct|undefined} deepest hit element or undefined */
function ui_editor_hit_test(_element, _mx, _my)
{
    if (_element == undefined) exit;

    if !(_element.visible) exit;

    var _base_scale = ui_get_base_scale();
    var _abs_x = _element.get_absolute_x();
    var _abs_y = _element.get_absolute_y();

    var _x1 = _abs_x * _base_scale.x;
    var _y1 = _abs_y * _base_scale.y;
    var _x2 = _x1 + (_element.width * _base_scale.x);
    var _y2 = _y1 + (_element.height * _base_scale.y);

    /* check children first (deepest wins) */
    var _child_count = array_length(_element.children);

    for (var i = 0; i < _child_count; ++i)
    {
        var _hit = ui_editor_hit_test(_element.children[i], _mx, _my);

        if (_hit != undefined)
        {
            return _hit;
        }
    }

    /* check self */
    if (_mx >= _x1) && (_mx <= _x2) && (_my >= _y1) && (_my <= _y2)
    {
        /* skip zero-size elements */
        if (_element.width > 0) && (_element.height > 0)
        {
            return _element;
        }
    }

    return undefined;
}


/* find an ast node by element name in the definitions tree */
/* @param {array} _defs array of ast definitions */
/* @param {string} _name element name to find */
/* @returns {struct|undefined} matching ast element node */
function ui_editor_find_ast_node(_defs, _name)
{
    var _count = array_length(_defs);

    for (var i = 0; i < _count; ++i)
    {
        var _def = _defs[i];

        if (_def == undefined) continue;

        if (!is_struct(_def)) continue;

        if (_def.type == UI_AST.ELEMENT)
        {
            if (_def.name == _name)
            {
                return _def;
            }

            /* recurse into children */
            var _found = ui_editor_find_ast_node(_def.children, _name);

            if (_found != undefined)
            {
                return _found;
            }
        }
        else if (_def.type == UI_AST.EXPORT_ELEMENT) && (is_struct(_def.element))
        {
            if (_def.element.name == _name)
            {
                return _def.element;
            }

            var _found = ui_editor_find_ast_node(_def.element.children, _name);

            if (_found != undefined)
            {
                return _found;
            }
        }
    }

    return undefined;
}
