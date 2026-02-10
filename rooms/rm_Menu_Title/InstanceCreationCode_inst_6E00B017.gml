menu_anchor_position(x, y, GUI_ANCHOR.MIDDLE, room_width, room_height);

index = 3;

text = loca_translate("phantasia:menu.title.exit");

on_select_release = function()
{
    var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
    
    with (_inst_header)
    {
        text = loca_translate("phantasia:menu.exit.header");
        
        menu_layer = 1;
        
        on_draw = function(_x, _y, _xscale, _yscale, _c)
        {
            var _halign = draw_get_halign();
            var _valign = draw_get_valign();
            
            draw_set_align(fa_center, fa_middle);
            
            // Header was scale 1 in 540p. Now 1 * _xscale.
            render_text(_x, _y, text, _xscale, _yscale);
            
            draw_set_align(_halign, _valign);
        }
    }
    
    var _inst_no = instance_create_layer(412, 300, "Instances", obj_Menu_Button);
    
    with (_inst_no)
    {
        text = loca_translate("phantasia:menu.generic.no");
        
        image_xscale = 8;
        image_yscale = 3;
        
        menu_layer = 1;
        
        on_select_release = menu_popup_destroy;
    }
    
    var _inst_yes = instance_create_layer(548, 300, "Instances", obj_Menu_Button);
    
    with (_inst_yes)
    {
        text = loca_translate("phantasia:menu.generic.yes");
        
        image_xscale = 8;
        image_yscale = 3;
        
        menu_layer = 1;
        
        on_select_release = function()
        {
            game_end();
        }
    }
    
    menu_popup_create([
        _inst_header,
        _inst_no,
        _inst_yes
    ]);
}