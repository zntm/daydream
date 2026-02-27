text = loca_translate("phantasia:menu.pause.resume");

on_select_release = function()
{
    obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.PAUSE;
    
    control_instance_unpause();
}