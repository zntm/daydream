function control_physics(_dt, _id)
{
    with (_id)
    {
        control_physics_x();
        control_physics_y(_dt, entity_value.physics.gravity);
    }
}