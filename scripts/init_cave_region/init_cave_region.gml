global.cave_region_data = [];
global.cave_region_data_length = 0;

/// @desc Initialize special cave regions from data files.
function init_cave_region(_directory, _namespace = "phantasia", _id = undefined)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);

    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";

        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");

        if (directory_exists(_subdirectory))
        {
            init_cave_region(_subdirectory, _namespace, _name);

            continue;
        }

        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_cave_region");

            var _json = tag_value_parse(buffer_load_json(_subdirectory));

            if (is_struct(_json))
            {
                var _name_clean = string_delete(_name, string_length(_name) - 4, 5);

                var _region = new CaveRegionData(_name_clean, _json);

                array_push(global.cave_region_data, _region);

                dbg_timer("init_cave_region", $"[Init] Loaded Cave Region: \'{_name_clean}\'");
            }

            delete _json;
        }
    }

    global.cave_region_data_length = array_length(global.cave_region_data);
}
