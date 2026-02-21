/// @desc Set entity scale for collision calculations
function entity_set_scale(_xscale, _yscale = _xscale)
{
    image_xscale = _xscale;
    image_yscale = _yscale;
    
    entity_xscale = _xscale;
    entity_yscale = _yscale;
    
    if (id[$ "physics_body"] != undefined)
    {
        physics_body.scale_x = _xscale;
        physics_body.scale_y = _yscale;
    }
}