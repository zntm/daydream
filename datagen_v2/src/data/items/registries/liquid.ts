class LiquidRegistry {
    namespace: string;
    id: string;
    flow_speed: number;
    fluidCollisions: FluidFlowCollision[];
    item_drop_modifier?: {
        despawn?: number;
    };

    constructor(
        namespace: string,
        id: string,
        flow_speed: number,
        fluid_collisions: FluidFlowCollision[],
        item_drop_modifier?: {
            despawn?: number;
        },
    ) {
        this.namespace = namespace;
        this.id = id;
        this.flow_speed = flow_speed;
        this.fluidCollisions = fluid_collisions;
        this.item_drop_modifier = item_drop_modifier;
    }
}

class FluidFlowCollision {
    id: string;
    liquid_id: string;

    constructor(id: string, liquid_id: string) {
        this.id = id;
        this.liquid_id = liquid_id;
    }
}

export default [
    new LiquidRegistry("phantasia", "lava", 24, [
        new FluidFlowCollision("phantasia:stone", "phantasia:water"),
    ], {
        despawn: 4,
    }),
    new LiquidRegistry("phantasia", "water", 8, [
        new FluidFlowCollision("phantasia:obsidian", "phantasia:lava"),
    ]),
];
