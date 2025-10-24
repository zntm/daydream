import { DatagenReturnData } from "../index";
import { createReadStream, Dirent, readdirSync } from "fs";
import { parseStream } from "music-metadata";
import { join } from "path";

/**
 * Represents the metadata for a single audio file.
 */
class Music {
    private duration: number;
    private title?: string;
    private author?: string;

    constructor(duration: number, title?: string, author?: string) {
        this.author = author;
        this.title = title;
        this.duration = duration;
    }
}

// --- Configuration ---

// Regex to identify grouped sound effects (e.g., hurt0.ogg, hurt1.ogg)
// Group 1: Base name (e.g., "hurt")
// Group 2: Number (e.g., "0")
const sfxRegex = /^([a-zA-Z_]+)(\d+)\.ogg$/;

const sourceAudioDir = join(__dirname, "./sounds");
const destAudioDir = join(__dirname, "../generated/assets/sounds");

// --- File Processing ---

// 1. Read all file entries recursively
const allFiles = readdirSync(sourceAudioDir, {
    recursive: true,
    withFileTypes: true,
});

// 2. Partition files into individual tracks and grouped SFX
const individualFiles: Dirent[] = [];
const sfxGroups = new Map<string, Dirent[]>(); // Key: group path (e.g., "sfx/hurt"), Value: list of files

for (const file of allFiles) {
    // Skip directories
    if (file.isDirectory()) {
        continue;
    }

    const match = file.name.match(sfxRegex);
    const isOgg = file.name.endsWith(".ogg");

    if (isOgg && match) {
        // This is a grouped SFX file (e.g., hurt0.ogg)
        const relDir = file.parentPath.replace(sourceAudioDir, "").substring(1); // e.g., "sfx"
        const groupName = match[1]; // e.g., "hurt"
        const groupKey = join(relDir, groupName); // e.g., "sfx/hurt"

        // Add to its group
        if (!sfxGroups.has(groupKey)) {
            sfxGroups.set(groupKey, []);
        }
        sfxGroups.get(groupKey)!.push(file);
    } else if (isOgg) {
        // This is an individual audio file (e.g., music)
        individualFiles.push(file);
    }
    // Other file types are ignored
}

// 3. Process individual files
const individualPromises = individualFiles.map(async (file) => {
    const sourcePath = join(file.parentPath, file.name);
    const relDir = file.parentPath.replace(sourceAudioDir, "").substring(1); // e.g., "music"

    // Parse metadata
    const audioStream = createReadStream(sourcePath);
    const metadata = await parseStream(
        audioStream,
        { mimeType: "audio/ogg" },
        { duration: true },
    );
    audioStream.close();

    // Determine ID, title, and author
    const name = file.name.replace(/\.ogg$/, "");
    let id, title, author;

    if (/[A-Za-z]+\ \-\ [A-Za-z0-9\ ]+\.ogg$/.test(file.name)) {
        const [a, t] = name.split(" - ");
        author = a;
        title = t;
        // @ts-ignore
        id = t?.replaceAll(" ", "_").toLowerCase();
    } else {
        // @ts-ignore
        id = name.replaceAll(" ", "_").toLowerCase();
        title = name;
    }

    console.log(`Individual: ${id}`, title, author);

    // Copy file to destination
    const destFilePath = join(destAudioDir, relDir, `${id}.ogg`);
    const f = Bun.file(sourcePath);

    f.arrayBuffer()
        .then((arrayBuffer) => {
            Bun.write(destFilePath, arrayBuffer, {
                createPath: true,
            });
        })
        .catch((error) => {
            console.error(`Error writing file ${destFilePath}: ${error}`);
        });

    // Create JSON metadata object
    const jsonPath = join(
        "generated/assets/sounds",
        relDir,
        `${id}.ogg.json`,
    ).replace(/\\/g, "/");

    return new DatagenReturnData(
        jsonPath,
        new Music(Math.round(metadata.format.duration ?? 0), title, author),
    );
});

// 4. Process grouped SFX
const groupPromises = Array.from(sfxGroups.entries()).map(
    async ([groupKey, files]) => {
        // groupKey is e.g., "sfx/hurt"
        // files is [Dirent(hurt0.ogg), Dirent(hurt1.ogg), ...]

        const groupName = groupKey.split(join.separator).pop()!;
        const destGroupDir = join(destAudioDir, groupKey); // e.g., .../generated/assets/sounds/sfx/hurt

        console.log(`Group: ${groupKey}`);

        // Sort files numerically to ensure correct order in the JSON array
        files.sort((a, b) => {
            const aNum = parseInt(a.name.match(sfxRegex)![2]);
            const bNum = parseInt(b.name.match(sfxRegex)![2]);
            return aNum - bNum;
        });

        // Copy all files in the group AND get their durations
        const fileProcessingPromises = files.map(async (file) => {
            const match = file.name.match(sfxRegex)!;
            const number = match[2]; // e.g., "0"

            const sourcePath = join(file.parentPath, file.name);
            const destPath = join(destGroupDir, `${number}.ogg`); // e.g., .../generated/assets/sounds/sfx/hurt/0.ogg

            // Parse metadata *first* to get duration
            let duration = 0;
            try {
                const audioStream = createReadStream(sourcePath);
                const metadata = await parseStream(
                    audioStream,
                    { mimeType: "audio/ogg" },
                    { duration: true },
                );
                audioStream.close();
                duration = Math.round(metadata.format.duration ?? 0);
            } catch (e) {
                console.error(`Error parsing metadata for ${sourcePath}: ${e}`);
            }

            // Copy file
            const f = Bun.file(sourcePath);
            await f
                .arrayBuffer()
                .then((arrayBuffer) => {
                    Bun.write(destPath, arrayBuffer, {
                        createPath: true,
                    });
                })
                .catch((error) => {
                    console.error(`Error writing file ${destPath}: ${error}`);
                });

            // Return the duration object for the JSON array
            return { duration };
        });

        // Wait for all files to be processed and get their duration objects
        const durationData = await Promise.all(fileProcessingPromises);

        // Create the single JSON for the group
        const jsonPath = join(
            "generated/assets/sounds",
            `${groupKey}.json`,
        ).replace(/\\/g, "/"); // e.g., "generated/assets/sounds/sfx/hurt.json"

        // Use the new array structure as the data object
        const dataObject = durationData;

        return new DatagenReturnData(jsonPath, dataObject);
    },
);

// 5. Export all promises
export default [...individualPromises, ...groupPromises];
