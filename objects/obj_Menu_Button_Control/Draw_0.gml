with (obj_Menu_Anchor)
{
    if (on_draw != undefined)
    {
        on_draw();
    }
}

with (obj_Menu_Button)
{
    var _asset = asset_get_index($"{sprite_get_name(sprite_index)}_Edge");
    
    show_debug_message(sprite_get_name(sprite_index));
    show_debug_message($"{sprite_get_name(sprite_index)}_Edge");
    show_debug_message(_asset);
    
    var _asset_offset = ((sprite_exists(_asset)) ? sprite_get_height(_asset) : 0);
    
    if (boolean & MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            if (sprite_exists(_asset))
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
            if (sprite_exists(_asset))
            {
                draw_sprite_ext(_asset, 0, x, y + (sprite_get_height(sprite_index) * image_yscale / 2), image_xscale, 1, 0, c_white, 1);
            }
            
            draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
}