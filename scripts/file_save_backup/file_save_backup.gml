global.async_save_map = {}

function file_backup_get_interval_seconds(_world)
{
    if (_world == undefined) return 0;

    var _backup = _world[$ "backup"] ?? {};
    var _minutes = max(0, round(_backup[$ "interval_minutes"] ?? 0));

    return _minutes * 60;
}

function file_backup_get_slots(_world)
{
    if (_world == undefined) return 0;

    var _backup = _world[$ "backup"] ?? {};

    return max(0, round(_backup[$ "slots"] ?? 0));
}

function file_backup_delete_directory_recursive(_directory)
{
    if (!directory_exists(_directory)) exit;

    var _entries = file_read_directory(_directory);

    for (var i = array_length(_entries) - 1; i >= 0; --i)
    {
        var _entry = _entries[i];
        var _path = $"{_directory}/{_entry}";

        if (directory_exists(_path))
        {
            file_backup_delete_directory_recursive(_path);
        }
        else if (file_exists(_path))
        {
            file_delete(_path);
        }
    }

    directory_destroy(_directory);
}

function file_backup_prune_slots(_directory, _max_slots)
{
    if (_max_slots <= 0) exit;
    if (!directory_exists(_directory)) exit;

    static __sort_backup_timestamp = function(_a, _b)
    {
        return real(_a) - real(_b);
    }

    var _entries = file_read_directory(_directory);
    var _backups = [];

    for (var i = array_length(_entries) - 1; i >= 0; --i)
    {
        var _entry = _entries[i];
        var _path = $"{_directory}/{_entry}";

        if (!directory_exists(_path)) continue;
        if (string_digits(_entry) != _entry) continue;

        array_push(_backups, _entry);
    }

    var _length = array_length(_backups);

    if (_length <= _max_slots) exit;

    array_sort(_backups, __sort_backup_timestamp);

    for (var i = 0; i < _length - _max_slots; ++i)
    {
        file_backup_delete_directory_recursive($"{_directory}/{_backups[i]}");
    }
}

function buffer_save_compressed_async(_buffer, _path)
{
    var _buffer_compressed = buffer_compress(_buffer, 0, buffer_get_size(_buffer));

    /* store for cleanup in async system event */
    var _id = buffer_save_async(_buffer_compressed, _path, 0, buffer_get_size(_buffer_compressed));

    global.async_save_map[$ string(_id)] = _buffer_compressed;

    return _id;
}

