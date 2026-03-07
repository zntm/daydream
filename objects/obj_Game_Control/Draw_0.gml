var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _camera_x = variable_global_exists("camera_x") ? global.camera_x : 0;
var _camera_y = variable_global_exists("camera_y") ? global.camera_y : 0;

var _camera_width  = variable_global_exists("camera_width") ? global.camera_width : 960;
var _camera_height = variable_global_exists("camera_height") ? global.camera_height : 540;

if (is_opened & WORLD_OPENED_BOOL.GENERATING_WORLD)
{
    if !(surface_refresh & SURFACE_REFRESH_BOOL.GENERATING_WORLD)
    {
        surface_refresh |= SURFACE_REFRESH_BOOL.GENERATING_WORLD;

        render_pause();
    }

    if (surface_exists(surface_pause[1]))
    {
        var _display_blur = global.settings.display_blur;

        if (_display_blur > 0)
        {
            gpu_set_texfilter(true);

            draw_surface_stretched_ext(surface_pause[@ 1], _camera_x, _camera_y, _camera_width + GUI_PAUSE_BLUR_RESIZE, _camera_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);

            gpu_set_texfilter(false);
        }
    }
    else
    {
        draw_clear(c_black);
    }

    /* spawn loading ui if not yet created */
    if (!variable_instance_exists(id, "ui_loading")) || (ui_loading == undefined)
    {
        var _loading_def = ui_load("ui/menu/loading.ui");

        if (_loading_def != undefined)
        {
            ui_loading_link = {
                loading_text: loca_translate("phantasia:menu.loading_world.title")
            }

            ui_loading = ui_spawn(_loading_def, {
                link: ui_loading_link
            });
        }
    }

    /* draw loading ui */
    if (ui_loading != undefined)
    {
        /* update to process bindings (loading text) */
        ui_update(ui_loading);

        /* ui_draw handles scaling internally via ui_get_base_scale */
        ui_draw(ui_loading);
    }

    ui_editor_draw();

    gpu_set_blendmode(bm_normal);

    exit;
}

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

/* render lightning bolts on top of the scene */
global.lightning_pool.render();

/* register colorgrade pass once */
if (!__colorgrade_pass_registered)
{
    __colorgrade_pass_registered = true;

    global.post_process.add_pass(shd_Colorgrade, function()
    {
        var _world_data = global.world_data[$ global.current_world.dimension];
        var _weather    = global.current_world.weather;
        var _storm      = clamp(_weather.storm, 0, 1);

        /* base from world data, storm desaturates on top */
        var _saturation    = _world_data.get_colorgrade_saturation() * (1 - _storm * 0.6);
        var _tint_r        = _world_data.get_colorgrade_tint_r();
        var _tint_g        = _world_data.get_colorgrade_tint_g();
        var _tint_b        = _world_data.get_colorgrade_tint_b();
        var _tint_strength = _world_data.get_colorgrade_tint_strength();

        /* storm layers a blue-grey tint on top */
        if (_storm > 0)
        {
            var _storm_r = 0.75;
            var _storm_g = 0.82;
            var _storm_b = 0.90;
            var _storm_t = _storm * 0.4;

            _tint_r        = lerp(_tint_r, _storm_r, _storm_t);
            _tint_g        = lerp(_tint_g, _storm_g, _storm_t);
            _tint_b        = lerp(_tint_b, _storm_b, _storm_t);
            _tint_strength = clamp(_tint_strength + _storm_t, 0, 1);
        }

        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_saturation"),
            _saturation
        );

        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_tint_color"),
            _tint_r, _tint_g, _tint_b
        );

        shader_set_uniform_f(
            shader_get_uniform(shd_Colorgrade, "u_tint_strength"),
            _tint_strength
        );
    }, true);
}

/* apply all post-processing passes */
global.post_process.apply(
    surface_get_width(application_surface),
    surface_get_height(application_surface)
);

/* find local player */
var _lp = noone;
with (obj_Player) { if (is_local) { _lp = id; break; } }

if (_lp == noone)
{
    ui_editor_draw();

    gpu_set_blendmode(bm_normal);

    exit;
}

var _player_x = _lp.x;
var _player_y = _lp.y;

