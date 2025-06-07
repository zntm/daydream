function control_inventory_position()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _gui_inventory_data = global.gui_inventory;
    
	var _inventory_instance = global.inventory_instance;
	var _inventory_length = global.inventory_length;
	
	var _inventory_names = global.inventory_names;
	var _inventory_names_length = array_length(_inventory_names);
	
	for (var i = 0; i < _inventory_names_length; ++i)
	{
        var _inventory_name = _inventory_names[i];
        
        var _data = _gui_inventory_data[$ _inventory_name];
        
        var _anchor_type = _data.anchor_type;
        
        var _anchor_x = _camera_x + _data.surface_xoffset + gui_yanchor(_anchor_type, _camera_width);
        var _anchor_y = _camera_y + _data.surface_yoffset + gui_xanchor(_anchor_type, _camera_height);
        
		var _length = _inventory_length[$ _inventory_name];
        
        var _inventory = _inventory_instance[$ _inventory_name];
		
		for (var j = 0; j < _length; ++j)
        {
            var _inst = _inventory[j];
            
            _inst.x = _anchor_x + _inst.xoffset;
            _inst.y = _anchor_y + _inst.yoffset;
        }
    }
}