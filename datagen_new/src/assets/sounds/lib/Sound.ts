export class Sound {
    id: string;
    gain?: number | string;

    constructor(id: string, gain?: number | string) {
        this.id = id;
        this.gain = gain;
    }
}
