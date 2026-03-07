/// @desc Push all legacy menu object instances off-screen. Called before showing/hiding any pause or main menu.
function control_game_menu_hide_instances()
{
    with (obj_Menu_Anchor)    { y = -1000; }
    with (obj_Menu_Button)    { y = -1000; }
    with (obj_Menu_Dropdown)  { y = -1000; }
    with (obj_Menu_Textbox)   { y = -1000; }
}
