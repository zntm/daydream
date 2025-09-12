function control_instance_unpause()
{
    obj_Menu_Control_Render.xoffset = -1000;
    obj_Menu_Control_Render.yoffset = -1000;
    
    inst_629EFD9E.y = -1000;
    
    inst_13FA255D.y = -1000;
    
    inst_7A620B98.y = -1000;
    
    inst_284F3DC8.y = -1000;
    
    var _layer = layer_get_id("Settings");
    
    with (all)
    {
        if (layer == _layer)
        {
            instance_destroy();
        }
    }
}