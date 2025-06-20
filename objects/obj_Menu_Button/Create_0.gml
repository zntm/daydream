text = -1;
icon = -1;
icon_index = 0;

index = 0;

icon_xscale = 1;
icon_yscale = 1;

surface_index = 0;

on_destroy = undefined;
on_hold    = undefined;
on_press   = undefined;

on_draw        = undefined;
on_draw_behind = undefined;

enum MENU_BUTTON_BOOLEAN {
    IS_SELECTED       = 1 << 0,
    IS_BUTTON_VISIBLE = 1 << 1
}

boolean =
    MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE;

area = undefined;

depth = -1;