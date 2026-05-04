use bevy::prelude::*;

use crate::consts::TILE_SIZE;

/* ── component ──────────────────────────────────────────────────────────── */

#[derive(Component)]
pub struct Player;

/* ── resource ───────────────────────────────────────────────────────────── */

#[derive(Resource)]
pub struct PlayerSpeed(pub f32);

impl Default for PlayerSpeed
{
    fn default() -> Self { Self(200.0) }
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct PlayerPlugin;

impl Plugin for PlayerPlugin
{
    fn build(&self, app: &mut App)
    {
        app.init_resource::<PlayerSpeed>()
           .add_systems(Startup,        spawn_player)
           .add_systems(Update,         move_player);
    }
}

fn spawn_player(mut commands: Commands)
{
    /* surface is at tile-y 64 → screen-y = -(64 * TILE_SIZE).
       Place the player two tiles above the surface. */
    let surface_screen_y = -(64.0 * TILE_SIZE);

    commands.spawn((
        Player,
        Sprite {
            color:       Color::srgb(0.95, 0.75, 0.5),
            custom_size: Some(Vec2::new(TILE_SIZE * 0.75, TILE_SIZE * 1.5)),
            ..default()
        },
        Transform::from_xyz(0.0, surface_screen_y - TILE_SIZE * 2.0, 100.0),
    ));
}

fn move_player(
    keys:        Res<ButtonInput<KeyCode>>,
    speed:       Res<PlayerSpeed>,
    time:        Res<Time>,
    mut players: Query<&mut Transform, With<Player>>,
)
{
    let Ok(mut transform) = players.get_single_mut()
    else
    {
        return;
    };

    let mut dir = Vec2::ZERO;

    if keys.pressed(KeyCode::KeyW) || keys.pressed(KeyCode::ArrowUp)
    {
        dir.y += 1.0;  /* up on screen = positive Y in Bevy 2D */
    }
    if keys.pressed(KeyCode::KeyS) || keys.pressed(KeyCode::ArrowDown)
    {
        dir.y -= 1.0;
    }
    if keys.pressed(KeyCode::KeyA) || keys.pressed(KeyCode::ArrowLeft)
    {
        dir.x -= 1.0;
    }
    if keys.pressed(KeyCode::KeyD) || keys.pressed(KeyCode::ArrowRight)
    {
        dir.x += 1.0;
    }

    if dir != Vec2::ZERO
    {
        dir = dir.normalize();
    }

    let dt    = time.delta_secs();
    let delta = dir * speed.0 * dt;

    transform.translation.x += delta.x;
    transform.translation.y += delta.y;
}
