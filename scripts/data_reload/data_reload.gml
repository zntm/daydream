/// @desc Clears and reloads all JSON-driven data in the same order as init().
/// Does NOT reload assets (sprites/atlas) or localisation — those require restart.
/// Designed for developer hot reload only.
function data_reload()
{
    var _namespace = "phantasia";
    var _res       = PROGRAM_DIRECTORY_RESOURCES;

    global.item_data       = {};
    global.creature_data   = {};
    global.biome_data      = {};
    global.world_data      = {};
    global.crafting_data   = [];
    global.crafting_stations = [];
    global.region_data     = {};
    global.tag_data        = {};
    global.effect_data     = {};
    global.projectile_data = {};
    global.particle_data   = {};
    global.loot_data       = {};

    /* NOTE: drops pending list must be cleared before re-running init_item */
    global.__item_drops_pending = [];

    init_tag_recursive(_namespace, $"{_res}/data/tags");

    init_particle_recursive(_namespace, $"{_res}/data/particles");

    init_projectile(_namespace, $"{_res}/data/projectiles");

    init_effect(_namespace, $"{_res}/data/effects");

    init_item(_namespace, $"{_res}/data/items");
    init_item_resolve_drops();

    init_crafting(_namespace, $"{_res}/data/json/crafting_recipes.json");

    init_structure(_namespace, $"{_res}/data/structures");

    init_region_recursive(_namespace, $"{_res}/data/regions");

    init_biome_recursive(_namespace, $"{_res}/data/biomes");

    init_world(_namespace, $"{_res}/data/worlds");

    init_creature(_namespace, $"{_res}/data/creatures");

    init_achievement(_namespace, $"{_res}/data/achievements");

    init_loot(_namespace, $"{_res}/data/loot");

    PRINT("[data_reload] data reloaded.");
}

/// @desc Initialises the MD5-based file watch table.
/// Call once after init() completes (developer mode only).
/// Stores per-file hashes as a baseline for change detection.
/// @param {Array<String>} [_extra_directories] OPTIONAL: additional directories to watch (for future mod support)
function data_reload_watch_init(_extra_directories = [])
{
    var _res   = PROGRAM_DIRECTORY_RESOURCES;
    var _dirs  = [
        $"{_res}/data/tags",
        $"{_res}/data/particles",
        $"{_res}/data/projectiles",
        $"{_res}/data/effects",
        $"{_res}/data/items",
        $"{_res}/data/json/crafting_recipes.json",
        $"{_res}/data/structures",
        $"{_res}/data/regions",
        $"{_res}/data/biomes",
        $"{_res}/data/worlds",
        $"{_res}/data/creatures",
        $"{_res}/data/achievements",
        $"{_res}/data/loot",
    ];

    /* append extra directories (reserved for future mod support) */
    for (var i = array_length(_extra_directories) - 1; i >= 0; --i)
    {
        array_push(_dirs, _extra_directories[i]);
    }

    global.__data_watch       = {};
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

    PRINT("[data_reload] change detected — reloading data...");

    data_reload();

    /* re-hash everything after reload so next check starts fresh */
    __data_reload_watch_hash_all();
}

/// @desc (internal) Walks all watched directories, collects JSON file paths,
/// and stores MD5 hashes in global.__data_watch.
function __data_reload_watch_hash_all()
{
    global.__data_watch = {};

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

        /* directory — recurse */
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
