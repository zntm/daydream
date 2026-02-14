export class DatagenReturnData {
    destination: string;
    data: any;
    isRaw: boolean;

    constructor(destination: string, data: any, isRaw: boolean = false) {
        this.destination = destination;
        this.data = data;
        this.isRaw = isRaw;
    }
}
