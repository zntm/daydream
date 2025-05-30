function inventory_delete(_type, _index)
{
    delete global.inventory[$ _type][_index];
    
    global.inventory[$ _type][@ _index] = INVENTORY_EMPTY;
}