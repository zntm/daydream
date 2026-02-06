// Basic Daydream highlighter for markdown-it
module.exports = (md) => {
    // Save the original renderer
    const defaultRender = md.renderer.rules.fence || function(tokens, idx, options, env, slf) {
        return slf.renderToken(tokens, idx, options);
    };
    
    md.renderer.rules.fence = (tokens, idx, options, env, slf) => {
        const token = tokens[idx];
        const info = token.info ? token.info.trim() : "";
        const langName = info.split(/\s+/g)[0].toLowerCase();

        if (langName === "daydream") {
            let code = token.content;
            
            // Basic regex-based highlighting
            const rules = [
                { reg: /\/\/.*/g, cls: "daydream-comment" }, // Line comment
                { reg: /\/\*[\s\S]*?\*\//g, cls: "daydream-comment" }, // Block comment
                { reg: /"(?:\\.|[^"\\])*"/g, cls: "daydream-string" }, // Double quote string
                { reg: /'(?:\\.|[^'\\])*'/g, cls: "daydream-string" }, // Single quote string
                { reg: /\/(?![*+?])(?:\\.|[^\/\n])+\/[gimuy]*/g, cls: "daydream-regex" }, // Regex
                { reg: /\b(var|global|static|public|private|protected|abstract|implements|extends|class|interface|new|super|this|fn|function|return|if|else|for|while|repeat|break|continue|in|try|catch|throw|switch|case|default|import|export|from|as|package|and|or|not|typeof|instanceof)\b/g, cls: "daydream-keyword" },
                { reg: /\b(true|false|undefined|null|infinity|NaN|PI|TAU|E|PHI)\b/g, cls: "daydream-constant" },
                { reg: /\b(0x[0-9a-fA-F]+|\d+(_\d+)*(\.\d+(_\d+)*)?)\b/g, cls: "daydream-number" },
                { reg: /\b([a-zA-Z_]\w*)(?=\s*\()/g, cls: "daydream-function" }, // Function calls
                { reg: /(\.)\s*([a-zA-Z_]\w*)/g, cls: "daydream-property" } // Properties
            ];

            // Escaping HTML
            code = code.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

            // Build the string with highlighting
            const matches = [];
            rules.forEach(rule => {
                let m;
                // Reset regex lastIndex
                rule.reg.lastIndex = 0;
                while ((m = rule.reg.exec(code)) !== null) {
                    matches.push({ start: m.index, end: m.index + m[0].length, cls: rule.cls, text: m[0] });
                }
            });
            
            // Sort matches: earlier first, then longer first
            matches.sort((a, b) => a.start - b.start || (b.end - b.start) - (a.end - a.start));
            
            const finalMatches = [];
            let lastEnd = 0;
            for (const m of matches) {
                if (m.start >= lastEnd) {
                    finalMatches.push(m);
                    lastEnd = m.end;
                }
            }
            
            // Build the final result
            let result = "";
            let current = 0;
            for (const m of finalMatches) {
                result += code.substring(current, m.start);
                result += `<span class="${m.cls}">${m.text}</span>`;
                current = m.end;
            }
            result += code.substring(current);

            return `<div class="daydream-code-wrapper"><pre class="daydream-code"><code class="language-daydream">${result}</code></pre></div>`;
        }
        
        return defaultRender(tokens, idx, options, env, slf);
    };
    return md;
};
