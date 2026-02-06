const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('Daydream extension is active');

    let functionsData = [];

    // Dynamic Data Loading
    const loadData = () => {
        const dataPath = path.join(context.extensionPath, 'data', 'functions.json');
        if (fs.existsSync(dataPath)) {
            try {
                functionsData = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
            } catch (e) {
                console.error('Failed to parse functions.json', e);
            }
        }
    };

    loadData();

    // Watch for changes to functions.json
    const watcher = vscode.workspace.createFileSystemWatcher('**/data/functions.json');
    watcher.onDidChange(loadData);
    watcher.onDidCreate(loadData);
    context.subscriptions.push(watcher);

    const checkFunction = (word) => {
        if (!functionsData) loadData();
        return functionsData.find(f => f.name === word);
    };

    const createMarkdownDocumentation = (func) => {
        const md = new vscode.MarkdownString();
        md.appendCodeblock(`${func.name}(${func.parameters.map(p => p.name).join(', ')}) : ${func.returnType}`, 'daydream');
        md.appendMarkdown(`\n\n${func.description}\n\n`);
        
        if (func.parameters.length > 0) {
            md.appendMarkdown('**Parameters:**\n');
            func.parameters.forEach(p => {
                md.appendMarkdown(`- \`${p.name}\` (${p.type}): ${p.description}`);
                if (p.optional) md.appendMarkdown(' (Optional)');
                md.appendMarkdown('\n');
            });
        }

        if (func.example) {
            md.appendMarkdown('\n**Example:**\n');
            const ex = Array.isArray(func.example) ? func.example.join('\n') : func.example;
            md.appendCodeblock(ex, 'daydream');
        }
        return md;
    };

    const hoverProvider = vscode.languages.registerHoverProvider('daydream', {
        provideHover(document, position, token) {
            const range = document.getWordRangeAtPosition(position);
            const word = document.getText(range);

            const func = checkFunction(word);
            if (func) {
                return new vscode.Hover(createMarkdownDocumentation(func));
            }
        }
    });

    context.subscriptions.push(hoverProvider);

    const completionProvider = vscode.languages.registerCompletionItemProvider('daydream', {
        provideCompletionItems(document, position, token, context) {
            if (!functionsData || functionsData.length === 0) loadData();

            return functionsData.map(func => {
                const item = new vscode.CompletionItem(func.name, vscode.CompletionItemKind.Function);
                item.detail = `${func.name}(${func.parameters.map(p => p.name).join(', ')}) : ${func.returnType}`;
                item.documentation = createMarkdownDocumentation(func);
                
                // Construct snippet
                const paramBody = func.parameters
                    .map((p, index) => `\${${index + 1}:${p.name}}`)
                    .join(", ");
                item.insertText = new vscode.SnippetString(`${func.name}(${paramBody})`);
                
                return item;
            });
        }
    });

    context.subscriptions.push(completionProvider);

    const signatureHelpProvider = vscode.languages.registerSignatureHelpProvider('daydream', {
        provideSignatureHelp(document, position, token, context) {
            const line = document.lineAt(position).text;
            const prefix = line.substring(0, position.character);
            
            // Find the most relevant function call by scanning backwards
            let parenBalance = 0;
            let commas = 0;
            let funcName = '';
            
            for (let i = prefix.length - 1; i >= 0; i--) {
                const char = prefix[i];
                if (char === ')') {
                    parenBalance++;
                } else if (char === '(') {
                    if (parenBalance === 0) {
                        // Found the start of the current function call
                        // Now find the word before it
                        const beforeParen = prefix.substring(0, i).trimEnd();
                        const wordMatch = beforeParen.match(/([a-zA-Z_]\w*)$/);
                        if (wordMatch) {
                            funcName = wordMatch[1];
                            break;
                        }
                    } else {
                        parenBalance--;
                    }
                } else if (char === ',' && parenBalance === 0) {
                    commas++;
                }
            }
            
            if (!funcName) return undefined;
            
            const func = checkFunction(funcName);
            if (func) {
                const signature = new vscode.SignatureInformation(
                    `${func.name}(${func.parameters.map(p => p.name).join(', ')}) : ${func.returnType}`, 
                    createMarkdownDocumentation(func)
                );

                signature.parameters = func.parameters.map(p => {
                    return new vscode.ParameterInformation(
                        p.name, 
                        new vscode.MarkdownString(`**${p.type}**: ${p.description}`)
                    );
                });
                
                const help = new vscode.SignatureHelp();
                help.signatures = [signature];
                help.activeSignature = 0;
                help.activeParameter = commas;
                return help;
            }
            return undefined;
        }
    }, '(', ',');

    context.subscriptions.push(signatureHelpProvider);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
}
