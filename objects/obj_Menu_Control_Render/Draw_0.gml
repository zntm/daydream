var _render_xoffset = xoffset;
var _render_yoffset = yoffset;

var _render_xscale = xscale;
var _render_yscale = yscale;

var _loca_font_scale = global.loca_font_scale * _render_xscale;

var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_align(fa_center, fa_middle);

var _sw = window_get_width();
var _sh = window_get_height();

var _camera_x = variable_global_exists("camera_x") ? global.camera_x : 0;
var _camera_y = variable_global_exists("camera_y") ? global.camera_y : 0;

var _gui_w = room_width  * _render_xscale;
var _gui_h = room_height * _render_yscale;

/* uniform scale: fit height, allow horizontal expansion for widescreen */
var _scale   = _sh / _gui_h;
var _scale_x = _scale;
var _scale_y = _scale;

/* center content - positive when window is wider than the gui base aspect ratio */
var _content_w  = _gui_w * _scale;
var _content_ox = (_sw - _content_w) / 2;

/* iterate through all active menu layers */
var _max_layer = surface_index_length - 1;

with (obj_Menu_Control_Button)
{
    _max_layer = max(menu_layer, _max_layer);
}

/* ensure surfaces array is large enough */
if (array_length(surfaces) <= _max_layer)
{
    array_resize(surfaces, _max_layer + 1);
}

