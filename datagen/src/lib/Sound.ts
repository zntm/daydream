export class Sound {
    private id: string;
    private gain?: number;

    constructor(id: string, gain?: number) {
        this.id = id;

        if (gain !== undefined) {
            this.gain = gain;
        }
    }
}
