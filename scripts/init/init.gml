function resource_load_assets()
{
    global.sprite_asset = {}
    global.sound_asset  = {}

    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        var _root = _roots[i];
        var _assets_root = $"{_root.root}/assets";

        if (!directory_exists(_assets_root)) continue;

        var _files = file_read_directory(_assets_root);
        var _file_length = array_length(_files);

        for (var j = 0; j < _file_length; ++j)
        {
            var _file = _files[j];
            var _directory = $"{_assets_root}/{_file}";

            if (!directory_exists(_directory)) continue;

            init_assets(_root.namespace, _directory);
        }
    }
}

function resource_load_data()
{
    global.credit_data = [];
    global.menu_data = {};

    global.item_data = {}
    global.creature_data = {}
    global.biome_data = {}
    global.world_data = {}
    global.crafting_data = [];
    global.crafting_stations = [];
    global.region_data = {}
    global.tag_data = {}
    global.effect_data = {}
    global.projectile_data = {}
    global.particle_data = {}
    global.loot_data = {}
    global.background_data = {}
    global.structure_data = {}
    global.attire_data = {}
    global.achievement_data = {}
    global.rarity_data = {}

    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        var _root = _roots[i];
        var _namespace = _root.namespace;
        var _res = _root.root;

        if (file_exists($"{_res}/credit/data.json"))
        {
            init_credit($"{_res}/credit/data.json");
        }

        if (file_exists($"{_res}/data/json/rarity_colours.json"))
        {
            init_rarity(_namespace, $"{_res}/data/json/rarity_colours.json");
        }

        if (directory_exists($"{_res}/data/tags"))
        {
            init_tag_recursive(_namespace, $"{_res}/data/tags");
        }

        if (directory_exists($"{_res}/data/attires"))
        {
            init_attire(_namespace, $"{_res}/data/attires");
        }

        if (directory_exists($"{_res}/data/particles"))
        {
            init_particle_recursive(_namespace, $"{_res}/data/particles");
        }

        if (directory_exists($"{_res}/data/projectiles"))
        {
            init_projectile(_namespace, $"{_res}/data/projectiles");
        }

        if (directory_exists($"{_res}/data/effects"))
        {
            init_effect(_namespace, $"{_res}/data/effects");
        }

        if (directory_exists($"{_res}/data/items"))
        {
            init_item(_namespace, $"{_res}/data/items");
        }

        if (file_exists($"{_res}/data/json/crafting_recipes.json"))
        {
            init_crafting(_namespace, $"{_res}/data/json/crafting_recipes.json");
        }

        if (directory_exists($"{_res}/data/structures"))
        {
            init_structure(_namespace, $"{_res}/data/structures");
        }

        if (directory_exists($"{_res}/data/regions"))
        {
            init_region_recursive(_namespace, $"{_res}/data/regions");
        }

        if (directory_exists($"{_res}/data/biomes"))
        {
            init_biome_recursive(_namespace, $"{_res}/data/biomes");
        }

        if (directory_exists($"{_res}/data/worlds"))
        {
            init_world(_namespace, $"{_res}/data/worlds");
        }

        if (file_exists($"{_res}/data/json/menu/music.json"))
        {
            init_menu($"{_res}/data/json/menu/music.json");
        }

        if (file_exists($"{_res}/data/json/menu/biomes.json"))
        {
            init_menu_biomes($"{_res}/data/json/menu/biomes.json");
        }

        if (file_exists($"{_res}/data/json/menu/splash_texts.json"))
        {
            init_splash($"{_res}/data/json/menu/splash_texts.json");
        }

        if (directory_exists($"{_res}/data/creatures"))
        {
            init_creature(_namespace, $"{_res}/data/creatures");
        }

        if (directory_exists($"{_res}/data/achievements"))
        {
            init_achievement(_namespace, $"{_res}/data/achievements");
        }

        if (directory_exists($"{_res}/data/loot"))
        {
            init_loot(_namespace, $"{_res}/data/loot");
        }
    }

    init_item_resolve_drops();
}

function init(_namespace)
{
    resource_rebuild_registry(_namespace);
    resource_load_assets();
    resource_load_data();

    if (IS_DEVELOPER_MODE)
    {
        data_reload_watch_init();
    }
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");

    randomize();

    menu_refresh_value_background();

    room_goto((global.settings.menu_skip_epilepsy) ? rm_Menu_Title : rm_Menu_Warning_Epilepsy);

    file_load_menu_preferences();
    file_load_players();
}, false);
