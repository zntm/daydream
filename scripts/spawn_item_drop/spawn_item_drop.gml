function spawn_item_drop(_x, _y, _item, _direction = 0, _xvelocity = 0, _yvelocity = 0, _timer_pickup = 0.85, _timer_life = 60 * 15)
{
    if (_item == INVENTORY_EMPTY) exit;
    
    var _data = global.item_data[$ _item.get_id()];
    
    if (_data == undefined) exit;
    
    with (instance_create_layer(_x, _y, "Instances", obj_Item_Drop))
    {
        var _size = _data.get_inventory_size();
        
        attribute = {
            collision_box: {
                width:  _size,
                height: _size
            },
            physics: {
                gravity: 0.15
            }
        }
        
        image_xscale = _size / 8;
        image_yscale = _size / 8;
        
        image_index = _data.get_inventory_index();
        image_speed = 0;
        
        inst = noone;
        
        xvelocity = _xvelocity;
        yvelocity = _yvelocity;
        
        item = _item;
        
        timer_pickup = _timer_pickup;
        timer_life = _timer_life;
    }
}