function entity_set_scale(_xscale, _yscale)
{
    entity_xscale = _xscale;
    entity_yscale = _yscale;
    
    image_xscale = _xscale * attribute.get_collision_box_width()  / 8;
    image_yscale = _yscale * attribute.get_collision_box_height() / 8;
}