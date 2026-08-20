import { readdirSync } from "node:fs";
import { homedir } from "node:os";
import { resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { type AutocompleteItem, fuzzyFilter } from "@earendil-works/pi-tui";

function resolveDirectory(base: string, path: string): string {
	if (path === "~") return homedir();
	if (path.startsWith("~/")) return resolve(homedir(), path.slice(2));
	return resolve(base, path);
}

function completeDirectories(prefix: string): AutocompleteItem[] | null {
	if (prefix === "~") return [{ value: "~/", label: "~/" }];

	const slashIndex = prefix.lastIndexOf("/");
	const directoryPart = prefix.slice(0, slashIndex + 1);
	const query = prefix.slice(slashIndex + 1);
	const searchPath = resolveDirectory(process.cwd(), directoryPart || ".");

	try {
		const directoryNames = readdirSync(searchPath, { withFileTypes: true })
			.filter((entry) => entry.isDirectory())
			.map((entry) => entry.name)
			.sort();
		const matches = query ? fuzzyFilter(directoryNames, query, (name) => name) : directoryNames;
		const items = matches.map((name) => {
			const value = `${directoryPart}${name}/`;
			return { value, label: value };
		});
		return items.length ? items : null;
	} catch {
		return null;
	}
}

export default function (pi: ExtensionAPI): void {
	pi.registerCommand("cd", {
		description: "Change directory and start a new session",
		getArgumentCompletions: completeDirectories,
		handler: async (args, ctx) => {
			const input = args.trim();
			if (!input) {
				ctx.ui.notify("Usage: /cd <directory>", "error");
				return;
			}

			const oldDirectory = ctx.cwd;
			const target = resolveDirectory(oldDirectory, input);

			try {
				process.chdir(target);
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(message, "error");
				return;
			}

			try {
				const result = await ctx.newSession({
					parentSession: ctx.sessionManager.getSessionFile() ?? undefined,
					withSession: async (newCtx) => {
						newCtx.ui.notify(`Working directory: ${newCtx.cwd}`, "info");
					},
				});

				if (result.cancelled) process.chdir(oldDirectory);
			} catch (error) {
				process.chdir(oldDirectory);
				throw error;
			}
		},
	});
}
