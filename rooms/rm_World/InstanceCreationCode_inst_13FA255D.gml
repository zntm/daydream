text = loca_translate("menu.pause.resume");

on_select_release = function()
{
    obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    control_instance_unpause();
}