function file_backup_player(_current_player, _lp)
{
    if (!IS_ENABLED_BACKUP) exit;

    var _uuid       = _current_player.uuid;
    var _timestamp  = datetime_to_unix();
    var _backup_dir = $"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}/backups/{_timestamp}";

    /* 1. global data backup */
    var _buffer_global = buffer_create(0xff, buffer_grow, 1);

    buffer_write(_buffer_global, buffer_u32, PROGRAM_VERSION_NUMBER);
    buffer_write(_buffer_global, buffer_f64, _timestamp);
    buffer_write(_buffer_global, buffer_string, _current_player.name);

    var _names  = global.attire_elements;
    var _length = array_length(_names);

    for (var i = 0; i < _length; ++i)
    {
        var _name   = _names[i];
        var _attire = _current_player.attire[$ _name];

        buffer_write(_buffer_global, buffer_string, _name);
        buffer_write(_buffer_global, buffer_u16,    _attire.colour);

        if (_name != "body")
        {
            buffer_write(_buffer_global, buffer_u16, _attire.index);
        }
    }

    buffer_write(_buffer_global, buffer_u16, _lp.hp);
    buffer_write(_buffer_global, buffer_u16, _lp.hp_max);
    buffer_write(_buffer_global, buffer_u16, _lp.saturation);

    file_save_snippet_effects(_buffer_global, _lp[$ "effects"] ?? {});

    buffer_write(_buffer_global, buffer_u8, global.inventory_selected_hotbar);

    statistics_save_player(_buffer_global);
    achievement_save_player(_buffer_global);

    buffer_save_compressed_async(_buffer_global, $"{_backup_dir}/global.dat");
    buffer_delete(_buffer_global);

    /* 2. inventory backup */
    var _item_data        = global.item_data;
    var _inventory        = global.inventory;
    var _inventory_length = global.inventory_length;
    var _inv_names        = global.inventory_names;
    var _inv_names_length = array_length(_inv_names);

    for (var i = 0; i < _inv_names_length; ++i)
    {
        var _name = _inv_names[i];

        if (string_starts_with(_name, "_")) continue;

        var _v   = _inventory[$ _name];
        var _len = _inventory_length[$ _name];

        var _buffer_inv = buffer_create(0xff * _len, buffer_grow, 1);

        buffer_write(_buffer_inv, buffer_u32, PROGRAM_VERSION_NUMBER);

        var _palette_list   = [];
        var _palette_lookup = {}

        var _collect = function(_inv, _l, _idata, _map, _list, _self_func)
        {
            for (var j = 0; j < _l; ++j)
            {
                var _item = _inv[j];

                if (_item == INVENTORY_EMPTY) continue;

                var _id = _item.get_id();

                if (!struct_exists(_map, _id))
                {
                    _map[$ _id] = true;
                    array_push(_list, _id);
                }

                var _data = _idata[$ _id];

                if (_data == undefined) continue;

                var _sub_len = _data.get_item_inventory_length();

                if (_sub_len > 0)
                {
                    var _sub_inv = _item.get_inventory();

                    if (is_array(_sub_inv))
                    {
                        _self_func(_sub_inv, _sub_len, _idata, _map, _list, _self_func);
                    }
                }
            }
        }

        _collect(_v, _len, _item_data, _palette_lookup, _palette_list, _collect);
        array_sort(_palette_list, true);

        var _p_len = array_length(_palette_list);
        var _p_map = {}

        buffer_write(_buffer_inv, buffer_u16, _p_len);

        for (var j = 0; j < _p_len; ++j)
        {
            var _id = _palette_list[j];

            buffer_write(_buffer_inv, buffer_string, _id);
            _p_map[$ _id] = j;
        }

        file_save_snippet_inventory(_buffer_inv, _v, _len, _item_data, _p_map);
        buffer_save_compressed_async(_buffer_inv, $"{_backup_dir}/inventory/{_name}.dat");
        buffer_delete(_buffer_inv);
    }
}

