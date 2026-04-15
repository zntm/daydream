export type DatagenNamespaceDependency = {
    $NAMESPACE_EXISTS?: string[];
    $MIXIN?: string;
};

export class DatagenReturnData {
    destination: string;
    data: any;
    namespaceExists?: string[];
    mixin?: string;

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

    setMixin(target: string) {
        this.mixin = target;

        return this;
    }

    getSerializableData() {
        if (!this.namespaceExists?.length && !this.mixin) {
            return this.data;
        }

        if (
            typeof this.data !== "object" ||
            this.data === null ||
            Array.isArray(this.data)
        ) {
            throw new Error(
                `$NAMESPACE_EXISTS and $MIXIN can only be applied to object-like JSON roots (${this.destination})`,
            );
        }

        const root: DatagenNamespaceDependency = {
            ...this.data,
        };

        if (this.namespaceExists?.length) {
            root.$NAMESPACE_EXISTS = this.namespaceExists;
        }

        if (this.mixin) {
            root.$MIXIN = this.mixin;
        }

        return root;
    }
}
