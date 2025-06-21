with (obj_Menu_Anchor)
{
    if (on_draw != undefined)
    {
        on_draw();
    }
}

var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_align(fa_center, fa_middle);

with (obj_Menu_Button)
{
    var _asset = asset_get_index($"{sprite_get_name(sprite_index)}_Edge");
    
    var _asset_exists = sprite_exists(_asset);
    var _asset_offset = ((_asset_exists) ? sprite_get_height(_asset) : 0);
    
    if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            var _button_width  = (image_xscale * 16) + 2;
            var _button_height = (image_yscale * 16) + 2;
            
            draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, x - (_button_width / 2), y - (_button_height / 2) + _asset_offset, _button_width, _button_height, c_white, 1);
            
            if (_asset_exists)
            {
                draw_sprite_ext(sprite_index, 1, x, y + _asset_offset, image_xscale, image_yscale, 0, c_white, 1);
            }
            else
            {
                draw_sprite_ext(sprite_index, 1, x, y, image_xscale, image_yscale, 0, c_white, 1);
            }
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
            {
                var _button_width  = (image_xscale * 16) + 2;
                var _button_height = (image_yscale * 16) + 2;
                
                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, x - (_button_width / 2), y - (_button_height / 2), _button_width, _button_height + _asset_offset, c_white, 1);
            }
            
            if (_asset_exists)
            {
                draw_sprite_ext(_asset, 0, x, y + (sprite_get_height(sprite_index) * image_yscale / 2), image_xscale, 1, 0, c_white, 1);
            }
            
            draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    if (text != undefined) && (icon != undefined)
    { 
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            draw_sprite_ext(icon, icon_index, x - (string_width(text) * FONT_SCALE / 2), y + _asset_offset, 1, 1, 0, c_ltgray, 1);
            
            draw_text_transformed_colour(x + (sprite_get_width(icon) / 2), y + _asset_offset, text, FONT_SCALE, FONT_SCALE, 0, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 1);
        }
        else
        {
            draw_sprite_ext(icon, icon_index, x - (string_width(text) * FONT_SCALE / 2), y, 1, 1, 0, c_white, 1);
            
            draw_text_transformed_colour(x + (sprite_get_width(icon) / 2), y, text, FONT_SCALE, FONT_SCALE, 0, c_white, c_white, c_white, c_white, 1);
        }
    }
    else if (text != undefined)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            draw_text_transformed_colour(x, y + _asset_offset, text, FONT_SCALE, FONT_SCALE, 0, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 1);
        }
        else
        {
        	draw_text_transformed_colour(x, y, text, FONT_SCALE, FONT_SCALE, 0, c_white, c_white, c_white, c_white, 1);
        }
    }
    else if (icon != undefined)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            draw_sprite_ext(icon, icon_index, x, y + _asset_offset, 1, 1, 0, c_ltgray, 1);
        }
        else
        {
        	draw_sprite_ext(icon, icon_index, x, y, 1, 1, 0, c_white, 1);
        }
    }
}

draw_set_align(_halign, _valign);