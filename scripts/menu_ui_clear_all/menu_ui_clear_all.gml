function menu_ui_clear_all()
{
	/* Destroy all registered UI instances */
    if (variable_global_exists("ui_instances"))
    {
        var _keys = struct_get_names(global.ui_instances);
        for (var i = array_length(_keys) - 1; i >= 0; --i)
        {
            ui_instance_destroy(global.ui_instances[$ _keys[i]]);
        }
    }
    
	/* Explicitly clear gui_root children just in case */
    if (variable_global_exists("gui_root") && global.gui_root != undefined)
    {
        global.gui_root.children = [];
    }
}
