export class ColorGradient {
    private points: { time: number; value: string }[] = [];

    /**
     * Add a point to the gradient.
     * @param time Normalized time (0.0 to 1.0)
     * @param value The color value at this time (hex string)
     */
    addPoint(time: number, value: string): this {
        this.points.push({ time, value });
        this.points.sort((a, b) => a.time - b.time);
        return this;
    }

    /**
     * Helper for JSON serialization.
     * Returns array of [time, color] tuples.
     */
    toJSON() {
        return this.points.map((p) => [p.time, p.value]);
    }
}