function file_backup_world_chunk(_current_world, _chunk)
{
    if (!IS_ENABLED_BACKUP) exit;

    var _creature_data = global.creature_data;
    var _item_data     = global.item_data;
    var _world_data    = global.world_data[$ _current_world.dimension];

    var _chunk_x    = _chunk.chunk_xstart / CHUNK_SIZE;
    var _chunk_y    = _chunk.chunk_ystart / CHUNK_SIZE;

    var _timestamp  = datetime_to_unix();
    var _backup_dir = $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/backups/{_timestamp}/dim/{_world_data.get_namespace()}/{_world_data.get_id()}";
    var _path       = $"{_backup_dir}/c{_chunk_x}_{_chunk_y}.dat";

    /* start by writing the current chunk to a temporary buffer */
    var _current_chunk_buffer = buffer_create(1024, buffer_grow, 1);

    buffer_write(_current_chunk_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    buffer_write(_current_chunk_buffer, buffer_f64, _timestamp);

    var _is_generated  = !!(_chunk.boolean & CHUNK_BOOL.GENERATED);
    var _chunk_display = _chunk.chunk_display;

    buffer_write(_current_chunk_buffer, buffer_bool, _is_generated);
    buffer_write(_current_chunk_buffer, buffer_u16,  _chunk_display);

    /* we need to replicate the palette collection and serialization from file_save_world_chunk.gml */
    var _palette_map   = {}
    var _palette_array = [];
    var _palette_index = 0;
    var _index_ref     = [_palette_index];

    var _collect_id = function(_id, _map, _array, _index_ref)
    {
        if (!struct_exists(_map, _id))
        {
            _map[$ _id] = _index_ref[0]++;
            array_push(_array, _id);
        }
    }

    var _collect_inventory_ids = function(_inventory, _length, _item_data, _map, _array, _index_ref, _self_func)
    {
        for (var k = 0; k < _length; ++k)
        {
            var _item = _inventory[k];

            if (_item == INVENTORY_EMPTY) continue;

            var _iid = _item.get_id();

            if (!struct_exists(_map, _iid))
            {
                _map[$ _iid] = _index_ref[0]++;
                array_push(_array, _iid);
            }

            var _idata = _item_data[$ _iid];

            if (_idata != undefined)
            {
                var _ilen = _idata.get_item_inventory_length();

                if (_ilen > 0)
                {
                    var _inv_sub = _item.get_inventory();

                    if (is_array(_inv_sub))
                    {
                        _self_func(_inv_sub, _ilen, _item_data, _map, _array, _index_ref, _self_func);
                    }
                }
            }
        }
    }

    /* abridged collection for backup - similar to file_save_world_chunk.gml */
    if (_chunk_display)
    {
        var _chunk2 = _chunk.chunk;

        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;

            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _tile = _chunk2[tile_index_xyz(l, j, i)];

                    if (_tile != TILE_EMPTY)
                    {
                        var _id = _tile.get_id();

                        _collect_id(_id, _palette_map, _palette_array, _index_ref);

                        var _tdata = _item_data[$ _id];

                        if (_tdata != undefined)
                        {
                            var _tlen = _tdata.get_tile_inventory_length();

                            if (_tlen > 0)
                            {
                                var _inventory = _tile.get_inventory();

                                if (!is_string(_inventory))
                                {
                                    _collect_inventory_ids(_inventory, _tlen, _item_data, _palette_map, _palette_array, _index_ref, _collect_inventory_ids);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /* other collection logic for items/creatures would go here, but keeping it to chunks for now as a representative backup */
    _palette_index = _index_ref[0];

    buffer_write(_current_chunk_buffer, buffer_u16, _palette_index);

    for (var i = 0; i < _palette_index; ++i)
    {
        buffer_write(_current_chunk_buffer, buffer_string, _palette_array[i]);
    }

    var _chunk_covered = _chunk.chunk_covered;

    for (var i = 0; i < CHUNK_SIZE; ++i)
    {
        buffer_write(_current_chunk_buffer, buffer_u16, _chunk_covered[i]);
    }

    for (var i = 0; i < CHUNK_DEPTH; ++i)
    {
        if !(_chunk_display & (1 << i)) continue;

        buffer_write(_current_chunk_buffer, buffer_u16, _chunk.chunk_count[i]);

        for (var j = 0; j < CHUNK_SIZE; ++j)
        {
            for (var l = 0; l < CHUNK_SIZE; ++l)
            {
                var _tile = _chunk.chunk[tile_index_xyz(l, j, i)];

                file_save_snippet_tile(_current_chunk_buffer, _tile, _item_data, _palette_map);
            }
        }
    }

    buffer_save_compressed_async(_current_chunk_buffer, _path);
    buffer_delete(_current_chunk_buffer);
}

function file_backup_world_global(_current_world)
{
    if (!IS_ENABLED_BACKUP) exit;

    var _timestamp  = datetime_to_unix();
    var _backup_dir = $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/backups/{_timestamp}";
    var _path       = $"{_backup_dir}/global.dat";

    var _buffer = buffer_create(1024, buffer_grow, 1);

    file_write_world_global_data(_buffer, _current_world);

    buffer_save_compressed_async(_buffer, _path);
    buffer_delete(_buffer);
}
