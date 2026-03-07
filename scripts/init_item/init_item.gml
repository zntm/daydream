global.item_data = {}

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

            /* filter tile references */
            var _tile = _item[$ "tile"];

            if (_tile != undefined)
            {
                var _drops = _tile[$ "drops"];

                if (is_array(_drops))
                {
                    var _drops_parsed = [];

                    for (var j = array_length(_drops) - 1; j >= 0; --j)
                    {
                        var _drop    = _drops[j];
                        var _drop_id = init_asset_resolve(_namespace, _drop.id);

                        if (init_asset_item_exists(_drop_id))
                        {
                            _drop.id = _drop_id;

                            array_push(_drops_parsed, _drop);
                        }
                        else
                        {
                             PRINT($"[init_item] '{_id}': tile drop '{_drop_id}' not loaded, skipping");
                        }
                    }

                    _tile.drops = _drops_parsed;
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
        }

        global.item_data[$ $"{_namespace}:{_id}"] = _item_data;

        delete _json;

        dbg_timer("init_item", $"[Init] Loaded Item: '{_id}'");
    }
}