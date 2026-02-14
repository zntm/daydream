import { DocFunction } from "./DocFunction";

export interface DocSection {
    title: string;
    content: string;
}

export class DocModule {
    constructor(
        public title: string,
        public description: string = "",
        public functions: DocFunction[] = [],
        public sections: DocSection[] = []
    ) { }

    toMarkdown(): string {
        let md = `# ${this.title}\n\n`;
        if (this.description) {
            md += `${this.description}\n\n`;
        }

        for (const section of this.sections) {
            md += `## ${section.title}\n\n${section.content}\n\n`;
        }

        if (this.functions.length > 0) {
            md += `## Functions\n\n`;
            for (const fn of this.functions) {
                md += fn.toMarkdown();
            }
        }

        return md.trim() + "\n";
    }
}
