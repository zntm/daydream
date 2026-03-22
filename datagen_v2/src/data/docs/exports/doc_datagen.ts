import { DatagenReturnData } from "../../../lib";
import * as daydream from "../daydream";
import * as stdlib from "../stdlib";
import * as ui from "../ui";

const results: DatagenReturnData[] = [];

// Daydream language docs
for (const [name, content] of Object.entries(daydream)) {
    if (typeof content !== "string") continue;

    results.push(new DatagenReturnData(`daydream/${name}.md`, content));
}

// Stdlib docs
for (const [name, content] of Object.entries(stdlib)) {
    if (typeof content !== "string") continue;

    results.push(new DatagenReturnData(`daydream/stdlib/${name}.md`, content));
}

// UI docs
for (const [name, content] of Object.entries(ui)) {
    if (typeof content !== "string") continue;

    results.push(new DatagenReturnData(`ui/${name}.md`, content));
}

export default results;