/* render each layer to its own window-sized surface */
for (var j = 0; j <= _max_layer; ++j)
{
    if (!surface_exists(surfaces[j]))
    {
        surfaces[j] = surface_create(_sw, _sh);
    }

    surface_set_target(surfaces[j]);
    draw_clear_alpha(c_black, 0);

    var _matrix_saved = matrix_get(matrix_world);
    var _matrix_scale = matrix_build(_content_ox, 0, 0, 0, 0, 0, _scale_x, _scale_y, 1);
    matrix_set(matrix_world, _matrix_scale);

    var _should_dim = (j > 0);

    if (_should_dim) && (j < array_length(surface_index_shader))
    {
        var _check_struct = surface_index_shader[j];

        if (is_struct(_check_struct)) && (_check_struct[$ "no_dim"] == true)
        {
            _should_dim = false;
        }
    }

    if (_should_dim)
    {
        /* draw in gui-space coordinates - the matrix scales + offsets to window */
        draw_sprite_ext(spr_Square, 0, -_content_ox / _scale_x, 0, _sw / _scale_x, _sh / _scale_y, 0, c_black, 0.5);
    }

    with (obj_Menu_Anchor)
    {
        var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);

        if (_surface_index == j) && (on_draw != undefined)
        {
            on_draw(_render_xoffset, _render_yoffset, _render_xscale, _render_yscale);
        }
    }

    with (obj_Menu_Button)
    {
        var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);

        if (_surface_index != j) || (!rectangle_in_rectangle(0, 0, room_width, room_height, bbox_left + _render_xoffset, bbox_top + _render_yoffset, bbox_right + _render_xoffset, bbox_bottom + _render_yoffset)) continue;

        var _x = (_render_xoffset + x) * _render_xscale;
        var _y = (_render_yoffset + y) * _render_yscale;

        var _xscale = image_xscale * _render_xscale;
        var _yscale = image_yscale * _render_yscale;

        var _asset = asset_get_index($"{sprite_get_name(sprite_index)}_Edge");

        var _asset_exists = sprite_exists(_asset);
        var _asset_offset = ((_asset_exists) ? sprite_get_height(_asset) : 0);

        if (on_draw_behind != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                on_draw_behind(_x, _y + _asset_offset, _render_xscale, _render_yscale, c_ltgray);
            }
            else
            {
                on_draw_behind(_x, _y, _render_xscale, _render_yscale, c_white);
            }
        }

        if (boolean & MENU_BUTTON_BOOL.IS_VISIBLE)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                var _button_width  = (_xscale * 16) + 2;
                var _button_height = (_yscale * 16) + 2;

                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2) + _asset_offset, _button_width, _button_height, c_white, 1);

                if (_asset_exists)
                {
                    draw_sprite_ext(sprite_index, 1, _x, _y + _asset_offset, _xscale, _yscale, 0, c_white, 1);
                }
                else
                {
                    draw_sprite_ext(sprite_index, 1, _x, _y, _xscale, _yscale, 0, c_white, 1);
                }
            }
            else
            {
                if (boolean & MENU_BUTTON_BOOL.IS_HOVER)
                {
                    var _button_width  = (_xscale * 16) + 2;
                    var _button_height = (_yscale * 16) + 2;

                    draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height + _asset_offset, c_white, 1);
                }

                if (_asset_exists)
                {
                    draw_sprite_ext(_asset, 0, _x, _y + (sprite_get_height(sprite_index) * _yscale / 2), _xscale, 1, 0, c_white, 1);
                }

                draw_sprite_ext(sprite_index, 0, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }
        }

        if (text != undefined) && (icon != undefined)
        {
            var _icon_shader = (variable_instance_exists(id, "icon_shader") ? icon_shader : undefined);

            if (_icon_shader != undefined)
            {
                shader_set(_icon_shader);

                var _uniforms = (variable_instance_exists(id, "icon_shader_uniforms") ? icon_shader_uniforms : undefined);

                if (_uniforms != undefined)
                {
                    var _keys    = struct_get_names(_uniforms);
                    var _cnt     = array_length(_keys);
                    var _use_int = _uniforms[$ "_use_int"] ?? false;

                    for (var k = _cnt - 1; k >= 0; --k)
                    {
                        var _key = _keys[k];
                        if (_key == "_use_int") continue;

                        var _u = shader_get_uniform(_icon_shader, _key);
                        if (_u == -1) continue;

                        var _val = _uniforms[$ _key];

                        if (is_array(_val))
                        {
                            if (_use_int) shader_set_uniform_i_array(_u, _val);
                            else shader_set_uniform_f_array(_u, _val);
                        }
                        else
                        {
                            if (_use_int) shader_set_uniform_i(_u, _val);
                            else shader_set_uniform_f(_u, _val);
                        }
                    }
                }
            }

            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y + _asset_offset, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_ltgray, 1);
            }
            else
            {
                draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_white, 1);
            }

            if (_icon_shader != undefined) shader_reset();

            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y + _asset_offset, text, _render_xscale, _render_yscale, 0, c_ltgray, 1);
            }
            else
            {
                render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y, text, _render_xscale, _render_yscale, 0, c_white, 1);
            }
        }
        else if (text != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                render_text(_x, _y + _asset_offset, text, _render_xscale, _render_yscale, 0, c_ltgray, 1);
            }
            else
            {
                render_text(_x, _y, text, _render_xscale, _render_yscale, 0, c_white, 1);
            }
        }
        else if (icon != undefined)
        {
            var _icon_shader = (variable_instance_exists(id, "icon_shader") ? icon_shader : undefined);

            if (_icon_shader != undefined)
            {
                shader_set(_icon_shader);

                var _uniforms = (variable_instance_exists(id, "icon_shader_uniforms") ? icon_shader_uniforms : undefined);

                if (_uniforms != undefined)
                {
                    var _keys    = struct_get_names(_uniforms);
                    var _cnt     = array_length(_keys);
                    var _use_int = _uniforms[$ "_use_int"] ?? false;

                    for (var k = _cnt - 1; k >= 0; --k)
                    {
                        var _key = _keys[k];
                        if (_key == "_use_int") continue;

                        var _u = shader_get_uniform(_icon_shader, _key);
                        if (_u == -1) continue;

                        var _val = _uniforms[$ _key];

                        if (is_array(_val))
                        {
                            if (_use_int) shader_set_uniform_i_array(_u, _val);
                            else shader_set_uniform_f_array(_u, _val);
                        }
                        else
                        {
                            if (_use_int) shader_set_uniform_i(_u, _val);
                            else shader_set_uniform_f(_u, _val);
                        }
                    }
                }
            }

            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                draw_sprite_ext(icon, icon_index, _x, _y + _asset_offset, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_ltgray, 1);
            }
            else
            {
                draw_sprite_ext(icon, icon_index, _x, _y, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_white, 1);
            }

            if (_icon_shader != undefined) shader_reset();
        }

        if (on_draw != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                on_draw(_x, _y + _asset_offset, c_ltgray);
            }
            else
            {
                on_draw(_x, _y, c_white);
            }
        }
    }

    with (obj_Menu_Dropdown)
    {
        var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);

        if (_surface_index != j) || (!rectangle_in_rectangle(0, 0, room_width, room_height, bbox_left + _render_xoffset, bbox_top + _render_yoffset, bbox_right + _render_xoffset, bbox_bottom + _render_yoffset)) continue;

        var _x = (_render_xoffset + x) * _render_xscale;
        var _y = (_render_yoffset + y) * _render_yscale;

        var _xscale = image_xscale * _render_xscale;
        var _yscale = image_yscale * _render_yscale;

        var _choices_length = array_length(choices);

        if (boolean & MENU_BUTTON_BOOL.IS_VISIBLE)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                var _button_width  = ((_xscale / 2) * 16) + 2;
                var _button_height = ((_yscale / 2) * 16) + 2;

                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);

                draw_sprite_ext(sprite_index, 1, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }
            else
            {
                if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
                {
                    var _button_width  = ((_xscale / 2) * 16) + 2;
                    var _button_height = ((_yscale / 2) * 16) + 2;

                    draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);
                }

                draw_sprite_ext(sprite_index, 0, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }

            if (boolean & MENU_BUTTON_BOOL.IS_SELECTED) && (_choices_length > 0)
            {
                var _button_width  = (_xscale / 2) * 16;
                var _button_height = (_yscale / 2) * 16;

                for (var l = _choices_length - 1; l >= 0; --l)
                {
                    draw_sprite_ext(sprite_index, 0, _x, _y + ((l + 1) * _button_height), _xscale, _yscale, 0, c_white, 1);

                    render_text(_x, _y + ((l + 1) * _button_height), choices[l], _render_xscale, _render_yscale, 0, c_white, 1);
                }
            }
        }

        if (_choices_length > 0) && (choice_index < _choices_length)
        {
            var _choice = choices[choice_index];

            if (_choice != "")
            {
                render_text(_x, _y, _choice, _render_xscale, _render_yscale, 0, c_white, 1);
            }
        }
    }

    with (obj_Menu_Textbox)
    {
        var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);

        if (_surface_index != j) || (!rectangle_in_rectangle(0, 0, room_width, room_height, bbox_left + _render_xoffset, bbox_top + _render_yoffset, bbox_right + _render_xoffset, bbox_bottom + _render_yoffset)) continue;

        var _x = (_render_xoffset + x) * _render_xscale;
        var _y = (_render_yoffset + y) * _render_yscale;

        var _xscale = image_xscale * _render_xscale;
        var _yscale = image_yscale * _render_yscale;

        if (boolean & MENU_BUTTON_BOOL.IS_VISIBLE)
        {
            if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
            {
                var _button_width  = ((_xscale / 2) * 16) + 2;
                var _button_height = ((_yscale / 2) * 16) + 2;

                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);

                draw_sprite_ext(sprite_index, 1, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }
            else
            {
                if (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING))
                {
                    var _button_width  = ((_xscale / 2) * 16) + 2;
                    var _button_height = ((_yscale / 2) * 16) + 2;

                    draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);
                }

                draw_sprite_ext(sprite_index, 0, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }
        }

        if (text_display != "")
        {
            render_text(_x, _y, text_display, _render_xscale, _render_yscale, 0, c_white, 1);
        }
        else if (placeholder != undefined)
        {
            render_text(_x, _y, placeholder, _render_xscale, _render_yscale, 0, c_white, 0.25);
        }
    }

    matrix_set(matrix_world, _matrix_saved);
    surface_reset_target();

    /* draw declarative ui on top layer */
    if (j == _max_layer) && (variable_global_exists("gui_root")) && (global.gui_root != undefined)
    {
        surface_set_target(surfaces[j]);

        /*
         * declarative UI handles its own scaling relative to the design 540p height
         * reset matrix to identity (identity surface) so UI draws at its intended logical scale
         */
        var _m_identity = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
        matrix_set(matrix_world, _m_identity);

        global.gui_root.draw();

        /* draw dynamically spawned UI instances (unparented ones) */
        if (variable_global_exists("ui_instances"))
        {
            var _ui_keys  = struct_get_names(global.ui_instances);
            var _ui_count = array_length(_ui_keys);

            for (var i = _ui_count - 1; i >= 0; --i)
            {
                var _ui_inst = global.ui_instances[$ _ui_keys[i]];

                if (_ui_inst != undefined) && (array_length(_ui_inst.root_elements) > 0) && (_ui_inst.root_elements[0].parent == undefined)
                {
                    ui_draw(_ui_inst);
                }
            }
        }

        matrix_set(matrix_world, _matrix_saved);
        surface_reset_target();
    }
}

