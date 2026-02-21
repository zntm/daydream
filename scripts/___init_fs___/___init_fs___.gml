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

#macro PROGRAM_DIRECTORY_DATA      __get_program_directory_data()

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