import { Table } from "./Table";

export class Doc {
    private content: string = "";

    constructor(title?: string) {
        if (title) {
            this.content += `# ${title}\n\n`;
        }
    }

    add(text: string): this {
        this.content += text + "\n\n";
        return this;
    }

    section(title: string): this {
        this.content += `## ${title}\n\n`;
        return this;
    }

    function(name: string, args_sig: string, returns: string, description: string, args?: [string, string, string][], example?: string): this {
        this.content += `### \`${name}(${args_sig})\`: ${returns}\n\n`;
        this.content += `${description}\n\n`;

        if (args && args.length > 0) {
            this.content += "**Arguments:**\n";
            const table = new Table(["Name", "Type", "Description"]);
            for (const arg of args) {
                table.addRow(arg);
            }
            this.content += table.toString() + "\n\n";
        }

        this.content += `**Returns:** ${returns}\n\n`;

        if (example) {
            this.content += "```javascript\n" + example + "\n```\n\n";
        }

        this.content += "---\n\n";
        return this;
    }

    table(headers: string[], callback: (t: Table) => void): this {
        const t = new Table(headers);
        callback(t);
        this.content += t.toString() + "\n\n";
        return this;
    }

    toString(): string {
        return this.content.trim() + "\n";
    }
}
