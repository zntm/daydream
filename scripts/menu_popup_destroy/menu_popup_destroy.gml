function menu_popup_destroy()
{
    var _inst = obj_Menu_Control_Button.menu_popup[obj_Menu_Control_Button.menu_layer - 1];
    var _length = array_length(_inst);
    
    for (var i = 0; i < _length; ++i)
    {
        instance_destroy(_inst[i]);
    }
    
    array_delete(obj_Menu_Control_Button.menu_popup, obj_Menu_Control_Button.menu_layer - 1, 1);
    
    --obj_Menu_Control_Button.menu_layer;
}