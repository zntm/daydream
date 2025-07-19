gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _render_xoffset = xoffset;
var _render_yoffset = yoffset;

with (obj_Menu_Anchor)
{
    if (on_draw != undefined)
    {
        on_draw(_render_xoffset, _render_yoffset);
    }
}

var _loca_font_scale = global.loca_font_scale;

var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_align(fa_center, fa_middle);

with (obj_Menu_Button)
{
    var _x = _render_xoffset + x;
    var _y = _render_yoffset + y;
    
    if (_x < -256) || (_y < -256) continue;
    
    var _asset = asset_get_index($"{sprite_get_name(sprite_index)}_Edge");
    
    var _asset_exists = sprite_exists(_asset);
    var _asset_offset = ((_asset_exists) ? sprite_get_height(_asset) : 0);
    
    if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            var _button_width  = (image_xscale * 16) + 2;
            var _button_height = (image_yscale * 16) + 2;
            
            draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2) + _asset_offset, _button_width, _button_height, c_white, 1);
            
            if (_asset_exists)
            {
                draw_sprite_ext(sprite_index, 1, _x, _y + _asset_offset, image_xscale, image_yscale, 0, c_white, 1);
            }
            else
            {
                draw_sprite_ext(sprite_index, 1, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
            }
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
            {
                var _button_width  = (image_xscale * 16) + 2;
                var _button_height = (image_yscale * 16) + 2;
                
                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height + _asset_offset, c_white, 1);
            }
            
            if (_asset_exists)
            {
                draw_sprite_ext(_asset, 0, _x, _y + (sprite_get_height(sprite_index) * image_yscale / 2), image_xscale, 1, 0, c_white, 1);
            }
            
            draw_sprite_ext(sprite_index, 0, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    if (text != undefined) && (icon != undefined)
    { 
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y + _asset_offset, icon_xscale, icon_yscale, 0, c_ltgray, 1);
            
            render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y + _asset_offset, text, 1, 1, 0, c_ltgray, 1);
        }
        else
        {
            draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y, icon_xscale, icon_yscale, 0, c_white, 1);
            
            render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y, text, 1, 1, 0, c_white, 1);
        }
    }
    else if (text != undefined)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            render_text(_x, _y + _asset_offset, text, 1, 1, 0, c_ltgray, 1);
        }
        else
        {
            render_text(_x, _y, text, 1, 1, 0, c_white, 1);
        }
    }
    else if (icon != undefined)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            draw_sprite_ext(icon, icon_index, _x, _y + _asset_offset, icon_xscale, icon_yscale, 0, c_ltgray, 1);
        }
        else
        {
            draw_sprite_ext(icon, icon_index, _x, _y, icon_xscale, icon_yscale, 0, c_white, 1);
        }
    }
    
    if (on_draw != undefined)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            on_draw(_x, _y + _asset_offset, c_ltgray);
        }
        else
        {
        	on_draw(_x, _y, c_white);
        }
    }
}

with (obj_Menu_Textbox)
{
    var _x = _render_xoffset + x;
    var _y = _render_yoffset + y;
    
    if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            var _button_width  = (image_xscale / 2 * 16) + 2;
            var _button_height = (image_yscale / 2 * 16) + 2;
            
            draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);
            
            draw_sprite_ext(sprite_index, 1, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
            {
                var _button_width  = (image_xscale / 2 * 16) + 2;
                var _button_height = (image_yscale / 2 * 16) + 2;
                
                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);
            }
            
            draw_sprite_ext(sprite_index, 0, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    if (text_display != "")
    {
        render_text(_x, _y, text_display, 1, 1, 0, c_white, 1);
    }
    else if (placeholder != undefined)
    {
        render_text(_x, _y, placeholder, 1, 1, 0, c_white, 0.25);
    }
}

draw_set_align(_halign, _valign);

gpu_set_blendmode(bm_normal);