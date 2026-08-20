import { spawn } from "node:child_process";
import { readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";

const MAX_RESULTS = 20;
const MAX_CANDIDATES = 100;
const MAX_DIRECTORIES = 10_000;

function toDisplayPath(value: string): string {
	return value.replace(/\\/g, "/");
}

function resolveDirectory(base: string, path: string): string {
	if (path === "~") return homedir();
	if (path.startsWith("~/")) return resolve(homedir(), path.slice(2));
	return resolve(base, path);
}

function isDirectory(path: string): boolean {
	try {
		return statSync(path).isDirectory();
	} catch {
		return false;
	}
}

function resolveScopedQuery(rawQuery: string): { baseDir: string; query: string; displayBase: string } | null {
	const normalizedQuery = toDisplayPath(rawQuery);
	const slashIndex = normalizedQuery.lastIndexOf("/");
	if (slashIndex === -1) return null;

	const displayBase = normalizedQuery.slice(0, slashIndex + 1);
	const query = normalizedQuery.slice(slashIndex + 1);
	const baseDir = resolveDirectory(process.cwd(), displayBase);
	if (!isDirectory(baseDir)) return null;

	return { baseDir, query, displayBase };
}

function listDirectories(root: string, includeHidden: boolean): string[] {
	const directories: string[] = [];
	const pending = [""];

	while (pending.length && directories.length < MAX_DIRECTORIES) {
		const parent = pending.pop() ?? "";

		try {
			for (const entry of readdirSync(resolve(root, parent), { withFileTypes: true })) {
				if (!entry.isDirectory()) continue;
				if (!includeHidden && entry.name.startsWith(".")) continue;

				const path = parent ? `${parent}/${entry.name}` : entry.name;
				directories.push(path);
				pending.push(path);
				if (directories.length === MAX_DIRECTORIES) break;
			}
		} catch {
			// Ignore directories that cannot be read.
		}
	}

	return directories;
}

function scoreDirectory(path: string, query: string): number {
	const name = basename(path).toLowerCase();
	const normalizedPath = path.toLowerCase();
	const normalizedQuery = query.toLowerCase();

	if (name === normalizedQuery) return 110;
	if (name.startsWith(normalizedQuery)) return 90;
	if (name.includes(normalizedQuery)) return 60;
	if (normalizedPath.includes(normalizedQuery)) return 40;
	return 0;
}

function searchWithFd(baseDir: string, query: string, includeHidden: boolean): Promise<string[] | null> {
	const args = [
		"--base-directory",
		baseDir,
		"--max-results",
		String(MAX_CANDIDATES),
		"--type",
		"d",
		"--follow",
		"--exclude",
		".git",
		"--exclude",
		".git/*",
		"--exclude",
		".git/**",
	];
	if (includeHidden) args.push("--hidden");
	if (query) args.push(query);

	return new Promise((done) => {
		const child = spawn("fd", args, { stdio: ["ignore", "pipe", "ignore"] });
		let stdout = "";
		let settled = false;
		const finish = (result: string[] | null) => {
			if (settled) return;
			settled = true;
			done(result);
		};

		child.stdout.setEncoding("utf8");
		child.stdout.on("data", (chunk: string) => {
			stdout += chunk;
		});
		child.on("error", () => finish(null));
		child.on("close", (code) => {
			if (code !== 0) return finish(null);
			const paths = stdout
				.split("\n")
				.map((path) => toDisplayPath(path).replace(/\/$/, ""))
				.filter(Boolean);
			finish(paths);
		});
	});
}

async function completeDirectories(prefix: string): Promise<AutocompleteItem[] | null> {
	if (prefix === "~") return [{ value: "~/", label: "~/" }];

	const scopedQuery = resolveScopedQuery(prefix);
	const baseDir = scopedQuery?.baseDir ?? process.cwd();
	const query = scopedQuery?.query ?? prefix;
	const displayBase = scopedQuery?.displayBase ?? "";
	const includeHidden = true;
	const fdPaths = await searchWithFd(baseDir, query, includeHidden);
	const paths = fdPaths ?? listDirectories(baseDir, includeHidden);

	const matches = paths
		.map((path) => ({ path, score: query ? scoreDirectory(path, query) : 1 }))
		.filter((entry) => entry.score > 0)
		.sort((a, b) => b.score - a.score || a.path.localeCompare(b.path))
		.slice(0, MAX_RESULTS);

	const items = matches.map(({ path }) => {
		const value = `${displayBase}${path}/`;
		return {
			value,
			label: `${basename(path)}/`,
			description: value.slice(0, -1),
		};
	});
	return items.length ? items : null;
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

			if (!isDirectory(target)) {
				pi.sendUserMessage(`/cd ${args}`);
				return;
			}

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
