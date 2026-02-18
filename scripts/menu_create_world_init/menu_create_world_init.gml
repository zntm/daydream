function menu_create_world_init()
{
    var _save_data = global.world_save_data;

    if (_save_data.name == "")
    {
        do
        {
            _save_data.name = menu_textbox_randomize_world_name();
        }
        until (string(_save_data.name) != "undefined") && (string_length(_save_data.name) <= 40);
    }

    if (_save_data.seed == "")
    {
        _save_data.seed = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
    }

    var _link = {
        world_name: _save_data.name,
        world_seed: _save_data.seed,
        difficulty: _save_data.difficulty,
        death_penalty_item_drop: _save_data.death_penalty_item_drop,
        death_penalty_item_durability: _save_data.death_penalty_item_durability,
        backup_interval: _save_data.backup_interval
    };

    var _def = ui_load("ui/create_world.ui");

    global.ui_create_world = ui_spawn(_def, {
        link: _link,
        parent: undefined
    });

    var _elements = global.ui_create_world.elements;

    var _btn_randomize_name = _elements[$ "btn_randomize_name"];

    if (_btn_randomize_name != undefined)
    {
        _btn_randomize_name.add_event_handler("on_select_release",
            method({ link: _link, el: _elements[$ "textbox_name"] }, function(_data)
            {
                var _text = "";

                do
                {
                    _text = menu_textbox_randomize_world_name();
                }
                until (string(_text) != "undefined") && (string_length(_text) <= 40);

                link.world_name = _text;
                global.world_save_data.name = _text;

                if (el != undefined)
                {
                    el.text = _text;
                }
            })
        );
    }

    var _btn_randomize_seed = _elements[$ "btn_randomize_seed"];

    if (_btn_randomize_seed != undefined)
    {
        _btn_randomize_seed.add_event_handler("on_select_release",
            method({ link: _link, el: _elements[$ "textbox_seed"] }, function(_data)
            {
                var _text = string(irandom_range(-0x8000_0000, 0x7fff_ffff));

                link.world_seed = _text;
                global.world_save_data.seed = _text;

                if (el != undefined)
                {
                    el.text = _text;
                }
            })
        );
    }

    var _slider_difficulty = _elements[$ "slider_difficulty"];

    if (_slider_difficulty != undefined)
    {
        _slider_difficulty.add_event_handler("on_change",
            method({ link: _link }, function(_data)
            {
                link.difficulty = _data.value;
                global.world_save_data.difficulty = _data.value;
            })
        );
    }

    var _slider_item_drop = _elements[$ "slider_item_drop"];

    if (_slider_item_drop != undefined)
    {
        _slider_item_drop.add_event_handler("on_change",
            method({ link: _link }, function(_data)
            {
                link.death_penalty_item_drop = _data.value;
                global.world_save_data.death_penalty_item_drop = _data.value;
            })
        );
    }

    var _slider_item_durability = _elements[$ "slider_item_durability"];

    if (_slider_item_durability != undefined)
    {
        _slider_item_durability.add_event_handler("on_change",
            method({ link: _link }, function(_data)
            {
                link.death_penalty_item_durability = _data.value;
                global.world_save_data.death_penalty_item_durability = _data.value;
            })
        );
    }

    var _slider_backup = _elements[$ "slider_backup"];

    if (_slider_backup != undefined)
    {
        _slider_backup.add_event_handler("on_change",
            method({ link: _link }, function(_data)
            {
                link.backup_interval = _data.value;
                global.world_save_data.backup_interval = _data.value;
            })
        );
    }

    var _btn_create = _elements[$ "btn_create"];

    if (_btn_create != undefined)
    {
        _btn_create.add_event_handler("on_select_release",
            method({ link: _link, elements: _elements }, function(_data)
            {
                var _name = "";

                var _textbox_name = elements[$ "textbox_name"];

                if (_textbox_name != undefined)
                {
                    _name = string_trim(_textbox_name.text);
                }

                if (_name == "")
                {
                    _name = string_trim(link.world_name);
                }

                if (_name == "")
                {
                    return;
                }

                var _seed = "";

                var _textbox_seed = elements[$ "textbox_seed"];

                if (_textbox_seed != undefined)
                {
                    _seed = _textbox_seed.text;
                }

                if (_seed == "")
                {
                    _seed = link.world_seed;
                }

                if (!string_contains(_seed, "."))
                {
                    if (string_starts_with(_seed, "-"))
                    {
                        if ($"-{string_digits(_seed)}" == _seed)
                        {
                            _seed = real(_seed);
                        }
                    }
                    else
                    {
                        if (string_digits(_seed) == _seed)
                        {
                            _seed = real(_seed);
                        }
                    }
                }

                if (is_string(_seed))
                {
                    _seed = string_get_seed(_seed);
                }

                global.world_save_data.name = _name;
                global.world_save_data.seed = _seed;

                randomize();

                var _uuid = "";
                var _index = datetime_to_unix();

                do
                {
                    _uuid = uuid_generate(_index++);
                }
                until (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_uuid}"));

                global.world_save_data.uuid = _uuid;

                room_goto(rm_World);
            })
        );
    }
}

function menu_create_world_cleanup()
{
    if (variable_global_exists("ui_create_world") && global.ui_create_world != undefined)
    {
        ui_instance_destroy(global.ui_create_world);
        global.ui_create_world = undefined;
    }
}
