export interface ScriptFunctionParameter {
    name: string;
    type: string;
    description: string;
    optional?: boolean;
}

export class ScriptFunction {
    name: string;
    description: string;
    example?: string | string[];
    parameters: ScriptFunctionParameter[];
    returnType: string;

    constructor(
        name: string,
        description: string,
        returnType: string = "void",
        parameters: ScriptFunctionParameter[] = []
    ) {
        this.name = name;
        this.description = description;
        this.returnType = returnType;
        this.parameters = parameters;
    }

    setExample(example: string | string[]): this {
        this.example = example;
        return this;
    }

    toVSCodeSnippet() {
        const paramBody = this.parameters
            .map((p, index) => `\${${index + 1}:${p.name}}`)
            .join(", ");

        const body = `${this.name}(${paramBody})`;

        let description = `${this.description}\n\n`;
        if (this.parameters.length > 0) {
            description += `**Parameters:**\n`;
            this.parameters.forEach((p) => {
                description += `- \`${p.name}\` (${p.type}): ${p.description}${p.optional ? " (Optional)" : ""
                    }\n`;
            });
            description += `\n`;
        }
        description += `**Returns:** ${this.returnType}\n\n`;

        if (this.example) {
            description += `**Example:**\n\`\`\`\n${Array.isArray(this.example)
                    ? this.example.join("\n")
                    : this.example
                }\n\`\`\``;
        }

        return {
            prefix: this.name,
            body: body,
            description: description,
            scope: "daydream",
        };
    }

    toTypeDefinition() {
        const typeMap: { [key: string]: string } = {
            any: "any",
            string: "string",
            number: "number",
            boolean: "boolean",
            void: "void",
            array: "any[]",
            struct: "Record<string, any>",
            function: "Function",
            regex: "any",
        };

        const mapType = (t: string) => typeMap[t] || "any";

        let jsdoc = `/**\n * ${this.description}\n`;

        this.parameters.forEach((p) => {
            jsdoc += ` * @param ${p.name} ${p.description}\n`;
        });

        if (this.returnType !== "void") {
            jsdoc += ` * @returns ${this.returnType}\n`;
        }

        if (this.example) {
            const ex = Array.isArray(this.example)
                ? this.example.join("\n * ")
                : this.example;
            jsdoc += ` * @example\n * ${ex}\n`;
        }

        jsdoc += ` */`;

        const params = this.parameters
            .map((p) => {
                const optional = p.optional ? "?" : "";
                return `${p.name}${optional}: ${mapType(p.type)}`;
            })
            .join(", ");

        return `${jsdoc}\ndeclare function ${this.name}(${params}): ${mapType(
            this.returnType
        )};\n`;
    }
}
