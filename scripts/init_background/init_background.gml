global.background_data = {}

function init_background(_directory, _namespace = "phantasia", _type = 0)
{
	var _files = file_read_directory(_directory);
	var _files_length = array_length(_files);
	
	for (var i = 0; i < _files_length; ++i)
	{
		dbg_timer("init_data_background");
		
		var _file = _files[i];
		
		var _background = file_read_directory($"{_directory}/{_file}");
		var _background_length = array_length(_background);
		
		var _background_data = new BackgroundData();
		
		for (var j = 0; j < _background_length; ++j)
		{
			var _sprite = sprite_add($"{_directory}/{_file}/{_background[j]}", 1, false, false, 0, 0);
			
			sprite_set_offset(_sprite, sprite_get_width(_sprite) / 2, sprite_get_height(_sprite));
			
            _background_data.add_sprite(_sprite);
		}
        
        global.background_data[$ $"{_namespace}:{_file}"] = _background_data;
		
		dbg_timer("init_data_background", $"[Init] Loaded Background: \'{_file}\' ({_background_length})");
	}
}