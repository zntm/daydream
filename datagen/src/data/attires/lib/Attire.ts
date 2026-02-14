export class Attire {
    private colour: string | string[];
    private icon: string;
    private white?: string | string[];

<<<<<<< HEAD:datagen_new/src/data/attires/lib/Attire.ts
    constructor(
        colour: string | string[],
        icon: string,
        white?: string | string[],
    ) {
=======
    constructor(colour: string | string[], icon: string, white?: string | string[]) {
>>>>>>> region:datagen/src/data/attires/lib/Attire.ts
        this.colour = colour;
        this.icon = icon;
        this.white = white;
    }
}
