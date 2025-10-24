import { DatagenReturnData } from "../index";
import { createReadStream, Dirent, readdirSync } from "fs";
import { parseStream } from "music-metadata";
import { join } from "path";

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

const getMetadata = async (sourcePath: string) => {
    const audioStream = createReadStream(sourcePath);

    const metadata = await parseStream(
        audioStream,
        { mimeType: "audio/ogg" },
        { duration: true },
    );

    audioStream.close();

    return metadata;
};

const sfxRegex = /^([a-zA-Z_]+)(\d+)\.ogg$/;

const sourceAudioDir = join(__dirname, "./sounds");
const destAudioDir = join(__dirname, "../generated/assets/sounds");

const allFiles = readdirSync(sourceAudioDir, {
    recursive: true,
    withFileTypes: true,
}).filter((file) => !file.isDirectory());

const individualFiles: Dirent[] = [];
const sfxGroups = new Map<string, Dirent[]>();

for (const file of allFiles) {
    const match = file.name.match(sfxRegex);

    if (match) {
        const relDir = file.parentPath.replace(sourceAudioDir, "").substring(1);
        const groupName = match[1] ?? "";
        const groupKey = join(relDir, groupName);

        if (!sfxGroups.has(groupKey)) {
            sfxGroups.set(groupKey, []);
        }
        sfxGroups.get(groupKey)!.push(file);
    } else {
        individualFiles.push(file);
    }
}

const individualPromises = individualFiles.map(async (file) => {
    const sourcePath = join(file.parentPath, file.name);
    const relDir = file.parentPath.replace(sourceAudioDir, "").substring(1);

    const metadata = await getMetadata(sourcePath);

    const name = file.name.replace(/\.ogg$/, "");
    let id, title, author;

    if (/[A-Za-z]+\ \-\ [A-Za-z0-9\ ]+\.ogg$/.test(file.name)) {
        const [a, ...t] = name.split(" - ");

        author = a;
        title = t.join(" ");

        // @ts-ignore
        id = title.replaceAll(" ", "_").toLowerCase();
    } else {
        // @ts-ignore
        id = name.replaceAll(" ", "_").toLowerCase();
        title = name;
    }

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

    return new DatagenReturnData(
        join("generated/assets/sounds", relDir, `${id}.ogg.json`).replace(
            /\\/g,
            "/",
        ),
        new Music(Math.ceil(metadata.format.duration ?? 0), title, author),
    );
});

const groupPromises = Array.from(sfxGroups.entries()).map(
    async ([groupKey, files]) => {
        const destGroupDir = join(destAudioDir, groupKey);

        files.sort((a, b) => {
            const aNum = parseInt(a.name.match(sfxRegex)![2] ?? "0");
            const bNum = parseInt(b.name.match(sfxRegex)![2] ?? "0");
            return aNum - bNum;
        });

        const fileProcessingPromises = files.map(async (file) => {
            const match = file.name.match(sfxRegex)!;
            const number = match[2];

            const sourcePath = join(file.parentPath, file.name);
            const destPath = join(destGroupDir, `${number}.ogg`);

            let duration = 0;

            try {
                const metadata = await getMetadata(sourcePath);

                duration = Math.ceil(metadata.format.duration ?? 0);
            } catch (e) {
                console.error(`Error parsing metadata for ${sourcePath}: ${e}`);
            }

            const f = Bun.file(sourcePath);
            await f
                .arrayBuffer()
                .then((arrayBuffer) => {
                    Bun.write(destPath, arrayBuffer, {
                        createPath: true,
                    });
                })
                .catch((error) =>
                    console.error(`Error writing file ${destPath}: ${error}`),
                );

            return { duration };
        });

        const durationData = await Promise.all(fileProcessingPromises);

        return new DatagenReturnData(
            join("generated/assets/sounds", `${groupKey}.json`),
            durationData,
        );
    },
);

export default [...individualPromises, ...groupPromises];
