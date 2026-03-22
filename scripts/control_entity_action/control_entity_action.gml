/// @desc Shared entity action logic (swinging, tool spawning, on_attack callbacks)
/// @desc Works for both players and creatures that have an equipped item

/// @param {Id.Instance} _entity The entity instance (player or creature)
/// @param {Struct} _inv_target The inventory struct to read from
/// @param {Real} _hotbar_index Which hotbar slot to use
function control_entity_action(_entity, _inv_target, _hotbar_index)
{
    with (_entity)
    {
        var _item = _inv_target.base[_hotbar_index];
        var _id   = "";
        var _data = undefined;

        if (_item != INVENTORY_EMPTY)
        {
            _id   = _item.get_id();
            _data = global.item_data[$ _id];
        }

        var _can_swing = (timer_attack <= 0) && (input_state.attack_held);

        if (_can_swing) && (_item != INVENTORY_EMPTY) && (_data != undefined)
        {
            sfx_diegetic_play(audio_emitter, x, y, "phantasia:sfx/item/swing", global.settings.audio_sfx);

            timer_attack = 0.3;

            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item._id = _id;
                inst_item.sprite_index = global.sprite_asset[$ _data.get_sprite()].get_sprite();
                inst_item.image_index = _data.get_inventory_index();
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;

                inst_item.hold_type = _data.get_hold_type();

                if (inst_item.hold_type == ITEM_HOLD_TYPE.WHIP)
                {
                    inst_item.whip_segments = _data.get_hold_whip_segments();
                }
            }

            var _on_attack = _data.get_on_attack();

            if (_on_attack != undefined)
            {
                var _tx = round(x / TILE_SIZE);
                var _ty = round(y / TILE_SIZE);

                var _on_attack_length = _data.get_on_attack_length();

                for (var j = _on_attack_length - 1; j >= 0; --j)
                {
                    function_execute(_on_attack[j], _tx, _ty, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                }
            }
        }

        /* attack timer and weapon swing animation */
        if (timer_attack > 0)
        {
            timer_attack = max(0, timer_attack - (1 / GAME_TICK));
        }

        if (timer_attack <= 0)
        {
            if (input_state.move_x != 0)
            {
                image_xscale = abs(image_xscale) * sign(input_state.move_x);
            }

            if (instance_exists(inst_item))
            {
                instance_destroy(inst_item);
            }
        }
        else if (instance_exists(inst_item))
        {
            /* weapon swing animation */
            var _direction = sign(image_xscale);
            var _id_tool   = inst_item._id;
            var _data_tool = global.item_data[$ _id_tool];
            var _hold_type = _data_tool.get_hold_type();

            if (_hold_type == ITEM_HOLD_TYPE.SWING)
            {
                var _t     = power((0.3 - timer_attack) / 0.3, 1 / 4);
                var _angle = (45 * cos(_t * pi)) + 15;

                with (inst_item)
                {
                    var _sprite_width  = sprite_get_width(sprite_index);
                    var _sprite_height = sprite_get_height(sprite_index);

                    image_yscale = _direction;

                    x = other.x + (lengthdir_x(_sprite_width, _angle) * _direction);
                    y = other.y - 20 + (lengthdir_y(_sprite_height, _angle));

                    if (_direction > 0)
                    {
                        image_angle = _angle - ((global.item_data[$ _id_tool].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
                    }
                    else
                    {
                        image_angle = 180 - _angle + ((global.item_data[$ _id_tool].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
                    }
                }
            }
            else if (_hold_type == ITEM_HOLD_TYPE.SPEAR)
            {
                var _aim_angle = input_state.aim_angle;
                var _t = 0;

                if (timer_attack > 0)
                {
                    if (timer_attack > 0.15)
                    {
                        _t = (0.3 - timer_attack) / 0.15;
                    }
                    else
                    {
                        _t = timer_attack / 0.15;
                    }
                }

                var _dist = 8 + (_t * 24);

                with (inst_item)
                {
                    x = other.x + lengthdir_x(_dist, _aim_angle);
                    y = other.y - 24 + lengthdir_y(_dist, _aim_angle);
                    image_angle = _aim_angle;
                    if (_aim_angle > 90) && (_aim_angle < 270) image_yscale = -1;
                }
            }
        }
    }
}
