class LiquidRegistry {
    namespace: string;
    id: string;
    flow_speed: number;
    fluid_collisions: FluidFlowCollision[];

    constructor(
        namespace: string,
        id: string,
        flow_speed: number,
        fluid_collisions: FluidFlowCollision[],
    ) {
        this.namespace = namespace;
        this.id = id;
        this.flow_speed = flow_speed;
        this.fluid_collisions = fluid_collisions;
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
    ]),
    new LiquidRegistry("phantasia", "water", 8, [
        new FluidFlowCollision("phantasia:obsidian", "phantasia:lava"),
    ]),
];