/* capture background for blur (if requested by transition or if in main menu) */
var _is_menu_room = string_starts_with(room_get_name(room), "rm_Menu");

if (global.menu_capture_blur) || (_is_menu_room)
{
    render_menu_blur();

    if (!_is_menu_room)
    {
        global.menu_capture_blur = false;
    }
}

/* composite all surfaces with transition effect */
var _transition_alpha = global.menu_transition_alpha ?? 1;
var _transition_scale = global.menu_transition_scale ?? 1;

/* center on window, shrink toward window center during transition */
var _trans_offset_x = (_sw / 2) * (1 - _transition_scale);
var _trans_offset_y = (_sh / 2) * (1 - _transition_scale);

/* draw blur background during transition */
var _blur_alpha = global.menu_blur_alpha ?? 0;

if (_blur_alpha > 0.01)
{
    if (surface_exists(global.menu_blur_surface[@ 1]))
    {
        var _tex_filter = gpu_get_tex_filter();
        gpu_set_tex_filter(true);

        var _blur_view_w = camera_get_view_width(view_camera[0]);
        var _blur_view_h = camera_get_view_height(view_camera[0]);

        draw_surface_stretched_ext(
            global.menu_blur_surface[@ 1],
            _camera_x, _camera_y,
            _blur_view_w + (GUI_MENU_BLUR_RESIZE * (_blur_view_w / _sw)),
            _blur_view_h + (GUI_MENU_BLUR_RESIZE * (_blur_view_h / _sh)),
            c_white,
            _blur_alpha
        );

        gpu_set_tex_filter(_tex_filter);
    }
    else
    {
        var _blur_view_w = camera_get_view_width(view_camera[0]);
        var _blur_view_h = camera_get_view_height(view_camera[0]);

        draw_sprite_ext(spr_Square, 0, _camera_x, _camera_y, _blur_view_w, _blur_view_h, 0, c_black, _blur_alpha * 0.5);
    }
}