if (is_opened & (WORLD_OPENED_BOOL.PAUSE | WORLD_OPENED_BOOL.EXIT))
{
    if !(surface_refresh & SURFACE_REFRESH_BOOL.PAUSE) || (!surface_exists(surface_pause[0])) || (!surface_exists(surface_pause[1]))
    {
        surface_refresh |= SURFACE_REFRESH_BOOL.PAUSE;

        render_pause();
    }

    var _display_blur = global.settings.display_blur;

    if (_display_blur > 0)
    {
        gpu_set_texfilter(true);

        draw_surface_stretched_ext(surface_pause[@ 1], _camera_x, _camera_y, _camera_width + GUI_PAUSE_BLUR_RESIZE, _camera_height + GUI_PAUSE_BLUR_RESIZE, c_white, _display_blur);

        gpu_set_texfilter(false);
    }

    /* draw pause ui buttons */
    if (variable_instance_exists(id, "ui_pause")) && (ui_pause != undefined)
    {
        global.ui_hover_consumed = false;
        global.ui_input_consumed = false;

        ui_update(ui_pause);
    }

    ui_editor_draw();

    gpu_set_blendmode(bm_normal);

    exit;
}

var _gui_scale = global.gui_scale;
var _aspect_ratio = global.window_width / global.window_height;
var _gui_w = (_aspect_ratio * 540) * _gui_scale;
var _gui_h = 540 * _gui_scale;

/* uniform scale based on height */
var _scale = _camera_height / _gui_h;

/* content horizontal offset (centering) */
var _ox = (_camera_width - (_gui_w * _scale)) / 2;

var _matrix_saved = matrix_get(matrix_world);
var _matrix_scale = matrix_build(_camera_x + _ox, _camera_y, 0, 0, 0, 0, _scale, _scale, 1);
matrix_set(matrix_world, _matrix_scale);

render_gui_vignette(_player_y, _gui_w, _gui_h);

/* only draw HUD elements when GUI is toggled on */
if (is_opened & WORLD_OPENED_BOOL.GUI)
{
    render_hud(_gui_w, _gui_h);
}

matrix_set(matrix_world, _matrix_saved);

/* draw declarative UI relative to camera - UI handles its own design-to-pixel scaling */
if (is_opened & WORLD_OPENED_BOOL.GUI)
{
    var _matrix_ui = matrix_build(_camera_x, _camera_y, 0, 0, 0, 0, 1, 1, 1);
    matrix_set(matrix_world, _matrix_ui);

    if (global.gui_root != undefined)
    {
        global.gui_root.draw();
    }

    /* draw dynamically spawned UI instances (blueprints, etc.) */
    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys  = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);

        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];

            if (_ui_inst != undefined)
            {
                /* only draw if the instance's root elements are not parented */
                if (array_length(_ui_inst.root_elements) > 0) && (_ui_inst.root_elements[0].parent == undefined)
                {
                    ui_draw(_ui_inst);
                }
            }
        }
    }

    matrix_set(matrix_world, _matrix_saved);

    /* draw deferred text */
    var _deferred_text_length = array_length(global.gui_deferred_text);

    if (_deferred_text_length > 0)
    {
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);

        for (var i = _deferred_text_length - 1; i >= 0; --i)
        {
            var _ = global.gui_deferred_text[i];

            if (struct_exists(_, "halign")) draw_set_halign(_.halign);
            else draw_set_halign(fa_right);

            if (struct_exists(_, "valign")) draw_set_valign(_.valign);
            else draw_set_valign(fa_bottom);

            render_text(_.x, _.y, _.text, _.xscale, _.yscale, 0, _.colour, _.alpha);
        }

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        array_resize(global.gui_deferred_text, 0);
    }

    /* display held item name */
    if !(is_opened & WORLD_OPENED_BOOL.INVENTORY)
    {
        var _item = global.inventory.base[global.inventory_selected_hotbar];

        if (_item != INVENTORY_EMPTY)
        {
            var _gui_scale = global.gui_scale;
            var _data      = global.item_data[$ _item.get_id()];

            var _text_x = _gui_w / 2;
            var _text_y = _gui_h - (INVENTORY_SLOT_DIMENSION_SCALED + (96 * _gui_scale));

            draw_set_halign(fa_center);
            draw_set_valign(fa_bottom);

            render_text(_text_x, _text_y, loca_translate($"{_data.get_namespace()}:item.{_data.get_id()}.name"), 1.5 * _gui_scale, 1.5 * _gui_scale);

            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}

/* screenshot */
if (keyboard_check_pressed(vk_f2))
{
    sfx_play("phantasia:sfx/menu/screenshot", global.settings.audio_sfx);

    var _surface = surface_create(_window_width, _window_height);

    surface_set_target(_surface);

    draw_surface_stretched(application_surface, 0, 0, _window_width, _window_height);

    surface_reset_target();

    surface_save(_surface, $"{PROGRAM_DIRECTORY_SCREENSHOTS}/{current_year}-{current_month}-{current_day}_{current_hour}.{current_minute}.{current_second}.png");

    surface_free(_surface);
}

gpu_set_blendmode(bm_normal);

ui_editor_draw();