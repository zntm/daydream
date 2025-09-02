gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _render_xoffset = xoffset;
var _render_yoffset = yoffset;

var _render_xscale = xscale;
var _render_yscale = yscale;

var _loca_font_scale = global.loca_font_scale * _render_xscale;

var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_align(fa_center, fa_middle);
\
for (var i = 0; i <= obj_Menu_Control_Button.menu_layer; ++i)
{
    if (i != 0)
    {
        draw_sprite_ext(spr_Square, 0, 0, 0, room_width, room_height, 0, c_black, 0.5);
    }
    
    with (obj_Menu_Anchor)
    {
        if (menu_layer == i) && (on_draw != undefined)
        {
            on_draw(_render_xoffset, _render_yoffset, _render_xscale, _render_yscale);
        }
    }
    
    with (obj_Menu_Button)
    {
        if (menu_layer != i) || (!rectangle_in_rectangle(0, 0, room_width, room_height, bbox_left + _render_xoffset, bbox_top + _render_yoffset, bbox_right + _render_xoffset, bbox_bottom + _render_yoffset)) continue;
        
        var _x = (_render_xoffset + x) * _render_xscale;
        var _y = (_render_yoffset + y) * _render_yscale;
        
        var _xscale = image_xscale * _render_xscale;
        var _yscale = image_yscale * _render_yscale;
        
        var _asset = asset_get_index($"{sprite_get_name(sprite_index)}_Edge");
        
        var _asset_exists = sprite_exists(_asset);
        var _asset_offset = ((_asset_exists) ? sprite_get_height(_asset) : 0);
        
        if (on_draw_behind != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
            {
                on_draw_behind(_x, _y + _asset_offset, _render_xscale, _render_yscale, c_ltgray);
            }
            else
            {
            	on_draw_behind(_x, _y, _render_xscale, _render_yscale, c_white);
            }
        }
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
        {
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
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
                if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
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
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
            {
                draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y + _asset_offset, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_ltgray, 1);
                
                render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y + _asset_offset, text, _render_xscale, _render_yscale, 0, c_ltgray, 1);
            }
            else
            {
                draw_sprite_ext(icon, icon_index, _x - (string_width(text) * _loca_font_scale / 2), _y, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_white, 1);
                
                render_text(_x + (sprite_get_width(icon) * icon_xscale / 2), _y, text, _render_xscale, _render_yscale, 0, c_white, 1);
            }
        }
        else if (text != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
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
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
            {
                draw_sprite_ext(icon, icon_index, _x, _y + _asset_offset, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_ltgray, 1);
            }
            else
            {
                draw_sprite_ext(icon, icon_index, _x, _y, _render_xscale * icon_xscale, _render_yscale * icon_yscale, 0, c_white, 1);
            }
        }
        
        if (on_draw != undefined)
        {
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
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
        if (menu_layer != i) || (!rectangle_in_rectangle(0, 0, room_width, room_height, bbox_left + _render_xoffset, bbox_top + _render_yoffset, bbox_right + _render_xoffset, bbox_bottom + _render_yoffset)) continue;
        
        var _x = (_render_xoffset + x) * _render_xscale;
        var _y = (_render_yoffset + y) * _render_yscale;
        
        var _xscale = image_xscale * _render_xscale;
        var _yscale = image_yscale * _render_yscale;
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
        {
            if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
            {
                var _button_width  = ((_xscale / 2) * 16) + 2;
                var _button_height = ((_yscale / 2) * 16) + 2;
                
                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - (_button_width / 2), _y - (_button_height / 2), _button_width, _button_height, c_white, 1);
                
                draw_sprite_ext(sprite_index, 1, _x, _y, _xscale, _yscale, 0, c_white, 1);
            }
            else
            {
                if (boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING))
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
}

draw_set_align(_halign, _valign);

gpu_set_blendmode(bm_normal);