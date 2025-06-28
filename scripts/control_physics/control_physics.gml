function control_physics(_dt, _id, _gravity = undefined)
{
    with (_id)
    {
        control_physics_x(_dt);
        control_physics_y(_dt, _gravity ?? entity_value.physics.gravity);
    }
}