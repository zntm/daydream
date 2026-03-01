export class Attire {
    private colour: string | string[];
    private icon: string;
    private white?: string | string[];

    constructor(colour: string | string[], icon: string, white?: string | string[]) {
        this.colour = colour;
        this.icon = icon;
        this.white = white;
    }
}
