function menu_popup_create(_array)
{
    var _menu_layer = obj_Menu_Control_Button.menu_layer + 1;
    
    obj_Menu_Control_Button.menu_popup[obj_Menu_Control_Button.menu_layer] = _array;
    
    var _length = array_length(_array);
    
    for (var i = 0; i < _length; ++i)
    {
        var _inst = _array[i];
        
        if (instance_exists(_inst))
        {
            _inst.menu_layer = _menu_layer;
            
            if (variable_instance_exists(_inst, "surface_index"))
            {
                _inst.surface_index = _menu_layer;
            }
        }
    }
    
    ++obj_Menu_Control_Button.menu_layer;
}