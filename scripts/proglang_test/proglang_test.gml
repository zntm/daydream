if (IS_DEVELOPER_MODE)
{
    call_later(1, time_source_units_frames, function()
    {
        var _files = file_read_directory($"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts/tests");
        var _length = array_length(_files);
        
        for (var i = _length - 1; i >= 0; --i)
        {
            var _file = _files[i];
            var _dir = $"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts/tests/{_file}";
            
            /* Skip directories and non-.daydream files */
            if (directory_exists(_dir))
            {
                continue;
            }
            
            if (!string_ends_with(_file, ".daydream"))
            {
                continue;
            }
            
            show_debug_message($"[ProglangTest] Executing: {_file}");
            
            proglang_execute(buffer_load_text(_dir), {}, _dir);
        }
        
        show_debug_message(struct_get_names(global.proglang_scripts))
    });
}
