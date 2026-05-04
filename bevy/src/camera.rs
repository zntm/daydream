use bevy::prelude::*;

use crate::player::Player;

/* ── component ──────────────────────────────────────────────────────────── */

#[derive(Component)]
pub struct GameCamera;

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct CameraPlugin;

impl Plugin for CameraPlugin
{
    fn build(&self, app: &mut App)
    {
        app.add_systems(Startup, spawn_camera)
           .add_systems(PostUpdate, follow_player);
    }
}

fn spawn_camera(mut commands: Commands)
{
    commands.spawn((
        GameCamera,
        Camera2d,
    ));
}

fn follow_player(
    players: Query<&Transform, With<Player>>,
    mut cameras: Query<&mut Transform, (With<GameCamera>, Without<Player>)>,
)
{
    let Ok(player_t)  = players.get_single()
    else
    {
        return;
    };
    let Ok(mut cam_t) = cameras.get_single_mut()
    else
    {
        return;
    };

    /* lerp camera toward player for a smooth follow, then snap to integer
       pixel coords to prevent sub-pixel gaps between tile quads */
    let target  = player_t.translation.truncate();
    let current = cam_t.translation.truncate();
    let smoothed = current.lerp(target, 0.12);

    cam_t.translation.x = smoothed.x.round();
    cam_t.translation.y = smoothed.y.round();
}