for (var j = 0; j <= _max_layer; ++j)
{
    var _shader_struct = undefined;
    var _shader        = undefined;

    if (j < array_length(surface_index_shader))
    {
        _shader_struct = surface_index_shader[j];

        if (is_struct(_shader_struct))
        {
            _shader = _shader_struct.id;
        }
        else
        {
            _shader = _shader_struct;
        }
    }

    if (_shader != undefined)
    {
        shader_set(_shader);

        if (is_struct(_shader_struct))
        {
            var _keys   = struct_get_names(_shader_struct);
            var _length = array_length(_keys);

            for (var k = _length - 1; k >= 0; --k)
            {
                var _key = _keys[k];

                if (_key == "id") || (_key == "no_dim") continue;

                var _uniform = shader_get_uniform(_shader, _key);

                if (_uniform != -1)
                {
                    var _value = _shader_struct[$ _key];

                    if (is_array(_value))
                    {
                        shader_set_uniform_f_array(_uniform, _value);
                    }
                    else
                    {
                        shader_set_uniform_f(_uniform, _value);
                    }
                }
            }
        }
    }

    /* surfaces are window-sized; scale down to fit camera/view space */
    var _view_w = camera_get_view_width(view_camera[0]);
    var _view_h = camera_get_view_height(view_camera[0]);
    var _surf_scale_x = (_view_w / _sw) * _transition_scale;
    var _surf_scale_y = (_view_h / _sh) * _transition_scale;

    draw_surface_ext(
        surfaces[j],
        _camera_x + _trans_offset_x * (_view_w / _sw),
        _camera_y + _trans_offset_y * (_view_h / _sh),
        _surf_scale_x,
        _surf_scale_y,
        0,
        c_white,
        _transition_alpha
    );

    if (_shader != undefined) shader_reset();
}

draw_set_align(_halign, _valign);

gpu_set_blendmode(bm_normal);

ui_editor_draw();
