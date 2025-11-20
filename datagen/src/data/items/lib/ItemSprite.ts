export class ItemSprite {
    private xoffset: number;
    private yoffset: number;
    private length: number;

    constructor(xoffset: number, yoffset: number, length: number = 1) {
        this.xoffset = xoffset;
        this.yoffset = yoffset;
        this.length = length;
    }
}
