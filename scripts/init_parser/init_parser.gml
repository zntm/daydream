/// @desc Resolves an ID with a namespace if it doesn't already have one.
/// @param {String} _namespace The namespace to prepend.
/// @param {String} _id        The ID to resolve.
function init_asset_resolve(_namespace, _id)
{
    if (string_pos(":", _id) > 0) return _id;

    return _namespace + ":" + _id;
}

/// @desc Returns true if a namespace/mod is currently loaded.
/// @param {String} _namespace Namespace ID, e.g. "phantasia" or "disease_mod".
function init_namespace_exists(_namespace)
{
    var _roots = resource_get_roots();
    var _length = array_length(_roots);

    for (var i = 0; i < _length; ++i)
    {
        if (_roots[i].namespace == _namespace) return true;
    }

    return false;
}

/// @desc Returns true when all namespace dependencies are satisfied.
/// @param {Any} _requirements String or array of strings from "$NAMESPACE_EXISTS".
function init_namespace_requirements_met(_requirements)
{
    if (_requirements == undefined) return true;

    if (is_string(_requirements))
    {
        return init_namespace_exists(_requirements);
    }

    if (!is_array(_requirements)) return false;

    var _length = array_length(_requirements);

    for (var i = 0; i < _length; ++i)
    {
        if (!init_namespace_exists(string(_requirements[i])))
        {
            return false;
        }
    }

    return true;
}

/// @desc Returns true if a parsed JSON root should be loaded for the current runtime.
/// @param {Any} _json Parsed JSON root.
/// @param {String} _context Short identifier for debug logging.
function init_data_namespace_allowed(_json, _context = "")
{
    if (!is_struct(_json)) return true;

    var _requirements = _json[$ "$NAMESPACE_EXISTS"];

    if (init_namespace_requirements_met(_requirements)) return true;

    PRINT($"[init] Skipping '{_context}': missing required namespace dependency");

    return false;
}

/// @desc Returns true if the given namespaced sprite ID exists in the loaded sprite asset registry.
/// @param {String} _id  Full namespaced sprite ID, e.g. "phantasia:tiles/stone".
function init_asset_sprite_exists(_id)
{
    return (global.sprite_asset[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced item/tile ID exists in the loaded item data registry.
/// @param {String} _id  Full namespaced item ID, e.g. "phantasia:stone".
function init_asset_item_exists(_id)
{
    return (global.item_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced particle group ID exists in the loaded particle data registry.
/// @param {String} _id  Full namespaced particle ID, e.g. "phantasia:particles/hit".
function init_asset_particle_exists(_id)
{
    return (global.particle_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced effect ID exists in the loaded effect data registry.
/// @param {String} _id  Full namespaced effect ID, e.g. "phantasia:poisoned".
function init_asset_effect_exists(_id)
{
    return (global.effect_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced creature ID exists in the loaded creature data registry.
/// @param {String} _id  Full namespaced creature ID, e.g. "phantasia:slime".
function init_asset_creature_exists(_id)
{
    return (global.creature_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced structure ID exists in the loaded structure data registry.
/// @param {String} _id  Full namespaced structure ID.
function init_asset_structure_exists(_id)
{
    return (global.structure_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced music ID exists in the loaded sound asset registry.
/// @param {String} _id  Full namespaced music ID.
function init_asset_music_exists(_id)
{
    return (global.sound_asset[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced projectile ID exists in the loaded projectile data registry.
/// @param {String} _id  Full namespaced projectile ID.
function init_asset_projectile_exists(_id)
{
    return (global.projectile_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced tag ID exists in the loaded tag data registry.
/// @param {String} _id  Full namespaced tag ID.
function init_asset_tag_exists(_id)
{
    return (global.tag_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced biome ID exists in the loaded biome data registry.
/// @param {String} _id  Full namespaced biome ID.
function init_asset_biome_exists(_id)
{
    return (global.biome_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced achievement ID exists in the loaded achievement data registry.
/// @param {String} _id  Full namespaced achievement ID.
function init_asset_achievement_exists(_id)
{
    return (global.achievement_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced background ID exists in the loaded background data registry.
/// @param {String} _id  Full namespaced background ID.
function init_asset_background_exists(_id)
{
    return (global.background_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced attire ID exists in the loaded attire data registry.
/// @param {String} _id  Full namespaced attire ID.
function init_asset_attire_exists(_id)
{
    return (global.attire_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced region ID exists in the loaded region data registry.
/// @param {String} _id  Full namespaced region ID.
function init_asset_region_exists(_id)
{
    return (global.region_data[$ _id] != undefined);
}

/// @desc Returns true if the given namespaced world ID exists in the loaded world data registry.
/// @param {String} _id  Full namespaced world ID.
function init_asset_world_exists(_id)
{
    return (global.world_data[$ _id] != undefined);
}
