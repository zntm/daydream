import { existsSync, readdirSync, readFileSync } from "fs";
import { join, basename } from "path";
import { DatagenReturnData } from "../../lib";

const DOCS_DIR = join(__dirname, "../../../doc/stdlib");

const generateDocs = (): DatagenReturnData[] => {
    if (!existsSync(DOCS_DIR)) {
        console.warn(`Docs directory not found: ${DOCS_DIR}`);
        return [];
    }

    const results: DatagenReturnData[] = [];

    for (const file of readdirSync(DOCS_DIR)) {
        if (!file.endsWith(".md")) continue;

        const filePath = join(DOCS_DIR, file);
        const content = readFileSync(filePath, "utf-8");
        const name = basename(file, ".md");

        results.push(
            new DatagenReturnData(`docs/stdlib/${name}.json`, {
                name,
                content,
            })
        );
    }

    return results;
};

export default generateDocs();
