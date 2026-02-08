export class FluidFlowCollision {
    id: string;
    liquid_id: string;

    constructor(id: string, liquid_id: string) {
        this.id = id;
        this.liquid_id = liquid_id;
    }
}

export class LiquidRegistry {
    namespace: string;
    id: string;
    tick_delay: number;
    fluid_collisions: FluidFlowCollision[];

    constructor(
        namespace: string,
        id: string,
        tick_delay: number,
        fluid_collisions: FluidFlowCollision[],
    ) {
        this.namespace = namespace;
        this.id = id;
        this.tick_delay = tick_delay;
        this.fluid_collisions = fluid_collisions;
    }
}

export default [
    new LiquidRegistry("phantasia", "lava", 1, [
        new FluidFlowCollision("phantasia:stone", "phantasia:water"),
    ]),
    new LiquidRegistry("phantasia", "water", 5, [
        new FluidFlowCollision("phantasia:stone", "phantasia:lava"),
    ]),
];
