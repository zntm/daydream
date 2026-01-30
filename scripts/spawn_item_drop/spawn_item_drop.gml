/// @desc Spawn an item drop with physics
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Struct} _item Item struct
/// @param {Real} [_direction] Direction multiplier
/// @param {Real} [_xvelocity] Initial X velocity
/// @param {Real} [_yvelocity] Initial Y velocity
/// @param {Real} [_timer_pickup] Pickup delay
/// @param {Real} [_timer_life] Lifetime

function spawn_item_drop(_x, _y, _item, _direction = 0, _xvelocity = 0, _yvelocity = 0, _timer_pickup = 0.85, _timer_life = 60 * 15)
{
    if (_item == INVENTORY_EMPTY) exit;
    
    var _data = global.item_data[$ _item.get_id()];
    
    if (_data == undefined) exit;
    
    var _size = _data.get_inventory_size();
    
    with (instance_create_layer(_x, _y + (_size / 2), "Instances", obj_Item_Drop))
    {
        attribute = new Attribute()
            .set_collision_box(_size, _size)
            .set_gravity(0.15);
        
        // Create physics body
        physics_body = new PhysicsBody(attribute);
        physics_body.pos_x = x;
        physics_body.pos_y = y;
        physics_body.vel_x = _xvelocity;
        physics_body.vel_y = _yvelocity;
        physics_body.scale_x = _size / 8;
        physics_body.scale_y = _size / 8;
        
        image_xscale = physics_body.scale_x;
        image_yscale = physics_body.scale_y;
        
        image_index = _data.get_inventory_index();
        image_speed = 0;
        
        inst = noone;
        item = _item;
        
        timer_pickup = _timer_pickup;
        timer_life = _timer_life;
        
        // Interpolation state
        interp_start_x = x;
        interp_start_y = y;
        interp_target_x = x;
        interp_target_y = y;
        interp_timer = 0;
        interp_duration = 0.05;
    }
}