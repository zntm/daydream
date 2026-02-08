/**
 * Container for datagen output - a destination path and the data to write.
 */
export class DatagenReturnData {
    readonly destination: string;
    readonly data: unknown;

    constructor(destination: string, data: unknown) {
        this.destination = destination;
        this.data = data;
    }
}
