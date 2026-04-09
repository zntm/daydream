/// @desc Clears and reloads all JSON-driven data in the same order as init().
/// Does NOT reload assets (sprites/atlas) or localisation - those require restart.
/// Designed for developer hot reload only.
function data_reload()
{
    /* NOTE: drops pending list must be cleared before re-running init_item */
    global.__item_drops_pending = [];

    resource_rebuild_registry(resource_get_base_namespace());
    resource_load_data();

    PRINT("[data_reload] data reloaded.");
}

/// @desc Initialises the MD5-based file watch table.
/// Call once after init() completes (developer mode only).
/// Stores per-file hashes as a baseline for change detection.
/// @param {Array<String>} [_extra_directories] OPTIONAL: additional directories to watch (for future mod support)
function data_reload_watch_init(_extra_directories = [])
{
    resource_rebuild_registry(resource_get_base_namespace());

    var _dirs = [];
    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        var _res = _roots[i].root;

        array_push(_dirs, $"{_res}/data/tags");
        array_push(_dirs, $"{_res}/data/particles");
        array_push(_dirs, $"{_res}/data/projectiles");
        array_push(_dirs, $"{_res}/data/effects");
        array_push(_dirs, $"{_res}/data/items");
        array_push(_dirs, $"{_res}/data/json/crafting_recipes.json");
        array_push(_dirs, $"{_res}/data/structures");
        array_push(_dirs, $"{_res}/data/regions");
        array_push(_dirs, $"{_res}/data/biomes");
        array_push(_dirs, $"{_res}/data/worlds");
        array_push(_dirs, $"{_res}/data/creatures");
        array_push(_dirs, $"{_res}/data/achievements");
        array_push(_dirs, $"{_res}/data/loot");
        array_push(_dirs, $"{_res}/data/json/menu/music.json");
        array_push(_dirs, $"{_res}/data/json/menu/biomes.json");
        array_push(_dirs, $"{_res}/data/json/menu/splash_texts.json");
        array_push(_dirs, $"{_res}/credit/data.json");
    }

    /* append extra directories (reserved for future mod support) */
    for (var i = array_length(_extra_directories) - 1; i >= 0; --i)
    {
        array_push(_dirs, _extra_directories[i]);
    }

    global.__data_watch       = {}
    global.__data_watch_dirs  = _dirs;
    global.__data_watch_timer = 0;

    __data_reload_watch_hash_all();
}

/// @desc Polls watched files for changes. Call from debug_step() when auto-reload is enabled.
/// Checks every 60 frames. If any file hash has changed, fires data_reload().
function data_reload_watch_step()
{
    if (global.__data_watch_timer > 0)
    {
        --global.__data_watch_timer;

        exit;
    }

    global.__data_watch_timer = 60;

    var _changed = false;
    var _watch   = global.__data_watch;
    var _keys    = struct_get_names(_watch);

    for (var i = array_length(_keys) - 1; i >= 0; --i)
    {
        var _path = _keys[i];

        if (!file_exists(_path)) continue;

        var _buf = buffer_load(_path);

        if (_buf == -1) continue;

        var _new_hash = buffer_md5(_buf, 0, buffer_get_size(_buf));
        buffer_delete(_buf);

        if (_new_hash != _watch[$ _path])
        {
            _changed = true;

            break;
        }
    }

    if (!_changed) exit;

    PRINT("[data_reload] change detected - reloading data...");

    data_reload();

    /* re-hash everything after reload so next check starts fresh */
    __data_reload_watch_hash_all();
}

/// @desc (internal) Walks all watched directories, collects JSON file paths,
/// and stores MD5 hashes in global.__data_watch.
function __data_reload_watch_hash_all()
{
    global.__data_watch = {}

    var _dirs = global.__data_watch_dirs;

    for (var i = array_length(_dirs) - 1; i >= 0; --i)
    {
        var _path = _dirs[i];

        /* single file (e.g. crafting_recipes.json) */
        if (string_ends_with(_path, ".json"))
        {
            __data_reload_watch_hash_file(_path);

            continue;
        }

        /* directory - recurse */
        __data_reload_watch_hash_dir(_path);
    }
}

/// @desc (internal) Hashes all JSON files in a directory recursively.
function __data_reload_watch_hash_dir(_directory)
{
    var _files = file_read_directory(_directory, true);

    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) continue;

        __data_reload_watch_hash_file($"{_directory}/{_file}");
    }
}

/// @desc (internal) Hashes a single file and stores it in global.__data_watch.
function __data_reload_watch_hash_file(_path)
{
    if (!file_exists(_path)) exit;

    var _buf = buffer_load(_path);

    if (_buf == -1) exit;

    global.__data_watch[$ _path] = buffer_md5(_buf, 0, buffer_get_size(_buf));

    buffer_delete(_buf);
}
