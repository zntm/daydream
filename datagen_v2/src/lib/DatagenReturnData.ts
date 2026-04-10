export type DatagenNamespaceDependency = {
    $NAMESPACE_EXISTS?: string[];
};

export class DatagenReturnData {
    destination: string;
    data: any;
    namespaceExists?: string[];

    constructor(destination: string, data: any) {
        this.destination = destination;
        this.data = data;
    }

    setNamespaceExists(namespaces: string | string[]) {
        this.namespaceExists = Array.isArray(namespaces)
            ? [...namespaces]
            : [namespaces];

        return this;
    }

    getSerializableData() {
        if (!this.namespaceExists?.length) {
            return this.data;
        }

        if (
            typeof this.data !== "object" ||
            this.data === null ||
            Array.isArray(this.data)
        ) {
            throw new Error(
                `$NAMESPACE_EXISTS can only be applied to object-like JSON roots (${this.destination})`,
            );
        }

        return {
            ...this.data,
            $NAMESPACE_EXISTS: this.namespaceExists,
        } satisfies DatagenNamespaceDependency;
    }
}
