global.item_data = {}

/* pending drop resolution entries: array of { namespace, id, drops } */
global.__item_drops_pending = [];

function init_item(_namespace, _directory)
{
    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);

    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) continue;

        var _id = string_delete(_file, string_length(_file) - 4, 5);

        dbg_timer("init_item0");

        var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));

        if (!is_struct(_json)) continue;

        var _sprite    = _json.sprite;
        var _sprite_id = init_asset_resolve(_namespace, _sprite);

        if (!init_asset_sprite_exists(_sprite_id))
        {
            PRINT($"[init_item] Skipping '{_id}': missing sprite '{_sprite_id}'");

            delete _json;

            continue;
        }

        var _item      = _json[$ "item"];
        var _item_data = new ItemData(_namespace, _id);

        _item_data.set_sprite(_sprite);
        _item_data.set_inventory(_json.inventory);

        if (_item != undefined)
        {
            /* filter item references */
            var _projectile = _item[$ "projectile"];

            if (_projectile != undefined)
            {
                var _projectile_id = init_asset_resolve(_namespace, _projectile);

                if (!init_asset_projectile_exists(_projectile_id))
                {
                    PRINT($"[init_item] '{_id}': projectile '{_projectile_id}' not loaded, clearing");

                    _item.projectile = undefined;
                }
                else
                {
                    _item.projectile = _projectile_id;
                }
            }

            var _ammo_type = _item[$ "ammo_type"];

            if (_ammo_type != undefined)
            {
                _item.ammo_type = init_asset_resolve(_namespace, _ammo_type);
            }

            _item_data.set_item(_item);

            /* defer tile drop resolution until all items are loaded */
            var _tile = _item[$ "tile"];

            if (_tile != undefined)
            {
                var _render = _tile[$ "render"];

                if (_render != undefined)
                {
                    var _emissive = _render[$ "emissive"];

                    if (_emissive != undefined)
                    {
                        _render.emissive = init_asset_resolve(_namespace, _emissive);
                    }
                }

                var _drops = _tile[$ "drops"];

                if (is_array(_drops))
                {
                    /* store raw drops for pass 2 — resolve ids against namespace */
                    var _drops_raw = [];

                    for (var j = array_length(_drops) - 1; j >= 0; --j)
                    {
                        var _drop        = _drops[j];
                        var _drop_copy   = variable_clone(_drop);

                        _drop_copy.id = init_asset_resolve(_namespace, _drop.id);

                        array_push(_drops_raw, _drop_copy);
                    }

                    array_push(global.__item_drops_pending, {
                        full_id:   $"{_namespace}:{_id}",
                        drops_raw: _drops_raw
                    });

                    /* clear drops for now — filled in pass 2 */
                    _tile.drops = [];
                }

                _item_data.set_tile(_tile);
            }
        }

        _item_data.set_properties(_json[$ "properties"]);
        _item_data.set_type(_json.type);

        var _sprite_asset_obj = global.sprite_asset[$ _sprite_id];

        var _real_sprite = _sprite_asset_obj.get_sprite();
        var _col_box     = _json[$ "collision_box"];

        var _type_box = TILE_COLLISION_BOX_TYPE.RECTANGLE;
        var _left     = -sprite_get_xoffset(_real_sprite);
        var _top      = -sprite_get_yoffset(_real_sprite);
        var _width    = sprite_get_width(_real_sprite);
        var _height   = sprite_get_height(_real_sprite);

        if (_col_box != undefined)
        {
            if (_col_box[$ "type"] == "triangle") _type_box = TILE_COLLISION_BOX_TYPE.TRIANGLE;
            if (_col_box[$ "left"]   != undefined) _left   = _col_box.left;
            if (_col_box[$ "top"]    != undefined) _top    = _col_box.top;
            if (_col_box[$ "right"]  != undefined) _width  = _col_box.right;
            if (_col_box[$ "bottom"] != undefined) _height = _col_box.bottom;
        }

        _item_data.set_collision_box(_type_box, _left, _top, _width, _height);

        if (_item_data.get_type() & (ITEM_TYPE_BIT.PLATFORM | ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE))
        {
            atla_push("item", _sprite_asset_obj.get_sprite(), _sprite_id);

            var _emissive_sprite = _item_data.get_tile_emissive_sprite();

            if (_emissive_sprite != undefined)
            {
                var _emissive_asset = global.sprite_asset[$ _emissive_sprite];

                if (_emissive_asset != undefined)
                {
                    atla_push("item", _emissive_asset.get_sprite(), _emissive_sprite);
                }
                else
                {
                    PRINT($"[init_item] '{_namespace}:{_id}': emissive sprite '{_emissive_sprite}' not loaded");
                }
            }
        }

        global.item_data[$ $"{_namespace}:{_id}"] = _item_data;

        delete _json;

        dbg_timer("init_item", $"[Init] Loaded Item: '{_id}'");
    }
}

/// @desc Pass 2 — resolves all deferred tile drops now that every item is registered.
/// Call this once after all init_item() calls have finished.
function init_item_resolve_drops()
{
    var _pending        = global.__item_drops_pending;
    var _pending_length = array_length(_pending);

    for (var i = _pending_length - 1; i >= 0; --i)
    {
        var _entry   = _pending[i];
        var _data    = global.item_data[$ _entry.full_id];
        var _drops   = _entry.drops_raw;

        if (_data == undefined) continue;

        var _drops_parsed = [];

        for (var j = array_length(_drops) - 1; j >= 0; --j)
        {
            var _drop    = _drops[j];
            var _drop_id = _drop.id;

            if (init_asset_item_exists(_drop_id))
            {
                array_push(_drops_parsed, _drop);
            }
            else
            {
                PRINT($"[init_item] '{_entry.full_id}': tile drop '{_drop_id}' not found after full load");
            }
        }

        _data.set_tile_drops(_drops_parsed);
    }

    global.__item_drops_pending = [];
}
