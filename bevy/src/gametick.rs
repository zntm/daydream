use bevy::prelude::*;

use crate::consts::GAME_TICK;

/* ── resource ───────────────────────────────────────────────────────────── */

#[derive(Resource, Default)]
pub struct GameTickState
{
    pub accumulator: f64,
    pub tick:        u64,  /* total ticks elapsed */
}

/* ── event ──────────────────────────────────────────────────────────────── */

#[derive(Event)]
pub struct GameTickEvent
{
    pub tick: u64,
}

/* ── plugin ─────────────────────────────────────────────────────────────── */

pub struct GameTickPlugin;

impl Plugin for GameTickPlugin
{
    fn build(&self, app: &mut App)
    {
        app.init_resource::<GameTickState>()
           .add_event::<GameTickEvent>()
           .add_systems(Update, advance_gametick);
    }
}

/* advance the fixed-rate tick accumulator and fire GameTickEvent each tick */
fn advance_gametick(
    time:          Res<Time>,
    mut state:     ResMut<GameTickState>,
    mut tick_evts: EventWriter<GameTickEvent>,
)
{
    let dt = time.delta_secs_f64();

    state.accumulator += dt * GAME_TICK;

    while state.accumulator >= 1.0
    {
        state.tick       += 1;
        state.accumulator -= 1.0;

        tick_evts.send(GameTickEvent { tick: state.tick });
    }
}
