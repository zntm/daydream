function __get_program_directory_datafiles()
{
    static _res = undefined;
    if (_res != undefined) return _res;

    if (GM_build_type == "run")
    {
        var _proj = GM_project_filename;
        if (_proj != "")
        {
            var _path = string_replace_all(filename_dir(_proj) + "/datafiles", "\\", "/");
            if (directory_exists(_path))
            {
                _res = _path;
                return _res;
            }
        }
    }

    _res = "";
    return _res;
}

function __get_program_directory_resources()
{
    static _res = undefined;
    if (_res != undefined) return _res;

    var _datafiles = __get_program_directory_datafiles();
    if (_datafiles != "")
    {
        var _path = _datafiles + "/resources";
        if (directory_exists(_path))
        {
            _res = _path;
            return _res;
        }
    }

    _res = "resources";
    return _res;
}

function __get_program_directory_data()
{
    static _res = undefined;
    if (_res != undefined) return _res;

    var _datafiles = __get_program_directory_datafiles();
    if (_datafiles != "")
    {
        var _path = _datafiles + "/data";
        if (directory_exists(_path))
        {
            _res = _path;
            return _res;
        }
    }

    _res = "data";
    return _res;
}

#macro PROGRAM_DIRECTORY_DATAFILES __get_program_directory_datafiles()
#macro PROGRAM_DIRECTORY_RESOURCES __get_program_directory_resources()
#macro PROGRAM_DIRECTORY_ASSETS    $"{PROGRAM_DIRECTORY_RESOURCES}/assets"
#macro PROGRAM_DIRECTORY_MODS      __get_program_directory_mods()

#macro PROGRAM_DIRECTORY_DATA      __get_program_directory_data()

function __get_program_directory_mods()
{
    static _res = undefined;
    if (_res != undefined) return _res;

    var _datafiles = __get_program_directory_datafiles();
    if (_datafiles != "")
    {
        var _path = _datafiles + "/mods";
        if (directory_exists(_path))
        {
            _res = _path;
            return _res;
        }
    }

    _res = "mods";
    return _res;
}

function resource_get_base_namespace()
{
    return global.resource_base_namespace ?? "phantasia";
}

function resource_mod_format_authors(_authors)
{
    var _count = array_length(_authors);

    if (_count <= 0) return "";
    if (_count == 1) return string(_authors[0]);
    if (_count == 2) return $"{_authors[0]}, {_authors[1]}";

    return $"{_authors[0]}, {_authors[1]}, and {_count - 2} more";
}

function resource_mod_normalize_info(_namespace, _root, _json)
{
    var _authors = [];
    var _author = _json[$ "author"];

    if (is_array(_author))
    {
        var _author_count = array_length(_author);

        for (var i = 0; i < _author_count; ++i)
        {
            array_push(_authors, string(_author[i]));
        }
    }
    else if (_author != undefined)
    {
        array_push(_authors, string(_author));
    }

    return {
        namespace: _namespace,
        root: _root,
        name: _json[$ "name"] ?? _namespace,
        author: _author,
        authors: _authors,
        author_display: resource_mod_format_authors(_authors),
        description: _json[$ "description"] ?? "",
        icon_path: file_exists($"{_root}/icon.png") ? $"{_root}/icon.png" : undefined,
        info_path: file_exists($"{_root}/info.json") ? $"{_root}/info.json" : undefined
    };
}

function resource_rebuild_registry(_base_namespace = "phantasia")
{
    global.resource_base_namespace = _base_namespace;
    global.resource_roots = [];
    global.mod_data = {};
    global.mod_list = [];

    var _base_root = PROGRAM_DIRECTORY_RESOURCES;
    var _base_info = {
        namespace: _base_namespace,
        root: _base_root,
        name: "Base Game",
        author: "Phantasia",
        authors: [ "Phantasia" ],
        author_display: "Phantasia",
        description: "Built-in game resources.",
        icon_path: undefined,
        info_path: undefined
    };

    array_push(global.resource_roots, {
        namespace: _base_namespace,
        root: _base_root,
        type: "base",
        info: _base_info
    });

    var _mods_root = PROGRAM_DIRECTORY_MODS;

    if (!directory_exists(_mods_root)) return global.resource_roots;

    var _mods = file_read_directory(_mods_root);
    array_sort(_mods, true);

    var _mods_length = array_length(_mods);

    for (var i = 0; i < _mods_length; ++i)
    {
        var _namespace = _mods[i];
        var _root = $"{_mods_root}/{_namespace}";

        if (!directory_exists(_root)) continue;

        var _info = {};
        var _info_path = $"{_root}/info.json";

        if (file_exists(_info_path))
        {
            var _info_json = buffer_load_json(_info_path);
            if (is_struct(_info_json)) _info = _info_json;
        }

        var _mod_info = resource_mod_normalize_info(_namespace, _root, _info);

        global.mod_data[$ _namespace] = _mod_info;
        array_push(global.mod_list, _mod_info);
        array_push(global.resource_roots, {
            namespace: _namespace,
            root: _root,
            type: "mod",
            info: _mod_info
        });
    }

    return global.resource_roots;
}

function resource_get_roots()
{
    if (!variable_global_exists("resource_roots")) || !is_array(global.resource_roots)
    {
        return resource_rebuild_registry(resource_get_base_namespace());
    }

    return global.resource_roots;
}

