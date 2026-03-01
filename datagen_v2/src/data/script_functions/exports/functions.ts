import { DatagenReturnData } from "../../../lib";
import {
    stringFunctions,
    typeFunctions,
    mathFunctions,
    randomFunctions,
    dataStructureFunctions,
    gameFunctions,
    systemFunctions,
    regexFunctions,
    renderFunctions,
    testFunctions,
    allScriptFunctions
} from "../ScriptFunctionData";
import { ScriptFunction } from "../lib/ScriptFunction";

const generateSnippets = (functions: ScriptFunction[]) => {
    const snippets: { [key: string]: any } = {};
    functions.forEach(func => {
        snippets[func.name] = func.toVSCodeSnippet();
    });
    return snippets;
};

const generateMarkdown = (title: string, functions: ScriptFunction[]) => {
    let md = `# ${title}\n\n`;

    functions.forEach(func => {
        md += `### \`${func.name}(${func.parameters.map(p => p.name).join(", ")})\`: ${func.returnType}\n\n`;
        md += `${func.description.trim()}\n\n`;

        if (func.parameters.length > 0) {
            md += `**Arguments:**\n`;
            md += `| Name | Type | Description |\n`;
            md += `|------|------|-------------|\n`;
            func.parameters.forEach(p => {
                md += `| \`${p.name}\` | ${p.type} | ${p.description}${p.optional ? " (Optional)" : ""} |\n`;
            });
            md += `\n`;
        }

        md += `**Returns:** ${func.returnType}\n\n`;

        if (func.example) {
            md += `\`\`\`javascript\n${Array.isArray(func.example) ? func.example.join("\n") : func.example}\n\`\`\`\n\n`;
        }

        md += `---\n\n`;
    });

    return md;
};

export default [
    new DatagenReturnData(
        "../../../.vscode/daydream.code-snippets",
        generateSnippets(allScriptFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/strings.md",
        generateMarkdown("Strings and Types", [...stringFunctions, ...typeFunctions])
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/math.md",
        generateMarkdown("Math Functions", mathFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/random.md",
        generateMarkdown("Random Functions", randomFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/collections.md",
        generateMarkdown("Data Structures", dataStructureFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/game.md",
        generateMarkdown("Game API", gameFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/system.md",
        generateMarkdown("System & Environment", systemFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/regex.md",
        generateMarkdown("Regular Expressions", regexFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/rendering.md",
        generateMarkdown("Rendering", renderFunctions)
    ),
    new DatagenReturnData(
        "../../../doc/stdlib/testing.md",
        generateMarkdown("Testing", testFunctions)
    ),
    new DatagenReturnData(
        "../../../.vscode/extensions/daydream-extension/data/functions.json",
        allScriptFunctions
    )
];
