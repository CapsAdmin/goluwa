import {
  ExtensionContext, languages, Range, TextDocument,
  TextEdit, window, workspace
} from "vscode";
import {
  LanguageClient,
  LanguageClientOptions
} from "vscode-languageclient/node";
import { startServerConnection } from "./start-server";

let client: LanguageClient;
const config = workspace.getConfiguration("nattlua");

export async function activate(context: ExtensionContext) {
  let serverOutput = window.createOutputChannel("Nattlua Server");

  const path = config.get<string>("path");
  const args = config.get<string[]>("arguments");
  const selector = [{ scheme: 'file', language: 'nattlua' }];

  const clientOptions: LanguageClientOptions = {
    documentSelector: selector,
    synchronize: {
      configurationSection: "nattlua",
    },
  };

  client = new LanguageClient(
    "nattlua",
    "NattLua Client",
    () => startServerConnection({ path, args, client, serverOutput, context }),
    clientOptions
  );

  languages.registerDocumentFormattingEditProvider(selector, {
    async provideDocumentFormattingEdits(document: TextDocument) {
      try {
        const range = document.validateRange(
          new Range(0, 0, Infinity, Infinity)
        );
        const params = await client.sendRequest<{ code: string }>(
          "nattlua/format",
          { code: document.getText(), path: document.uri.path }
        );
        return [
          new TextEdit(
            range,
            Buffer.from(params.code, "base64").toString("utf8")
          ),
        ];
      } catch (err) {
        serverOutput.appendLine(`NattLua Format error : ${err.message}`);
      }
      return [];
    },
  });

  const ref = client.start();
  context.subscriptions.push(ref);
  await client.onReady()
}

export async function deactivate() {
  if (!client) {
    return undefined;
  }
  return client.stop();
}
