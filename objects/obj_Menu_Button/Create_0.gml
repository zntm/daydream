text = undefined;
icon = undefined;
icon_index = 0;

index = 0;

icon_xscale = 1;
icon_yscale = 1;

surface_index = 0;

on_select = undefined;
on_select_hold = undefined;
on_select_release = undefined;

on_destroy = undefined;

on_draw        = undefined;
on_draw_behind = undefined;

enum MENU_BUTTON_BOOLEAN {
    IS_BUTTON_VISIBLE = 1 << 0,
    IS_HOVER          = 1 << 1,
    IS_SELECTED       = 1 << 2,
}

boolean =
    MENU_BUTTON_BOOLEAN.IS_BUTTON_VISIBLE;

area = undefined;

depth = -1;