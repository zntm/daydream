export class Sprite {
    public xoffset: number;
    public yoffset: number;
    public length: number;

    constructor(xoffset: number, yoffset: number, length: number = 1) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.length = length;
    }
}
