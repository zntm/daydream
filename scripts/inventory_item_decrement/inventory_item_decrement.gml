function inventory_item_decrement(_type, _index)
{
    global.inventory[$ _type][_index].add_amount(-1);
    
    if (global.inventory[$ _type][_index].get_amount() <= 0)
    {
        inventory_delete(_type, _index);
    }
}