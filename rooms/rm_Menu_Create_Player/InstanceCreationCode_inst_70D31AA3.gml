text = loca_translate($"menu.create_player.attire.{global.attire_elements[global.menu_player_attire_index]}");

halign = fa_center;
valign = fa_middle;

image_xscale = 1.5;
image_yscale = 1.5;

on_draw = method(id, render_menu_anchor);