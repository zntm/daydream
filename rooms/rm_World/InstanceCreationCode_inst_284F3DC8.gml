text = loca_translate("phantasia:menu.pause.exit");

on_select_release = function()
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.EXIT;
    
    control_instance_unpause();
}