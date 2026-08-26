import { spawnSync } from "node:child_process";
import { access } from "node:fs/promises";
import { resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const FILE_TOOLS = new Set(["edit", "write"]);

async function openNeovim(paths: string[], ctx: ExtensionContext): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify("Neovim requires the TUI mode.", "error");
		return;
	}

	const existingPaths: string[] = [];
	for (const path of paths) {
		try {
			await access(path);
			existingPaths.push(path);
		} catch {
			continue;
		}
	}

	if (existingPaths.length === 0) {
		ctx.ui.notify("No referenced files exist.", "error");
		return;
	}

	const exitCode = await ctx.ui.custom<number | null>((tui, _theme, _keybindings, done) => {
		tui.stop();
		process.stdout.write("\x1b[2J\x1b[H");

		const quitAllCommand = "cabbrev <expr> q getcmdtype() == ':' && getcmdline() ==# 'q' ? 'qa' : 'q'";
		const result = spawnSync("nvim", ["--cmd", quitAllCommand, "--", ...existingPaths], {
			cwd: ctx.cwd,
			stdio: "inherit",
			env: process.env,
		});

		tui.start();
		tui.requestRender(true);
		done(result.status);
		return { render: () => [], invalidate: () => {} };
	});

	if (exitCode !== 0) {
		ctx.ui.notify(`Neovim exited with code ${exitCode ?? "unknown"}.`, "error");
	}
}

export default function (pi: ExtensionAPI) {
	const files = new Set<string>();

	const rememberPath = (path: string, cwd: string) => {
		const absolutePath = resolve(cwd, path.replace(/^@/, ""));
		files.delete(absolutePath);
		files.add(absolutePath);
	};

	const rememberReferences = (text: string, cwd: string) => {
		for (const match of text.matchAll(/(?:^|\s)@([^\s]+)/g)) {
			rememberPath(match[1].replace(/[),;:!?]+$/, ""), cwd);
		}
	};

	const rememberContent = (content: string | { type: string; text?: string }[], cwd: string) => {
		if (typeof content === "string") {
			rememberReferences(content, cwd);
			return;
		}

		for (const part of content) {
			if (part.type === "text" && part.text) rememberReferences(part.text, cwd);
		}
	};

	const rememberToolPath = (toolName: string, input: unknown, cwd: string) => {
		const name = toolName.split(".").at(-1);
		if (!name || !FILE_TOOLS.has(name) || !input || typeof input !== "object") return;

		const path = (input as { path?: unknown }).path;
		if (typeof path === "string") rememberPath(path, cwd);
	};

	pi.on("session_start", (_event, ctx) => {
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;

			const message = entry.message;
			if (message.role === "user") rememberContent(message.content, ctx.cwd);

			if (message.role === "assistant") {
				for (const part of message.content) {
					if (part.type === "toolCall") rememberToolPath(part.name, part.arguments, ctx.cwd);
				}
			}
		}
	});

	pi.on("input", (event, ctx) => rememberReferences(event.text, ctx.cwd));
	pi.on("tool_call", (event, ctx) => rememberToolPath(event.toolName, event.input, ctx.cwd));

	pi.registerShortcut("ctrl+e", {
		description: "Open the last referenced file in Neovim",
		handler: async (ctx) => {
			if (files.size === 0) {
				ctx.ui.notify("No file was referenced in this session.", "warning");
				return;
			}

			await openNeovim([...files].reverse(), ctx);
		},
	});

	pi.registerCommand("file", {
		description: "Open a referenced file in Neovim",
		handler: async (_args, ctx) => {
			const choices = [...files].reverse();
			if (choices.length === 0) {
				ctx.ui.notify("No files were referenced in this session.", "warning");
				return;
			}

			const selected = await ctx.ui.select("Open file", choices);
			if (selected) await openNeovim([selected], ctx);
		},
	});
}
