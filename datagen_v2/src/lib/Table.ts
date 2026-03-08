export class Table {
    private headers: string[];
    private rows: string[][];

    constructor(headers: string[]) {
        this.headers = headers;
        this.rows = [];
    }

    addRow(cells: string[]): this {
        this.rows.push(cells);

        return this;
    }

    toString(): string {
        const colCount = this.headers.length;
        const colWidths = this.headers.map((h) => h.length);

        for (const row of this.rows) {
            for (let i = 0; i < colCount; ++i) {
                const cell = row[i] ?? "";
                const width = colWidths[i] ?? 0;

                if (cell.length > width) {
                    colWidths[i] = cell.length;
                }
            }
        }

        const pad = (s: string, w: number) => s + " ".repeat(w - s.length);

        const header =
            "| " +
            this.headers.map((h, i) => pad(h, colWidths[i] ?? 0)).join(" | ") +
            " |";

        const divider =
            "| " +
            colWidths.map((w) => "-".repeat(w)).join(" | ") +
            " |";

        const bodyRows = this.rows.map(
            (row) =>
                "| " +
                this.headers
                    .map((_, i) => pad(row[i] ?? "", colWidths[i] ?? 0))
                    .join(" | ") +
                " |",
        );

        return [header, divider, ...bodyRows].join("\n");
    }
}
