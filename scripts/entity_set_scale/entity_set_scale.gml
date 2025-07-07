function entity_set_scale(_scale)
{
    entity_scale = _scale;
    
    image_xscale = _scale * attribute.get_collision_box_width()  / 8;
    image_yscale = _scale * attribute.get_collision_box_height() / 8;
}