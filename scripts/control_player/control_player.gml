/// @desc Player control using new physics system
/// @param {Real} _dt Delta time

function control_player(_dt)
{
    if (hp <= 0) exit;
    
    // --- INPUT ---
    input_state.poll_player();
    
    // --- DAMAGE CHECK ---
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst))
        {
            var _data = global.creature_data[$ _inst._id];
            
            if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.HOSTILE)
            {
                var _died = control_entity_damage(id, _inst, _data.get_contact_damage());
                
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                
                if (_died) exit;
                
                // Knockback using new physics
                var _kb_dir = sign(x - _inst.x);
                if (_kb_dir == 0) _kb_dir = 1;
                physics_body.vel_x = _kb_dir * 4;
                physics_body.vel_y = -3;
            }
        }
    }
    
    if (timer_immunity > 0)
    {
        timer_immunity = max(0, timer_immunity - (_dt / GAME_TICK));
    }
    
    // --- AUDIO ---
    audio_listener_position(x, y, 0);
    
    // --- PHYSICS ---
    physics_body.sync_from_instance(id);
    entity_update_collision(physics_body);
    
    // Choose physics mode based on debug settings
    if (IS_DEVELOPER_MODE && !global.dbg_settings[$ "enable_physics"])
    {
        // Creative flight mode
        physics_body.mode = MOVEMENT_MODE.FLY;
    }
    
    physics_step(physics_body, input_state, _dt);
    physics_body.sync_to_instance(id);
    
    // --- COMBAT ---
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU) && (timer_attack <= 0) && (input_state.attack_held)
    {
        sfx_diegetic_play(audio_emitter, x, y, "phantasia:sfx/item/swing", global.settings.audio_sfx);
        
        timer_attack = 0.3;
        
        var _item = global.inventory.base[global.inventory_selected_hotbar];
        
        if (_item != INVENTORY_EMPTY)
        {
            var _id = _item.get_id();
            var _data = global.item_data[$ _id];
            
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item._id = _id;
                inst_item.sprite_index = global.sprite_asset[$ _data.get_sprite()].get_sprite();
                inst_item.image_index = _data.get_inventory_index();
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;
            }
            
            // Shooting logic
            var _angle = input_state.aim_angle;
            if (control_entity_shoot(id, _id, x, y - 24, _angle))
            {
                // Shot something
            }
            
            var _on_attack = _data.get_on_attack();
            var _on_attack_length = _data.get_on_attack_length();
            
            for (var j = 0; j < _on_attack_length; ++j)
            {
                function_execute(_on_attack[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), _dt);
            }
        }
    }
    
    // Attack timer and weapon swing animation
    if (timer_attack > 0)
    {
        timer_attack = max(0, timer_attack - (_dt / GAME_TICK));
    }
    
    if (timer_attack <= 0)
    {
        // Face movement direction
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
        // Weapon swing animation
        var _direction = sign(image_xscale);
        var _t = power((0.3 - timer_attack) / 0.3, 1 / 4);
        var _angle = (45 * cos(_t * pi)) + 15;
        
        with (inst_item)
        {
            var _id = self._id;
            var _sprite_width = sprite_get_width(sprite_index);
            var _sprite_height = sprite_get_height(sprite_index);
            
            image_yscale = _direction;
            
            x = other.x + (lengthdir_x(_sprite_width, _angle) * _direction);
            y = other.y - 24 + (lengthdir_y(_sprite_height, _angle));
            
            if (_direction > 0)
            {
                image_angle = _angle - ((global.item_data[$ _id].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
            }
            else
            {
                image_angle = 180 - _angle + ((global.item_data[$ _id].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
            }
        }
    }
    
    // --- FALL DAMAGE ---
    if (y > y_last)
    {
        if (physics_body.collision.ground)
        {
            var _difference = max(0, y - y_last - (TILE_SIZE * 4));
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0 && !attribute.has_boolean(ATTRIBUTE_BOOLEAN.IS_FALL_DAMAGE_RESISTANT))
            {
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                hp -= _value;
                y_last = y;
                
                repeat (irandom_range(2, 6))
                {
                    spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
                }
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    obj_Game_Control.timer_respawn = 3;
                    exit;
                }
            }
        }
    }
    else
    {
        y_last = y;
    }
    
    // --- POST-PHYSICS ---
    control_entity_sfx(_dt);
    
    // Camera
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
    
    // Regeneration
    var _is_regenerated = false;
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        _is_regenerated = control_entity_regeneration(_dt / GAME_TICK);
    }
    
    control_entity_effect();
    
    if (_is_regenerated)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
    }
    
    // Chunk visibility
    if (physics_body.vel_x != 0 || physics_body.vel_y != 0)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        var _camera_width = global.camera_width;
        var _camera_height = global.camera_height;
        
        var _xstart = round((_camera_x + (_camera_width / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        
        if (_xstart != obj_Game_Control.chunk_in_view_x || _ystart != obj_Game_Control.chunk_in_view_y)
        {
            obj_Game_Control.chunk_in_view_x = _xstart;
            obj_Game_Control.chunk_in_view_y = _ystart;
            control_update_chunk_in_view();
        }
    }
    
    control_entity_suffocation(id);
}