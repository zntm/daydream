export class ItemScript {
    private id: string;
    private parameters?: Record<string, unknown>;
    private chance?: string | number;
    private repeat?: string | number;

    constructor(
        id: string,
        parameters?: Record<string, unknown>,
        chance?: string | number,
        repeat?: string | number,
    ) {
        this.id = id;
        if (parameters !== undefined) this.parameters = parameters;
        if (chance !== undefined) this.chance = chance;
        if (repeat !== undefined) this.repeat = repeat;
    }
}
