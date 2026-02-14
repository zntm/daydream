/**
 * Easing types for spline interpolation between control points.
 */
export enum SplineEasing {
    Linear = "linear", // Constant speed
    EaseIn = "ease_in", // Slow start, fast end (quadratic)
    EaseOut = "ease_out", // Fast start, slow end (quadratic)
    EaseInOut = "ease_in_out", // Slow start and end (smoothstep)
    EaseInCubic = "ease_in_cubic",
    EaseOutCubic = "ease_out_cubic",
    EaseInOutCubic = "ease_in_out_cubic",
    Step = "step", // Instant jump at the end
}

/**
 * A control point for a spline curve.
 * Position is the input value (e.g., depth), value is the output (e.g., cave size factor).
 * Easing controls how the interpolation happens from this point to the next.
 */
export class SplinePoint {
    position: number;
    value: number;
    easing?: SplineEasing;

    constructor(position: number, value: number, easing?: SplineEasing) {
        this.position = position;
        this.value = value;
        if (easing) this.easing = easing;
    }
}

/**
 * A spline curve defined by control points.
 * Supports linear and eased interpolation between points.
 */
export class Spline {
    points: SplinePoint[];
    type: string = "spline";

    constructor(points: SplinePoint[] = []) {
        // Sort points by position for proper interpolation
        this.points = points.sort((a, b) => a.position - b.position);
    }

    /**
     * Add a control point to the spline.
     */
    addPoint(position: number, value: number, easing?: SplineEasing): this {
        this.points.push(new SplinePoint(position, value, easing));
        this.points.sort((a, b) => a.position - b.position);
        return this;
    }
}