function resource_collect_paths(_relative_path)
{
    var _paths = [];
    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        var _root = _roots[i];
        var _path = $"{_root.root}/{_relative_path}";

        if (file_exists(_path)) || (directory_exists(_path))
        {
            array_push(_paths, {
                namespace: _root.namespace,
                path: _path,
                root: _root.root,
                type: _root.type,
                info: _root.info
            });
        }
    }

    return _paths;
}

function resource_resolve_path(_relative_path, _prefer_overrides = true)
{
    var _paths = resource_collect_paths(_relative_path);
    var _length = array_length(_paths);

    if (_length <= 0) return _relative_path;

    return _prefer_overrides ? _paths[_length - 1].path : _paths[0].path;
}

function resource_collect_data_files(_relative_directory, _extension = "")
{
    var _result = [];
    var _seen = {};
    var _paths = resource_collect_paths($"data/{_relative_directory}");
    var _length = array_length(_paths);

    for (var i = 0; i < _length; ++i)
    {
        var _entry = _paths[i];
        var _files = file_read_directory(_entry.path, true);
        var _file_length = array_length(_files);

        for (var j = 0; j < _file_length; ++j)
        {
            var _file = _files[j];

            if (_extension != "") && (!string_ends_with(_file, _extension)) continue;
            if (struct_exists(_seen, _file)) continue;

            _seen[$ _file] = true;
            array_push(_result, _file);
        }
    }

    array_sort(_result, true);

    return _result;
}

function resource_collect_loca_directories()
{
    var _directories = [];
    var _seen = {};
    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        var _loca_root = $"{_roots[i].root}/loca";

        if (!directory_exists(_loca_root)) continue;

        var _entries = file_read_directory(_loca_root);
        array_sort(_entries, true);

        var _entry_length = array_length(_entries);

        for (var j = 0; j < _entry_length; ++j)
        {
            var _directory = _entries[j];
            var _path = $"{_loca_root}/{_directory}";

            if (!directory_exists(_path)) continue;
            if (struct_exists(_seen, _directory)) continue;

            _seen[$ _directory] = true;
            array_push(_directories, _directory);
        }
    }

    return _directories;
}

function resource_reload_loca(_directory)
{
    var _paths = resource_collect_paths($"loca/{_directory}");
    var _length = array_length(_paths);

    if (_length <= 0)
    {
        init_loca(resource_get_base_namespace(), $"{PROGRAM_DIRECTORY_RESOURCES}/loca/{_directory}", true);
        
        return;
    }

    for (var i = 0; i < _length; ++i)
    {
        var _layer = _paths[i];
        
        init_loca(_layer.namespace, _layer.path, i == 0);
    }
}

function file_system_get_appdata_path()
{
    static _res = undefined;
    if (_res != undefined) return _res;

    switch (os_type)
    {
        case os_windows:
            _res = $"{environment_get_variable("LOCALAPPDATA")}/{PROGRAM_NAME}";
            break;

        case os_linux:
            _res = $"{environment_get_variable("HOME")}/.config/{PROGRAM_NAME}";
            break;

        case os_macosx:
            _res = $"{environment_get_variable("HOME")}/Library/Application Support/{PROGRAM_NAME}";
            break;

        default:
            // Fallback for other platforms (Android, iOS, etc.)
            _res = string_replace_all(game_save_id, "\\", "/");
            // Remove trailing slash if present
            if (string_byte_at(_res, string_byte_length(_res)) == ord("/"))
            {
                _res = string_copy(_res, 1, string_length(_res) - 1);
            }
            break;
    }

    return _res;
}

#macro PROGRAM_DIRECTORY_APPDATA file_system_get_appdata_path()


#macro PROGRAM_DIRECTORY_CRASH_LOG   $"{PROGRAM_DIRECTORY_APPDATA}/crash_log"
#macro PROGRAM_DIRECTORY_PLAYERS     $"{PROGRAM_DIRECTORY_APPDATA}/players"
#macro PROGRAM_DIRECTORY_SCREENSHOTS $"{PROGRAM_DIRECTORY_APPDATA}/screenshots"
#macro PROGRAM_DIRECTORY_STRUCTURES  $"{PROGRAM_DIRECTORY_APPDATA}/structures"
#macro PROGRAM_DIRECTORY_WORLDS      $"{PROGRAM_DIRECTORY_APPDATA}/worlds"

if (!directory_exists(PROGRAM_DIRECTORY_CRASH_LOG))
{
    directory_create(PROGRAM_DIRECTORY_CRASH_LOG);
}

if (!directory_exists(PROGRAM_DIRECTORY_PLAYERS))
{
    directory_create(PROGRAM_DIRECTORY_PLAYERS);
}

if (!directory_exists(PROGRAM_DIRECTORY_SCREENSHOTS))
{
    directory_create(PROGRAM_DIRECTORY_SCREENSHOTS);
}

if (!directory_exists(PROGRAM_DIRECTORY_STRUCTURES))
{
    directory_create(PROGRAM_DIRECTORY_STRUCTURES);
}

if (!directory_exists(PROGRAM_DIRECTORY_WORLDS))
{
    directory_create(PROGRAM_DIRECTORY_WORLDS);
}
