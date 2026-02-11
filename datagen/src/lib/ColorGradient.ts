export class ColorPoint {
    position: number;
    color: string;

    constructor(position: number, color: string) {
        this.position = position;
        this.color = /\#[0-9a-fA-F]{6}/.test(color) ? color.toUpperCase() : color;
    }
}

export class ColorGradient {
    points: ColorPoint[];

    constructor(points: ColorPoint[]) {
        this.points = points.sort((a, b) => a.position - b.position);
    }

    addPoint(position: number, color: string): ColorGradient {
        this.points.push(new ColorPoint(position, color));
        this.points.sort((a, b) => a.position - b.position);
        return this;
    }
}
