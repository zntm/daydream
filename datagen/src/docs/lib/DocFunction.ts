export interface DocArgument {
    name: string;
    type: string;
    description: string;
}

export class DocFunction {
    constructor(
        public name: string,
        public description: string,
        public args: DocArgument[] = [],
        public returns: string = "void",
        public example: string = ""
    ) { }

    toMarkdown(): string {
        let md = `### \`${this.name}(${this.args.map(a => a.name).join(", ")})\`: ${this.returns}\n\n`;
        md += `${this.description}\n\n`;

        if (this.args.length > 0) {
            md += "**Arguments:**\n";
            md += "| Name | Type | Description |\n";
            md += "|------|------|-------------|\n";
            for (const arg of this.args) {
                md += `| \`${arg.name}\` | ${arg.type} | ${arg.description} |\n`;
            }
            md += "\n";
        }

        md += `**Returns:** ${this.returns}\n\n`;

        if (this.example) {
            md += "```javascript\n";
            md += `${this.example}\n`;
            md += "```\n\n";
        }

        md += "---\n\n";
        return md;
    }
}
