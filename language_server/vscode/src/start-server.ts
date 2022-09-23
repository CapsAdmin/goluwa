import { Socket } from "net";
import { ExtensionContext, OutputChannel, workspace } from "vscode";
import { LanguageClient } from "vscode-languageclient/node";
import { ChildProcessWithoutNullStreams, spawn } from "child_process";
import { unwatchFile, watchFile } from "fs"
let server: ChildProcessWithoutNullStreams;
let init = false

const kill = () => {
    if (server) {
        server.kill("SIGKILL");
    }
    server = undefined;
};

export function spawnServer(config:
    {
        path: string,
        args: string[],
        output: OutputChannel,
        client: LanguageClient,
        context: ExtensionContext,
        onOutput: (data: string) => void,
    }
) {
    if (server) {
        kill();
    }

    const cwd = workspace.workspaceFolders[0].uri.path

    config.client.outputChannel.appendLine("SPAWN: " + config.path + " " + config.args.join(" "))
    config.client.outputChannel.appendLine("CWD: " + cwd)

    watchFile(config.path, (curStat, prevStat) => {
        config.client.outputChannel.appendLine(config.path + " changed, reloading")
        init = false
        kill()
        unwatchFile(config.path)
    })

    server = spawn(config.path, config.args, { cwd })

    config.context.subscriptions.push({
        dispose: () => {
            kill();
        },
    });

    server.stdout.setEncoding("utf8");
    server.stderr.setEncoding("utf8");

    server.stdout.on("data", (str: string) => {
        config.onOutput(str)
        config.output.append(str);
    });
    server.stderr.on("data", (str) => {
        config.output.append(str)
    });

    server.on("error", (err) => {
        config.output.appendLine("ERROR: " + err.toString());
        kill();
    });

    process.on("exit", (code) => {
        config.output.appendLine("EXIT: " + code.toString());
        kill();
    });
}

export const startServerConnection = (config: {
    path: string, args: string[],
    client: LanguageClient,
    serverOutput: OutputChannel,
    context: ExtensionContext
}): Promise<{ reader: Socket, writer: Socket }> => {
    return new Promise((resolve, reject) => {
        let socket = new Socket();

        socket.on("connect", () => {
            config.client.outputChannel.appendLine(
                "CONNECTED: " + socket.remoteAddress + ":" + socket.remotePort
            );
            resolve({
                reader: socket,
                writer: socket,
            });
        });

        let tryAgain = () => {
            try {
                spawnServer({
                    path: config.path,
                    args: config.args,
                    context: config.context,
                    output: config.serverOutput,
                    client: config.client,
                    onOutput: (str) => {
                        const match = [...str.matchAll(/HOST: ([\d.]*):([\d]+)/gm)][0];
                        if (match && match[0]) {
                            const host = match[1];
                            const port = parseInt(match[2], 10);

                            if (!init) {
                                init = true;
                                socket.connect(port, host);
                            }
                        }
                    },
                });
            } catch (e) {
                setTimeout(() => {
                    tryAgain();
                }, 10000);
            }
        };

        socket.on("error", (e) => {
            config.client.error("connection error", e, true)
            setTimeout(() => {
                tryAgain();
            }, 10000);
        });

        socket.on("close", () => {
            config.client.outputChannel.appendLine(`NattLua Connection closed, retrying`);
            tryAgain();
        });

        tryAgain();
    })
}